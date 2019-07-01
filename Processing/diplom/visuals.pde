/** This handles the visualization of the project **/

boolean debugDraw = true;

color c;

/* Data blob variables */
float _viscosity = .8; // viscosity
int _blob_distance = 60; // distance variable for the data blob. Bigger numbers = further apart
int circles_per_interruption = 10; // How many circles an interruption spawns
float blob_distance_increase_per_interruption = 1.5;

final int data_spawn_variance = 7;

// Width of the room in cm
int roomWidth = 620;
int roomHeight = 400;

Room room = new Room();
DataBlob blob = new DataBlob();

// Width of the room in pixel
//1660
//1080

//Laser[] lasers;
ArrayList<Laser> lasers = new ArrayList<Laser>();

void initializeLasers() {

  lasers.add ( new Laser(0, 10, 5, 155, 192));
lasers.add ( new Laser(1, 234, 4, 191, 196));
lasers.add ( new Laser(2, 237, 4, 341, 195));
lasers.add ( new Laser(3, 436, 194, 308, 5));
lasers.add ( new Laser(4, 439, 193, 483, 4));
lasers.add ( new Laser(5, 525, 4, 623, 151));
lasers.add ( new Laser(6, 625, 66, 452, 193));
lasers.add ( new Laser(7, 463, 214, 625, 250));
lasers.add ( new Laser(8, 624, 262, 561, 403));
lasers.add ( new Laser(9, 609, 403, 440, 207));
lasers.add ( new Laser(10, 366, 213, 498, 401));
lasers.add ( new Laser(11, 405, 209, 307, 405));
lasers.add ( new Laser(12, 366, 403, 308, 211));
lasers.add ( new Laser(13, 241, 211, 248, 405));
lasers.add ( new Laser(14, 215, 404, 20, 211));
lasers.add ( new Laser(15, 181, 210, 9, 321));
lasers.add ( new Laser(16, 8, 403, 149, 404));
}


// A laser class, has start coordinates, end coordinates and an index
class Laser {
  PVector start = new PVector(0, 0);
  PVector end = new PVector(0, 0);
  int pin = 0;
  boolean active = false;
  PVector middle = new PVector(0, 0);

  Laser() {
    active = false;
  }

  Laser(int _pin, int x, int y, int endx, int endy) {
    pin = _pin;
    start = new PVector(x, y);
    end = new PVector(endx, endy);
    active = true;
    middle = PVector.sub(end, start).mult(0.5).add(start);
  }

  PVector getPosition() {
    return start;
  }

  PVector getEnd() {
    return end;
  }

  boolean active() {
    return active;
  }

  void draw() {
    if (!active) return;

    // Factor in intensity for jitter

    // Factor in intensity for opacity

    // Factor in recent hits for opacity


    fill(#ff0000);
    strokeWeight(.7);
    stroke(#ff0000);
    line(start.x, start.y, end.x, end.y);
  }

  // Controls what happens when the laser gets interrupted
  void hit() {
    this.hitParticles();
    this.createDataCircles();

    // TODO: Turn laser off, fade in again

    // Set target
    blob.setTarget(int(middle.x), int(middle.y));
    blob.onInterrupt();
  }

  // Creates particles at the start point
  void hitParticles() {
  }

  // Creates data circles along the laser
  void createDataCircles() {

    // Draw circles along the laser
    for (int i=0; i < circles_per_interruption; i++) {
      PVector along = PVector.sub(end, start);
      along.mult(random(0, 1));
      along.add(start);
      // Add some small variance
      along.add(new PVector(random(-data_spawn_variance, data_spawn_variance), random(-data_spawn_variance, data_spawn_variance)));

      // TODO: Factor in intensity for size

      // TODO: Factor in intensity for color?

      blob.particles.add(new Particle(along.x, along.y, c, random(0.003, 0.03)));
    }
  }
}

// A room class, consists of several basic shapes. Visualizes the room in a 2D space.
class Room {
  void drawDoors() {
    // Doors
    fill(#000000);
    rect(10, -5, 120, 12);
    rect(10, roomHeight-5, 120, 12);
  }
  void draw() {

    fill(#000000);

    // Walls
    noFill();
    stroke(#333333);
    strokeWeight(10);
    //rect(0, 0, roomWidth, roomHeight);
    
    rect(0,0, 5, roomHeight);
    rect(roomWidth - 5, 0, 5, roomHeight -5);
    
    // Leave space for doors
    rect(120,0, roomWidth, 5);
    rect(120,roomHeight -5, roomWidth, 5);

    // Elements
    fill(#333333);
    noStroke();
    rect(0, roomHeight/2 - 15, roomWidth*3/4, 30);

    
  }
}


class DataBlob {

  ArrayList<Particle> particles = new ArrayList<Particle>();
  int targetx = 300;
  int targety = 300;
  float viscosity = _viscosity;
  int blob_distance = _blob_distance;
  int times_activated = 0;

  void handleInteractions() {
    for (int i = 0; i < particles.size(); i++) {
      float accX = 0; 
      float accY = 0;

      // particle interaction
      for (int j = 0; j < particles.size(); j++) {
        if (i != j) {
          float x = particles.get(j).xPos - particles.get(i).xPos;
          float y = particles.get(j).yPos - particles.get(i).yPos;
          float dis = sqrt(x*x+y*y);
          if (dis < 0.01) dis = 0.01;

          float force = (dis-(blob_distance + times_activated * blob_distance_increase_per_interruption))*particles.get(j).mass/dis;
          accX += force * x;
          accY += force * y;
          /*
          // Draw lines for close particles
           if(dis < min(3 * times_activated, 20)) {
           strokeWeight(.4);
           stroke(#ffffff);
           line( particles.get(j).xPos, particles.get(j).yPos, particles.get(i).xPos, particles.get(i).yPos);
           }*/
        }      

        // Target position interaction
        float x = targetx - particles.get(i).xPos;
        float y = targety - particles.get(i).yPos;
        float dis = sqrt(x*x+y*y);

        // adds a dampening effect
        if (dis < 40) dis = 40;
        if (dis > 50) dis = 50;


        float force = (dis-40)/(10*dis);
        force = dis/8000;
        accX += force * x;
        accY += force * y;
      }
      particles.get(i).xVel = particles.get(i).xVel * viscosity + accX * particles.get(i).mass;
      particles.get(i).yVel = particles.get(i).yVel * viscosity + accY * particles.get(i).mass;
    }
  }

  void setTarget(int x, int y) {
    targetx = x;
    targety = y;
  }

  void onInterrupt() {
    incrementTimesActivated();
  }

  void incrementTimesActivated() {
    times_activated++;
  }
}

class Particle {

  float xPos;
  float yPos;
  float xVel = 0;
  float yVel = 0;
  color col = color(235, 128, 64);

  // TODO: Make dependant on intensity and maybe number of times this laser was triggered already
  float mass = random(0.003, 0.03);

  Particle(float x, float y, color c, float _mass) {
    xPos = x;
    yPos = y;
    col = c;
    mass = _mass;
  }

  void move() {
    xPos += xVel;
    yPos += yVel;
  }

  void draw() {
    fill(col);
    fill(#ffffff);
    noStroke();
    ellipse(xPos, yPos, mass*300, mass*300);
  }
}


void drawLasers() {
  for (int i = 0; i < lasers.size(); i++) {
    if (!lasers.get(i).active()) continue;

    lasers.get(i).draw();
  }
}
