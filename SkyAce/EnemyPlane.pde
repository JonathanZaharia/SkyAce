// EnemyPlane.pde Enemy biplane

class EnemyPlane {
  float x, y, speed;
  int   hp=3, shootDelay, shootTimer=0, iFrames=0, animFrame=0, animTimer=0;
  final int I_FRAME_DUR=12, ANIM_SPEED=5;
  boolean facingRight=false;
  PImage fr1, fr2, fr3, frUp, frDown;

  // NEW: stable vertical animation state
  int verticalState = 0; // -1 = up, 1 = down, 0 = level

  EnemyPlane(float x, float y, float spd, int delay,
             PImage f1, PImage f2, PImage f3, PImage up, PImage dn) {
    this.x=x; this.y=y; speed=spd; shootDelay=delay;
    fr1=f1; fr2=f2; fr3=f3; frUp=up; frDown=dn;
  }

  void update(Plane player, ArrayList<Bullet> bullets) {

    // Chase player position (horizontal)
    if (player.x < x) x -= speed;
    else x += speed;

    // Chase player position (vertical) + set animation state
    if (player.y < y - 2) {
      y -= speed * .7;
      verticalState = -1; // going up
    } 
    else if (player.y > y + 2) {
      y += speed * .7;
      verticalState = 1;  // going down
    } 
    else {
      verticalState = 0;  // level flight
    }

    facingRight = (player.x > x);

    y = constrain(y,45,height-45);

    if (iFrames > 0) iFrames--;

    // Rocking animation cycle (only used when level)
    if (++animTimer >= ANIM_SPEED) { 
      animTimer = 0; 
      animFrame = (animFrame + 1) % 3; 
    }

    // Shooting
    if (++shootTimer >= shootDelay) { 
      shootTimer = 0; 
      bullets.add(new Bullet(x+(facingRight?30:-30), y, facingRight, false)); 
    }

    // Respawn if off screen
    if (x < -60) respawn(width+random(100,350), random(80,height-80)); 
  }

  void display() {
    PImage img;

    // Use stable animation state instead of dy
    if (verticalState == -1) {
      img = frUp;
    } 
    else if (verticalState == 1) {
      img = frDown;
    } 
    else {
      // Default rocking animation
      img = (animFrame == 0) ? fr1 : (animFrame == 1) ? fr2 : fr3;
    }

    if (iFrames > 0 && iFrames % 3 < 2) tint(255,180,180); // flash red when hit

    pushMatrix(); 
    translate(x,y); 
    scale(facingRight?1:-1,1); // sprite flip
    image(img,-img.width/2,-img.height/2); 
    popMatrix(); 
    noTint();

    if (hp == 2) drawSmoke(greySmoke, 130); // damage smoke simialr to player
    if (hp == 1) drawSmoke(blackSmoke,160);
  }

  void drawSmoke(PImage sm, float alpha) {
    if (sm == null) return;
    tint(255,alpha); imageMode(CENTER);
    image(sm, facingRight?x-32:x+32, y+sin(frameCount*.3)*6, sm.width*.55, sm.height*.55);
    imageMode(CORNER); noTint();
  }

  // Returns true if this hit killed the plane; caller removes from list
  boolean hit(ArrayList<Explosion> fx, PImage exp, PImage grey, PImage blk) {
    if (iFrames > 0) return false; // immune from last hit
    iFrames = I_FRAME_DUR; 
    hp--;
    if (hp <= 0) { 
      fx.add(new Explosion(x,y,exp,grey,blk)); 
      return true; 
    }
    return false;
  }

  // Only called when enemy drifts off left edge (not a kill no score)
  void respawn(float nx, float ny) { 
    x = nx; 
    y = ny; 
    hp = 3; 
    iFrames = 0; 
    shootTimer = 0; 
  }
}
