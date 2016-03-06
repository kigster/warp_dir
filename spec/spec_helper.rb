require 'codeclimate-test-reporter'
require 'warp/dir'
require 'rspec/core'

CodeClimate::TestReporter.start

module Warp
  module Dir
    module App
      class Response
        class << self
          attr_accessor :exit_disabled

          def enable_exit!
            self.exit_disabled = false
          end

          def disable_exit!
            self.exit_disabled = true
          end

          def exit_disabled?
            self.exit_disabled
          end
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.before do
    Warp::Dir::App::Response.disable_exit!
    Warp::Dir::App::Response.instance.configure do
      @messages.clear
      @type = nil
    end
  end
end

RSpec.shared_context :store_can_be_recreated do
  module Warp
    module Dir
      class Store
        class << self
          # Here we cheat and give us the ability to create new Stores.
          def create(*args, &block)
            new(*args, &block)
          end
        end
      end
    end
  end
end

RSpec.shared_context :fake_serializer do
  include_context :store_can_be_recreated
  let(:file) { @file ||= ::Tempfile.new('warp-dir') }
  let(:config) { Warp::Dir::Config.new(config: file.path) }
  let(:serializer) {
    @initialized_store ||= FakeSerializer ||= Class.new(Warp::Dir::Serializer::Base) do
      def persist!;
      end

      def restore!;
      end
    end
  }

  after do
    file.close
    file.unlink
  end
end

RSpec.shared_context :fixture_file do
  include_context :store_can_be_recreated
  let(:file) { @file ||= File.new('spec/fixtures/warprc') }
  let(:config) { Warp::Dir::Config.new(config: file.path) }
  let(:serializer) { Warp::Dir::Serializer::Dotfile.new }
end

RSpec.shared_context :initialized_store do
  let(:store) { Warp::Dir::Store.create(config, serializer) }
  let(:wp_path) { ENV['HOME'] + '/workspace/tinker-mania' }
  let(:wp_name) { 'harro' }
  let(:point) { Warp::Dir::Point.new(wp_name, wp_path) }
end
