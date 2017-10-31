#!/usr/bin/env ruby
require 'date'
require 'erb'
require 'pathname'
require 'yaml'

class Page
  def initialize(name)
    @pathname = Pathname.new name
  end

  def path
    "/pages/#{@pathname.basename(".md")}.html"
  end

  def title
    metadata["title"]
  end

  def to_date
    Date.parse(metadata["posted"])
  end

  def publish?
    metadata.key?("posted")
  end

  def description
    metadata["description"]
  end

  private

  def metadata
    return @metadata if @metadata
    @metadata = YAML.load(File.read(@pathname))
  end
end

pages = Dir.glob("src/*.md").map{|name| Page.new(name) }
pages.select!(&:publish?)
pages.sort!{|a, b| b.to_date <=> a.to_date }
ERB.new(File.read('conf/index.html.erb')).run(binding)
