require 'gtk3'
require_relative 'connector'




class MyWindow
  def initialize
    # Load the .glade file
    builder = Gtk::Builder.new
glade_file = File.expand_path('main.glade', ENV['HERE'])
    puts "Resolved path to main.glade: #{glade_file}"

    builder.add_from_file(glade_file)

    # Get the main window object
    @window = builder.get_object('main_window')
    unless @window
      puts "Error: Could not find the main_window object in the Glade file."
      exit
    end
    @window.signal_connect('destroy') { Gtk.main_quit }

    # Get the GtkEntry object
    @entry = builder.get_object('message_box')
    unless @entry
      puts "Error: Could not find the message_box object in the Glade file."
      exit
    end
    @entry.signal_connect('activate') { on_entry_activate }

    # Get the GtkButton object and connect its clicked signal
    button = builder.get_object('send_message')
    unless button
      puts "Error: Could not find the send_message object in the Glade file."
      exit
    end
    button.signal_connect('clicked') { on_button_clicked }

    # Get the GtkTextView object for displaying messages
    @message_view = builder.get_object('messages')
    unless @message_view
      puts "Error: Could not find the messages object in the Glade file."
      exit
    end

    # Show all the widgets
    @window.show_all

    # Initialize connection and pass the message text view
    @socket = start_connection('localhost', 4000, 'default_user', @message_view)
  end

  def on_entry_activate
    send_message
  end

  def on_button_clicked
    send_message
  end

  def send_message
    # Retrieve the text from the GtkEntry widget
    entry_text = @entry.text
    return if entry_text.strip.empty?

    puts "User inputted a message: #{entry_text}"
    # Send the message through the socket
    @socket.puts entry_text
    # Clear the GtkEntry widget
    @entry.text = ''

    # Append the sent message to the GtkTextView
    buffer = @message_view.buffer
    iter = buffer.end_iter
    buffer.insert(iter, "You: #{entry_text}\n")
    @message_view.scroll_to_iter(iter, 0, false, 0, 1)
  end
end

# Start the GTK main loop
MyWindow.new
Gtk.main
