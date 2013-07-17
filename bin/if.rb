#!/usr/bin/env ruby

lib_dir = File.dirname(__FILE__) + "/../lib"
$LOAD_PATH.unshift lib_dir unless $LOAD_PATH.include?(lib_dir)

require "if"

story_file, = ARGV

repl = IF::REPL::new story_file
repl.run