/***************************************************************
 ****************************************************************
 *****************  Telerobot                ********************
 ****************************************************************
 ****************************************************************
 
 _10 while I haven't done anything yet, the intention is that...
 * version 10 adds support for obstacle avoiding arduino
 * And a better-maintained connection to the arduino, which seems to
 drop-out occassionally
 * And to send responses back to the client on network status and 
 proximity sensors
 
 ****** version 1 was
 ****** adapted from... *****************************************/
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

import processing.serial.*;
import cc.arduino.*;
//tcp server stuff ****************************************************
import processing.net.*;
Server s;
Client c;
String input;
int data[];
int the_port = 1234;
//springiness stuff ***************************************************
int window_height = 200;    //this must be the same as on the client  *
int window_width = window_height;  //                                 *
int s_height = window_height / 10;     // Height                      *
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
int motors_x;
int motors_y;
//Arduino Stuff
Arduino arduino;
//////////////////////////////////
int Right_Reverse_Pin = 3;
int Right_Forward_Pin = 5;
int Left_Reverse_Pin = 6;
int Left_Forward_Pin = 9;
//////////////////////////////////
int Enable_Motors_Pin = 2;
int LED_Pin = 13;
boolean full_speed = false;

void setup() 
{
  size(window_width, window_height);
  background(204);
  stroke(0);
  frameRate(10); // Slow it down a little
  s = new Server(this, the_port); // Start a simple server on a port
  //springiness stuff
  rectMode(CORNERS);
  noStroke();
  //Arduino Stuff
  String[] lines;
  int the_serial_index;
  lines = loadStrings("serial_index.txt");
  the_serial_index = int(lines[0]);
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[the_serial_index], 57600);
  Stop_Motors();
  arduino.pinMode(LED_Pin, Arduino.OUTPUT);
  Set_Motor_Pins_to_Output();
  arduino.pinMode(Enable_Motors_Pin, Arduino.OUTPUT);
  //arduino.digitalWrite(LED_Pin, Arduino.HIGH);
  Stop_Motors();
}

void Set_Motor_Pins_to_Output()
{
  arduino.pinMode(Left_Forward_Pin, Arduino.OUTPUT);
  arduino.pinMode(Left_Reverse_Pin, Arduino.OUTPUT);
  arduino.pinMode(Right_Forward_Pin, Arduino.OUTPUT);
  arduino.pinMode(Right_Reverse_Pin, Arduino.OUTPUT); 
}

void Stop_Motors()
{
  arduino.digitalWrite(Enable_Motors_Pin, Arduino.LOW);
  arduino.digitalWrite(Left_Forward_Pin, Arduino.LOW);
  arduino.digitalWrite(Left_Reverse_Pin, Arduino.LOW);
  arduino.digitalWrite(Right_Forward_Pin, Arduino.LOW);
  arduino.digitalWrite(Right_Reverse_Pin, Arduino.LOW);
  arduino.digitalWrite(LED_Pin, Arduino.LOW);
}
void draw() 
{
  boolean deBug = true;//Set to true to debug, false to catch all errors(for running in production)
  if (!deBug)
  {
    //I've found that network disruptions can cause a crash in many locations in this code, so
    //the whole draw() loop is in one big try catch statement
    //if there is any error, the catch statement will attempt to stop the motors
    //then we will continue looping until something works
    try {
      do_draw();
    } 
    catch (Throwable t) {
      //stop the motors
      background(0);//set the background to black as an indicator
      Stop_Motors();
      println(t);
      if(t.toString() == "java.lang.NullPointerException")
      {
        println("HURRAY!!! it was a NullPointerException!!!");
      }
    }
  }
  else
  {
    do_draw();
  }
}

