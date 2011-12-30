/**
 * Shared Drawing Canvas (Client) 
 * by Alexander R. Galloway. 
 * 
 * The Processing Client class is instantiated by specifying a remote 
 * address and port number to which the socket connection should be made. 
 * Once the connection is made, the client may read (or write) data to the server.
 * Before running this program, start the Shared Drawing Canvas (Server) program.
 */

import processing.net.*;
//String the_server_ip = "127.0.0.1";//@self
//String the_server_ip = "10.2.40.184";//@work
String the_server_ip = "192.168.0.5";//@home
int the_port = 12345;

Client c;
String input;
int data[];


//drawing stuff
int window_height = 400;    //this must be the same as on the server
int window_width = window_height;    //

void setup() 
{
  size(window_width, window_height);
  background(204);
  stroke(0);
  frameRate(5); // Slow it down a little
  // Connect to the server's IP address and port
  c = new Client(this, the_server_ip, the_port); // Replace with your server's IP and port
}

void draw() 
{
  if (mousePressed == true) {
    // Draw our line
    stroke(255);
    line(pmouseX, pmouseY, mouseX, mouseY);
    // Send mouse coords to other person
    c.write(pmouseX + " " + pmouseY + " " + mouseX + " " + mouseY + "\n");
  }
  // Receive data from server
  if (c.available() > 0) {
    input = c.readString();
    input = input.substring(0, input.indexOf("\n")); // Only up to the newline
    data = int(split(input, ' ')); // Split values into an array
    // Draw line using received coords
    stroke(0);
    line(data[0], data[1], data[2], data[3]);
  }
}
