import processing.serial.*;

// Set to 1 if it's showtime.
int production = 1;

float scaleFactor = 1.4;

Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float inByte = 0;

/* Intensity is a measurement of how many beams are interrupted over a set of time. It increases as beams get interrupted up to a maximum of 1 and normalizes to 0 over time.*/

float intensity = 0;
float increasePerInterrupt = .08;
float decreasePerFrame = .003;
int frameRate = 30;

boolean drawIntensity = false;

public void settings() {
  if (production == 0) {
    scaleFactor = 1.0;
    size(int(728 * scaleFactor), int(410 *scaleFactor));
  } else {
    fullScreen();
    scaleFactor = 2.635;
  }
}

void setup () {
  //size(1920, 1080);

  setupMorseChars();
  frameRate(frameRate);

  // List all the available serial ports
  println(Serial.list());

  // Open whatever port is the one you're using. 1 on my desktop pc, will need to check for Raspberry Pi
  myPort = new Serial(this, Serial.list()[0], 19200);

  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');

  // Set up the morse signal
  setupMorseSignal();

  // Initialize the lasers
  initializeLasers();


  // Set up the morse playback thread
  thread("morsePlayback");

  // Set initial background:
  background(0);
}

void draw () {

  background(#000000);
  pushMatrix();
  scale(scaleFactor);
  translate(5, 5);



  noStroke();
  // Basic room shape
  fill(#000000);
  rect(0, 0, roomWidth, roomHeight);
  
  room.drawDoors();
  drawLasers();
  room.draw();
  
  // Compute data blob movement
  blob.handleInteractions();
  
  // moves each particle, then draws it
  for (int i = 0; i < blob.particles.size(); i++) {
    blob.particles.get(i).move();
    blob.particles.get(i).draw();
  }

  popMatrix();

  // Decrease intensity every loop
  intensity = constrain(intensity - decreasePerFrame, 0, 1);
  //println(intensity);
}

void serialEvent (Serial myPort) {
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  //println(inString);

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    println(inString);
    enqueueMorseCode(inString);
    // convert to an int and map to the screen height:
    inByte = float(inString);
    //println(inByte);
    inByte = map(inByte, 0, 60, 0, height);
  }

  // TODO: Create morse code out of the pin number

  // Increase intensity
  intensity = constrain(intensity + increasePerInterrupt, 0, 1);
}
