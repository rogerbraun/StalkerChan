#!/usr/bin/env ruby

require "rubygems"
require "nokogiri"
require "open-uri"
require "exifr"

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
      File.open(File.join(@folder, url[/\d+\..*/]), 'w') do |file|
        file.write(open(url).read) 
      end 
      @@read_images[@href] = true
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
      Faden.new(@root,thread[:href],@folder).fetch
    end
  end
end

class Downloader

  def initialize(root, suffix, channel, folder)
    @root, @suffix, @channel,@folder = root, suffix, channel, folder
    if File.exists?(File.join(folder, channel + "_downloaded")) then
      puts channel + "_downloaded existiert"
    end
  end

  def fetch
    (0..10).each do |pagenum|
      Page.new(@root, @suffix, @channel, pagenum,@folder).fetch
    end
  end

  def fetch_endlessly
    while true do
      fetch
    end
  end

end

Downloader.new("http://krautchan.net",".html","s","images").fetch
