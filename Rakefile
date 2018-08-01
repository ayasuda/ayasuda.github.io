require 'date'
require 'erb'
require 'pathname'
require 'yaml'

PAGE_DIR = "pages"

PANDOC = "pandoc"
PANDOCTEMPLATE="src/html5_template.html"
PANDOCFLAGS = "-f markdown -t html --template=#{PANDOCTEMPLATE}"

SRCS = FileList["src/*.md"]
PAGES = SRCS.gsub(/^src\//, 'pages/').ext('.html')
INDEX = "index.html"
INDEX_BASE = "src/index.html.erb"

task default: :all

directory PAGE_DIR
task all: [PAGE_DIR, INDEX]

task INDEX => [:page_all, PANDOCTEMPLATE, INDEX_BASE].flatten do
  with_localhost = false
  pages = Dir.glob("src/*.md").map{|name| Page.new(name) }
  pages.select!(&:publish?)
  pages.sort!{|a, b| b.to_date <=> a.to_date }
  File.write(INDEX, ERB.new(File.read(INDEX_BASE)).result(binding))
end

task page_all: PAGES

task :clean do
  rm INDEX
  rm_rf PAGE_DIR
end

rule %r{^#{PAGE_DIR}/.+\.html} => "%{^#{PAGE_DIR},src}X.md" do |t|
  sh "#{PANDOC} #{PANDOCFLAGS} -o #{t.name} #{t.source}"
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
    metadata.key?("date")
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
