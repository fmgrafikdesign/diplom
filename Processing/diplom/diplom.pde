import processing.sound.*;
import processing.serial.*;

// Set to 1 if it's showtime.
int production = 0;

float scaleFactor = 1.4;

Serial myPort;        // The serial port
int xPos = 1;         // horizontal position of the graph
float inByte = 0;
boolean ready = false;

/* Intensity is a measurement of how many beams are interrupted over a set of time. It increases as beams get interrupted up to a maximum of 1 and normalizes to 0 over time.*/

float intensity = 0;
float increasePerInterrupt = .20;

float seconds_to_normalize = 50.0;
float decreasePerFrame = 1 / (30.0 * seconds_to_normalize);

// Forumula to increase intensity stronger in lower areas and slower in higher areas
float increaseIntensity() {
   intensity += increasePerInterrupt / (1.0 + intensity); 
   return intensity;
}

// Formula to decrease intensity stronger in higher areas and slower in lower areas
float decreaseIntensity() {
  intensity = constrain(intensity - (decreasePerFrame / (1.0 - intensity/2)), 0, 1);
  return intensity;
}

int frameRate = 30;

boolean drawIntensity = false;

public void settings() {
  if (production == 0) {
    scaleFactor = 2;
    //    size(int(1440 * scaleFactor), int(810 *scaleFactor));
    size(1920, 1080);
  } else {
    fullScreen();
    scaleFactor = 4/3;
  }
}

void setup () {
  //size(1920, 1080);
  println(decreasePerFrame);

  setupMorseChars();
  frameRate(frameRate);

  // List all the available serial ports
  println(Serial.list());

  // Open whatever port is the one you're using. 1 on my desktop pc, will need to check for Raspberry Pi
  myPort = new Serial(this, Serial.list()[1], 19200);

  // don't generate a serialEvent() unless you get a newline character:
  myPort.bufferUntil('\n');

  // Set up the morse signal
  setupMorseSignal();

  // Initialize the lasers
  initializeLasers();
  
  // Initialize the audio tracks
  initializeTracks();


  // Set up the morse playback thread
  thread("morsePlayback");

  // Set initial background:
  background(0);
  
  ready = true;
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
  
  adjustVolume();
  
  // Compute data blob movement
  blob.handleInteractions();
  
  // moves each particle, then draws it
  for (int i = 0; i < blob.particles.size(); i++) {
    blob.particles.get(i).move();
    blob.particles.get(i).draw();
  }

  popMatrix();

  // Decrease intensity every loop
  decreaseIntensity();
  //println(intensity);
  
  if(debugDraw) debugDraw();
}

void serialEvent (Serial myPort) {
  if(!ready) return;
  
  // get the ASCII string:
  String inString = myPort.readStringUntil('\n');
  //println(inString);

  if (inString != null) {
    // trim off any whitespace:
    inString = trim(inString);
    println(inString);
    // convert to an int and map to the screen height:
    inByte = float(inString);
    //println(inByte);
    inByte = map(inByte, 0, 60, 0, height);
    
    // Activate the laser
    int pin = int(inString);
    for(int i = 0; i < lasers.size(); i++) {
      if(pin == lasers.get(i).pin) {
         lasers.get(i).hit();
         println("Found laser with pin " + pin);
         enqueueMorseCode(inString);
         break;
      }
    }
    
  }

}
