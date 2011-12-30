/***************************************************************
****************************************************************
*********************robot client*******************************
****************************************************************
****************************************************************
****adapted from...*********************************************
 * Shared Drawing Canvas (Client) 
 * by Alexander R. Galloway. 
*/
/*
added AWSD letters
version 09 has green boxes on keystrokes
*/

import processing.net.*;
String the_server_ip;
int the_port = 1234;
PFont fontA;
char letter;

Client c;
String input;
int data[];



//drawing stuff
int window_height = 200;    //this must be the same as on the server
int window_width = window_height;    //
int s_height = window_height / 10;     // diameter of the circle
int max = window_height;//  Maximum Y value                           *
int min = 0;          // Minimum Y value                              *
boolean over = false;  // If mouse over                               *
boolean move = false;  // If mouse down and over                      *
// Spring simulation constants                                        *
float M = 0.1;   // Mass                                              *
float K = 0.8;   // Spring constant                                   *
float D = 0.09;  // Damping                                           *
float R = (window_height / 2);//  Rest position                       *
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
//keyboard stuff
boolean a_key_was_pressed = false;
char the_key;

void setup() 
{
  size(window_width, window_height);
  background(204);
  stroke(0);
  frameRate(5); // Slow it down a little
  rectMode(CORNERS);
  
  String[] lines;
  lines = loadStrings("ipaddress.txt");
  the_server_ip = lines[0];//get the IP address from a file     
  // Connect to the server's IP address and port
  c = new Client(this, the_server_ip, the_port); // Replace with your server's IP and port
  
  fontA = loadFont("Algerian-36.vlw");
  textAlign(CENTER);
  textFont(fontA, 32);
}

void draw() 
{
  background(102);
  stroke(255);
  draw_background_lines();
  if (mousePressed == true) 
  {
    // Draw our line
    stroke(255);
    line(pmouseX, pmouseY, mouseX, mouseY);
    // Send mouse coords to other person
    //c.write(pmouseX + " " + pmouseY + " " + mouseX + " " + mouseY + "\n");
  }
  /*// Receive data from server
  if (c.available() > 0) {
    input = c.readString();
    input = input.substring(0, input.indexOf("\n")); // Only up to the newline
    data = int(split(input, ' ')); // Split values into an array
    px = data[0]; // X Position
    ps = data[1]; // Y Position
    // Draw box using received coords
    stroke(0);
    rect(int(px), int(ps), int(px) + s_height, ps + s_height);//draw the box ***
  }*/
    //springiness stuff  
    updateSpring();
    drawSpring(); 
    
    //if a key was pressed, intercept and replace the mouse values
    if(a_key_was_pressed)
    {
      a_key_was_pressed = false;
      fill(0,255,0);
      switch(the_key)
      {
        case 'a':
          c.write(0 + " " + 100 + "\n"); 
          println("left");
          rect(0,60,60,140);
          break;
        case 'd':
          c.write(200 + " " + 100 + "\n");
          println("right");
          rect(140,60,200,140);
          break;
        case 'w':
          c.write(100 + " " + 0 + "\n");
          println("forward");
          
          rect(60,0,140,60);
          break;
        case 's':
          c.write(100 + " " + 200 + "\n");
          println("back");
          rect(60,140,140,200);
          break;
        default:
          c.write(100 + " " + 100 + "\n");
          //don't draw
          break;
      }
      //println("px=" + int(px) + " ps=" + int(ps));
      
      //send box coordinates
      //c.write(int(px) + " " + int(ps) + "\n");     
    }
    else
    {
      //send box coordinates
      c.write(int(px) + " " + int(ps) + "\n");     
    }
}


void drawSpring() 
{
  // Set color and draw circle
  if(over || move) { 
    fill(255);
  } else { 
    fill(204);
  }
  //rect(px, ps, px + s_height, ps + s_height);//draw the box ***************************
  ellipse(px, ps, s_height, s_height);//draw the circle ***************************
}

void draw_background_lines()
{
  
  line(60, 0, 60, window_height);
  line(140, 0, 140, window_height);
  line(0, 60, window_width, 60);
  line(0, 140, window_width, 140);
  
  letter = char('W');
  text(letter, 100, 40);
  
  letter = char('A');
  text(letter, 30, 110);
  
  letter = char('S');
  text(letter, 100, 180);
  
  letter = char('D');
  text(letter, 170, 110);  
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

  // Test if mouse is over the circle
  if((mouseX < px + (s_height/2)) && (mouseX > px - (s_height/2)) && (mouseY > ps - (s_height/2)) && (mouseY < ps + (s_height/2))) 
  {
    over = true;
  } else {
    over = false;
  }
  
  // Set and constrain the position of the circle
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

void keyPressed() 
{
  //int keyIndex = -1;
  if (key >= 'a' && key <= 'z') 
  {
    //px = 
    //ps =
    a_key_was_pressed = true;
    the_key = key;
  }
}


