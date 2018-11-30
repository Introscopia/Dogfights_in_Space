class Equipment{
  Vessel owner;
  float base_mass;
  Equipment(Vessel o){owner = o;}
  void tick( boolean activated ){}
  float mass(){ return base_mass; }
  void display(){}
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class MK_I_Generator extends Equipment{
  MK_I_Generator(Vessel o){
    super( o );
    base_mass = 50;
  }
  void tick( boolean activated ){
    owner.power = constrain( owner.power + 0.3, 0, owner.base_power );
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class Shield extends Equipment{
  int pmillis;
  float power_consumption, max_shield;
  float shield_radius, owner_radius;
  Shield(Vessel o){
    super( o );
    base_mass = 45;
    max_shield = 50;
    power_consumption = 20;
    owner_radius = owner.radius;
    shield_radius = 2 * owner_radius;
  }
  void tick( boolean activated ){
    if( activated && owner.power > ((1.0/frameRate)*power_consumption) ){
      owner.power -= ((millis()-pmillis)/1000.0) * power_consumption;
      owner.temperature += 0.4;
      if( owner.shield < 1 ) owner.shield = 1;
      else owner.shield = constrain( 1.1*owner.shield, 1, max_shield );
    }
    else owner.shield = owner.shield*0.5;
    
    owner.radius = map(owner.shield, 0, max_shield, owner_radius, shield_radius);
    pmillis = millis();
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class heat_dump extends Equipment{
  int pmillis;
  float rate, coolant;
  heat_dump(Vessel o){
    super( o );
    rate = 50;
    coolant = 2000;
  }
  void tick( boolean activated ){
    if( activated && coolant > 0 && owner.temperature > 50){
      float q = ellipticalMap( owner.temperature, 50, 600, 0, 30 );
      coolant -= q;
      owner.temperature -= q;
      int a = round(random(1, 3.5));
      float tm = PI/10f;
      float mm = owner.radius*1.25;
      for(int i = 0; i < a; i++){
        float t = owner.theta + HALF_PI + random(-tm, tm);
        float m = random( owner.radius, mm );
        special_effects.add( new Smoke(owner.pos.x + m*cos(t), owner.pos.y + m*sin(t), 2*cos(t), 2*sin(t), random(8, 22), color(180, random(q, 180), 0) ) );
      }
      a = round(random(1, 3.5));
      for(int i = 0; i < a; i++){
        float t = owner.theta - HALF_PI + random(-tm, tm);
        float m = random( owner.radius, mm );
        special_effects.add( new Smoke(owner.pos.x + m*cos(t), owner.pos.y + m*sin(t), 2*cos(t), 2*sin(t), random(8, 22), color(180, random(q, 180), 0) ) );
      }
    }
    pmillis = millis();
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|
class SEC_Launcher extends Equipment{
  int cooling_until, cooldown, charges;
  SEC_Launcher(Vessel o){
    super( o );
    charges = 60;
    cooldown = 600;
    base_mass = 9;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && charges > 0 && owner.power >= 2){
        float x = owner.pos.x + (owner.radius+30)*cos(owner.theta);
        float y = owner.pos.y + (owner.radius+30)*sin(owner.theta);
        shots.add( new small_explosive_charge( x, y, 10 + ( owner.vel.mag() * cos( PVector.angleBetween(new PVector(x - owner.pos.x, y - owner.pos.y), owner.vel) ) ), owner.theta) );
        cooling_until = millis() + cooldown;
        charges--;
        owner.power -= 2;
        owner.temperature += 1.5;
      }
    }
  }
  void display(){}
}
//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|
class MEC_Launcher extends Equipment{
  int cooling_until, cooldown, charges;
  MEC_Launcher(Vessel o){
    super( o );
    charges = 40;
    cooldown = 600;
    base_mass = 12;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && charges > 0 && owner.power >= 2){
        shots.add( new medium_explosive_charge(owner.pos.x + (owner.radius+17)*cos(owner.theta), owner.pos.y + (owner.radius+17)*sin(owner.theta), 9 + owner.vel.mag(), owner.theta) );
        cooling_until = millis() + cooldown;
        charges--;
        owner.power -= 3;
        owner.temperature += 2;
      }
    }
  }
  void display(){}
}
//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class plasma_gun extends Equipment{
  int cooling_until, cooldown;
  plasma_gun(Vessel o){
    super( o );
    cooldown = 120;
    base_mass = 18;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && owner.power >= 4){
        shots.add( new plasma(owner.pos.x + (owner.radius+5)*cos(owner.theta), owner.pos.y + (owner.radius+5)*sin(owner.theta), owner.theta) );
        cooling_until = millis() + cooldown;
        owner.power -= 4;
        owner.temperature += 6;
      }
    }
  }
  void display(){}
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class dual_plasma_gun extends Equipment{
  int cooling_until, cooldown;
  float mount;
  dual_plasma_gun(Vessel o){
    super( o );
    cooldown = 120;
    base_mass = 36;
    mount = PI/10f;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && owner.power >= 8){
        shots.add( new plasma(owner.pos.x + (owner.radius+5)*cos(owner.theta - mount), owner.pos.y + (owner.radius+5)*sin(owner.theta - mount), owner.theta) );
        shots.add( new plasma(owner.pos.x + (owner.radius+5)*cos(owner.theta + mount), owner.pos.y + (owner.radius+5)*sin(owner.theta + mount), owner.theta) );
        cooling_until = millis() + cooldown;
        owner.power -= 8;
        owner.temperature += 12;
      }
    }
  }
  void display(){}
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class alternating_dual_plasma_gun extends Equipment{
  int cooling_until, cooldown, gun;
  float mount;
  alternating_dual_plasma_gun(Vessel o){
    super( o );
    cooldown = 60;
    base_mass = 36;
    mount = PI/10f;
    gun = 1;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && owner.power >= 8){
        if( gun == 1 ) shots.add( new plasma(owner.pos.x + (owner.radius+5)*cos(owner.theta - mount), owner.pos.y + (owner.radius+5)*sin(owner.theta - mount), owner.theta) );
        else shots.add( new plasma(owner.pos.x + (owner.radius+5)*cos(owner.theta + mount), owner.pos.y + (owner.radius+5)*sin(owner.theta + mount), owner.theta) );
        gun *= -1;
        cooling_until = millis() + cooldown;
        owner.power -= 6;
        owner.temperature += 3;
      }
    }
  }
  void display(){}
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class lazer_beam extends Equipment{
  int cooling_until, cooldown;
  lazer_beam(Vessel o){
    super( o );
    cooldown = 600;
    base_mass = 18;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && owner.power >= 10){
        PVector i, f;
        i = new PVector(owner.pos.x + (owner.radius)*cos(owner.theta), owner.pos.y + (owner.radius)*sin(owner.theta));
        Ray beam = new Ray( owner.pos, owner.theta );
        line_segment intersector = new line_segment( enemy.pos, owner.theta, enemy.radius );
        //the_intersector = intersector;
        //the_beam = beam; 
        PVector hit = beam.intersect( intersector );
        if( hit != null ){
          f = hit.get();
          enemy.receive_damage( 10 );
        }
        else{
          f = new PVector(owner.pos.x + 10000*cos(owner.theta), owner.pos.y + 10000*sin(owner.theta));
        }
        special_effects.add( new Beam( i, f ) );
        
        cooling_until = millis() + cooldown;
        owner.power -= 10;
        owner.temperature += 10;
      }
    }
  }
  void display(){}
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class shotgun extends Equipment{
  int cooling_until, cooldown, shells;
  float spread;
  shotgun(Vessel o){
    super( o );
    cooldown = 800;
    base_mass = 36;
    spread = PI/10f;
    shells = 35;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && owner.power >= 0.5 && shells > 0){
        for(int i = 0; i < 10; i++){
          float a = random( owner.theta - spread, owner.theta + spread );
          shots.add( new shell(owner.pos.x + (owner.radius+4)*cos(a), owner.pos.y + (owner.radius+4)*sin(a), a) );
        }
        cooling_until = millis() + cooldown;
        owner.power -= 0.5;
        owner.temperature += 5;
        shells--;
      }
    }
  }
  void display(){}
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class seeker_launcher extends Equipment{
  int cooling_until, cooldown, missiles;
  seeker_launcher(Vessel o){
    super( o );
    cooldown = 2000;
    base_mass = 36;
    missiles = 5;
  }
  void tick( boolean activated ){
    if( cooling_until < millis() ){
      if( activated && owner.power >= 0.5 && missiles > 0){
        shots.add( new seeker_missle(owner.pos.x + (owner.radius+13)*cos(owner.theta), owner.pos.y + (owner.radius+13)*sin(owner.theta), owner.theta, enemy ) );
        cooling_until = millis() + cooldown;
        owner.power -= 0.5;
        owner.temperature += 2;
        missiles --;
      }
    }
  }
  void display(){}
}

