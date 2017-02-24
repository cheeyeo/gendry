require 'nokogiri'
require 'open-uri'

module Lita
  module Handlers

    class NextBike < Handler
      REDIS_CITY_KEY = "nc_"

      template_root File.expand_path("../../templates", __FILE__)
      route('nextbike', :nextbike, help: { "nextbike" => "Shows how many bikes are at a given location" })
      route('nextbike status', :status)
      route('nextbike update', :update)
      route('nextbike show cities', :listcities)
      route(/^nextbike show location\s(.+)/, :listlocation)

      def status(response)
        response.reply "Status: All good in the hood."
      end

      def update(response)
        doc = Nokogiri::XML(open("https://nextbike.net/maps/nextbike-official.xml"))
        count = 0
        doc.search('//country//city').each do |data|
	  uid = data['uid']
	  name = data['name']
          redis.hset(REDIS_CITY_KEY,uid,name)
	  count+=1
        end
        response.reply "*Update*: #{count} cities added/refreshed."
      end

      def listcities(response)
	city_list = redis.hvals(REDIS_CITY_KEY)
        if city_list.empty?
          response.reply("*Info*: No cities are stored, run update?")
        else
          response.reply(render_template("nextbike_cities.slack", data: city_list))
        end
      end

      def getUID
      end

      def getName
      end

      def listlocation(response)
        city_uid = nil
        city_name = response.matches.first
	city_list = redis.hgetall(REDIS_CITY_KEY)
	city_list.each do |key, value|
	  if "#{value.downcase}" == "#{city_name.first}"
	    city_uid = key
	  end
        end

	if city_uid.nil?
            response.reply("*Info*: Could not find the city #{city_name.first}")
	    return true
	end

        doc = Nokogiri::XML(open("https://nextbike.net/maps/nextbike-official.xml?city=#{city_uid}"))
        location_list = []
        doc.search('//country//city//place').each do |data|
	  location_list.push(data['name'])
        end
        
        response.reply(render_template("nextbike_location.slack", data: location_list))
      end

      def nextbike(response)
        doc = Nokogiri::XML(open("https://nextbike.net/maps/nextbike-official.xml?city=237"))
        doc.search('//country//city//place').each do |data|
          if data['uid'] == "264308"
	    response.reply("*#{data['name']}* has *#{data['bikes']}* bikes left.")
          end
        end
      end

    end

    Lita.register_handler(NextBike)

  end
end
