class line_segment{
  public float a, b, xi, xf;
  line_segment(){}
  line_segment( PVector i, PVector f ){
    if( f.x < i.x ){
      PVector temp = i.get();
      i = f.get();
      f = temp.get();
    }
    xi = i.x;
    xf = f.x;
    a = (f.y - i.y) / (f.x - i.x);
    b = i.y - (a * i.x);
  }
  line_segment( PVector o, float theta, float l){
    float co = l * cos( theta+HALF_PI );
    float si = l * sin( theta+HALF_PI );
    PVector i = new PVector(o.x - co, o.y - si);
    PVector f = new PVector(o.x + co, o.y + si);
    if( f.x < i.x ){
      PVector temp = i.get();
      i = f.get();
      f = temp.get();
    }
    xi = i.x;
    xf = f.x;
    a = (f.y - i.y) / (f.x - i.x);
    b = i.y - (a * i.x);
  }
  PVector intersection( line_segment ls ){
    float x = (ls.b - b) / (a - ls.a);
    if( ( (x < xf) && (x > xi) ) && ( (x < ls.xf) && (x > ls.xi) ) ) return new PVector( x, a*x + b );
    else return null;
  }
  void display(){
    stroke(255);
    line(xi, a*xi + b, xf, a*xf + b ); 
  }
}

class Ray{
  float a, b, xi;
  boolean rightward;
  Ray(){}
  Ray(PVector o, float theta){
    xi = o.x;    
    rightward  = ( cos(theta) > 0 )? true : false;
    a = tan(theta);
    b = o.y - (a * o.x);
  }
    
  boolean intersection( line_segment ls ){
    float x = (ls.b - b) / (a - ls.a);
    if( ( (rightward && (x > xi)) || (!rightward && (x < xi)) ) && ( (x < ls.xf) && (x > ls.xi) ) ) return true;
    else return false;
  }
  PVector intersect( line_segment ls ){
    float x = (ls.b - b) / (a - ls.a);
    //println("if( ( (rightward && (x > xi)) || (!rightward && (x < xi)) ) && ( (x < ls.xf) && (x > ls.xi) ) )");
    //println("if( ( ("+rightward+" && ("+x+" > "+xi+")) || (!"+rightward+" && ("+x+" < "+xi+")) ) && ( ("+x+" < "+ls.xf+") && ("+x+" > "+ls.xi+") ) )");
    if( ( (rightward && (x > xi)) || (!rightward && (x < xi)) ) && ( (x < ls.xf) && (x > ls.xi) ) ) return new PVector( x, a*x + b );
    else return null;
  }
  void display(){
    stroke(255);
    if( rightward ) line(xi, a*xi + b, xi + 1000, a*(xi+1000) + b ); 
    else line(xi, a*xi + b, xi - 1000, a*(xi-1000) + b ); 
  }
}

float ellipticalMap(float value, float start1, float stop1, float start2, float stop2){
  return stop2 +((start2-stop2)/abs(start2-stop2))*sqrt((1-(sq(value-start1)/sq(stop1-start1)))*sq(stop2-start2));
}