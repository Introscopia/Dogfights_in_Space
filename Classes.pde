class Body{
  public PVector pos, vel, acc;
  public float mass, radius, theta;
  public boolean fixed;
  int i=0;
  Body(float x, float y, float mass, float radius, boolean fixed){
    pos = new PVector(x, y);
    vel = new PVector();
    acc = new PVector();
    this.mass = mass;
    this.fixed = fixed;
    this.radius = radius;
  }
  boolean collide(Body b){
    if( pos.dist( b.pos ) < radius + b.radius ) return true;
    else return false;
  }
  void gravitate(Body b){
    PVector grav = new PVector(1,0);
    grav.setMag(G*(b.mass) / sq(dist(pos.x, pos.y, b.pos.x, b.pos.y)));
    grav.rotate( atan2(b.pos.y - pos.y, b.pos.x - pos.x) );
    acc.add(grav);
  }
  void move(){
    //if(!fixed){
    vel.add(acc);
    vel.setMag( inertia * vel.mag() );
    pos.add(vel);
    acc = new PVector(0,0);
    //}
  }
  void display(){}
  void display(PGraphics pg){}
}
//--------------------------------------------------------------------------------------------------------------------------------------------------*
// 0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0|
//--------------------------------------------------------------------------------------------------------------------------------------------------*

class Vessel extends Body{
  color c;
  float screen_x, screen_y;
  
  Equipment[] equipos;
  float base_mass, base_hull, base_power, temp_max, temp_leak;
  float hull, power, shield, temperature;
  
  int score;
  int dead_until;
  boolean dead;
  
  float thrust_control;
  boolean u, d, l, r, A, B, C, D, E, F, G, H;
  char u_key, d_key, l_key, r_key, A_key, B_key, C_key, D_key, E_key, F_key, G_key, H_key;
  
