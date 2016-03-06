#!/usr/bin/env ruby
require 'bundler/setup'
require 'warp/dir'
require 'warp/dir/app/response'
require 'slop'
require 'colored'

module Warp
  module Dir
    module App
      class CLI
        attr_accessor :argv, :config, :commander, :store, :valid, :opts, :flags

        def initialize(argv)
          self.argv      = argv
          self.flags     = argv.dup # anything after --

          self.commander = ::Warp::Dir::Commander.instance
          self.config    = ::Warp::Dir::Config.new
          self.opts      = nil
        end

        def validate
          no_arguments   = argv.empty?

          self.valid     = false
          config.verbose = false
          config.debug   = false

          commands       = shift_non_flag_commands
          argument       = self.flags.shift until argument.eql?('--') || self.flags.empty?

          begin
            self.opts = parse_with_slop(self.argv)
          rescue Slop::UnknownOption => e
            return on :error do
              "Invalid option: #{e.message}".red
            end
          end

          config.configure(opts.to_hash.merge(commands))
          self.store = Warp::Dir::Store.new(config, Warp::Dir::Serializer::Dotfile)

          config.command = :help if (opts.help? || no_arguments)
          config.command = :warp if !config.command && config.warp

          if config[:command]
            self.valid = true
          else
            raise Warp::Dir::Errors::InvalidCommand.new('Unable to determine what command to run.'.red)
          end
          yield self if block_given?
          valid
        end

        def run(&block)
          validate unless @valid
          response = process_command
          yield response if block_given?
          response
        rescue Exception => e
          if config.debug
            STDERR.puts(e.inspect)
            STDERR.puts(e.backtrace.join("\n"))
          end
          on :error do
            message e.message.red
          end
        end

        private

        def on(*args, &block)
          response = Warp::Dir.on(*args, &block)
          response.config = self.config
          response
        end

        def process_command
          argv = self.argv
          if config.command
            command_class = commander.find(config.command)
            if command_class
              command_class.new(store, config.point).run(flags)
            else
              on :error do
                message "command '#{config.command}' was not found.".red
              end
            end
          else
            on :error do
              message "#{$0}: passing #{argv ? argv.join(', ') : 'no arguments'} is invalid.".red
            end
          end
        end

        def parse_with_slop(arguments)
          opts        = Slop::Options.new
          opts.banner << "\n"
          opts.banner << '  Flags:'
          opts.string  '-m', '--command', '<command>      – command to run, ie. add, ls, list, rm, etc.'
          opts.string  '-p', '--point',   '<point-name>   – name of the warp point'
          opts.string  '-w', '--warp',    '<warp-point>   – warp to a given point'
          opts.bool    '-f', '--force',   '               - force, ie. overwrite existing point when adding'
          opts.bool    '-h', '--help',    '               – show help'
          opts.bool    '-v', '--verbose', '               – enable verbose mode'
          opts.bool    '-q', '--quiet',   '               – suppress output (quiet mode)'
          opts.bool    '-d', '--debug',   '               – show stacktrace if errors are detected'
          opts.string  '-s', '--dotfile', '<config>       – shell dotfile to be used for install command'
          opts.string  '-c', '--config',  '<config>       – location of the configuration file (default: ' + Warp::Dir.default_config + ')', default: Warp::Dir.default_config
          opts.boolean '-e', '--no-shell','                 – do not expect output to be evaluated by BASH', default: false
          opts.on      '-V', '--version', '               – print the version' do
            puts 'Version ' + Warp::Dir::VERSION
            exit
          end

          Slop::Parser.new(opts).parse(arguments)
        end

        def shift_non_flag_commands
          result = {}
          non_flags = []
          non_flags << argv.shift while not_a_flag(argv.first)
          case non_flags.size
            when 1
              argument = non_flags.first.to_sym
              if commander.lookup(argument)
                result[:command] = argument
              else
                result[:command] = :warp
                result[:point] = argument
              end
            when 2
              result[:command], result[:point] = non_flags.map(&:to_sym)
            when 3
              result[:command], result[:point], result[:point_path] = non_flags.map(&:to_sym)
          end
          result
        end

        def not_a_flag(arg)
          arg && !arg[0].eql?('-')
        end
      end
    end
  end
end
