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
String the_server_ip;// = "127.0.0.1";//@self
//String the_server_ip = "10.2.40.148";//@work 10.2.40.184
//String the_server_ip = "192.168.0.5";//@home
int the_port = 12345;

Client c;
String input;
int data[];


//drawing stuff
int window_height = 200;    //this must be the same as on the server
int window_width = window_height;    //
int s_height = window_height / 10;     // Height
//int ps = window_height / 2; // X Position
//int px = window_width / 2; // Y Position
int max = window_height;// - s_height;         // Maximum Y value        *
int min = 0;          // Minimum Y value                              *
boolean over = false;  // If mouse over                               *
boolean move = false;  // If mouse down and over                      *
//                                                                    *
// Spring simulation constants                                        *
float M = 0.1;   // Mass                                              *
float K = 0.8;   // Spring constant                                   *
float D = 0.09;  // Damping                                           *
float R = (window_height / 2);// - (s_height / 2);  // Rest position     *
//                                                                    *
// Y Spring simulation variables                                      *
float ps = window_height / 2; // Y Position                           *
float vs = 0.0;  // Velocity                                          *
float as = 0;    // Acceleration                                      *
float f = 0;     // Force                                             *
// X Spring simulation variables                                      *
float px = window_width / 2; // X Position                            *
float vx = 0.0;  // Velocity                                          *
float ax = 0;    // Acceleration                                      *
float fx = 0;     // Force   *

void setup() 
{
  size(window_width, window_height);
  background(204);
  stroke(0);
  frameRate(5); // Slow it down a little
  
  String[] lines;
  lines = loadStrings("ipaddress.txt");
  
  the_server_ip = lines[0];//get the IP address from a file
  
  
   
  // Connect to the server's IP address and port
  c = new Client(this, the_server_ip, the_port); // Replace with your server's IP and port
  rectMode(CORNERS);
  
}

void draw() 
{
  background(102);
  stroke(255);
  draw_background_lines();
  if (mousePressed == true) {
    // Draw our line
    stroke(255);
    line(pmouseX, pmouseY, mouseX, mouseY);
    // Send mouse coords to other person
    //c.write(pmouseX + " " + pmouseY + " " + mouseX + " " + mouseY + "\n");
  }
  // Receive data from server
  if (c.available() > 0) {
    input = c.readString();
    input = input.substring(0, input.indexOf("\n")); // Only up to the newline
    data = int(split(input, ' ')); // Split values into an array
    px = data[0]; // X Position
    ps = data[1]; // Y Position
    // Draw box using received coords
    stroke(0);
    rect(int(px), int(ps), int(px) + s_height, ps + s_height);//draw the box ***
 
    
  }
    //springiness stuff  
    updateSpring();
    drawSpring(); 
    //send box coordinates
    c.write(int(px) + " " + int(ps) + "\n");     
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
  //rect(px, ps, px + s_height, ps + s_height);//draw the box ***************************
  ellipse(px, ps, s_height, s_height);//draw the box ***************************
}

void draw_background_lines()
{
  line(60, 0, 60, window_height);
  line(140, 0, 140, window_height);
  line(0, 60, window_width, 60);
  line(0, 140, window_width, 140);
}

void updateSpring()
{
  // Update the spring position
  if(!move) {
    //set Y values
    f = -K * (ps - R);    // f=-ky
    as = f / M;           // Set the acceleration, f=ma == a=f/m
    vs = D * (vs + as);   // Set the velocity
    if(abs(vs) < 0.1) {
      vs = 0.0;
     }
    ps = ps + vs;         // Updated Y position
    //set X values
    f = -K * (px - R);    // f=-ky
    ax = f / M;           // Set the acceleration, f=ma == a=f/m
    vx = D * (vx + ax);   // Set the velocity
    if(abs(vx) < 0.1) {
      vx = 0.0;
     }
    px = px + vx;         // Updated Y position
  }

  // Test if mouse is over the top bar
  if((mouseX < px + (s_height/2)) && (mouseX > px - (s_height/2)) && (mouseY > ps - (s_height/2)) && (mouseY < ps + (s_height/2))) 
  {
    over = true;
  } else {
    over = false;
  }
  
  // Set and constrain the position of top bar
  if(move) {
    ps = mouseY;// - s_height/2;
    if (ps < min) { ps = min; } 
    if (ps > max) { ps = max; }
    px = mouseX;// - s_height/2;
    if (px < min) { px = min; }
    if (px > max) { px = max; } 
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