void do_draw() 
{
  background(102);
  stroke(255);
  draw_background_lines();
  //network server stuff
  if (mousePressed == true) {
    // Draw our line
    stroke(255);
    line(pmouseX, pmouseY, mouseX, mouseY);

    // Send mouse coords to other person
    //s.write(pmouseX + " " + pmouseY + " " + mouseX + " " + mouseY + "\n");
  }

  // Receive data from client
  c = s.available(); //this line will raise a NullPointerException if the port number is unacceptable
  if (c != null) 
  {
    input = c.readString();//the next line crashes a lot on network drop outs
    input = input.substring(0, input.indexOf("\n")); // Only up to the newline
    data = int(split(input, ' ')); // Split values into an array

    px = data[0]; // X Position
    ps = data[1]; // Y Position

    //springiness stuff  
    //updateSpring();
    drawSpring();

    //Arduino stuff
    //px,ps range from 0 - 200
    //translate these into forward, reverse, left and right conditions
    motors_x = int(px) - 100;//assumes a window of 200, ranges from -100 to +100
    motors_y = int(ps) - 100;//assumes a window of 200, ranges from -100 to +100
    //   | -100 | 0 | 100 |  x y
    //   |   A  | B |  C  |  -100   
    //   |   D  | E |  F  |    0
    //   |   G  | H |  I  |   100
    //println("motors_x=" + motors_x);
    
    // CASE A
    if ((motors_x < -40) && (motors_y < -40))
    {
      Stop_Motors();
      println("case A");
    }
    // CASE B **********forward!****************
    if ((motors_x >= -40) && (motors_x <= 40) && (motors_y < -40))
    {
      arduino.digitalWrite(Enable_Motors_Pin, Arduino.HIGH);
      arduino.digitalWrite(LED_Pin, Arduino.HIGH);
      arduino.digitalWrite(Left_Reverse_Pin, Arduino.LOW);
      arduino.digitalWrite(Right_Reverse_Pin, Arduino.LOW);
      if (full_speed)
      {
        arduino.pinMode(Left_Forward_Pin, Arduino.HIGH);
        arduino.pinMode(Right_Forward_Pin, Arduino.HIGH);         
        arduino.digitalWrite(Left_Forward_Pin, Arduino.HIGH);
        arduino.digitalWrite(Right_Forward_Pin, Arduino.HIGH);
      }
      else
      {
        if(motors_y < -95)
        {
          arduino.pinMode(Left_Forward_Pin, Arduino.HIGH);
          arduino.pinMode(Right_Forward_Pin, Arduino.HIGH); 
          arduino.digitalWrite(Left_Forward_Pin, Arduino.HIGH);
          arduino.digitalWrite(Right_Forward_Pin, Arduino.HIGH); 

          //println("case B full = " + motors_y);
        }
        else
        {
          // *** run for a duration of a second (rather than analogWrite)
          arduino.analogWrite(Left_Forward_Pin, int(map(motors_y, 0, -100, 0, 255)));
          arduino.analogWrite(Right_Forward_Pin, int(map(motors_y, 0, -100, 0, 255)));
        }
      }
      //println("case B = " + motors_y);
    }

    // CASE C
    if ((motors_x > 40) && (motors_y < -40))
    {
      Stop_Motors();
      println("case C");
    }
    // CASE D **********left!****************
    if ((motors_x < -40) && (motors_y >= -40) && (motors_y <= 40))
    {
      arduino.digitalWrite(Enable_Motors_Pin, Arduino.HIGH);
      arduino.digitalWrite(LED_Pin, Arduino.HIGH);
      arduino.digitalWrite(Left_Forward_Pin, Arduino.LOW);
      arduino.digitalWrite(Right_Reverse_Pin, Arduino.LOW);
      if (full_speed)
      {
        arduino.pinMode(Left_Reverse_Pin, Arduino.HIGH);
        arduino.pinMode(Right_Forward_Pin, Arduino.HIGH);
        arduino.digitalWrite(Left_Reverse_Pin, Arduino.HIGH);
        arduino.digitalWrite(Right_Forward_Pin, Arduino.HIGH);
      }
      else
      {
        if(motors_x < -95)
        {
          arduino.pinMode(Left_Reverse_Pin, Arduino.HIGH);
          arduino.pinMode(Right_Forward_Pin, Arduino.HIGH);
          arduino.digitalWrite(Left_Reverse_Pin, Arduino.HIGH);
          arduino.digitalWrite(Right_Forward_Pin, Arduino.HIGH);
        }
        else
        {
          // *** run for a duration of a second (rather than analogWrite)
          /*
          arduino.analogWrite(Left_Reverse_Pin, int(map(motors_x, 0, -100, 0, 255)));
          arduino.analogWrite(Right_Forward_Pin, int(map(motors_x, 0, -100, 0, 255)));
          */
          arduino.pinMode(Left_Reverse_Pin, Arduino.HIGH);
          arduino.pinMode(Right_Forward_Pin, Arduino.HIGH);
          arduino.digitalWrite(Left_Reverse_Pin, Arduino.HIGH);
          arduino.digitalWrite(Right_Forward_Pin, Arduino.HIGH);
          delay(250);
          arduino.digitalWrite(Left_Reverse_Pin, Arduino.LOW);
          arduino.digitalWrite(Right_Forward_Pin, Arduino.LOW);
          delay(250);         
        }
      }
      //println("case D = " + motors_x);
    }

    // CASE E
    if ((motors_x >= -40) && (motors_x <= 40) && (motors_y >= -40) && (motors_y <= 40))
    {
      Stop_Motors();
      //println("homeE");
    }
    // CASE F **********right!****************
    if ((motors_x > 40) && (motors_y >= -40) && (motors_y <= 40))
    {
      arduino.digitalWrite(Enable_Motors_Pin, Arduino.HIGH);
      arduino.digitalWrite(LED_Pin, Arduino.HIGH);
      arduino.digitalWrite(Left_Reverse_Pin, Arduino.LOW);
      arduino.digitalWrite(Right_Forward_Pin, Arduino.LOW);
      if (full_speed)
      {
        arduino.pinMode(Left_Forward_Pin, Arduino.HIGH);
        arduino.pinMode(Right_Reverse_Pin, Arduino.HIGH);          
        arduino.digitalWrite(Left_Forward_Pin, Arduino.HIGH);
        arduino.digitalWrite(Right_Reverse_Pin, Arduino.HIGH);
      }
      else
      {
        if(motors_x > 95)
        {
          arduino.pinMode(Left_Forward_Pin, Arduino.HIGH);
          arduino.pinMode(Right_Reverse_Pin, Arduino.HIGH);          
          arduino.digitalWrite(Left_Forward_Pin, Arduino.HIGH);
          arduino.digitalWrite(Right_Reverse_Pin, Arduino.HIGH);
        }
        else
        {
          // *** run for a duration of a second (rather than analogWrite)
          /*
          arduino.analogWrite(Left_Forward_Pin, int(map(motors_x, 0, 100, 0, 255)));
          arduino.analogWrite(Right_Reverse_Pin, int(map(motors_x, 0, 100, 0, 255)));
          */
          arduino.pinMode(Left_Forward_Pin, Arduino.HIGH);
          arduino.pinMode(Right_Reverse_Pin, Arduino.HIGH);          
          arduino.digitalWrite(Left_Forward_Pin, Arduino.HIGH);
          arduino.digitalWrite(Right_Reverse_Pin, Arduino.HIGH);
          delay(250);
          arduino.digitalWrite(Left_Forward_Pin, Arduino.HIGH);
          arduino.digitalWrite(Right_Reverse_Pin, Arduino.HIGH); 
          delay(250);         
        }
      }
      //println("case F = " + motors_x);
    }

    // CASE G
    if ((motors_x < -40) && (motors_y > 40))
    {
      Stop_Motors();
      println("case G");
    }
    // CASE H **********backward!****************
    if ((motors_x >= -40) && (motors_x <= 40) && (motors_y > 40))
    {
      arduino.digitalWrite(Enable_Motors_Pin, Arduino.HIGH);
      arduino.digitalWrite(LED_Pin, Arduino.HIGH);
      arduino.digitalWrite(Left_Forward_Pin, Arduino.LOW);
      arduino.digitalWrite(Right_Forward_Pin, Arduino.LOW);
      if (full_speed)
      {
        arduino.pinMode(Left_Reverse_Pin, Arduino.HIGH);
        arduino.pinMode(Right_Reverse_Pin, Arduino.HIGH);          
        arduino.digitalWrite(Left_Reverse_Pin, Arduino.HIGH);
        arduino.digitalWrite(Right_Reverse_Pin, Arduino.HIGH);
      }
      else
      {
        if(motors_y > 95)
        {
          arduino.pinMode(Left_Reverse_Pin, Arduino.HIGH);
          arduino.pinMode(Right_Reverse_Pin, Arduino.HIGH);          
          arduino.digitalWrite(Left_Reverse_Pin, Arduino.HIGH);
          arduino.digitalWrite(Right_Reverse_Pin, Arduino.HIGH);
        }
        else
        {
          // *** run for a duration of a second (rather than analogWrite)
          arduino.analogWrite(Left_Reverse_Pin, int(map(motors_y, 0, 100, 0, 255)));
          arduino.analogWrite(Right_Reverse_Pin, int(map(motors_y, 0, 100, 0, 255)));
        }
      }
      //println("case H = " + motors_y);
    }

    // CASE I
    if ((motors_x > 40) && (motors_y > 40))
    {
      Stop_Motors();
      println("case I");
    }
    //send box coordinates
    //s.write(int(px) + " " + int(ps) + "\n");
  }
  else
  {
    //no signal recieved
    //Stop_Motors(); //I think we want to stop motors, but must make above cases work first
    Stop_Motors();
  }
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
  } 
  else { 
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
  } 
  else {
    over = false;
  }

  // Set and constrain the position of top bar
  if(move) {
    ps = mouseY; // - s_height/2;
    if (ps < min) { 
      ps = min;
    } 
    if (ps > max) { 
      ps = max;
    }
    px = mouseX;// - s_height/2;
    if (px < min) { 
      px = min;
    }
    if (px > max) { 
      px = max;
    }
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

