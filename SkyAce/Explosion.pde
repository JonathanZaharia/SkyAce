// Explosion.pde — 3-phase VFX: flash → grey smoke → black smoke (fades out)
// Spawned on enemy kill. done() signals safe removal from the effects list.
class Explosion {
  float x, y;
  PImage expImg, greyImg, blackImg;
  int timer=0;
  final int DUR_EXP=15, DUR_GREY=22, DUR_BLACK=30;

  Explosion(float x, float y, PImage e, PImage g, PImage b) {
    this.x=x; this.y=y; expImg=e; greyImg=g; blackImg=b;
  }

  void update() { timer++; }

  void display() {
    imageMode(CENTER);
    if      (timer<=DUR_EXP) { if(expImg !=null) image(expImg, x,y); }
      else if (timer<=DUR_EXP+DUR_GREY) { if(greyImg!=null) image(greyImg,x,y); }
      else if (timer<=DUR_EXP+DUR_GREY+DUR_BLACK){ tint(255,map(timer-DUR_EXP-DUR_GREY,0,DUR_BLACK,255,0));
    if(blackImg!=null) image(blackImg,x,y); noTint(); }
    imageMode(CORNER);
  }

  boolean done() { return timer>DUR_EXP+DUR_GREY+DUR_BLACK; }
}
