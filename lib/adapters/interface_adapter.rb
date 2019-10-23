require 'pry'
require "tty-prompt"
require "tty-reader"


@prompt = TTY::Prompt.new
@reader = TTY::Reader.new

@splash_box = TTY::Box.frame(
    " ______   _______  ___      ___   __   __  _______  ______    __   __  __   __ ",
    "|██████| |███████||███|    |███| |██| |██||███████||██████|  |██| |██||██| |██|",
    "|███████||███████||███|    |███| |██|_|██||███████||███| █|  |██| |██||██| |██|",
    "|█| |███||███|___ |███|    |███| |███████||███|___ |███|_█|_ |██|_|██||██|_|██|",
    "|█|_|███||███████||███|___ |███| |███████||███████||████████||███████||███████|",
    "|███████||███|___ |███████||███|  |█████| |███|___ |███|  |█||███████||███████|",
    "|██████| |███████||███████||███|   |███|  |███████||███|  |█||███████||███████|",
    padding: 5,
    align: :center,
    width: TTY::Screen.width,
    height: 20,
    title: {top_left: ' DELIVERUU ', bottom_right: ' faster than DHL '},
    border: :thick
)

def splash_loading_bar(message, time)

    puts ""
    bar = TTY::ProgressBar.new("#{message} [:bar] :percent", total: time, width: TTY::Screen.width)
    time.times {bar.advance; sleep(0.07)}
    
end

def title

    puts `clear`
    print @splash_box
    puts ""
    
end

def splash

    title
    splash_loading_bar("Doing things and stuff", 60)
    app_launch_page

end

def app_launch_page
    @user = nil
    title

    user_choice = @prompt.select("Choose an option:") do |menu|

        menu.enum '.'
        menu.choice 'Log In', 1
        menu.choice 'Sign Up', 2

    end

    if user_choice == 1

        log_in_page

    elsif user_choice == 2

        sign_up_page

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
    puts ""
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
            puts ""
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
    # binding.pry
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

    user_real = User.all.find {|user| user.username == username}.username

    loop do

        if username == "home"

            return app_launch_page

        elsif user_real == username
            
            user_real = User.all.find {|user| user.username == username}.username
            username = @prompt.ask('That username is already in use! Enter a new one:')

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
    
    have_address = @prompt.yes?('Do you have your what3words address?')

    if !have_address

        puts ""
        puts "You'll be redirecred to the what3words website to find your address."
        puts "When you have it, please come back and enter it here."
        sleep(8)
        puts `open https://what3words.com/`
        sleep(2)

    end

    origin_address = @prompt.ask('What is your what3words address?').tr('/', '')

    if origin_address == "home"

        return app_launch_page
        
    end

    h1 = {
        first_name: first_name,
        last_name: last_name,
        username: username,
        password: password,
        origin_address: origin_address}

    @user = User.create(h1)
    homepage
    
end

def homepage

    title
    user_input = @prompt.select('Choose your option:') do |menu|

        menu.enum '.'
        menu.choice 'Create new delivery', 1
        menu.choice 'Check delivery status', 2 #, disabled: '(out of stock)'
        menu.choice 'Update delivery address', 3
        menu.choice 'Check past deliveries', 4
        menu.choice 'Cancel delivery', 5
        menu.choice 'Log out', 6

    end

    case user_input

    when 1

        new_delivery

    when 2

        delivery_status

    when 3

        update_delivery

    when 4

        past_deliveries

    when 5

        cancel_delivery

    else

        app_launch_page

    end

end

def new_delivery

    puts "worked"
    binding.pry

end

def delivery_status



end

def update_delivery



end

def past_deliveries



end

def cancel_delivery


    
end