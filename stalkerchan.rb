#!/usr/bin/env ruby

require "rubygems"
require "nokogiri"
require "open-uri"
require "exifr"
require "optparse"
require "fileutils"


class Image

  @@read_images = Hash.new

  def initialize(url, folder, options)
    @url,@folder,@options = url, folder, options
  end

  def fetch
    if @@read_images[@url] then
      puts "Schon geladen: #{@url}" if @options[:verbose]
    else
      puts "Lade #{@url}" if @options[:verbose]
      filename = File.join(@folder, @url[/\d+\..*/])     
      begin
        if !File.exists?(filename) then
          File.open(filename, 'w') do |file|
            file.write(open(@url).read)           
          end
        else  
          puts "File exists already: #{filename}" if File.exists?(filename) && @options[:verbose]
        end
        @@read_images[@href] = true
      rescue OpenURI::HTTPError => error
        puts error
        puts @url + " already gone..."
        File.delete(filename) 
      end
    end   
  end

end

class Faden 

  @@read_threads = Hash.new 

  def initialize(root, url, folder, options)
    @root, @url, @folder, @options = root, url, folder, options
    puts "Lese Thread #{url}" if @options[:verbose]
  end

  def url
    @root + @url
  end

  def fetch
    if @@read_threads[url.split("#")[0]] then
      puts "Thread schon gelesen!" if @options[:verbose]
    else
      begin
        @doc = Nokogiri(open(url))
        @@read_threads[url] = true
        @images = @doc/"a[@href*='files']"
        @images.each do |element|
          Image.new(@root+element[:href],@folder,@options).fetch
        end
      rescue OpenURI::HTTPError => error
        puts "Error while fetching #{url} - #{error}"
      end
    end  
  end
end

class Page
  
  def initialize(options, pagenum)
    @channel,@pagenum,@folder,@options = options[:channel],pagenum,File.join(options[:folder],options[:channel]), options
    @root, @suffix = "http://krautchan.net",".html" if @options[:chan] == "krautchan"
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
    FileUtils.makedirs(@folder)
    @threads.each do |thread|
      Faden.new(@root,thread[:href],@folder,@options).fetch
    end
  end
end

class Downloader

  def initialize(options)
    @channel,@folder, @options = options[:channel], options[:folder], options
    if File.exists?(File.join(@folder, @channel + "_downloaded")) then
      puts @channel + "_downloaded existiert"
    end
  end

  def really_fetch(pagenum)
    Page.new(@options,pagenum).fetch
  end

  def fetch
    threads = [] if @options[:threaded]
    (0..10).each do |pagenum|
      if @options[:threaded] then
        threads << Thread.new { really_fetch(pagenum) }        
      else
        really_fetch(pagenum)
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

  options[:channel] = "b"
  opts.on("-c","--channel CHANNEL","set channel to scrape (default: b)") do |channel|
    options[:channel] = channel
  end

  options[:folder] = "images"
  opts.on("-o","--output FOLDER","set output folder (default: images)") do |folder|
    options[:folder] = folder
  end

  options[:chan] = "krautchan"
  opts.on("-f","--fourchan","scrape 4chan instead of Krautchan") do
    options[:chan] = "4chan"
  end

  options[:gps] = false
  opts.on("-g","--gps","look for GPS data") do
    options[:gps] = true
  end

  opts.on("-h","--help","Display this screen") do
    puts opts
    exit
  end
end

optparse.parse!

Downloader.new(options).fetch
