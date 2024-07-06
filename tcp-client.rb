require 'socket'
require 'json'

# Get colors working
class String
  # Define color constants
  COLORS = {
    black:   30,
    red:     31,
    green:   32,
    yellow:  33,
    blue:    34,
    magenta: 35,
    cyan:    36,
    white:   37
  }
  # Define color methods
  COLORS.each do |color, code|
    define_method(color) { "\e[#{code}m#{self}\e[0m" }
  end
end

# Default configuration values
default_hostname = 'localhost'
default_port = 4000
default_username = 'default_user'

begin
  # Attempt to read and parse the configuration file
  config = JSON.parse(File.read('client-config.json'))
  
  # Extract configuration values
  hostname = config['hostname']
  port = config['port']
  username = config['username']
rescue Errno::ENOENT, JSON::ParserError
  # If the file is not found or there's a JSON parsing error, use default values
  puts "(Client) Error reading configuration file. Using default values.".yellow

  hostname = default_hostname
  port = default_port
  username = default_username

  printf "(Client) NOTE:".yellow
  puts "You can use 'config.json' if you want to preconfigure this"
end

begin
  socket = TCPSocket.open(hostname, port)
  puts "(Client) Connected to server at --> #{hostname}:#{port}".yellow


rescue Errno::ECONNREFUSED
  puts "(Client) Error: Connection refused. Please ensure the server is running and try again. Host Server:#{hostname} Host Server Port:#{port}".yellow
  exit
end

# Handle Ctrl+C (SIGINT) to gracefully shut down the client
trap("INT") do
  puts "\n (Client) Disconnecting from server...".yellow
  socket.puts "exit" rescue nil
  socket.close
  exit
end

Thread.new do
  loop do
    msg = socket.gets
    if msg.nil?
      puts "(Client) Connection closed by server.".yellow
      exit
    else
      msg.chomp!

      # Detect and apply color
      if msg.match(/\.\w+$/)
        color_code = msg.match(/\.(\w+)$/)[1]
        if String::COLORS.key?(color_code.to_sym)
          colored_msg = msg.gsub(/\.\w+$/, '').send(color_code.to_sym)
          puts colored_msg
        else
          puts msg
        end
      else
        puts msg
      end
    end
  end
end

loop do
  msg = $stdin.gets.chomp
  break if msg == "exit"
  socket.puts "#{username}:#{msg}" 
end