  Vessel(float x, float y, float mass, float radius, color co, float sx, float sy){
    super(x, y, mass, radius, false);
    c = co;
    score = 0;
    base_hull = 200;
    hull = base_hull;
    base_power = 100;
    power = base_power;
    temp_max = 600;
    temp_leak = 0.075;
    screen_x = sx;
    screen_y = sy;
    equipos = new Equipment[8];
    for(int i = 0; i < 8; i++) equipos[i] = new Equipment(this); 
    equipos[0] = new alternating_dual_plasma_gun(this);
    equipos[1] = new SEC_Launcher(this);
    equipos[2] = new Shield(this);
    equipos[3] = new seeker_launcher(this);
    equipos[4] = new lazer_beam(this);
    equipos[5] = new shotgun(this);
    equipos[6] = new heat_dump(this);
    equipos[7] = new MK_I_Generator(this);
    thrust_control = 1;
  }
  void set_equipment( int i, Equipment e ){
    equipos[i] = e;
  }
  void set_keys( char uk, char dk, char lk, char rk, char Ak, char Bk, char Ck, char Dk, char Ek, char Fk, char Gk, char Hk ){
    u_key = uk;
    d_key = dk;
    l_key = lk;
    r_key = rk; //           F   G
    A_key = Ak; //       E           H
    B_key = Bk; //          B   C    
    C_key = Ck; //      A            D
    D_key = Dk;
    E_key = Ek;
    F_key = Fk;
    G_key = Hk;
    H_key = Gk;
  }
  void char_controls( char k, boolean b ){
    //println( k, b );
    if (k == u_key || k == char(int(u_key)-32)) u = b; 
    else if (k == d_key || k == char(int(d_key)-32)) d = b; 
    else if (k == l_key || k == char(int(l_key)-32)) l = b; 
    else if (k == r_key || k == char(int(r_key)-32)) r = b;
    else if (k == A_key) A = b;
    else if (k == B_key) B = b;
    else if (k == C_key) C = b;
    else if (k == D_key) D = b;
    else if (k == E_key) E = b;
    else if (k == F_key) F = b;
    else if (k == G_key) G = b;
    else if (k == H_key) H = b;
  }
  void arrow_controls( char k, boolean b ){
    if (keyCode == UP) u = b; 
    else if (keyCode == DOWN) d = b; 
    else if (keyCode == LEFT) l = b; 
    else if (keyCode == RIGHT) r = b; 
    else if (k == A_key) A = b;
    else if (k == B_key) B = b;
    else if (k == C_key) C = b;
    else if (k == D_key) D = b;
    else if (k == E_key) E = b;
    else if (k == F_key) F = b;
    else if (k == G_key) G = b;
    else if (k == H_key) H = b;
  }
  void gpad_controls( int GP ){
    /*
    float Y = (GP == 0 )? gpad1.getSlider( IN[GP][0] ).getValue() : gpad2.getSlider( IN[GP][2] ).getValue();
    if( abs(Y) < 0.1 ){
      u = false;
      d = false;
    }
    else if( Y < 0 ){
      u = true;
      d = false;
      thrust_control = -Y;
    }
    else{
      d = true;
      u = false;
    }*/
    u = (GP == 0 )? gpad1.getButton( IN[GP][9] ).pressed() : gpad2.getButton( IN[GP][8] ).pressed();
    d = (GP == 0 )? gpad1.getButton( IN[GP][11] ).pressed() : gpad2.getButton( IN[GP][10] ).pressed();
    
    float X = (GP == 0 )? gpad1.getSlider( IN[GP][1] ).getValue() : gpad2.getSlider( IN[GP][3] ).getValue();
    if( abs(X) < 0.1 ){
      l = false;
      r = false;
    }
    else if( X < 0 ){
      l = true;
      r = false;
    }
    else{
      r = true;
      l = false;
    }
    /*
    equipos[0] = new alternating_dual_plasma_gun(this);
    equipos[1] = new SEC_Launcher(this);
    equipos[2] = new Shield(this);
    equipos[3] = new seeker_launcher(this);
    equipos[4] = new lazer_beam(this);
    equipos[5] = new shotgun(this);
    equipos[6] = new heat_dump(this);
    equipos[7] = new MK_I_Generator(this);
    */
    A = (GP == 0 )? gpad1.getButton( IN[GP][10] ).pressed() : gpad2.getButton( IN[GP][ 9] ).pressed();
    B = (GP == 0 )? gpad1.getButton( IN[GP][ 8] ).pressed() : gpad2.getButton( IN[GP][ 7] ).pressed();
    C = (GP == 0 )? gpad1.getButton( IN[GP][ 5] ).pressed() : gpad2.getButton( IN[GP][ 4] ).pressed();
    E = (GP == 0 )? gpad1.getButton( IN[GP][12] ).pressed() : gpad2.getButton( IN[GP][11] ).pressed();
    G = (GP == 0 )? gpad1.getButton( IN[GP][ 6] ).pressed() : gpad2.getButton( IN[GP][ 5] ).pressed();
    
  }
  void radar( Vessel v ){
    stroke(v.c);
    noFill();
    float a = atan2(v.pos.y - pos.y, v.pos.x - pos.x);
    pushMatrix();
    translate( screen_x + (0.2*width*cos(a)), screen_y + (0.2*width*sin(a)) );
    rotate(a);
    beginShape();
    vertex(8, 0);
    vertex(-8, 12);
    vertex(-8, -12);
    endShape(CLOSE);
    popMatrix();
  }
  void receive_damage( float dmg ){
    if( !dead ){
      hull -= constrain( dmg - shield, 0, dmg );
      power -= 0.15 * ( (dmg >= shield)? dmg : shield );
      //shield = constrain( shield - dmg, 0, shield ); 
      //println( hull,  dmg, shield );
      
      /*
      if( hull <= 0 ){
        dead = true;
        dead_until = millis() + respawnDelay;
        special_effects.add( new Explosion( pos.x, pos.y, 5, 7 ) );
      }
      else shield = constrain( shield - dmg, 0, shield ); 
      */
    }
  }
  void tick(){
    if( dead ){
      if( dead_until < millis() ){
        dead = false;
        hull = base_hull;
        power = base_power;
        temperature = 50;
        equipos[0] = new alternating_dual_plasma_gun(this);
        equipos[1] = new SEC_Launcher(this);
        equipos[2] = new Shield(this);
        equipos[3] = new seeker_launcher(this);
        equipos[4] = new lazer_beam(this);
        equipos[5] = new shotgun(this);
        equipos[6] = new heat_dump(this);
        equipos[7] = new MK_I_Generator(this);
      }
    }
    else{
      switch(controlScheme){
        case 0:
          if(u){
            acc.add(th * thrust_control * cos(theta), th * thrust_control * sin(theta), 0);
            
            int a = int(random(2, 5));
            float tm = PI/8f;
            float mm = radius+vel.mag();
            for(int i = 0; i < a; i++){
              float t = theta - PI + random(-tm, tm);
              float m = random( radius, mm );
              special_effects.add( new Smoke(pos.x + m*cos(t), pos.y + m*sin(t), th*cos(t), th*sin(t), random(8, 22), color(random(200, 255)) ) );
            }
          }
          if(d){
            acc.add(-th*cos(theta), -th*sin(theta), 0);
          } 
          if(l){
            theta -= tr;
          }
          if(r){
            theta += tr;
          }
          break;
        case 1:
          theta = atan2(mouseY - pos.y, mouseX -pos.x );
          if(u){
            acc.add(th*cos(theta), th*sin(theta), 0);
          }
          if(d){
            acc.add(-th*cos(theta), -th*sin(theta), 0);
          } 
          if(l){
            acc.add(th*cos(theta - QUARTER_PI), th*sin(theta - QUARTER_PI), 0);
          }
          if(r){
            acc.add(th*cos(theta + QUARTER_PI), th*sin(theta + QUARTER_PI), 0);
          }
          break;
        case 2:
         if(u){
            acc.add(0, -th, 0);
          }
          if(d){
            acc.add(0, th, 0);
          }
          if(l){
            acc.add(-th, 0, 0);
          }
          if(r){
            acc.add(th, 0, 0);
          }
          theta = atan2(mouseY - pos.y, mouseX -pos.x );
          break;
      }
      equipos[0].tick( A );
      equipos[1].tick( B );
      equipos[2].tick( C );
      equipos[3].tick( D );
      equipos[4].tick( E );
      equipos[5].tick( F );
      equipos[6].tick( G );
      equipos[7].tick( H );
      
      temperature = constrain(temperature -= temp_leak, 50, 10000);
      if( temperature > 200 ) hull -= ellipticalMap( temperature, 200, 600, 0, 1.5 );
      
      if( hull < 0 ){
        dead = true;
        special_effects.add( new Explosion( pos.x, pos.y, 5, 7 ) );
        float a = random(TWO_PI);
        pos = new PVector(enemy.pos.x+1000*cos(a), enemy.pos.x+1000*sin(a));
        dead_until = millis() + respawnDelay;
      }
      //println( int(hull), int(power), int(shield), int(temperature) );
    }
  }
  void display(){
    if( !dead ){
           
      if( split ){    
        pushMatrix();
        translate(screen_x, screen_y);
        rotate(theta);
        
        noFill();
        ship_glow(temperature);
        fill(0);
        strokeWeight(2);
        stroke( c );
        ship();
        
        noFill();
        strokeWeight(4);
        stroke(0, 100, 255, map(shield, 0, 50, 0, 255));
        ellipse(0, 0, 2*radius, 2*radius);
        strokeWeight(2);
        
        popMatrix();
      }
      else{
        pushMatrix();
        translate(pos.x, pos.y);
        rotate(theta);
        
        noStroke();
        ship_glow(temperature);
        fill(0);
        strokeWeight(2);
        stroke( c );
        ship();
        
        noFill();
        strokeWeight(4);
        stroke(0, 100, 255, map(shield, 0, 50, 0, 255));
        ellipse(0, 0, 2*radius, 2*radius);
        strokeWeight(2);
        
        popMatrix();
      }
    }
  }
}

