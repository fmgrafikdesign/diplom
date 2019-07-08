boolean start = true;
String serialized;
int pin = 0;
int current_laser = 0;

void keyPressed() {
  // changes the colour if the C key was pressed
  
  if (keyCode == 67)  {
    c = color(random(100), random(200, 255), random(200, 255), 192);
  }
  
  // changes the viscosity if the V key was pressed
  if (keyCode == 86)  {
    if (blob.viscosity >= 0.90) blob.viscosity = random(0.30, 0.60);
    else if (blob.viscosity < 0.60) blob.viscosity = random(0.70, 0.80);
    else blob.viscosity = random(0.90, 1.00);
  }
  
  if (keyCode == 82)  {
    blob.particles.clear();
  }
  
  if(key == ' ') {
     //blob.setTarget(mouseX, mouseY);
     
     //int laserid = int(random(0, lasers.size()));
     //println(laserid);
     //lasers.get(int(random(0, lasers.size()))).hit();
     if(current_laser >= lasers.size()) current_laser = 0;
     
     lasers.get(current_laser++).hit();
  }
  
  try {
    //enqueueMorseCode((str(key)));
    enqueueMorseCode(str(int(random(50))));
  } 
  catch (NumberFormatException e) {
    println("number input only.");
  }
}

// creates a new particle
void mousePressed() {
  //blob.particles.add(new Particle(mouseX, mouseY, c, random(0.003, 0.03)));
  if(start) {
    serialized = "lasers.add ( new Laser(" + pin + ", " + int(mouseX/scaleFactor) + ", " + int(mouseY/scaleFactor) + ", ";
     start = false; 
  } else {
     serialized += int(mouseX/scaleFactor) + ", " + int(mouseY/scaleFactor) + "));";
     start = true;
     pin++;
     //println(serialized);
  }
  //println((mouseX/scaleFactor) + " " + (mouseY/scaleFactor));
}

// creates a new particle
void mouseDragged() {
  //blob.particles.add(new Particle(mouseX, mouseY, c, random(0.003, 0.03)));
}
