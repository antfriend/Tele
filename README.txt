/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////    Telepresence Robot   ///////////////////////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
                                  |
  +-------------------------------+
  |
  Download, Install, and Set-Up software:
     |
     +-Get the zip from github: https://github.com/antfriend/Tele/zipball/master
     |
     +-Run just the compiled client:
     |   |
     |   +-from download/exctraction location, go to folder: [root location]\Tele_Client\application.windows
     |     and edit the file, "IPv4-Address.txt" - changing the first line to the computer name or IP address of the robot server machine. 
     |     Use the default value (127.0.0.1
) for local testing of client and server on one machine.
     |     Run Tele_Client.exe
     |
     |
     +-*OR* use The full source:
        |
        +-Load the StandardFirmatta libarary onto your arduino from the Arduino examples
        |
        +-Set Up Processing Arduino Firmatta library:
        |   http://www.arduino.cc/playground/Interfacing/Processing
        |     Follow instructions for getting Firmatta set up.  
        |       Use the example, "Libraries\arduino\arduino_output" to test your set up.
        |
        |
        |
        |