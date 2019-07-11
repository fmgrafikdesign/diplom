/** This handles the visualization of the project **/

boolean debugDraw = true;

color c;

/* Data blob variables */
float _viscosity = .8; // viscosity
int _blob_distance = 25; // distance variable for the data blob. Bigger numbers = further apart
float mass_modifier = 0.55; // Quick way to modify data circle size

int min_circles_per_interruption = 5; // How many circles are spawned baseline 
int circles_per_interruption = 5; // How many circles intensity can add per interruption
float blob_distance_increase_per_interruption = 1.4;

/* Laser variables */
float opacity_increase_per_frame = 0.12;
float max_position_jitter = 2.5;
float position_jitter_threshold = 0.4;

final int A1 = 55;
final int A0 = 54;
final int A2 = 56;

final int data_spawn_variance = 7;

// Width of the room in cm
int roomWidth = 687;
int roomHeight = 250;
int roomThickness = 10;
Room room = new Room();
DataBlob blob = new DataBlob();

// Width of the room in pixel
//1660
//1080

//Laser[] lasers;
ArrayList<Laser> lasers = new ArrayList<Laser>();

void initializeLasers() {

  lasers.add ( new Laser(33, 88, 95));
  lasers.add ( new Laser(A1, 170, 150));
  lasers.add ( new Laser(3, 223, 108));
  lasers.add ( new Laser(22, 208, 198));
  lasers.add ( new Laser(31, 45, 202));
  lasers.add ( new Laser(4, roomWidth-202, 242));
  lasers.add ( new Laser(24, 98, 208));
  lasers.add ( new Laser(25, 263, 238));
  lasers.add ( new Laser(A2, 290, 305));
  lasers.add ( new Laser(A0, 356, 310));
  lasers.add ( new Laser(23, 322, 315));
  lasers.add ( new Laser(26, roomWidth-154, 300));
  lasers.add ( new Laser(28, roomWidth-214, 303));
  lasers.add ( new Laser(30, 238, 295));
  lasers.add ( new Laser(29, roomWidth-74, 380));
  lasers.add ( new Laser(27, 374, 375));
  lasers.add ( new Laser(5, 176, 410));
  lasers.add ( new Laser(6, 338, 405));
  lasers.add ( new Laser(7, roomWidth, roomHeight-150, 460, roomHeight));
  lasers.add ( new Laser(8, roomWidth-214, 457));
  lasers.add ( new Laser(9, roomWidth-39, 465));
  lasers.add ( new Laser(10, roomWidth, roomHeight-213, 494, roomHeight));
  lasers.add ( new Laser(11, roomWidth-34, 510));
  lasers.add ( new Laser(12, roomWidth-156, 0, roomWidth, roomHeight-24));
}


// A laser class, has start coordinates, end coordinates and an index
class Laser {
  PVector start = new PVector(0, 0);
  PVector end = new PVector(0, 0);
  int pin = 0;
  boolean active = false;
  PVector middle = new PVector(0, 0);
  float opacity = 1.0;
  float max_offset = 0.0;

  Laser() {
    active = false;
  }

  Laser(int _pin, int x_start, int x_finish) {
    pin = _pin;
    start = new PVector(x_start, 0);
    end = new PVector(x_finish, roomHeight);
    active = true;
    middle = PVector.sub(end, start).mult(0.5).add(start);
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
    if (intensity > position_jitter_threshold)
      max_offset = max_position_jitter * (intensity - position_jitter_threshold);
    else
      max_offset = 0.0;


    // Factor in intensity for opacity

    // Factor in recent hits for opacity
    fill(255, 0, 0, 255 * opacity);
    strokeWeight(.7);
    stroke(255, 0, 0, 255 * opacity);

    float offset_start_x = random(-max_offset, max_offset);
    float offset_start_y = random(-max_offset, max_offset);
    float offset_end_x = random(-max_offset, max_offset);
    float offset_end_y = random(-max_offset, max_offset);
    //line(start.x + offset_start_x, start.y + offset_start_y, end.x + offset_end_x, end.y + offset_end_y);
    
    // Glow
    int glow_radius = 4;
    // Lower value = less falloff
    float glow_falloff = 1.6;
    
    for(int i = 1; i <= glow_radius; i++) {
       strokeWeight(i);
       // opacity is .7 at 0 intensity and 1 at <.4 intensity
       
       stroke(255, 0, 0, 255 * opacity * (1.0/(pow(i, glow_falloff))));
       line(start.x + offset_start_x, start.y + offset_start_y, end.x + offset_end_x, end.y + offset_end_y); 
    }
    
    // Increase opacity again, up to 1
    opacity = constrain(opacity + 1.0 * opacity_increase_per_frame*opacity_increase_per_frame, 0, 1);
  }

