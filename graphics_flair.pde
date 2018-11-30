class HUD{
  Vessel owner;
  float x, y, w, h;
  color hull_c;
  float hull_border_x, hull_border_y, hull_border_w, hull_border_h;
  float hull_x, hull_y, hull_h, hull_ox, hull_oy;
  color power_c;
  float power_x, power_y, power_d;
  float temp_x, temp_y, temp_w, temp_h, temp_bulb_x, temp_bulb_y, temp_bulb_d, temp_line_y;
  float border = 10;
  HUD(Vessel o, int p, float x, float y, float w, float h){
    owner = o;
    if( p == 0 ){
      power_c = #12FF82;
      power_d = w/4.0;
      power_x = x + (w/20.0) + power_d/2.0;
      power_y = y + h -(w/20.0) - power_d/2.0;
      hull_c = #FF4D12;
      hull_border_x = x + w/20.0;
      hull_border_y = y + h/3.0;
      hull_border_w = w/10.0;
      hull_border_h = (2/3.0)*h - hull_border_x - power_d/2.0;
      hull_x = hull_border_x + border;
      hull_y = hull_border_y + border;
      hull_h = hull_border_h - 2*border - 27;
      hull_ox = hull_border_x + hull_border_w - border;
      hull_oy = hull_y + hull_h;
      temp_x = x + hull_border_x + hull_border_w + border;
      temp_y = y + 0.5*h;
      temp_w = 0.4 * hull_border_w;
      temp_h = 0.5*h - power_d;
      temp_bulb_x = temp_x + (temp_w/2.0);
      temp_bulb_y = temp_y - 5;
      temp_bulb_d = 2*temp_w;
      temp_line_y = temp_y + temp_h - 10;
    }
    else{
      power_c = #12FF82;
      power_d = w/4.0;
      power_x = x + w-(w/20.0) - power_d/2.0;
      power_y = y + h -(w/20.0) - power_d/2.0;
      hull_c = #FF4D12;
      hull_border_x = x + w - (w/20.0) - (w/10.0);
      hull_border_y = y + h/3.0;
      hull_border_w = w/10.0;
      hull_border_h = (2/3.0)*h - (w/20.0) - power_d/2.0;
      hull_x = hull_border_x + border;
      hull_y = hull_border_y + border;
      hull_h = hull_border_h - 2*border - 27;
      hull_ox = hull_border_x + hull_border_w - border;
      hull_oy = hull_y + hull_h;
      temp_x = x + w - (w/20.0) - 1.4*hull_border_w - border;
      temp_y = y + 0.5*h;
      temp_w = 0.4 * hull_border_w;
      temp_h = 0.5*h - power_d;
      temp_bulb_x = temp_x + (temp_w/2.0);
      temp_bulb_y = temp_y - 5;
      temp_bulb_d = 2*temp_w;
      temp_line_y = temp_y + temp_h - 10;
    }
  }
  void display(){
    strokeWeight(2);
    
    fill(0);
    stroke(hull_c);
    rect(hull_border_x, hull_border_y, hull_border_w, hull_border_h);
    noStroke();
    fill(hull_c);
    rectMode(CORNERS);
    rect(hull_x, hull_y + map(owner.hull, 0, owner.base_hull, hull_h, 0), hull_ox, hull_oy);
    
    noStroke();
    fill(255);
    rectMode(CORNER);
    rect(temp_x, temp_y, temp_w, temp_h);
    ellipse(temp_bulb_x, temp_bulb_y, temp_bulb_d, temp_bulb_d);
    stroke(255, 0, 0);
    line( temp_bulb_x, temp_line_y, temp_bulb_x, temp_line_y - map( constrain(owner.temperature, 0, 300 ), 0, 300, 0, temp_h ) );
    if( owner.temperature > 300 ){
      noStroke();
      fill(255, 0, 0);
      ellipse(temp_bulb_x, temp_bulb_y, 0.6*temp_bulb_d, 0.6*temp_bulb_d);
    }
    
    fill(0);
    stroke(power_c);
    ellipse( power_x, power_y, power_d, power_d );
    noStroke();
    fill(power_c);
    float d = map( owner.power, 0, owner.base_power, 0, power_d - 2*border);
    ellipse( power_x, power_y, d, d );
  }
}

//--------------------------------------------------------------------------------------------*
// 0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0  *  0|
//--------------------------------------------------------------------------------------------*

