def speed_option(input)

  case input

  when 1
    return {type: "standard", cost_mult: 1.23}
  when 2
    return {type: "express", cost_mult: 3.69}
  when 3
    return {type: "lightning", cost_mult: 12.01}
  else
    return homepage
  end

end

def choose_menu_options(input)

    case input

    when 2

        ["1. go to your homepage?", "2. go back to the list of deliveries?", "3. log off?"]
        
    when 3

        ["1. go to your homepage?", "2. go back to the list of deliveries to update another one?", "3. log off?"]
        
    when 4

        ["1. go to your homepage?", "2. go back to the list of past deliveries?", "3. log off?"]

    when 5

        ["1. go to your homepage?", "2. go back to the list of deliveries to cancel another one?", "3. log off?"]
        
    else

        
        
    end
    
end

def log_in_page

    title
    puts "Type 'home' at any point to return."
    puts ""
    username = @prompt.ask('What is your username?')
    user_real = User.all.find {|user| user.username == username}

    loop do

        if username == "home"

            return app_launch_page

        elsif !user_real
            
            title
            puts "Type 'home' at any point to return."
            puts ""
            username = @prompt.ask('That username doesn\'t exist. Please re-enter your username:')
            user_real = User.all.find {|user| user.username == username}

        else

            break
                
        end

    end

    title
    puts "Type 'home' at any point to return."
    puts ""
    puts "USERNAME: #{username}"
    puts ""
    password = @prompt.mask('What is your password?')

    loop do

        if password == "home"
                
            return app_launch_page
                
        elsif password != user_real.password

            title
            puts "Type 'home' at any point to return."
            puts ""
            puts "USERNAME: #{username}"
            puts ""
            password = @prompt.mask('Password incorrect. Please re-enter your password:')

        else

            break
                
        end

    end

    splash_loading_bar("Logging into the mainframe", 40)
    @user = User.find_by(username: username)
    homepage
        

end

def sign_up_page
    
    title

    puts "Type 'home' at any point to return."
    puts ""
    
    first_name = @prompt.ask('What is your first name?').tr( '^A-Za-z\-', '' )

    if first_name == "home"

        return app_launch_page
        
    end

    last_name = @prompt.ask('What is your last name?').tr( '^A-Za-z\-', '' )

    if last_name == "home"

        return app_launch_page
        
    end

    username = @prompt.ask('Please choose a username:')

    user_exists = User.all.find_by(username: username)

    loop do

        if user_exists != nil

            username = @prompt.ask('That username is already in use! Enter a new one:')
            user_exists = User.all.find_by(username: username)
            
        else

            break
            
        end
        
    end

    password = @prompt.mask('Please type in a password:')

    if password == "home"

        return app_launch_page
        
    end

    repeat_password = @prompt.mask('Please repeat your password:')

    loop do

        if repeat_password == "home"
                
            return app_launch_page
                
        elsif repeat_password != password

            repeat_password = @prompt.mask('The password doesn\'t match! Re-enter your password!')
            
        else

            break

        end

    end
    
    puts "Do you have your what3words address? (y/n)"

    have_address = nil

    loop do 

        have_address = gets.chomp

        if have_address != "y" && have_address != "n"

            puts "Invalid input! Type y for yes, or n for no."
    
        else

            break
    
        end
        
    end


    if have_address == "n"

        puts ""
        puts "You'll be redirecred to the what3words website to find your address."
        puts "When you have it, please come back and enter it here."
        sleep(5)
        puts `open https://what3words.com/`
        sleep(2)

    end

    origin_address = sanitize_address('What is your what3words address?')

    # binding.pry
    h1 = {
        first_name: first_name,
        last_name: last_name,
        username: username,
        password: password,
        origin_address: origin_address}

    @user = User.create(h1)
    puts ""
    puts "Signed up successfully!"
    splash_loading_bar("Creating life", 50)
    homepage
    
end

def new_delivery

    title
    puts "Type 'home' at any point to return."
    puts ""

    name = @prompt.ask('Who are you sending your package to?')
    homepage if name == "home"
    puts ""
    destination = sanitize_address('What is the What3words address that you are sending it to?')
    puts ""
    description = @prompt.ask('Type a short description of the contents of your delivery:')
    homepage if description == "home"

    puts ""
    def speed_prompt

        @prompt.select('Choose your speed option:') do |menu|
            
            menu.enum '.'
            menu.choice 'Standard', 1
            menu.choice 'Express', 2 #, disabled: '(out of stock)'
            menu.choice 'Lightning', 3
            menu.choice 'Cancel new delivery', 4
            
        end
        
    end

    user_input = speed_prompt

    return homepage if user_input == 4

    destination_instance = Destination.find_or_create_by({name: name, destination_address: destination})
    
    @user.destinations << destination_instance

    created_delivery = Delivery.all.last

    created_delivery.status = "in transit"
    created_delivery.description = description
    created_delivery.distance = get_distance_between(@user.origin_address, created_delivery.destination.destination_address)
    created_delivery.cost = (created_delivery.distance * speed_option(user_input)[:cost_mult]).round(2)
    created_delivery.speed = speed_option(user_input)[:type]
    loop do
      puts ""
      puts "At a delivery distance of #{created_delivery.distance}km, the price at this speed option is £#{created_delivery.cost} is that acceptable? (y/n)"

      response = nil

      loop do 

        response = gets.chomp

          if response != "y" && response != "n"

              puts "Invalid input! Type y for yes, or n for no."
      
          else

              break
      
          end
        
    end

    if response == "n"

      response = false

    end

        if response

            created_delivery.save
            break
            
        else

            new_input = speed_prompt

            if new_input == 4

                Delivery.all.last.destroy
                break homepage
                
            end

            created_delivery.cost = (created_delivery.distance * speed_option(new_input)[:cost_mult]).round(2)
            # binding.pry
            created_delivery.speed = speed_option(new_input)[:type]
            
        end
        
    end

    if created_delivery.speed == "lightning"

        puts ""
        puts "Gee, you're rich AF if you can afford that."
        sleep(2)

    end

    puts ""
    puts "Your delivery is pending, please wait."
    sleep(3)
    splash_loading_bar("A courier is breaking into your house", 40)
    puts ""
    puts "The courier has the goodies!"
    sleep(2)
    splash_loading_bar("Pre-damaging your shipment", 40)
    puts ""
    puts "Your delivery is on its way!"
    sleep(2)
    puts ""
    puts "Returning to homepage..."
    sleep(2)
    homepage

