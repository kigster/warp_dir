# frozen_string_literal: true

require_relative '../../colored'
module Warp
  module Dir
    VERSION = '1.6.3'

    @install_notice = <<~EOF

      #{'>>> PLEASE READ THIS! '.bold.yellow}

      For this gem to work, you must also install the coupled shell function
      into your shell initialization file. The following command should complete the
      setup (but please change '~/.bash_profile' with whatever you use for shell
      initialization, although for most situations ~/.bash_profile is good enough).

    EOF
    @install_notice += <<-EOF.bold.green
  $ warp-dir install --dotfile ~/.bash_profile

    EOF
    @install_notice += <<~EOF
      Restart your shell, and you should now have 'wd' shell function that
      should be used instead of the warp-dir executable.

      Start with:

    EOF
    @install_notice += <<-EOF.bold.blue
  $ wd help
  $ wd <directory>  # change directory – works just like "cd"
  $ wd add <name>   # add current directory as a warp point, call it <name>
    EOF
    @install_notice += <<~EOF

      Please submit issues and pull requests to:
      https://github.com/kigster/warp-dir

      Thank you!
    EOF
    INSTALL_NOTICE = @install_notice
  end
end
