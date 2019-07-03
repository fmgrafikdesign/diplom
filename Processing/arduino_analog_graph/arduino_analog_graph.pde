/* This sketch visualizes serial data from the corresponding arduino serial connection */

import processing.serial.*;


Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float inByte = 0;
int[] pins = new int[16];
int pin = 0;

void setup () {
  size(1200, 600);
  // List all the available serial ports
  println(Serial.list());
  // Open whatever port is the one you're using. 1 on my desktop pc, will need to check for Raspberry Pi
  myPort = new Serial(this, Serial.list()[1], 19200);

  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');

  // Set initial background:
  background(0);
  delay(100);
}

void draw () {

  background(#000000);
  color(#ffffff);
  stroke(#ffffff);

  textSize(14);
  textAlign(CENTER, BOTTOM);
  rectMode(CORNERS);
  int columnwidth = 26;
  int spacing = 6;
  pushMatrix();
  translate(80, height-30);
  
  fill(120, 0, 0, 120);
  rect(0, 0, width, -300);
  
  fill(120, 120, 0, 120);
  rect(0, -300, width, -400);
  
  fill(0, 120, 0, 120);
  rect(0, -400, width, -512);
  
  line(-10, 0, width - 10, 0);
  line(0, 0, 0, -height + 40);
  stroke(#777777);
  fill(#ffffff);
  
  //1023 marker
  guideline(1023);
  guideline(1000);
  guideline(800);
  guideline(600);
  guideline(400);
  guideline(200);
  
  
  //1000 marker
  line(-30, 1000 / 2, width, 1000 / 2);
  
  //600 marker
  line(-30, 600/2, width, 600/2);
  
  for (int i = 0; i < pins.length; i++) {
    stroke(#ffffff);
    pushMatrix();
    translate(i * columnwidth, 0);
    line(0, 0, 0, 10);
    line(columnwidth, 0, columnwidth, -10);
    fill(#ffffff);
    text(i, columnwidth / 2, 20);

    int value = pins[i];
    //value = int(random(0, 1023));
    if (value >= 1000) fill(0, 255, 0);
    else if (value > 800) fill(0, 180, 0);
    else if (value > 600) fill(80, 128, 0);
    else if (value > 400) fill (128, 0, 0);
    else fill(255, 0, 0);
    noStroke();
    rect(spacing/2, 0, columnwidth - spacing/2, -value/2);

    popMatrix();
  }
  popMatrix();
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  //println(inString);

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    String[] info = split(inString, ",");
    //println(info);
    //println(info[0]);
    for(int i = 0; i < info.length; i++) {
      pins[i] = int(info[i]);
      //pin = int(info[i]);
    }
    //pins[1] = 110;
    //pins[int(info[0])] = int(info[1]);

  }
}

void guideline(int height) {
  stroke(#777777);
  fill(#ffffff);
  
  //1023 marker
  line(-30, -height / 2, width, -height/2);
  text(str(height), -50, -height/2);
}
