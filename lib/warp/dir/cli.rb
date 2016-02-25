#!/usr/bin/env ruby
require 'bundler/setup'
require 'warp/dir'
require 'slop'
require 'colored'
require 'pp'

module Warp
  module Dir
    USAGE = <<-EOF
  Usage:  wd [ --command ] [ show | list | clean | validate | wipe ]          [ flags ]
          wd [ --command ] [ add  [ -f/--force ] | rm | ls | path ] <point>   [ flags ]
          wd --help | help

  Warp Point Commands:
    add   <point>   Adds the current directory as a new warp point
    rm    <point>   Removes a warp point
    show  <point>   Show the path to the warp point
    ls    <point>   Show files from tne warp point
    path  <point>   Show the path to given warp point

  Global Commands:
    show            Print warp points to current directory
    clean           Remove points warping to nonexistent directories
    help            Show this extremely unhelpful text
    EOF
    class CLI
      def not_a_flag arg
        arg && !arg[0].eql?('-')
      end
      def shift_non_flag_argument
        if not_a_flag ARGV[0]
          return ARGV.shift
        end
        nil
      end

      def run
        @verbose = false

        begin
          # Slop v4 no longer supports commands, so we fake it:
          # if the first argument does not start with a dash, it must be a command.
          # So fake-add `--command` flag in front of it.
          @manager       = Warp::Dir::Commands::Manager.new

          first_argument = shift_non_flag_argument
          @command       = first_argument if first_argument && @manager.commands.include?(first_argument.to_sym)
          second_argument= shift_non_flag_argument
          @point         = second_argument

          opts           = Slop::Options.new
          opts.banner    = USAGE
          @manager.commands.each do |installed_command|
            opts.banner << sprintf("    %s\n", @manager.find(installed_command).help)
          end

          opts.banner << "\n"
          opts.banner << '  Flags:'
          opts.string '-m', '--command',    'command to run, ie. add, ls, list, rm, etc.'
          opts.string '-w', '--warp-point', 'name of the warp point'
          opts.bool   '-h', '--help',       'show help'
          opts.bool   '-v', '--verbose',    'enable verbose mode'
          opts.bool   '-q', '--quiet',      'suppress output (quiet mode)'
          opts.bool   '-d', '--debug',      'show stacktrace if errors are detected'
          opts.string '-c', '--config',     'location of the configuration file (default: ' + Warp::Dir.default_config + ')', default: Warp::Dir.default_config
          opts.boolean'-s', '--shell',      'Return output made for shell eva()'
          opts.on     '-V', '--version',    'print the version' do
            puts 'Version ' + Warp::Dir::VERSION
            exit
          end

          @result = nil
          begin
            parser  = Slop::Parser.new(opts)
            @result = parser.parse(ARGV)
          rescue Slop::UnknownOption => e
            STDERR.puts "Invalid option: #{e.message}".red
            exit 1
          end

          @config            = Warp::Dir::Config.new(@result.to_hash)
          @verbose           = true if @config.verbose
          @store             = Warp::Dir::Store.create(@config)
          @config.command    = @command if @command
          @config.warp_point = @point if @point

          if @config.debug
            pp @config
            pp @store
          end

          if @config.command
            command_class = @manager.find(@config.command)
            if command_class
              command_class.new(@store, @config.warp_point).run
            else
              STDERR.puts "command '#{@config.command}' was not found.".red
            end
          else
            if @result.help?
              puts @result.to_s.blue.bold
              exit 0
            else
              STDERR.puts "#{$0}: passing #{@argv ? @argv.join(', ') : 'no arguments'} is invalid.".white_on_red
              puts @results.to_s.blue
              abort
            end
          end
        rescue SystemExit
          return
        rescue Exception => e
          printf("ERROR: received exception #{e.class}, #{e.message}".red.bold + "\n".white)
          printf(e.backtrace.join("\n\t").yellow.bold + "\n")
          if @verbose
            require 'pp'
            pp @manager
            pp @config
            pp @storee
          end
        end
      end
    end
  end
end