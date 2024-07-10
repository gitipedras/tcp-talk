require 'json'
require 'socket'

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
server= '(Server)'

begin
  # Attempt to read and parse the configuration file
  config = JSON.parse(File.read('client-config.json'))
  
  # Extract configuration values
  hostname = config['hostname']
  port = config['port']
  @my_username = config['username']
rescue Errno::ENOENT, JSON::ParserError
  # If the file is not found or there's a JSON parsing error, use default values
  puts "(Client) Error reading configuration file. Using default values.".yellow

  hostname = default_hostname
  port = default_port
  username = default_username

  printf "(Client) NOTE:".yellow
  puts "You can use 'config.json' if you want to preconfigure this"
end

# Start the connection
def start_connection(hostname, port, username, text_view)
  begin
    socket = TCPSocket.open(hostname, port)
    puts "(Client) Connected to server at --> #{hostname}:#{port}".yellow

    Thread.new do
      loop do
        msg = socket.gets
        if msg.nil?
          puts "(Client) Connection closed by server.".yellow
          exit
        else
          msg.chomp!

          # Update the text buffer of the text_view on the GTK main thread
          GLib::Idle.add do
            buffer = text_view.buffer
            iter = buffer.end_iter
            buffer.insert(iter, "#{@my_username}: #{msg}" + "\n")
            text_view.scroll_to_iter(iter, 0, false, 0, 1)
            false
          end
        end
      end
    end


    return socket
  rescue Errno::ECONNREFUSED
    puts "(Client) Error: Connection refused. Please ensure the server is running and try again. Host Server:#{hostname} Host Server Port:#{port}".yellow
    exit
  end
end
