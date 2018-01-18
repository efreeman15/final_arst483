import processing.serial.*;

PGraphics screen, drawing;
ArrayList particles = new ArrayList();
ParticleSystem ps;
String mic;
Serial myPort; 
float partsize = 40;
float bg = 100;

void setup() {
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 9600);
  myPort.clear();
  // Throw out the first reading, in case we started reading 
  // in the middle of a string from the sender.
  mic = myPort.readStringUntil(10);
  mic = null;
  fullScreen();
  noStroke();
  screen = createGraphics(width, height);
  drawing = screen;
  ps = new ParticleSystem(new PVector(random(0, width), random(0, height)));
}

void draw() {
  while (myPort.available() > 0) {
    mic = myPort.readStringUntil(10);
    if (mic != null) {
      println(mic);
      mic = trim(mic);
    }
    fire();
  }
}

void fire() {
  screen.beginDraw();
  ps.addParticle();
  back();
  ps.run();
  screen.endDraw();
  image(screen, 0, 0);
}

void back() {
  if (mic != null) {
    bg = float(trim(mic));
  } else {
    bg = .1;
  }
  if (bg < .1) {
    save("noise" + str(bg));
  }
  screen.background(0, 100*bg, 1000*bg, 50);
}
class ParticleSystem {
  ArrayList<Particle> particles;
  PVector origin;

  ParticleSystem(PVector position) {
    origin = position.copy();
    particles = new ArrayList<Particle>();
  }

  void addParticle() {
    particles.add(new Particle(origin));
  }

  void run() {
    for (int i = particles.size()-1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.run();
      if (p.isDead()) {
        particles.remove(i);
      }
    }
  }
}


// A simple Particle class

class Particle {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float lifespan;
  float partsize = 30;
  float decrease = 2;


  Particle(PVector l) {
    position = l.copy();
    acceleration = new PVector(random(-.1, .2), random(-.1, .1));
    velocity = new PVector(random(-1, 0), random(-2, 0));;
    lifespan = 255.0;
  }

  void run() {
    update();
    display();
  }

  // Method to update position
  void update() {
    velocity.sub(acceleration);
    lifespan -= 1.0;
    partsize += .55;
    if (partsize<=3) {
      lifespan = -1;
    }
  }

  // Method to display
  void display() {
    if (mic == null) {
      partsize = .1;
    } else {
      partsize = float(trim(mic));
      println(float(trim(mic)));
    }
    stroke(255, lifespan*2);
    strokeWeight(partsize*2);
    partsize = partsize/decrease;
    noFill();
    ellipse(position.x, position.y, partsize*2000, partsize*2000);
  }

  boolean isDead() {
    if (lifespan < 0.0) {
      return true;
    } else {
      return false;
    }
  }
}