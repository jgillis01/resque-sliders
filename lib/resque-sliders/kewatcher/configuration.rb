module Resque
  module Plugins
    module ResqueSliders
      class KEWatcher
        class Configuration
          def initialize(options={})
            options = verify_and_set_file_paths(options)
            @options = default_values
            @options = @options.merge(options)
          end

          def to_hash
            @options
          end

          private

          def default_values
            options = {}
            options[:verbosity] = 0
            options[:zombie_term_wait] = 20
            options[:zombie_kill_wait] = 60
            options[:rakefile] = nil
            options[:pidfile] = nil
            options[:poolfile] = nil
            options[:max_children] = 10
            options[:async] = false
            options
          end

          def verify_and_set_file_paths(options)
            [:rakefile,:poolfile,:pidfile].each do |file|
              options = verify_and_set_file_path(file,options)
            end
            options
          end

          def verify_and_set_file_path(file,options)
            if options[file]
              path = File.expand_path(options[file])
              if File.exists?(path)
                options[file] = path
              end
            end
            options
          end
        end
      end
    end
  end
end