//--------------------------------------------------------------------------------------------*
// 0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0|
//--------------------------------------------------------------------------------------------*

class Shot extends Body{
  color c;
  float heading;
  Shot(float x, float y, float a, float mass, float radius, float speed, color co){
    super(x, y, mass, radius, false);
    vel = new PVector(1, 0);
    vel.rotate( a );
    vel.setMag(speed);
    heading = a;
    c = co;
  }
  boolean past_range( float dp1, float dp2 ){ return true; }
  void hit(Vessel v){}
  void display(){}
  void display(PGraphics pg){}
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class small_explosive_charge extends Shot{
  //Vessel target;
  float exp_fade, exp_speed;
  small_explosive_charge(float x, float y, float s, float a){
    //Shot(float x, float y, float a, float mass, float radius, float speed, color co){
    super(x, y, a, 15, 30, s, color(255, 215, 0));
    exp_fade = 8;
    exp_speed = 8;
    //target = t;
  }
  boolean past_range( float dp1, float dp2 ){ 
    if( dp1 > 2000 && dp2 > 2000 ) return true;
    else return false;
  }
  void hit(Vessel v){
    v.receive_damage( 15 );
    float a = atan2(v.pos.y - pos.y, v.pos.x - pos.x);
    v.acc.add( 2.5 * cos(a), 2.5 * sin(a));
    special_effects.add( new Explosion( this ) );
  }
  //void move(){
  //  this.gravitate(target);
  //  if(acc.mag() > vel.mag() )vel = acc.get();
  //  super.move();
  //}
  void display(){
    stroke(c);
    noFill();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate( heading );
    beginShape();
    vertex(0, -4);
    vertex(4, 0);
    vertex(0, 4);
    vertex(-4, 0);
    endShape(CLOSE);
    popMatrix();
  }
  void display(PGraphics pg){
    pg.stroke(c);
    pg.noFill();
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate( heading );
    pg.beginShape();
    pg.vertex(0, -4);
    pg.vertex(4, 0);
    pg.vertex(0, 4);
    pg.vertex(-4, 0);
    pg.endShape(CLOSE);
    pg.popMatrix();
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class medium_explosive_charge extends Shot{
  float exp_fade, exp_speed;
  medium_explosive_charge(float x, float y, float s, float a){
    //Shot(float x, float y, float a, float mass, float radius, float speed, color co){
    super(x, y, a, 25, 16, s, color(255, 115, 0));
    exp_fade = 6;
    exp_speed = 8;
  }
  boolean past_range( float dp1, float dp2 ){ 
    if( dp1 > 2000 && dp2 > 2000 ) return true;
    else return false;
  }
  void hit(Vessel v){
    v.receive_damage( 30 );
    float a = atan2(v.pos.y - pos.y, v.pos.x - pos.x);
    v.acc.add( 5 * cos(a), 5 * sin(a));
    special_effects.add( new Explosion( this ) );
  }
  void display(){
    stroke(c);
    noFill();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate( heading );
    beginShape();
    vertex(-4, -8);
    vertex(4, -8);
    vertex(8, -4);
    vertex(8, 4);
    vertex(4, 8);
    vertex(-4, 8);
    vertex(-8, 4);
    vertex(-8, -4);
    endShape(CLOSE);
    popMatrix();
  }
  void display(PGraphics pg){
    pg.stroke(c);
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate( heading );
    pg.beginShape();
    pg.vertex(-2, -4);
    pg.vertex(2, -4);
    pg.vertex(4, -2);
    pg.vertex(4, 2);
    pg.vertex(2, 4);
    pg.vertex(-2, 4);
    pg.vertex(-4, 2);
    pg.vertex(-4, -2);
    pg.endShape(CLOSE);
    pg.popMatrix();
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class plasma extends Shot{
  plasma(float x, float y, float a){
    //Shot(float x, float y, float a, float mass, float radius, float speed, color co){
    super(x, y, a, 15, 4, 20, #FF12A1);
  }
  boolean past_range( float dp1, float dp2 ){ 
    if( dp1 > 2000 && dp2 > 2000 ) return true;
    else return false;
  }
  void hit(Vessel v){
    v.receive_damage( 5 );
    special_effects.add( new bits( pos.x, pos.y, #FF12A1 ) );
  }
  void display(){
    stroke(c);
    noFill();
    pushMatrix();
    translate(pos.x, pos.y);
    rotate( heading );
    beginShape();
    vertex(0, -3);
    vertex(3, 0);
    vertex(0, 3);
    vertex(-8, 0);
    endShape(CLOSE);
    popMatrix();
  }
  void display(PGraphics pg){
    pg.stroke(c);
    pg.noFill();
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate( heading );
    pg.beginShape();
    pg.vertex(0, -3);
    pg.vertex(3, 0);
    pg.vertex(0, 3);
    pg.vertex(-8, 0);
    pg.endShape(CLOSE);
    pg.popMatrix();
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class shell extends Shot{
  PVector s;
  float a;
  shell(float x, float y, float a){
    //Shot(float x, float y, float a, float mass, float radius, float speed, color co){
    super(x, y, a, 8, 3, 50, color(255, 255, 0));
    s = new PVector( x, y );
    this.a = 200;
  }
  boolean past_range( float dp1, float dp2 ){
    if( s.dist( pos ) > 200 ) return true;
    else return false;
  }
  void hit(Vessel v){
    v.receive_damage( 4 );
    special_effects.add( new bits( pos.x, pos.y, color(255, 255, 0) ) );
  }
  void display(){
    strokeWeight(1);
    a--;
    stroke(c, a);
    line(s.x, s.y, pos.x, pos.y);
    strokeWeight(2);
  }
  void display(PGraphics pg){
    a--;
    pg.stroke(c, a);
    pg.line(s.x, s.y, pos.x, pos.y);
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class seeker_missle extends Shot{
  Vessel target;
  float speed, turn_rate, fuel;
  seeker_missle(float x, float y, float a, Vessel t){
    //Shot(float x, float y, float a, float mass, float radius, float speed, color co){
    super(x, y, a, 15, 10, 11, color(255, 255, 0));
    speed = 11;
    turn_rate = PI/75f;
    target = t;
    fuel = 750;
  }
  boolean past_range( float dp1, float dp2 ){
    return false;
  }
  void hit( Vessel v ){
    v.receive_damage( 22 );
    float a = atan2(v.pos.y - pos.y, v.pos.x - pos.x);
    v.acc.add( 3.5 * cos(a), 3.5 * sin(a));
    special_effects.add( new Explosion( pos.x, pos.y, 7, 8 ) );
  }
  void move(){
    if( fuel > 0 ){
      float a = atan2( target.pos.y - pos.y, target.pos.x - pos.x );
      //PVector.angleBetween( vel, new PVector(target.pos.x - pos.x, target.pos.y - pos.y) )
      if( abs( vel.heading() - a ) > turn_rate ){
        float new_a = 0;
        if( a > vel.heading() ){
          if( a > vel.heading()+PI ) new_a = vel.heading() - turn_rate;
          else new_a = vel.heading() + turn_rate;
        }
        else{
          if( a < vel.heading()-PI ) new_a =  vel.heading() + turn_rate;
          else new_a = vel.heading() - turn_rate;
        }
        vel = new PVector( speed*cos(new_a), speed*sin(new_a) );
      }
      pos.add(vel);
      fuel--;
    }
    else{
      vel.setMag( 0.999 * vel.mag() );
      pos.add(vel);
    }
  }
  void display(){
    pushMatrix();
    translate(pos.x, pos.y);
    rotate( vel.heading() );
    stroke(255);
    noFill();
    beginShape();
    vertex(10.0, 0.0);
    vertex(2.5, -2.5);
    vertex(-7.5, -2.5);
    vertex(-10.0, -5.0);
    vertex(-10.0, 5.0);
    vertex(-7.5, 2.5);
    vertex(2.5, 2.5);
    endShape(CLOSE);
    if( fuel > 0 ){
      stroke( c );
      beginShape();
      vertex(-10.0, -2.5);
      vertex(-17.5, 0.0);
      vertex(-10.0, 2.5);
      endShape();
    }
    popMatrix();
  }
  void display(PGraphics pg){
    pg.pushMatrix();
    pg.translate(pos.x, pos.y);
    pg.rotate( vel.heading() );
    pg.stroke(255);
    pg.noFill();
    pg.beginShape();
    pg.vertex(10.0, 0.0);
    pg.vertex(2.5, -2.5);
    pg.vertex(-7.5, -2.5);
    pg.vertex(-10.0, -5.0);
    pg.vertex(-10.0, 5.0);
    pg.vertex(-7.5, 2.5);
    pg.vertex(2.5, 2.5);
    pg.endShape(CLOSE);
    if( fuel > 0 ){
      pg.stroke( c );
      pg.beginShape();
      pg.vertex(-10.0, -2.5);
      pg.vertex(-17.5, 0.0);
      pg.vertex(-10.0, 2.5);
      pg.endShape();
    }
    pg.popMatrix();
  }
}
