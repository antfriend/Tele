/**
 * Shared Drawing Canvas (Server) 
 * by Alexander R. Galloway. 
 * 
 * A server that shares a drawing canvas between two computers. 
 * In order to open a socket connection, a server must select a 
 * port on which to listen for incoming clients and through which 
 * to communicate. Once the socket is established, a client may 
 * connect to the server and send or receive commands and data.
 * Get this program running and then start the Shared Drawing
 * Canvas (Client) program so see how they interact.
 */

//tcp server stuff ****************************************************
import processing.net.*;
Server s;
Client c;
String input;
int data[];
int the_port = 12345;
//springiness stuff ***************************************************
int window_height = 400;
int window_width = 400;
// Spring drawing constants for top bar                               *
int s_height = window_height / 10;     // Height                                      *
int left = (window_width /2) - (s_height / 2);         // Left position                               *
int right = (s_height / 2) + (window_width /2);       // Right position                              *
int max = window_height;         // Maximum Y value                             *
int min = 0;          // Minimum Y value                             *
boolean over = false;  // If mouse over                               *
boolean move = false;  // If mouse down and over                      *
//                                                                    *
// Spring simulation constants                                        *
float M = 0.2;   // Mass                                              *
float K = 0.8;   // Spring constant                                   *
float D = 0.09;  // Damping                                           *
float R = window_height / 2;    // Rest position                                     *
//                                                                    *
// Spring simulation variables                                        *
float ps = window_height / 2;; // Position                                          *
float vs = 0.0;  // Velocity                                          *
float as = 0;    // Acceleration                                      *
float f = 0;     // Force                                             *

void setup() 
{
  size(window_width, window_height);
  background(204);

  stroke(0);
  frameRate(5); // Slow it down a little
  s = new Server(this, the_port); // Start a simple server on a port
  //springiness stuff
  rectMode(CORNERS);
  noStroke();
}

void draw() 
{
  background(102);
  if (mousePressed == true) {
    // Draw our line
    stroke(255);
    line(pmouseX, pmouseY, mouseX, mouseY);
    // Send mouse coords to other person
    s.write(pmouseX + " " + pmouseY + " " + mouseX + " " + mouseY + "\n");
  }
  // Receive data from client
  c = s.available();
  if (c != null) {
    input = c.readString();
    input = input.substring(0, input.indexOf("\n")); // Only up to the newline
    data = int(split(input, ' ')); // Split values into an array
    // Draw line using received coords
    stroke(255,0,0);
    line(data[0], data[1], data[2], data[3]);
  }
  //springiness stuff  
  updateSpring();
  drawSpring();  
}


void drawSpring() 
{
  // Draw base
  //fill(0.2);
  //float b_width = 0.5 * ps + -8;
  //rect(width/2 - b_width, ps + s_height, width/2 + b_width, 150);

  // Set color and draw top bar
  if(over || move) { 
    fill(255);
  } else { 
    fill(204);
  }
  rect(left, ps, right, ps + s_height);
}


void updateSpring()
{
  // Update the spring position
  if(!move) {
    f = -K * (ps - R);    // f=-ky
    as = f / M;           // Set the acceleration, f=ma == a=f/m
    vs = D * (vs + as);   // Set the velocity
    ps = ps + vs;         // Updated position
  }
  if(abs(vs) < 0.1) {
    vs = 0.0;
  }

  // Test if mouse is over the top bar
  if(mouseX > left && mouseX < right && mouseY > ps && mouseY < ps + s_height) {
    over = true;
  } else {
    over = false;
  }
  
  // Set and constrain the position of top bar
  if(move) {
    ps = mouseY - s_height/2;
    if (ps < min) { ps = min; } 
    if (ps > max) { ps = max; }
  }
}

void mousePressed() {
  if(over) {
    move = true;
  }
}

void mouseReleased()
{
  move = false;
}
