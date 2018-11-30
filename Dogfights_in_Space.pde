/*
torus topology
heat damage nerf
not all weapons

[] screen centers on winner after kill
[] finite matches (i.e. 3 lives each)
[] menu screen: 
  [] loadout selection: speed, armor, power generator, gear, coolant
  [] map: inifinite, torus
  [] select gameplay elements ( asteroids, drops )
  [] control selection
[]asteroids, crates, neutral|hostile ships
[] controller support
[] speed boost power, blink
[] down key = reverse | inertial dampner
[] fuel injector: huge power gen rate, huge heat
[] change that awful heat effect to a circular one, or just use blur
*/

import org.gamecontrolplus.gui.*;
import org.gamecontrolplus.*;
import net.java.games.input.*;

ControlIO control;
//Configuration config;
ControlDevice gpad1, gpad2;


String[][] IN = { {"Eixo Y", "Eixo X", "Rotação Z", "Eixo Z", "cooliehat: Botão de ângulo de visão", 
                   "Botão 0", "Botão 1", "Botão 2", "Botão 3", "Botão 4", "Botão 5", "Botão 6", "Botão 7", 
                   "Botão 8", "Botão 9", "Botão 10", "Botão 11"},
                  {"Rotação Z", "Eixo Z", "Eixo Y", "Eixo X", "Botão 0", "Botão 1", "Botão 2", "Botão 3", 
                   "Botão 4", "Botão 5", "Botão 6", "Botão 7", "Botão 8", "Botão 9", "Botão 10", "Botão 11", 
                   "Botão 12", "cooliehat: Botão de ângulo de visão"} };
/*int gpf( int GP, int i ){
  if( GP == 1 ){
    if( i == 0 ) return 2;
    else if( i == 1 ) return 3;
    else if( i == 2 ) return 0;
    else if( i == 3 ) return 1;
    else if( i == 4 ) return 17;
    else if( i >= 5 && i <= 16 ) return i-1;
    else return i;
  }
  else return i;
}*/
/*  
0 5 triangulo
1 6 bola
2 7 X
3 8 quadrado
4 9 L1
5 10 R1
6 11 L2
7 12 R2
8 13 select
9 14 start
10 15 L3
11 16 R3
*/
float G = 100, inertia = 0.98, th = 0.2, tr = PI/50f, ss = th*180 ; // THrust, TurnRate, ShotSpeed
int respawnDelay;
boolean split;
Vessel P1, P2, enemy;
HUD hud1, hud2;
ArrayList<Shot> shots = new ArrayList();
ArrayList<SFX> special_effects = new ArrayList();
ArrayList<Asteroid> asteroids = new ArrayList();
float[][] starfield;
String input;
PVector screen_center;
float cx, cy;
byte controlScheme = 0;
int maxHealth = 6;

PGraphics left, right;
boolean screen_render, left_render, right_render;

line_segment the_intersector;
Ray the_beam;

void setup(){
  //size(1366, 500, FX2D);
  fullScreen(FX2D);
  frameRate(60);
  cx = width/2f;
  cy = height/2f;
  
  control = ControlIO.getInstance(this);
  
  gpad1 = control.getDevice("USB Joystick          ");
  
  if (gpad1 == null) {
    println("No suitable device configured");
    System.exit(-1); // End the program NOW!
  }
  
  left = createGraphics(int(cx), height);
  right = createGraphics(int(cx), height);
  
  strokeWeight(2);
  //Vessel(float x, float y, float mass, float radius, color co, float sx, float sy, char uk, char dk, char lk, char rk, char fk)
  P1 = new Vessel(width/4f, (3/4f)*height, 50, 22.5, color(0, 255, 255), width *0.25, cy);
  P2 = new Vessel((3/4f)*width, height/4f, 50, 22.5, color( 255, 0, 127 ), width *0.75, cy);
  P1.set_keys('w', 's', 'a', 'd', 'f', 'g', 'h', 'v', 'r', 't', 'y', 'c');
  P2.set_keys('0', '0', '0', '0', 'j', 'k', 'l', 'm', 'u', 'i', 'o', 'n');
  P2.theta = PI;
  float xs = 0.65;
  float ys = 0.8;
  hud1 = new HUD( P1, 0, 0, height - ys*height, xs*cx, ys*height );
  hud2 = new HUD( P2, 1, width - xs*cx, height - ys*height, xs*cx, ys*height );
  
  respawnDelay = 3500;
  the_intersector = new line_segment();
  the_beam = new Ray();
  
  for(int i=0; i < 25; i++){
    asteroids.add( new Asteroid( random( -2000, 2000 ), random( -2000, 2000 ), random( 35, 125 )) );
  }
  starfield = new float[600][3];
  for (int i = 0; i < starfield.length; i++) {
    float a = random( TWO_PI );
    float g = 2000 * abs(randomGaussian());
    starfield[i][0] = g * cos( a );
    starfield[i][1] = g * sin( a );
    starfield[i][2] = random( 1, 6 );
  }
}

