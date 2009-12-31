# StalkerChan

### About
This software will download all pictures of a 4chan channel and look for GPS data. If it finds some it copies the image to a special folder, which you can then analyze.

It is mostly a fork of github.com/anonymous/4chan.

### Why?
The program was inspired by a thread on /b/, asking for a program to quick-check if there is GPS data in images. I want to show that you should be more aware of what you are putting on the internet. Most modern phones and some cameras have a GPS module built in and will tag the images you take. Even if you tried to conceal your identity, having GPS data of where the photo was taken will make it easier to identify you.

### Features
- Downloads recursively everything on a 4chan channel
- Looks for GPS data and moves files which have it

### Planned Features
- Save only images containing GPS data
- auto-generate html files containing the picture and an embedded Google Maps view 

### Requirements
- hpricot
- exifr

### Usage
stalkerchan.rb [-c channel | -f folder]

For more options see stalkerchan.rb --help

### Attention
Using this software on NSFW channels (like /b/, or /s/, which is the default!) will result in NSFW images on your computer. Don't use it if you don't want that.