void ship_glow(float temp){
  if(temp > 200 ){
    int n = round( map( temp, 200, 600, 1, 30 ) );
    for(int i = n; i > 0; i-- ){
      fill( 255, 0, 0, map( i, 0, n, 255, 25.5 ) );
      ellipse( 0, 0, i*6, i*6 );
    }
    //strokeWeight(i*4);
    //strokeWeight(3);
    //stroke(255, 0, 0, map( n, 0, 32, 25.5, 255 ) );
    //ship();
    //strokeWeight(1);
  }
}

void ship(){
  beginShape();
  vertex(16.25, 0);
  vertex(-16.25, 12.5);
  vertex(-8.75, 0);
  vertex(-16.25, -12.5);
  endShape(CLOSE);
}


//--------------------------------------------------------------------------------------------*
// 0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0|
//--------------------------------------------------------------------------------------------*

class Asteroid extends Body{
  float[] vtx, vty;
  float H, w;
  float integrity;
  Asteroid( float x, float y, float r ){
    super( x, y, PI*sq(r), r , false );
    integrity = mass/80.0;
    int N = round(random( 6.501, 14.499 ));
    vtx = new float[N];
    vty = new float[N];
    float a = TWO_PI/float(N);
    for(int i=0; i < N; i++){
      float t = random( i*a, (i+1)*a );
      float k = random(0.8, 1.2);
      vtx[i] = k * r * cos( t );
      vty[i] = k * r * sin( t );
    }
    w = random( -PI * 0.001, PI * 0.001 );
    a = random(TWO_PI);
    float v = random(0.0005, 0.04);
    vel = new PVector( v*cos(a), v*sin(a) );
  }
  void display(){
    pushMatrix();
    translate( pos.x, pos.y );
    rotate(H);
    H += w;
    beginShape();
    for(int i=0; i < vtx.length; i++){
      vertex( vtx[i], vty[i] );
    }
    endShape(CLOSE);
    popMatrix();
  }
  boolean receive_damage( float dmg ){
    integrity -= dmg;
    if( integrity <= 0 ) return true;
    else return false;
  }
  void move(){
    H += w;
    super.move();
  }
  void display(PGraphics pg){
    pg.pushMatrix();
    pg.translate( pos.x, pos.y );
    pg.rotate(H);
    pg.beginShape();
    for(int i=0; i < vtx.length; i++){
      pg.vertex( vtx[i], vty[i] );
    }
    pg.endShape(CLOSE);
    pg.popMatrix();
  }
}
