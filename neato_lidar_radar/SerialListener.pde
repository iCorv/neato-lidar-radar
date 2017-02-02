/*
  Read serial data very fast in a own thread.
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

import processing.serial.*; //the functionality for using the Serial Port lies in a speical library. This tells Processing to use it.

public class SerialListener {
  private int arrayLength;
  private int[] measuredData;
  Serial myPort;        // Create a "serial port" object/variable. "Serial" is the type of the object (just like "int"), "myPort" is the name of the variable
  Thread t;

  SerialListener() {
    arrayLength = 360;
    measuredData = new int[arrayLength];
    for (int i = 0; i < arrayLength; i++) {
      measuredData[i] = 0;
    }
  }

  SerialListener(Serial port) {
    myPort = port;
    arrayLength = 360;
    measuredData = new int[arrayLength];
    for (int i = 0; i < arrayLength; i++) {
      measuredData[i] = 0;
    }
  }


  private class ReadSerialPort implements Runnable {
    public void run() {
      try {
        while (true) {
          for (int i = 0; i < 359; i++) {
            int[] data = readLineFromSerial(myPort);
            if (data.length==2) {
              if(data[1] < 3000) {
                measuredData[data[0]] = (int)round(data[1]/10);
              }else{
                measuredData[data[0]] = 0;
              }
            }
          }
          Thread.sleep(1);
        }
      } 
      catch (InterruptedException e) {
        threadMessage("Thread interrupted prematurely!");
      }
    }
  }
  public void startListener() throws InterruptedException {
    t = new Thread(new ReadSerialPort());
    t.start();
  }
  public void stopListener() throws InterruptedException {
    t.interrupt();
  }


  // Display a message, preceded by
  // the name of the current thread
  private void threadMessage(String message) {
    String threadName =
      Thread.currentThread().getName();
    System.out.format("%s: %s%n", 
      threadName, 
      message);
  }

  public int[] serialDataUpdate() {
    return measuredData;
  }

  // this function reads a line from the serial port and returns an array of numbers
  // multiple numbers can be received if they separated by tab stops ("\t") 
  // by courtesy of Felix Bonowski
  private int[] readLineFromSerial(Serial  port) {
    byte temp[] = port.readBytesUntil('\n'); //read data from buffer until a new line is finished
    //port.clear();
    // check if any data is available
    if (temp == null) {
      return new int[0]; //got nothing - return an empty array
    } else {
      String inBuffer= new String(temp); //convert raw data to a string
      inBuffer=trim(inBuffer); //cut off whitespace
      int[] numbers=int(split(inBuffer, "\t")); //cut into pieces at tab-stops and convert to an array of floats
      return  numbers; //return the numbers we got
    }
  }
}