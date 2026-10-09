// Plane.pde — Player plane
// 3 HP per life. Grey smoke at 2 HP, black smoke at 1 HP.
// On death nose-dives off screen, then explosion VFX plays at exit point.
class Plane {
  float x, y;
  final float SPEED = 5;

  // Input flags set by keyPressed/keyReleased in SkyAce.pde
  boolean up, down, left, right, shooting, facingRight=true;

  int hp=3;

  // Sprites: 3 prop frames + up/down
  PImage lv1, lv2, lv3, tiltUp, tiltDown;
  int animFrame=0, animTimer=0;
  final int ANIM_SPEED=5, SHOOT_RATE=10;
  int shootTimer=0;

  // Death arc state
  boolean dying=false, arcDone=false;
  float dvx, dvy, lastX, lastY;
  int vfxTimer=0;
  final int DUR_EXP=18, DUR_GREY=22, DUR_BLACK=30;

  Plane(float x, float y, PImage l1, PImage l2, PImage l3, PImage up, PImage dn) {
    this.x=x; this.y=y;
    lv1=l1; lv2=l2; lv3=l3; tiltUp=up; tiltDown=dn;
  }

  void handleInput() {
    if (dying) return;
    if (left)  { x-=SPEED; facingRight=false; }
    if (right) { x+=SPEED; facingRight=true;  }
    if (up)    y-=SPEED;
    if (down)  y+=SPEED;
    x=constrain(x,0,width-50); y=constrain(y,45,height-50);
    // Fire at fixed rate while SPACE held
    if (shooting) { if (++shootTimer%SHOOT_RATE==0) { bullets.add(new Bullet(x+(facingRight?30:-30),y,facingRight,true)); sfxShot.play(); } }
    else shootTimer=0;
  }

  void update() {
    if (dying) return;
    if (++animTimer>=ANIM_SPEED) { animTimer=0; animFrame=(animFrame+1)%3; }
  }

  void takeHit() { hp--; } // caller checks hp<=0 and triggers death

  void display() {
    if (dying) { displayDeath(); return; }
    // Pick sprite: tilt on vertical input, else cycle prop frames
    PImage img = (up&&!down)?tiltUp : (down&&!up)?tiltDown :
                 (animFrame==0)?lv1 : (animFrame==1)?lv2 : lv3;
    pushMatrix(); translate(x,y); scale(facingRight?1:-1,1);
    image(img,-img.width/2,-img.height/2); popMatrix();
    // Damage smoke trail — grey at 2 HP, black at 1 HP
    if (hp==2) drawSmoke(greySmoke,  130);
    if (hp==1) drawSmoke(blackSmoke, 160);
  }

  // Drifting smoke puff trailing behind the plane
  void drawSmoke(PImage sm, float alpha) {
    if (sm==null) return;
    tint(255,alpha); imageMode(CENTER);
    image(sm, facingRight?x-32:x+32, y+sin(frameCount*0.3)*6, sm.width*.55, sm.height*.55);
    imageMode(CORNER); noTint();
  }

  // Kick off nose-dive: slight horizontal carry, gravity builds each frame
  void startDeath() {
    dying=true; arcDone=false; vfxTimer=0;
    dvx=facingRight?2.0:-2.0; dvy=1.5;
    lastX=x; lastY=y;
  }

  void updateDeath() {
    if (!dying||arcDone) { if (arcDone) vfxTimer++; return; }
    dvy+=0.4; x+=dvx; y+=dvy;     // accelerating dive
    lastX=x; lastY=y;
    if (y>height+lv1.height) arcDone=true;
  }

  void displayDeath() {
    if (!arcDone) {
      // Plane visible diving nose-down
      pushMatrix(); translate(x,y); scale(facingRight?1:-1,1);
      image(tiltDown,-tiltDown.width/2,-tiltDown.height/2); popMatrix();
    } else {
      // VFX at the bottom-edge exit point
      imageMode(CENTER);
      float vx=lastX, vy=min(lastY,height-20);
      if (vfxTimer<=DUR_EXP) { if(explosionImg!=null) image(explosionImg,vx,vy); }
      else if (vfxTimer<=DUR_EXP+DUR_GREY) { if(greySmoke!=null) image(greySmoke,vx,vy); }
      else if (vfxTimer<=DUR_EXP+DUR_GREY+DUR_BLACK){ tint(255,map(vfxTimer-DUR_EXP-DUR_GREY,0,DUR_BLACK,255,0));
      if(blackSmoke!=null) image(blackSmoke,vx,vy); noTint(); }
      imageMode(CORNER);
    }
  }

  boolean deathDone() { return arcDone && vfxTimer>DUR_EXP+DUR_GREY+DUR_BLACK; }
}