class SFX{
  float x, y;
  SFX(){}
  SFX(float a, float b){
   x = a;
   y = b;
  }
  boolean tick(){ return false; }
  void exe(PGraphics pg){}
  boolean exe(){ return false; }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class Explosion extends SFX{
  float d, ddt, a, adt;
  Explosion(float a, float b, float duration, float speed){
    super(a, b);
    ddt = speed;
    adt = duration;
    d = 0;
    this.a = 255;   
  }
  Explosion( small_explosive_charge s ){
    super( s.pos.x, s.pos.y );
    ddt = s.exp_speed;
    adt = s.exp_fade;
    d = 0;
    a = 255; 
  }
  Explosion( medium_explosive_charge s ){
    super( s.pos.x, s.pos.y );
    ddt = s.exp_speed;
    adt = s.exp_fade;
    d = 0;
    a = 255; 
  }  
  boolean tick(){
    d += ddt;
    a -= adt;
    if( a < 0 ){return true;}
    return false;
  }
  boolean exe(){
    d += ddt;
    a -= adt;
    if( a < 0 ){return true;}
    stroke( a, a, 0 );
    noFill();
    ellipse(x, y, d, d);
    return false;
  }
  void exe(PGraphics pg){
    pg.stroke( a, a, 0 );
    pg.noFill();
    pg.ellipse(x, y, d, d);
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class Smoke extends SFX{
  float vx, vy;
  float d, a, adt;
  color c;
  Smoke( float x_, float y_, float vx_, float vy_, float d_, color c_ ){
    super(x_, y_);
    vx = vx_;
    vy = vy_;
    d = d_;
    c = c_;
    a = 255; 
    adt = random(4, 6);
  }
  boolean tick(){ 
    x += vx;
    y += vy;
    a -= adt;
    if( a < 0 ){return true;}
    return false;
  }
  void exe(PGraphics pg){
    pg.noStroke();
    pg.fill(c, a);
    pg.ellipse(x, y, d, d);
  }
  boolean exe(){ 
    x += vx;
    y += vy;
    a -= adt;
    if( a < 0 ){ return true; }
    noStroke();
    fill(c, a);
    ellipse(x, y, d, d);
    return false;
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class bits extends SFX{
  PVector[] p, v;
  float a;
  color c;
  bits( float x, float y, color co){
    super(x, y);
    int n = round(random(3.5, 8.5));
    p = new PVector[n];
    v = new PVector[n];
    for(int i = 0; i < n; i++) p[i] = new PVector(x, y);
    for(int i = 0; i < n; i++) v[i] = new PVector(random(-4, 4), random(-4, 4));
    a = 255;
    c = co;
  }
  boolean tick(){
    for(int i = 0; i < p.length; i++) p[i].add(v[i]);
    a -= 5;
    if( a < 0 ){return true;}
    return false;
  }
  void exe(PGraphics pg){
    pg.stroke(c, a);
    for(int i = 0; i < p.length; i++) pg.point( p[i].x, p[i].y );
  }
  boolean exe(){ 
    for(int i = 0; i < p.length; i++) p[i].add(v[i]);
    a -= 5;
    if( a < 0 ){ return true; }
    stroke(c, a);
    for(int i = 0; i < p.length; i++) point( p[i].x, p[i].y );
    return false;
  }
}

//N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N  ]|
// N N N N N N N N N N N N N N N N N N N N N \ \ N N N N N N N N N N N N N N N N N N N ]|

class Beam extends SFX{
  PVector i, f;
  float a;
  Beam( PVector i, PVector f ){
    this.i = i.get();
    this.f = f.get();
    a = 255;
  }
  boolean tick(){
    //i.lerp( f, 0.005 );
    a -= 8;
    if( a < 0 ){return true;}
    return false;
  }
  void exe(PGraphics pg){
    pg.stroke(255, 0, 0, a/4.0);
    pg.strokeWeight(8);
    pg.line( i.x, i.y, f.x, f.y );
    pg.stroke(255, 0, 0, a/2.0);
    pg.strokeWeight(5);
    pg.line( i.x, i.y, f.x, f.y );
    pg.stroke(255, 0, 0, a);
    pg.strokeWeight(2);
    pg.line( i.x, i.y, f.x, f.y );
  }
  boolean exe(){
    //i.lerp( f, 0.005 );
    a -= 8;
    if( a < 0 ){ return true; }
    stroke(255, 0, 0, a/4.0);
    strokeWeight(8);
    line( i.x, i.y, f.x, f.y );
    stroke(255, 0, 0, a/2.0);
    strokeWeight(5);
    line( i.x, i.y, f.x, f.y );
    stroke(255, 0, 0, a);
    strokeWeight(2);
    line( i.x, i.y, f.x, f.y );
    
    return false;
  }
}