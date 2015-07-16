/**
 * (Loose) artistic interpretation of Large Hadron Collider ATLAS detector
 * 
 * Multiple-object collision.
 */

import java.util.*;

int maxParticles = 10000;
int numEventParticles = 30;
int numScintillators = 200;
float scintillatorRadius = 300;
int nextParticleId = 0;
int boundary = 0;
float friction = 0.9;
float bField = 0.8;
float dt = 0.02;
ArrayList<Particle> particles = new ArrayList<Particle>();
ArrayList<Scintillator> scintillators = new ArrayList<Scintillator>();

void setup() {
  size(displayWidth, displayHeight);
  colorMode(HSB, 255);
  collisionEvent();
  noStroke();
  fill(255, 204);
  for(int i = 0; i < numScintillators; i++){
    scintillators.add(new Scintillator(scintillatorRadius, TWO_PI/numScintillators * i, TWO_PI*scintillatorRadius/numScintillators));
  }
}

void draw() {
  background(0);
  //text(frameRate,20,20);
  //text(particles.size(), 20, 40);
  pushMatrix();
  translate(width/2, height/2);
  for (int i = 0; i < particles.size(); i++) {
    Particle p = particles.get(i);
    if(p.offscreen){
      particles.remove(i);
    }else{
      p.move();
      p.draw();
    }
  }
  for (int i = 0; i < scintillators.size(); i++) {
    Scintillator s = scintillators.get(i);
    s.draw();
  }
  popMatrix();
}

class Scintillator {
  float r, theta, size;
  float excitation = 0;
  
  Scintillator(float rin, float thetain, float sizein){
    r = rin;
    theta = thetain;
    size = sizein;
  }
  
  void excite(){
    excitation += 15;
  }
  
  void draw(){
    excitation *= 0.95;
    pushMatrix();
    rotate(theta);
    translate(0, r);
    rect(-size/2, 0, size, size+excitation);
    popMatrix();
  }
}

class Jet {
  
}

class Particle {
  
  public float x, y;
  float diameter;
  int q;
  float vx, vy;
  public boolean offscreen = false;
  boolean escaped = false;
 
  Particle(float xin, float yin, float vin, float anglein, float din, int qin) {
    x = xin;
    y = yin;
    vx = vin * cos(anglein);
    vy = vin * sin(anglein);
    diameter = din;
    q = qin;
  }
  
  void move() {
    //vy += gravity;
    x += vx;
    y += vy;
    
    if( pow(x, 2) + pow(y, 2) > 10000 ){
      if(q == 0){
        // Possible jet
        if(diameter > 3){
          if(random(100) < 20){
            offscreen = true;
            particles.add(new Particle(x, y, sqrt(pow(vx,2)+pow(vy,2)), atan2(vy,vx)+((10+random(10))/180*PI), diameter*0.6, q));
            particles.add(new Particle(x, y, sqrt(pow(vx,2)+pow(vy,2)), atan2(vy,vx)-((10-random(10))/180*PI), diameter*0.6, q));
          }
        }
      }else{
        // Lorentz Force
        float fx = q * bField * -vy;
        float fy = q * bField * vx;
        vx += fx * dt;
        vy += fy * dt;
      }
    }
    
    if( pow(x, 2) + pow(y, 2) > scintillatorRadius * scintillatorRadius ){
      if(escaped == false && random(100) < 30){
        float theta = atan2(y, x);
        int scintillatorId = int((theta - HALF_PI)/TWO_PI * numScintillators) % numScintillators;
        while(scintillatorId < 0){
          scintillatorId += numScintillators;
        }
        Scintillator s = scintillators.get(scintillatorId);
        s.excite();
        offscreen = true;
      }else{
        escaped = true;
      }
    }
    
    
      
      
    
    if(boundary == 0){
      if(x-diameter > width/2 || x+diameter < -width/2 || y-diameter > height/2 || y+diameter < -height/2){
        offscreen = true;
      }
    }else if(boundary == 1){
      if(x > width/2){
        x = -width/2;
      }else if(x < -width/2){
        x = width/2;
      }
      if(y > height/2){
        y = -height/2;
      }else if(y < -height/2){
        y = height/2;
      }
    }
  }
  
  void draw() {
    ellipse(x, y, diameter, diameter);
  }
}

void collisionEvent(){
  while(particles.size()+numEventParticles > maxParticles){
    particles.remove(0);
  }
  for (int i = 0; i < numEventParticles; i++) {
    particles.add(new Particle(0, 0, random(10)+10, random(2*PI), random(5, 15), ((int) random(3)) - 1));
  }
}

void keyPressed(){
  collisionEvent();
}
