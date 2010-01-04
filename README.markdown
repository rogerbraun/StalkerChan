# StalkerChan

### About
This software will download all pictures of a (4|Kraut)chan channel and look for GPS data in them. 

### Why?
The program was inspired by a thread on /b/, asking for a program to quick-check if there is GPS data in images. I want to show that you should be more aware of what you are putting on the internet. Most modern phones and some cameras have a GPS module built in and will tag the images you take. Even if you tried to conceal your identity, having GPS data of where the photo was taken will make it easier to identify you.

### Features
- Downloads everything on a Krautchan or 4chan channel recursively 
- Looks for GPS data and prints position data

### Planned Features
- Looks for GPS data and moves files which have it
- Save only images containing GPS data
- auto-generate html files containing the picture and an embedded Google Maps view 

### Requirements
- hpricot
- exifr

### Usage
    stalkerchan.rb [-c channel | -o folder]

For more options see 

    stalkerchan.rb --help

#### Example
    stalkerchan.rb -f -c s -g -e

This will download images from 4chan (-f) from the /s/ channel (-c s) and will look for gps data (-g) endlessly in a loop (-e)

### Attention
Using this software on NSFW channels (like /b/, which is the default!) will result in NSFW images on your computer. Don't use it if you don't want that.

### Author
Roger Braun

roger.braun@student.uni-tuebingen.de
