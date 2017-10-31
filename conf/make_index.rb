#!/usr/bin/env ruby
require 'erb'

pages = Dir.glob("pages/*.html")
ERB.new(File.read('conf/index.html.erb')).run(binding)
