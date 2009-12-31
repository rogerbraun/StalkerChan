#! /usr/bin/ruby
require "rubygems"
require "exifr"


dir = Dir.new(Dir.getwd)

dir.each do |file|

  if file.downcase["jpg"] then
    jpg = EXIFR::JPEG.new(file)
   
    if jpg.exif? then  
      if jpg.exif.gps_latitude != nil then
        lat = jpg.exif.gps_latitude[0].to_f  + (jpg.exif.gps_latitude[1].to_f / 60) + (jpg.exif.gps_latitude[2].to_f / 3600)
        long = jpg.exif.gps_longitude[0] + (jpg.exif.gps_longitude[1].to_f / 60) + (jpg.exif.gps_longitude[2].to_f / 3600)
        long = long * -1 if jpg.exif.gps_longitude_ref == "W"   # (W is -, E is +)

        puts "Picture: #{file} Latitude: #{lat} Longitude #{long}"
        puts "Google Maps: http://maps.google.com/maps?ll=#{lat},#{long}&q=#{lat},#{long}"
      end
    end
  end


end
