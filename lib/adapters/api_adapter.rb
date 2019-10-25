def get_coordinates(three_words)

  url = URI("https://api.what3words.com/v3/convert-to-coordinates?key=6RXCEY3L&words=#{three_words}&format=json")

  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Get.new(url)

  response = http.request(request)
  output = JSON.parse(response.read_body)

  if output == {"error"=>{"code"=>"BadWords", "message"=>"words must be a valid 3 word address, such as filled.count.soap or ///filled.count.soap"}}
    output = "error"
  else                  

    lon = output["coordinates"]["lng"]
    lat = output["coordinates"]["lat"]

    coordinates = [lat, lon]
  end

end

def sanitize_address(question)

    origin_address = @prompt.ask(question)

    loop do

        loop do

            if origin_address == nil || origin_address == ""
    
                origin_address = @prompt.ask('Not a valid What3words address, enter again: ')
                
            elsif origin_address == "home"
    
                return app_launch_page
    
            else
    
                origin_address = origin_address.split(".").map {|e| e.gsub(/\W+/, '')}.join('.')
                # binding.pry
                break
    
            end
            
        end

        # binding.pry

        if origin_address == nil || origin_address == ""

            origin_address = "blank"

        elsif origin_address == "home"

            return app_launch_page

        elsif get_coordinates(origin_address) == "error"

            origin_address = @prompt.ask('Not a valid What3words address, enter again: ')

        else
            
            break

        end

    end

    origin_address
    
end

def get_distance_between(origin_address, dest_address)

    a_one = get_coordinates(origin_address)
    a_two = get_coordinates(dest_address)
    if a_one == "error" || a_two == "error"
      puts "That is not a valid what3words address"
    else
      dist = Geocoder::Calculations.distance_between(a_one, a_two) * 1.609
      dist.round(2)
    end

end