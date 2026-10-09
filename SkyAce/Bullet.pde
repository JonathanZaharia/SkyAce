// Bullet.pde — fired by player (friendly=true) or enemy (false)
// Travels horizontally at fixed speed; removed when off-screen or over MAX_DIST.
class Bullet {
  float x, y, startX;
  boolean right, friendly;
  final float SPEED=10, MAX_DIST=650;

  Bullet(float x, float y, boolean right, boolean friendly) {
    this.x=this.startX=x; this.y=y; this.right=right; this.friendly=friendly;
  }

  void update() { x+=right?SPEED:-SPEED; }
  void display() { pushMatrix(); translate(x,y); if(!right) scale(-1,1); image(bulletImg,-bulletImg.width/2,-bulletImg.height/2); 
  popMatrix(); }

  boolean offScreen() { return x<-10||x>width+10||abs(x-startX)>MAX_DIST; }
  boolean hits(EnemyPlane e) { return  friendly&&dist(x,y,e.x,e.y)<26; }
  boolean hitsPlayer(Plane p){ return !friendly&&dist(x,y,p.x,p.y)<26; }
}
