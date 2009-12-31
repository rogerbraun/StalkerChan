#!/usr/bin/env ruby

require "rubygems"
require "nokogiri"
require "open-uri"
require "exifr"
require "optparse"

class Image

  @@read_images = Hash.new

  def initialize(root, href, folder)
    @root, @href, @folder = root, href,folder
  end

  def url
    @root + @href
  end

  def fetch
    if @@read_images[@href] then
      puts "Schon geladen: #{url}"
    else
      puts "Lade #{url}"
      filename = File.join(@folder, url[/\d+\..*/])     
      begin
        File.open(filename, 'w') do |file|
          file.write(open(url).read)           
        end 
        @@read_images[@href] = true
      rescue OpenURI::HTTPError
        puts error
        puts url + " already gone..."
        File.delete(filename) 
      end
    end   
  end

end

class Faden 

  @@read_threads = Hash.new 

  def initialize(root, url, folder)
    @root, @url, @folder = root, url, folder
    puts "Lese Thread #{url}"
  end

  def url
    @root + @url
  end

  def fetch
    if @@read_threads[url.split("#")[0]] then
      puts "Thread schon gelesen!"
    else
      @doc = Nokogiri(open(url))
      @@read_threads[url] = true
      @images = @doc/"a[@href*='files']"
      @images.each do |element|
        Image.new(@root,element[:href],@folder).fetch
      end
    end  
  end
end

class Page
  
  def initialize(root, suffix, channel, pagenum, folder)
    @root,@suffix,@channel,@pagenum,@folder = root, suffix, channel, pagenum,folder
  end

  def page
    @pagenum.to_s + @suffix
  end

  def url
    @root + "/" + @channel + "/" + page
  end

  def fetch
    puts url
    @doc = Nokogiri(open(url))

    @threads = @doc/"a[@href*='thread-']"

    @threads.each do |thread|
      puts "Thread: #{@pagenum}"
      Faden.new(@root,thread[:href],@folder).fetch
    end
  end
end

class Downloader

  def initialize(root, suffix, channel, folder, options)
    @root, @suffix, @channel,@folder,@options = root, suffix, channel, folder,options
    if File.exists?(File.join(folder, channel + "_downloaded")) then
      puts channel + "_downloaded existiert"
    end
  end

  def fetch
    threads = [] if @options[:threaded]
    (0..10).each do |pagenum|
      if @options[:threaded] then
        threads << Thread.new { Page.new(@root, @suffix, @channel, pagenum,@folder).fetch}        
      else
        Page.new(@root, @suffix, @channel, pagenum,@folder).fetch
      end
    end
    threads.each do |thread| thread.join end if @options[:threaded]
  end

  def fetch_endlessly
    while true do
      fetch
    end
  end

end

options = {}

optparse = OptionParser.new do |opts|

  opts.banner = "Usage: stalkerchan.rb [options]"

  options[:verbose] = false
  opts.on( "-v","--verbose","Verbose mode") do
    options[:verbose] = true
  end

  options[:threaded] = false
  opts.on("-t","--threaded","Use threads") do
    options[:threaded] = true
  end

  opts.on("-h","--help","Display this screen") do
    puts opts
    exit
  end
end

optparse.parse!

Downloader.new("http://krautchan.net",".html","b","images", options).fetch
