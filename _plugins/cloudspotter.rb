# Cloudspotter tag.
#
# Generates a gallery of your Cloudspotter uploads. 
#
# Based on Thomas Mango's Flickr Set tag.
# 
# Usage:
#
#   {% cloudspotter %}
#
# You'll need to extract your uid and token from your iThing, by
# inspecting the SSL requests from the app. Look for the request to
# https://api.cloudspotterapp.com/get/user_cloudcollection/1/json and
# populate the values in _config.yml
#
# Default Configuration (override in _config.yml):
#
#   cloudspotter:
#     uid:         ''
#     token:       ''
#     a_href:        nil
#     a_target:      '_blank'
#     image_rel:     ''
#     image_size:    's'
#     api_key:       ''
#
# Author: Chris Burgess
# Site: http://chris.bur.gs
# Plugin Source: http://github.com/xurizaemon/jekyll_cloudspotter_tag
# Plugin License: MIT

require 'net/https'
require 'uri'
require 'json'

module Jekyll
  class CloudSpotterTag < Liquid::Tag
    def initialize(tag_name, config, token)
      super

      @set  = config.strip

      @config = Jekyll.configuration({})['cloudspotter'] || {}

      @config['gallery_tag']   ||= 'p'
      @config['gallery_class'] ||= 'gallery'
      @config['a_href']        ||= nil
      @config['a_target']      ||= '_blank'
      @config['image_rel']     ||= ''
      @config['image_size']    ||= 's'
    end

    def render(context)
      html = "<#{@config['gallery_tag']} class=\"#{@config['gallery_class']}\">"

      photos.each do |photo|
        html << "<a class=\"cloudspotting\" href=\"#{photo.url(@config['a_href'])}\" target=\"#{@config['a_target']}\">"
        html << "<img src=\"#{photo.thumbnail_url}\" title=\"#{photo.cloud_type} - #{photo.placename}\"/>"
        html << "</a>"
      end

      html << "</#{@config['gallery_tag']}>"

      return html
    end

    def photos
      @photos = Array.new
      JSON.parse(json)['result']['spottings'].each do |key, item|
        @photos << CloudSpotting.new(item['spotting_id'], item['image'], item['location'], item['cloud_id'], item['status'])
      end

      @photos.sort
    end

    def json
      uri  = URI.parse("https://api.cloudspotterapp.com/get/user_cloudcollection/1/json?token=#{@config['token']}&uid=#{@config['uid']}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      return http.request(Net::HTTP::Get.new(uri.request_uri)).body
    end
  end

  class CloudSpotting
    # Cloudspotting has turned into CloudTypeIdSpotting
    CLOUD_TYPES = 

    def initialize(title, image, location, cloud_id, status)
      @title          = title
      @image          = image
      @location       = location
      @url            = image['1536x1536r']
      @thumbnail_url  = image['80x80r']
      @cloud_id       = cloud_id
      @status         = status
    end

    def title
      return @title
    end

    def url(size_override = nil)
      return @url
    end

    def thumbnail_url
      return @thumbnail_url
    end

    def <=>(photo)
      @title <=> photo.title
    end
    
    def placename
      return "#{@location["en"]["name"]}, #{@location["en"]["toponymName"]}, #{@location["en"]["adminName1"]}, #{@location["countryCode"]}"
    end

    def cloud_type
      return {
        1 => "Cumulus",       2 => "Stratocumulus",   3 => "",
        4 => "",              5 => "",                6 => "Altocumulus",
        7 => "Cirrus",        8 => "Cirrostratus",    9 => "Cirrocumulus",
        10 => "Cumulonimbus", 11 => "",               12 => "",
        13 => "Fog",          14 => "Undulatus",      15 => "Virga",
        16 => "",             17 => "",               18 => "",
        19 => "Radiatus",     20 => "",               21 => "",
        22 => "",             23 => "",               24 => "Lenticularis",
        25 => "",             26 => "",               27 => "",
        28 => "",             29 => "",               30 => "",
        31 => "Rainbow",      32 => "22 degree Halo", 33 => "Corona",
        34 => "",             35 => "",               36 => "Crepuscular Rays", 
        37 => "",             38 => "Cloudbow",
      }[@cloud_id.to_i]
    end
    
    def status
      return {
        1 => "",
        2 => "Confirmed",
        3 => "Rejected",
      }[@status]
    end
  end
end

Liquid::Template.register_tag('cloudspotter', Jekyll::CloudSpotterTag)
