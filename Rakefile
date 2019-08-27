require 'date'
require 'erb'
require 'pathname'
require 'yaml'


PANDOC = "pandoc"
PANDOCTEMPLATE="src/html5_template.html"
PANDOCFLAGS = "-f markdown -t html --template=#{PANDOCTEMPLATE}"

SRCS = FileList["src/**/*.md"]

PAGE_DIR = "pages"
PAGES = SRCS.gsub(/^src\//, 'pages/').ext('.html')

INDEX = "index.html"
INDEX_BASE = "src/index.html.erb"

LOCALHOST = ENV['LOCAL'] || false

task default: :all

desc "test command to develop rake file self"
task :test do
  p PAGES
end

directory PAGE_DIR

desc "compile all published articles, index page and any of all"
task all: [PAGE_DIR, INDEX]

desc "compile index.html"
task INDEX => [:page_all, PANDOCTEMPLATE, INDEX_BASE].flatten do
  with_localhost = LOCALHOST
  pages = Dir.glob("src/*.md").map{|name| Page.new(name) }
  pages.select!(&:publish?)
  pages.sort!{|a, b| b.to_date <=> a.to_date }
  File.write(INDEX, ERB.new(File.read(INDEX_BASE)).result(binding))
end

desc "compile all published articles"
task page_all: PAGES

desc "clean up all published files"
task :clean do
  rm_rf PAGE_DIR
  rm INDEX
end

rule %r{^#{PAGE_DIR}/.+\.html} => "%{^#{PAGE_DIR},src}X.md" do |t|
  if Page.new(t.source).publish?
    if LOCALHOST
      sh "#{PANDOC} #{PANDOCFLAGS} -V localhost=1 -o #{t.name} #{t.source}"
    else
      sh "#{PANDOC} #{PANDOCFLAGS} -o #{t.name} #{t.source}"
    end
  end
end

desc "run local web server to check page view"
task :run do
  sh "ruby -run -e httpd . -p 3000"
end

desc "show draft articles"
task :draft do
  SRCS.each do |src|
    page = Page.new(src)
    next if page.publish?
    puts [src, page.title].join("\t")
  end
end

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
    Date.parse(metadata["date"])
  end

  def publish?
    return false unless metadata.key?("date")
    d = Date.parse(metadata["date"])
    (d <= Date.today)
  end

  def description
    metadata["description"]
  end

  def keywords
    metadata["keywords"]
  end

  private

  def metadata
    return @metadata if @metadata
    @metadata = YAML.load(File.read(@pathname))
  end
end