end

def retrieve_deliveries_by_args(args, menu_option)

    title
    deliveries_array = Delivery.all.where(args)

    formatted_deliveries = deliveries_array.map do |element|
    
        "Delivery to: #{element.destination.name} at #{element.destination.destination_address} - id: #{element.id}"

    end

    if formatted_deliveries.empty?

        puts "No deliveries to show!"
        puts ""
        sleep(1.5)
        puts "Returning to homepage."
        sleep(1.5)
        homepage
        
    end
    chosen_delivery = @prompt.select("Select a delivery (use arrow keys and Enter)") do |menu|
    
        menu.per_page 7
        menu.help ''
        menu.enum '.'
        menu.choices formatted_deliveries
    
    end
    
    delivery_id = chosen_delivery.split("id: ")[-1].to_i
    delivery = Delivery.find_by(id: delivery_id)

    if menu_option != 5
        
        puts ""
        puts "Your delivery is #{delivery.status}."
        # puts "ETA: #{delivery.status == "delivered" ? 'N/A' : 'whatever function'}" #{convert_to_readable_time(Time.now.utc, delivery.created_on)}"
        puts "Cost: £#{delivery.cost}"
        puts "Shipment method: #{delivery.speed}"
        puts "Initialized on: #{delivery.created_at}"
        puts "Contents: #{delivery.description}"
        puts ""
        # binding.pry
        # puts "Recepient: #{delivery.destination.name}"
        # puts "Recepient address: #{delivery.destination.destination_address}"
        sleep(1)

    else

        puts ""

    end

    delivery_options_menu(args, menu_option, delivery)

end

def delivery_options_menu(args, menu_option_choice, delivery_instance)

    menu_options = choose_menu_options(menu_option_choice)

    if  menu_option_choice == 3

        update_delivery(delivery_instance)

    elsif menu_option_choice == 5

        cancel_delivery(delivery_instance)

    end

    user_input = @prompt.select('Would you like to:', menu_options)
    
    case user_input

    when menu_options[0]

        homepage

    when menu_options[1]

        retrieve_deliveries_by_args(args, menu_option_choice)

    else

        app_launch_page

    end


    
end

def cancel_delivery(del_instance)

    are_you_sure = @prompt.select('Are you sure you want to cancel this delivery?') do |menu|
    
        menu.help ''
        menu.enum '.'
        menu.choice "Yes", 1
        menu.choice "No", 2
    
    end

    if are_you_sure == 2

        return

    end
    puts ""
    puts "Delivery has been cancelled."
    sleep(1)
    puts ""
    del_instance.destroy

end

def update_delivery(del_instance)

  which_change = @prompt.select('What do you want to change?') do |menu|
    
    menu.help ''
    menu.enum '.'
    menu.choice "Recipient name", 1
    menu.choice "Recipient address", 2
    menu.choice "Return to homepage", 3

  end

  puts ""

  if which_change == 1

    new_name = @prompt.ask("What do you change the name to?")

    are_you_sure = @prompt.select('Are you sure you want to update this delivery?') do |menu|
      
      menu.help ''
      menu.enum '.'
      menu.choice "Yes", 1
      menu.choice "No", 2
    
      end

    if are_you_sure == 2

        return

    end

    puts ""
    puts "Delivery has been updated."
    sleep(1)
    puts ""
    del_instance.destination.name = new_name

  elsif which_change == 2

    new_destination = sanitize_address("What do you want to change the destination to?")

    are_you_sure = @prompt.select('Are you sure you want to update this delivery?') do |menu|
      
      menu.help ''
      menu.enum '.'
      menu.choice "Yes", 1
      menu.choice "No", 2
    
      end

    if are_you_sure == 2

        return

    end

    puts ""
    puts "Delivery has been updated."
    sleep(1)
    puts ""
    del_instance.destination.destination_address = new_destination

  else

    homepage

  end
  
  del_instance.destination.save

end
