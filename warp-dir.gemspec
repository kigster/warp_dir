# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'warp/dir/version'

Gem::Specification.new do |gem|
  gem.name          = 'warp-dir'
  gem.license       = 'MIT'
  gem.authors       = ['Konstantin Gredeskoul']
  gem.email         = ['kig@reinvent.one']
  gem.version       = Warp::Dir::VERSION

  gem.summary       = %q{Warp-Dir (aka 'wd') is a command line tool that lets you bookmark any folders, and then 'wd' between any two points on file system in one command.}
  gem.description   = %q{Warp-Dir is compatible (and inspired by) the popular 'wd' tool available as a ZSH module. This one is written in ruby and so it should work in any shell. Credits for the original zsh-only tool go to (https://github.com/mfaerevaag/wd).}
  gem.homepage      = "https://github.com/kigster/warp-dir"

  gem.files         = `git ls-files`.split($\).reject{ |f| f =~ /^doc\// }
  gem.executables   << 'warp-dir'

  gem.post_install_message =<<-EOF

PLEASE NOTE:

For this gem to work, you must also install the coupled shell function
into your ~/.bashrc file (or any other shell initialization file). The
following command should complete the setup.

  $ warp-dir install

By default, the installer will check common "rc" scripts, but you can
tell warp-dir where to add shell wrapper with --dotfile <filename>, i.e.

  $ warp-dir install --dotfile ~/.bashrc

Restart your shell, and you should now have 'wd' shell function that
should be used instead of the warp-dir executable.

Start with

  $ wd help

Thank you!

  EOF

  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('slop', '~> 4.2')
  gem.add_dependency('colored', '~> 1')

  gem.add_development_dependency 'codeclimate-test-reporter', '~> 0.5'
  gem.add_development_dependency 'bundler', '~> 1.11'
  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 3.4'
end
