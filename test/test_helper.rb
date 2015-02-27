# Mostly copied from Resque in order to have similar test environment.
# https://github.com/defunkt/resque/blob/master/test/test_helper.rb

dir = File.dirname(File.expand_path(__FILE__))
$LOAD_PATH.unshift dir + '/../lib'
$TESTING = true
require 'minitest/autorun'
require 'rubygems'
require 'resque'

begin
  require 'leftright'
rescue LoadError
end
require 'resque'
require 'resque-sliders/kewatcher'

#
# make sure we can run redis
#

#if !system("which redis-server")
#  puts '', "** can't find `redis-server` in your path"
#  puts "** try running `sudo rake install`"
#  abort ''
#end


#
# start your own redis when the tests start,
# kill it when they end
#
Resque.redis = 'localhost:6379'


##
# test/spec/mini 3
# http://gist.github.com/25455
# chris@ozmm.org
# file:lib/test/spec/mini.rb
#
def context(*args, &block)
  return super unless (name = args.first) && block
  klass = Class.new(defined?(ActiveSupport::TestCase) ? ActiveSupport::TestCase : Minitest::Test) do
    def self.test(name, &block)
      define_method("test_#{name.gsub(/\W/,'_')}", &block) if block
    end
    def self.xtest(*args) end
    def self.setup(&block) define_method(:setup, &block) end
    def self.teardown(&block) define_method(:teardown, &block) end
  end
  (class << klass; self end).send(:define_method, :name) { name.gsub(/\W/,'_') }
  klass.class_eval &block
end
