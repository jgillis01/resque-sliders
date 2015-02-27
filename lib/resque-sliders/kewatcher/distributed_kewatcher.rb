module Resque
  module Plugins
    module ResqueSliders
      # KEWatcher class provides a daemon to run on host that are running resque workers.
      class DistributedKEWatcher < KEWatcher

        def initialize(options={})
          super
        end

        private

        def key_prefix
          "plugins:distributed-kewatcher"
        end

        def host_key
          "#{key_prefix}:#{determine_hostname}"
        end

        def add_existing_workers
          yml = YAML.load(File.open(@poolfile))
          # local workers
          add_workers(yml,"#{key_prefix}:#{@hostname}")
          # Global listing
          add_workers(yml,"#{key_prefix}:global")
          set_max_counts(yml)
        end

        def add_workers(yml,key)
          workers = yml.keys.flat_map{|key| key.split(',')}.uniq
          workers.each do |worker|
            unless redis_get_hash_field(key, worker)
              redis_set_hash(key, worker, 0)
            end
          end
        end

        def queue_diff
          # Queries Redis to get Hash of what should running
          # figures what is running and does a diff
          # returns an Array of 2 Arrays: to_start, to_kill
          goal, to_start, to_kill = [], [], []
          goal = determine_queue_goal
          binding.pry

          running_queues = @pids.values # check list
          to_start = queues_to_start(goal)
          to_kill = queues_to_kill

          if (to_start.length + @pids.keys.length - to_kill.length) > @max_children
            # if to_start with existing minus whats to be killed is still greater than max children
            log "WARN: need to start too many children, please raise max children"
          end

          kill_queues = to_kill.map { |x| @pids[x] }
          log! ["GOTTA START:", to_start.map { |x| "#{x} (#{to_start.count(x)})" }.uniq.join(', '), "= #{to_start.length}"].delete_if { |x| x == (nil || '') }.join(' ')
          log! ["GOTTA KILL:", kill_queues.map { |x| "#{x} (#{kill_queues.count(x)})" }.uniq.join(', '), "= #{to_kill.length}"].delete_if { |x| x == (nil || '') }.join(' ')

          [to_start, to_kill] # return whats left
        end

        def determine_queue_goal
          goal = []
          queue_values(@hostname).each_pair do |queue,count|
            goal += [queue] * count.to_i
          end

          goal
        end

        def queues_to_start(goal)
          to_start = []
          running_queues = @pids.values # check list
          goal.each do |q|
            if running_queues.include?(q)
              # delete from checklist cause its already running
              running_queues.delete_at(running_queues.index(q))
            else
              # not included in running queue, need to start
              if to_start.count(q) < max_workers_for_queue(q) && to_start.count(q) < max_global_workers_per_queue_left(q)
                to_start << q
              end
            end
          end
          to_start
        end

        def queues_to_kill
          to_kill = []
          running_queues = @pids.values # check list
          @pids.dup.each do |k,v|
            if running_queues.include?(v)
              # whatever is left over in this checklist shouldn't be running
              to_kill << k
              running_queues.delete_at(running_queues.index(v))
            end
          end
          to_kill
        end

        def max_workers_for_queue(queue)
          key = "#{host_key}:max_workers"
          redis_get_hash_field(key,queue).to_i
        end

        def max_global_workers_per_queue_left(q)
          workers = Array(Resque.redis.smembers("workers"))
          global_count = max_total_queue_count(q)
          global_count - workers.select {|w| w.index(q) }.count
        end

        def set_max_counts(yml)
          yml.each do |queue,settings|
            key = "#{host_key}:max_workers"
            queue.split(",").each do |q|
              redis_set_hash(key,q,settings['max_workers'])
            end
          end
        end

        def max_total_queue_count(queue)
          key = "#{key_prefix}:global"
          redis_get_hash_field(key,queue).to_i
        end
      end
    end
  end
end

