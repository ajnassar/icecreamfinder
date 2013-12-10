require 'rest-client'
require "addressable/uri"
require 'json'
require 'nokogiri'

GOOGLE_API_KEY = 'AIzaSyDF3RIup3Y3_IFa383gDqfQekuATU9mkmE'

def find_nearby_location
  puts "Where are you located?"
  user_location = get_coordinates
  destination = build_places_url(user_location, 'ice cream')
  locations_json = JSON.parse(RestClient.get(destination))
  final_destination_coord =
  [locations_json['results'][0]['geometry']['location']['lat'].to_f,
    locations_json['results'][0]['geometry']['location']['lng'].to_f]
  directions_url = build_direcitons_url(user_location, final_destination_coord)
   directions_url = JSON.parse(RestClient.get(directions_url))
  give_directions(directions_url)
end

def give_directions(url)
  #p url["routes"][0]["legs"][0]["steps"]

  url["routes"][0]["legs"][0]["steps"].each do |step|
     puts Nokogiri::HTML(step["html_instructions"]).text
  end

end

def build_direcitons_url(start, finish)

  Addressable::URI.new(
     :scheme => "http",
     :host => "maps.googleapis.com",
     :path => "maps/api/directions/json",
     :query_values => {
       :origin => "#{start.first},#{start.last}",
       :destination => "#{finish.first},#{finish.last}",
       :sensor => false
     }
   ).to_s

end

def get_coordinates
  puts "type your address"
  address = get_address
  url = build_geocoder_url(address)
  convert(RestClient.get(url))
end

def convert(geo_results)
  results = JSON.parse(geo_results)
  [results['results'][0]['geometry']['location']['lat'].to_f,
    results['results'][0]['geometry']['location']['lng'].to_f]
end

def get_address
  gets.chomp
end

def build_geocoder_url(address)
  Addressable::URI.new(
     :scheme => "http",
     :host => "maps.googleapis.com",
     :path => "maps/api/geocode/json",
     :query_values => {:address => address, :sensor => false}
   ).to_s
end

def build_places_url(location, keyword)
  Addressable::URI.new(
    :scheme => 'https',
    :host => 'maps.googleapis.com',
    :path => 'maps/api/place/nearbysearch/json',
    :query_values => {
      :key => GOOGLE_API_KEY,
      :location => "#{location.first},#{location.last}",
      :radius => 500,
      :keyword => keyword,
      :sensor => false
      }
    ).to_s
end

if __FILE__ == $PROGRAM_NAME
  find_nearby_location
end