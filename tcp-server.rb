require 'socket'
require 'json'


# Attempt to read and parse the configuration file
config = JSON.parse(File.read('server-config.json'))
# Extract configuration values
$server_name = config['servername']
PORT = config['port']


# Initialize the server and client list
server = TCPServer.open(PORT)
clients = []


puts "Server started on port #{PORT}..."

loop do
  client = server.accept
  clients << client
  puts "Client connected."


  Thread.start(client) do |client_conn|
    begin
      client_conn.puts "Hello, welcome to #{server_name}"

      
      loop do
        msg = client_conn.gets&.chomp
        break if msg.nil? || msg == "exit"

        clients.each do |c|
          begin
            c.puts msg unless c == client_conn
          rescue Errno::EPIPE, IOError => e
            puts "Error: #{e.message}. Removing client."
            clients.delete(c)
            c.close
          end
        end
      end
    rescue Errno::EPIPE, IOError => e
      puts "Error: #{e.message}. Client disconnected unexpectedly."
    ensure
      clients.delete(client_conn)
      client_conn.puts "[TCP Server] Server shut down!" rescue nil
      client_conn.close
      puts "Client disconnected."
    end
  end
end
