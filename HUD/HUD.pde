Vessel v;
HUDD hud_l, hud_r;
void setup(){
  size(444, 500);
  v = new Vessel();
  hud_l = new HUDD( v, 0, 0, 0, width, height );
  hud_r = new HUDD( v, 1, 0, 0, width, height );
}
void draw(){  
  background(0);
  hud_l.display();
  hud_r.display();
}
class Vessel{
  float base_mass, base_hull, base_power, temp_max;
  float hull, power, shield, temperature;
  Vessel(){
    base_hull = 100;
    base_power = 100;
    temp_max = 300;
    hull = 100;
    power = 100;
    temperature = 50;
  }
}

class HUDD{
  Vessel owner;
  float x, y, w, h;
  color hull_c;
  float hull_border_x, hull_border_y, hull_border_w, hull_border_h;
  float hull_x, hull_y, hull_h, hull_ox, hull_oy;
  color power_c;
  float power_x, power_y, power_d;
  float temp_x, temp_y, temp_w, temp_h, temp_bulb_x, temp_bulb_y, temp_bulb_d, temp_line_y;
  float border = 10;
  HUDD(Vessel o, int p, float x, float y, float w, float h){
    owner = o;
    if( p == 0 ){
      power_c = #12FF82;
      power_d = w/4.0;
      power_x = (w/20.0) + power_d/2.0;
      power_y = h -(w/20.0) - power_d/2.0;
      hull_c = #FF4D12;
      hull_border_x = w/20.0;
      hull_border_y = h/3.0;
      hull_border_w = w/10.0;
      hull_border_h = (2/3.0)*h - hull_border_x - power_d/2.0;
      hull_x = hull_border_x + border;
      hull_y = hull_border_y + border;
      hull_h = hull_border_h - 2*border - 0.05*width;
      hull_ox = hull_border_x + hull_border_w - border;
      hull_oy = hull_y + hull_h;
      temp_x = hull_border_x + hull_border_w + border;
      temp_y = 0.5*h;
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
      power_x = w-(w/20.0) - power_d/2.0;
      power_y = h -(w/20.0) - power_d/2.0;
      hull_c = #FF4D12;
      hull_border_x = w - (w/20.0) - (w/10.0);
      hull_border_y = h/3.0;
      hull_border_w = w/10.0;
      hull_border_h = (2/3.0)*h - (w/20.0) - power_d/2.0;
      hull_x = hull_border_x + border;
      hull_y = hull_border_y + border;
      hull_h = hull_border_h - 2*border - 0.05*width;
      hull_ox = hull_border_x + hull_border_w - border;
      hull_oy = hull_y + hull_h;
      temp_x = w - (w/20.0) - 1.4*hull_border_w - border;
      temp_y = 0.5*h;
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
    line( temp_bulb_x, temp_line_y, temp_bulb_x, temp_line_y - map( owner.temperature, 0, owner.temp_max, 0, temp_h ) );
    
    fill(0);
    stroke(power_c);
    ellipse( power_x, power_y, power_d, power_d );
    noStroke();
    fill(power_c);
    float d = map( owner.power, 0, owner.base_power, 0, power_d - 2*border);
    ellipse( power_x, power_y, d, d );
  }
}