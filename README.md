# Warp Directory

[![Downloads](http://ruby-gem-downloads-badge.herokuapp.com/warp-dir?type=total)](https://rubygems.org/gems/warp-dir)
[![Gem Version](https://badge.fury.io/rb/warp-dir.svg)](https://badge.fury.io/rb/warp-dir)
[![Gitter](https://img.shields.io/gitter/room/gitterHQ/gitter.svg)](https://gitter.im/kigster/warp-dir)

[![Build Status](https://travis-ci.org/kigster/warp-dir.svg?branch=master)](https://travis-ci.org/kigster/warp-dir)
![Github Build](https://github.com/kigster/warp-dir/workflows/Ruby/badge.svg)
[![Code Climate](https://codeclimate.com/github/kigster/warp-dir/badges/gpa.svg)](https://codeclimate.com/github/kigster/warp-dir)
[![Test Coverage](https://codeclimate.com/github/kigster/warp-dir/badges/coverage.svg)](https://codeclimate.com/github/kigster/warp-dir/coverage)

<!-- TOC depthFrom:2 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Warp This](#warp-this)
- [Installation](#installation)
- [Usage](#usage)
	- [Command Completion](#command-completion)
	- [Config File (aka. Warp Points Database)](#config-file-aka-warp-points-database)
- [`wd` Concept](#wd-concept)
	- [Notable Differences with original `wd`](#notable-differences-with-original-wd)
- [Future Development](#future-development)
- [Development](#development)
- [Adding New Commands](#adding-new-commands)
- [Contributing](#contributing)
- [Author](#author)
- [License](#license)

<!-- /TOC -->
This is a ruby implementation of the tool `wd` (warp directory),
[originally written as a `ZSH` module](https://github.com/mfaerevaag/wd)
by [Markus Færevaag](https://github.com/mfaerevaag).

I personaly went back to `bash` after trying out `ZSH`, but it was the `wd` plugin that I really missed.

While Markus kindly offered a ruby version in a [separate branch of this module](https://github.com/mfaerevaag/wd/tree/ruby),
it wasn't quite as extensible as I wanted to (or well tested), so it ended up being an inspiration for this gem.

## Warp This

WarpDir is a UNIX command line tool that works somewhat similar to the standard built-in command `cd` — "change directory".

The main difference is that `wd` is able to add/remove/list folder "shortcuts", and allows you to jump to these shortcuts from anywhere on the filesystem.

This of this as a folder-navigation super-charge tool that you'd use on a most frequently-used set of folders. This becomes __really useful__ if you are often finding youself going into a small number of deeply nested folders with a long path prefix.

## Installation

Three steps:

 - `wd` requires a Ruby interpreter version 2.2 higher.
   - Please Check your default ruby with `ruby --version`. You should see something like "ruby 2.3.0p0....".
   - If you see version 1.9 or earlier, please upgrade your ruby using the package manager native to your OS.   
 - Install `warp-dir` ruby gem (note: you may need to prefix the command with `sudo` if you are installing into the "system" ruby namespace).

   ```bash
   $ gem install warp-dir --no-ri --no-rdoc
   ```

 - The last step is to install the `wd` BASH function and auto-completion. This step appends the required shell function to your shell initialization file, that is specified with the `--dotfile` flag.

   ```bash
   $ warp-dir install --dotfile ~/.bash_profile
   ```

After the last step you __need to restart your session__, so – if you are on Mac OS X, – please reopen your Terminal or better yet – [iTerm2](https://www.iterm2.com/), and then type:

```bash
$ wd help
```

If the above command returns a properly formatted help that looks like the image below, your setup is now complete!

![Image](doc/wd-help.png?refresh=1)


## Usage

> __NOTE:__ in the below examples, the characters `~ ❯ ` denote the current shell prompt, showing the current folder you are in. The command to type is on the right hand side of the "❯".

Let's first bookmark a long directory:

```bash
~ ❯ cd ~/workspace/arduino/robots/command-bridge/src
~/workspace/arduino/robots/command-bridge/src ❯ wd add cbsrc
Warp point saved!

~/workspace/arduino/robots/command-bridge/src ❯ cd ~/workspace/c++/foo/src
~/workspace/c++/foo/src ❯ wd add foosrc
Warp point saved!

~/workspace/c++/foo/src ❯ cd /usr/local/Cellar
/usr/local/Cellar ❯ wd add brew
Warp point saved!
```

Now we can list/inspect current set of warp points:

```bash
/usr/local/Cellar ❯ wd l
   cbsrc -> ~/workspace/arduino/robots/command-bridge/src
  foosrc -> ~/workspace/c++/foo/src
    brew -> /usr/local/Cellar
```

Now we can jump around these warp points, as well as run 'ls' inside (even passing arbitrary arguments to the `ls` itself):

```bash
/usr/local/Cellar ❯ wd cbsrc
~/workspace/arduino/robots/command-bridge/src ❯ wd foosrc
~/workspace/c++/foo/src ❯  1 wd ls brew -- -alF | head -4        # run ls -alF inside /usr/local/Cellar
total 0
drwxrwx---  73 kig  staff  2482 May  7 15:29 ./
drwxrwx---  21 kig  staff   714 Apr 28 11:40 ../
drwxrwx---   3 kig  staff   102 Dec 24 03:14 ack/
```

### Command Completion

If you installed `wd` properly, it should register it's own command completion for BASH and be ready for your tabs :)

Note that you can use `wd` to change directory by giving an absolute or relative directory name, just like `cd` (so not just using warp-points), so when you type `wd [TAB]` you will see all saved warp points as well as the local directories you can `cd` into.

That's basically it!  

### Config File (aka. Warp Points Database)

All of the mappings are stored in the `~/.warprc` file, where the warp point name is followed by a colon, and the path it maps to. So it's trivial to do a global search/replace on that file in your favorite editor, if, for example, a commond top level folder had changed.

The format of the file was left identical to that of the `ZSH` version of `wd` so that one could switch back and force between the two versions of `wd` and still be able to use their collection of warp points.

See? I think we thought of everything :)

Happy warping!


## `wd` Concept

The overall concept comes from the realization that when we work on the command line, we often do things that `wd` tool provides straight out of the box, such as:

 * we often have to deal with a limited number of folders at any given time
 * on occastion have to jump between these folders (which we call __warp points__), which may require mult-level `cd` command, for example: `cd ~/workspace/foo/src/include/; ....; cd ~/Documents/Microsoft\ Word/; ...`
 * seems like it should be easy to add, remove and list warp points
 * everything should require typing few characters as possible :)
 * it would be great to have full BASH completion support

Some future extensions could be based on some additional realizations:

 * perhaps you might want to inspect a bookmarked folder without leaving your current place.
 * maybe by inspecting we mean — running a `find`, or `ls` or any other command for that matter

### Notable Differences with original `wd`

 * instead of `wd add!` use `wd add -f <point>` (or --force)

These features will be added shortly:

 * for now `wd clean` is not supported
 * for now history is not supported
 * for now '-' is not supported

## Future Development

I have so many cool ideas about where this can go, that I created a
[dedicated page](ROADMAP.md) for the discussion of future features.  Please head over
there if you'ld like to participate.

## Development

Fork the repo to your github username, and create a feature branch.

Run `bin/setup` to install dependencies.  You can also run `bin/console` for an interactive prompt that will
allow you to experiment.

To install this gem onto your local machine, run `bundle install`.

To submit your change, create a new pull request, and ensure to provide tests for any new code.


## Adding New Commands

Just follow the patter in the `lib/warp/dir/commands/` folder, copy and modify
one of the existing commands.  Command class name is used as an actual command.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kigster/warp-dir.

## Author

<p>&copy; 2016-2020 Konstantin Gredeskoul, All rights reserved.</p>

## License

This project is distributed under the [MIT License](https://raw.githubusercontent.com/kigster/warp-dir/master/LICENSE).