  // Controls what happens when the laser gets interrupted
  void hit() {
    this.hitParticles();
    this.createDataCircles();

    // Turn laser off
    opacity = 0.0;

    // Increase intensity
    increaseIntensity();
    
    // Process current state, maybe play sound effect
    potentialSoundEffect();

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
    for (int i=0; i < int(circles_per_interruption * intensity) + min_circles_per_interruption; i++) {
      PVector along = PVector.sub(end, start);
      along.mult(random(0, 1));
      along.add(start);
      // Add some small variance
      along.add(new PVector(random(-data_spawn_variance, data_spawn_variance), random(-data_spawn_variance, data_spawn_variance)));

      // TODO: Factor in intensity for size

      // TODO: Factor in intensity for color?

      // 0 --> 0.003
      // 1 --> 0.03
      
      // 0.003 + intensity * 0.027 
      blob.particles.add(new Particle(along.x, along.y, c, (0.012 + intensity * 0.027 + random(0.003 * intensity )) * mass_modifier));
    }
  }
}

// A room class, consists of several basic shapes. Visualizes the room in a 2D space.
class Room {
  void drawDoors() {
    // Doors
    fill(#000000);
    //rect(10, -5, 120, 12);
    //rect(10, roomHeight-5, 120, 12);
  }
  void draw() {

    pushMatrix();
    translate(roomThickness, roomThickness);

    fill(#000000);

    // Walls
    noFill();
    stroke(#333333);
    fill(#333333);
    strokeWeight(10);
    noStroke();
    //rect(0, 0, roomWidth, roomHeight);

    // Upper Wall
    rect(-roomThickness, -roomThickness, roomWidth, roomThickness);

    // Lower Wall, save the door
    rect(-roomThickness, roomHeight, roomWidth - 100, roomThickness);

    // Left Wall, save the door
    rect(-roomThickness, -roomThickness, roomThickness, 63);
    rect(-roomThickness, 125+63, roomThickness, 63);

    // Right Wall
    rect(roomWidth - roomThickness, -roomThickness, roomThickness, roomHeight + roomThickness * 2);

    //rect(0,0, roomWidth, 0);
    //rect(0,roomHeight, roomWidth, roomHeight);
    popMatrix();
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

          float force = (dis-(blob_distance + times_activated * blob_distance_increase_per_interruption))*particles.get(j).mass/dis * (1/mass_modifier);
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
  float max_offset = 0.0;

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
    
    if (intensity > position_jitter_threshold)
      max_offset = max_position_jitter * (intensity - position_jitter_threshold) / 2;
    else
      max_offset = 0.0;
      
    fill(col);
    fill(#ffffff);
    noStroke();
    ellipse(xPos  + random(-max_offset, max_offset), yPos + random(-max_offset, max_offset), mass*300, mass*300);
  }
}


void drawLasers() {
  pushMatrix();
  translate(0, roomThickness);
  for (int i = 0; i < lasers.size(); i++) {
    if (!lasers.get(i).active()) continue;

    lasers.get(i).draw();
  }
  popMatrix();
}

void debugDraw() {
  text(intensity, 10, 10);
}
