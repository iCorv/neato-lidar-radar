/*
  Display distance measurements as a radar picture in Processing.
  Created 2017 by Arne C. Jaedicke
  -------------------------------------------------------------------------------------
  The MIT License

  Copyright (c) 2017 Arne C. Jaedicke

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.
*/

import processing.serial.*; 
Serial myPort;        
SerialListener mySerialListener;
int x_M; //window center in x-direction
int y_M; //window center in y-direction

int arrayLength = 360;
int[] measuredData = new int[arrayLength];


//this function gets called at the beginnign of the program
void setup () {
  for (int i = 0; i<arrayLength; i++) {
    measuredData[i] = 0;
  }
  // Initialze Serial communication. There may be multiple serial ports on your computer, so we have to select one:
  String[] portNames=Serial.list(); //Serial.list() returns an array of port names
  println(portNames);  //print them to the user
  // initialize the Serial port Object using the last name from the list and a Baudrate of 115200
  myPort = new Serial(this, portNames[portNames.length-1], 115200);
  mySerialListener = new SerialListener(myPort);
  try {
    mySerialListener.startListener();
  }
  catch (InterruptedException e) {
    print("shitshitshit thread dead");
  }
  // Set up the screen:
  size(900, 700, P2D); // set size of the window
  background(0);// set  background color to black
  stroke(255); // set the color of things we draw to white
  x_M = width/2;
  y_M = height/2;
  // make the loop run as fast as it can so we dont loose any data
  frameRate(30);
  drawBackground();
}

//this function is called continously, just as "loop" in arduino
void draw () {
  measuredData = mySerialListener.serialDataUpdate();

  drawBackground();
  drawCenter();
  for (int i = 0; i<arrayLength; i++) {
    
    drawDistance(arrayLength-i, measuredData[i]);
  }
  
}


void drawDistance(int pos, float dist) {
  color c = color(255, 204, 0);  // Define RGB color 'c'
  stroke(c);
  fill(c);
  // x = r * cos(phi), y = r * sin(phi)
  // use radian measure
  int x = round(x_M + dist * cos(PI/180*pos));
  int y = round(y_M + dist * sin(PI/180*pos));

  ellipse(x, y, 5, 5);
}


void drawBackground() {
  // Using only one value with color()
  // generates a grayscale value.
  color c = color(65);  // Define 'c' with grayscale value
  background(c);  // 'c' as background color
  noFill();
  stroke(255);
  ellipse(x_M, y_M, 100, 100);
  ellipse(x_M, y_M, 200, 200);
  ellipse(x_M, y_M, 300, 300);
  ellipse(x_M, y_M, 400, 400);
  ellipse(x_M, y_M, 500, 500);
  line(x_M - 250, y_M, x_M + 250, y_M);
  line(x_M, y_M - 250, x_M, y_M + 250);
}

void drawCenter() {
  color c = color(20, 204, 0);  // Define RGB color 'c'
  fill(c);  // Use color variable 'c' as fill color
  noStroke();  // Don't draw a stroke around shapes
  ellipse(x_M, y_M, 10, 10);  // Draw left circle
}

void stop() {
  try {
    mySerialListener.stopListener();
  }
  catch (InterruptedException e) {
    print("shitshitshit thread dead");
  }
} 