void draw(){
  background(0);

  P1.gpad_controls( 0 );
  P2.gpad_controls( 1 );
  
  //print("P1 ");
  enemy = P2;
  P1.tick();
  
  //print("P2 ");
  enemy = P1;
  P2.tick();
  
  inertia = 0.99;
  P1.move();
  P2.move();
  
  //ASTEROID COLLISIONS
  for(int i=0; i < asteroids.size(); i++){
    if( P1.pos.dist( asteroids.get(i).pos ) < asteroids.get(i).radius ){
      P1.vel.mult(0.5);
      float mag = P1.vel.mag();
      asteroids.get(i).vel.add( P1.vel );
      PVector e = new PVector(mag, 0 );
      e.rotate( atan2( P1.pos.y - asteroids.get(i).pos.y, P1.pos.x - asteroids.get(i).pos.x ) );
      P1.vel = e.get();
      mag *= 10;
      P1.receive_damage( mag );
      special_effects.add( new bits( P1.pos.x, P1.pos.y, #FFFFFF ) );
      if( asteroids.get(i).receive_damage( mag ) ){
        asteroids.remove(i);
        break;
      }
    }
  }//ASTEROID COLLISIONS
  for(int i=0; i < asteroids.size(); i++){
    if( P2.pos.dist( asteroids.get(i).pos ) < asteroids.get(i).radius ){
      P2.vel.mult(0.5);
      float mag = P2.vel.mag();
      asteroids.get(i).vel.add( P2.vel );
      PVector e = new PVector(mag, 0 );
      e.rotate( atan2( P2.pos.y - asteroids.get(i).pos.y, P2.pos.x - asteroids.get(i).pos.x ) );
      P2.vel = e.get();
      mag *= 10;
      P2.receive_damage( mag );
      special_effects.add( new bits( P2.pos.x, P2.pos.y, #FFFFFF ) );
      if( asteroids.get(i).receive_damage( mag ) ){
        asteroids.remove(i);
        break;
      }
    }
  }
  
  inertia = 1;
  
  pushMatrix();
  split = ( abs(P1.pos.x - P2.pos.x) > width || abs(P1.pos.y - P2.pos.y) > height );//? true : false;
  if( split ){
    effects_tick();
    effects_left_screen();
    effects_right_screen();
    image(left, 0, 0);
    image(right, cx, 0);
    P1.radar(P2);
    P2.radar(P1);
    stroke(255);
    line( cx, 0, cx, height );
  }
  else{
    screen_center = new PVector( P1.pos.x + (( P2.pos.x - P1.pos.x )/2f), P1.pos.y + (( P2.pos.y - P1.pos.y )/2f) );
    translate( cx - screen_center.x, cy - screen_center.y);
    effects_single_screen();    
  }  

  P1.display();
  P2.display();  
  
  //the_intersector.display();  
  //the_beam.display();
  //stroke(#FF62ED);
  //rect(0, 0, width, height);
  //ellipse(screen_center.x , screen_center.y, 5, 5);
  popMatrix();
  
  hud1.display();
  hud2.display();
  //println(frameRate);
}
//--------------------------------------------------------------------------------------------*
// 0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0|
//--------------------------------------------------------------------------------------------*

void effects_single_screen(){
  screen_render = false;
  
  pushStyle();
  noFill();
  stroke(255);
  strokeWeight(3);
  for(int i=0; i < asteroids.size(); i++){
    asteroids.get(i).move();
    asteroids.get(i).display();
  }
  popStyle();
  
  for(int i = shots.size()-1; i >= 0; i--){
    
    shots.get(i).move();
    
    float distP1 = shots.get(i).pos.dist( P1.pos );
    float distP2 = shots.get(i).pos.dist( P2.pos );
    
    if( shots.get(i).past_range(distP1, distP2) ) shots.remove(i); 

    else{
      shots.get(i).display();
      
      if( distP1 < shots.get(i).radius + P1.radius ){
        shots.get(i).hit( P1 );
        shots.remove(i); 
      }
      else if(distP2 < shots.get(i).radius + P2.radius){
        shots.get(i).hit( P2 );
        shots.remove(i);
      }
      for(int j = asteroids.size()-1; j >= 0 ; j--){
        if( i >= shots.size() ) i = shots.size()-1;
        if( i < 0 ) break;
        if( shots.get(i).pos.dist( asteroids.get(j).pos ) < asteroids.get(j).radius ){
          for(int k=0; k < 2; k++) special_effects.add( new bits( shots.get(i).pos.x, shots.get(i).pos.y, #FFFFFF ) );
          shots.remove(i);
          if( asteroids.get(j).receive_damage(10.0) ) asteroids.remove(j);
          break;
        }
      }
    }
  }
  for(int i = special_effects.size()-1; i >= 0 ; i--) if( special_effects.get(i).exe() ) special_effects.remove(i);
  
  noStroke(); 
  fill(255);
  for (int i = 0; i < starfield.length; i++) {
    ellipse( starfield[i][0], starfield[i][1], starfield[i][2], starfield[i][2] );
  }
  
  screen_render = true;
}

//--------------------------------------------------------------------------------------------*
// 0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0|
//--------------------------------------------------------------------------------------------*

void effects_tick(){
  
  for(int i=0; i < asteroids.size(); i++) asteroids.get(i).move();
  
  for(int i = shots.size()-1; i >= 0; i--){
    
    shots.get(i).move();
    
    float distP1 = shots.get(i).pos.dist( P1.pos );
    float distP2 = shots.get(i).pos.dist( P2.pos );
    
    if( shots.get(i).past_range(distP1, distP2) ) shots.remove(i); 
    
    else{      
      if( distP1 < shots.get(i).radius + P1.radius ){
        if( !(P1.dead) ){
          shots.get(i).hit( P1 );
          shots.remove(i); 
        }
      }
      else if(distP2 < shots.get(i).radius + P2.radius){
        if( !(P2.dead) ){
          shots.get(i).hit( P2 );
          shots.remove(i);
        }
      }
      for(int j = asteroids.size()-1; j >= 0 ; j--){
        if( i >= shots.size() ) i = shots.size()-1;
        if( i < 0 ) break;
        if( shots.get(i).pos.dist( asteroids.get(j).pos ) < asteroids.get(j).radius ){
          for(int k=0; k < 2; k++) special_effects.add( new bits( shots.get(i).pos.x, shots.get(i).pos.y, #FFFFFF ) );
          shots.remove(i);
          if( asteroids.get(j).receive_damage(10.0) ) asteroids.remove(j);
          break;
        }
      }
    }
  }
  for(int i = special_effects.size()-1; i >= 0 ; i--) special_effects.get(i).tick();
}

void effects_left_screen(){
  left_render = false;
  left.beginDraw();
  left.background(0);
  left.noFill();
  left.strokeWeight(2);
  left.translate( P1.screen_x - P1.pos.x, cy - P1.pos.y);
  left.pushStyle();
  left.noStroke(); 
  left.fill(255);
  for (int i = 0; i < starfield.length; i++) {
    left.ellipse( starfield[i][0], starfield[i][1], starfield[i][2], starfield[i][2] );
  }
  left.noFill();
  left.stroke(255);
  left.strokeWeight(3);
  for(int i=0; i < asteroids.size(); i++) asteroids.get(i).display(left);
  left.popStyle();
  for(int i = shots.size()-1; i >= 0; i--) shots.get(i).display( left );
  for(int i = special_effects.size()-1; i >= 0 ; i--) special_effects.get(i).exe( left );
  left.endDraw();
  left_render = true;
}

void effects_right_screen(){
  right_render = false;
  right.beginDraw();
  right.background(0);
  right.noFill();
  right.strokeWeight(2);  
  right.translate( P1.screen_x - P2.pos.x, cy - P2.pos.y);
  right.pushStyle();
  right.noStroke(); 
  right.fill(255);
  for (int i = 0; i < starfield.length; i++) {
    right.ellipse( starfield[i][0], starfield[i][1], starfield[i][2], starfield[i][2] );
  }
  right.noFill();
  right.stroke(255);
  right.strokeWeight(3);
  for(int i=0; i < asteroids.size(); i++) asteroids.get(i).display(right);
  right.popStyle();
  for(int i = shots.size()-1; i >= 0; i--) shots.get(i).display( right );
  for(int i = special_effects.size()-1; i >= 0 ; i--) special_effects.get(i).exe( right );
  right.endDraw();
  right_render = true;
}

//--------------------------------------------------------------------------------------------*
// 0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0|
//--------------------------------------------------------------------------------------------*

void keyPressed() {
  //println("typed", key);
  //P1.char_controls( char(int(key)+32), true );
  //P2.arrow_controls( char(int(key)+32), true );
}
void keyReleased(){
  //println("released", key);
  //P1.char_controls( char(int(key)+32), false );
  //P2.arrow_controls(  char(int(key)+32), false );
}
