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

task :test do
  p PAGES
end

directory PAGE_DIR
task all: [PAGE_DIR, INDEX]

task INDEX => [:page_all, PANDOCTEMPLATE, INDEX_BASE].flatten do
  with_localhost = LOCALHOST
  pages = Dir.glob("src/*.md").map{|name| Page.new(name) }
  pages.select!(&:publish?)
  pages.sort!{|a, b| b.to_date <=> a.to_date }
  File.write(INDEX, ERB.new(File.read(INDEX_BASE)).result(binding))
end

task page_all: PAGES

task :clean do
  rm_rf PAGE_DIR
  rm INDEX
end

rule %r{^#{PAGE_DIR}/.+\.html} => "%{^#{PAGE_DIR},src}X.md" do |t|
  if LOCALHOST
    sh "#{PANDOC} #{PANDOCFLAGS} -V localhost=1 -o #{t.name} #{t.source}"
  else
    sh "#{PANDOC} #{PANDOCFLAGS} -o #{t.name} #{t.source}"
  end
end

task :run do
  sh "ruby -run -e httpd . -p 3000"
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
    (d < Date.today)
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
