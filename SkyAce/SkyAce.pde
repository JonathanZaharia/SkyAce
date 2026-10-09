// SkyAce.pde — Main sketch | Jonathan Zaharia | Final Version
import processing.sound.*;

// Game states
final int STATE_START=0, STATE_PLAYING=1, STATE_DYING=2, STATE_GAMEOVER=3;
final int[] LEVEL_THRESHOLDS = { 0, 25, 60, 110 };

// Difficulty tables — indexed by (level-1)
// Max 3–5 enemies as levels increase; more than 5 felt unfair
final float[] LVL_SPEED = { 1.5, 1.8, 2.2, 2.7 };
final int[]   LVL_FIRE  = { 100,  85,  70,  55  };
final int[]   LVL_COUNT = {   3,   4,   5,   5  };

// Game objects
Plane player;
Background bg;
ArrayList<EnemyPlane> enemies = new ArrayList<EnemyPlane>();
ArrayList<Bullet>     bullets = new ArrayList<Bullet>();
ArrayList<Explosion>  effects = new ArrayList<Explosion>();

// Game state variables
int gameState, score, bestScore, lives, level, bgBand, levelFlashTimer;
final int LEVEL_FLASH_DUR = 120;

// Shared images — loaded once, passed by reference to all objects
PImage titleImg, explosionImg, greySmoke, blackSmoke, bulletImg;
PImage pl1, pl2, pl3, plUp, plDown;        // player sprites
PImage enFr1, enFr2, enFr3, enUp, enDown; // enemy sprites

// Audio
SoundFile sfxShot, sfxExplosion, sfxEngines, sfxDiving, musicBg, musicVictory;

// Difficulty lookups — clamp so level 4+ never overflows the arrays
float lvlSpeed(int l) { return LVL_SPEED[constrain(l-1,0,3)]; }
int   lvlFire (int l) { return LVL_FIRE [constrain(l-1,0,3)]; }
int   lvlCount(int l) { return LVL_COUNT[constrain(l-1,0,3)]; }

// Setup
void setup() {
  size(900, 550); pixelDensity(1); frameRate(60);
  //Player images
  pl1=loadImage("green2.png"); //level plane varient one 
  pl2=loadImage("green3.png"); //level plane varient two 
  pl3=loadImage("green6.png"); //level plane varient three
  plUp=loadImage("green1.png"); //going down
  plDown=loadImage("green5.png"); //going up
  //Enemy images
  enFr1=loadImage("red3.png"); //level enemy plane varient one 
  enFr2=loadImage("red6.png"); //level enemy plane varient two
  enFr3=loadImage("red7.png"); //level enemy plane varient three
  enUp=loadImage("red5.png");  //enemy down
  enDown=loadImage("red8.png"); //enemy up

  bulletImg=loadImage("bullet.png"); //bullet sprite
  titleImg=loadImage("title.png"); //SkyAce logo on title page
  explosionImg=loadImage("explosion.png"); //fireball
  greySmoke=loadImage("greysmoke.png"); //used for explosions and damage state
  blackSmoke=loadImage("blacksmoke.png"); //used for explosions and damage state

  sfxShot=new SoundFile(this,"shot.mp3"); //for every shot
  sfxExplosion=new SoundFile(this,"explosion.mp3"); //used for explosions and damgae delt
  sfxEngines=new SoundFile(this,"engines.mp3"); //used for all planes
  sfxDiving=new SoundFile(this,"diving.mp3"); //used in death sequence of player
  musicBg=new SoundFile(this,"bird.mp3"); //main gameplay background music
  musicVictory=new SoundFile(this,"seashore.mp3"); //main title music

  musicVictory.loop(); //loop audio in case player does not start game
  musicVictory.amp(0.8); //less loud
  bg = new Background(width, height); //load background image
}

void draw() {
  switch (gameState) {
    case STATE_START: drawStart();    break; //game starts
    case STATE_PLAYING: drawPlaying();  break; //game plays, enemies and background
    case STATE_DYING: drawDying();    break; //freeze eneimes and play death animation
    case STATE_GAMEOVER: drawGameOver(); break; //black screen/transparent black scrren with scoreboard
  }
}

// Reset everything for a new game
void resetGame() {
  score=0; lives=3; level=1; bgBand=0; levelFlashTimer=0; //variables
  enemies.clear(); bullets.clear(); effects.clear(); //clear to not have multiply assests unused on screen
  player = new Plane(120, height/2, pl1, pl2, pl3, plUp, plDown);
  bg.startGame();
}

// Spawn one enemy off the right edge at current level stats
void spawnEnemy() {
  enemies.add(new EnemyPlane(
    width + 80 + random(300), random(80, height-80),
    lvlSpeed(level), lvlFire(level),
    enFr1, enFr2, enFr3, enUp, enDown
  ));
}

// Title screen 
void drawStart() {
  bg.update(); bg.display();
  if (titleImg!=null) { imageMode(CENTER); image(titleImg,width/2,250); imageMode(CORNER); }

  fill(10,10,40,200); noStroke(); rectMode(CENTER); rect(width/2,375,600,270,14); rectMode(CORNER); //give a black box for text to be on
  fill(255,220,50); textAlign(CENTER,CENTER); textSize(18); text("HOW TO PLAY",width/2,268);
  fill(220,220,255); textSize(13);
  int ly=295;
  text("W A S D  or  Arrow Keys  to  Move",width/2,ly);  //instructions
  ly+=24;
  text("SPACEBAR  to  Shoot", width/2,ly); 
  ly+=24;
  text("Kill enemies for +5 pts each", width/2,ly); 
  ly+=24;
  text("You have 3 lives, each life takes 3 hits to lose while your enemy takes 4 hits to die", width/2,ly); 
  ly+=24;
  text("Damage state is shown by a smoke trail behindthe plane. Grey smoke = 1 hit & Black smoke = 2 hits", width/2,ly); 
  ly+=24;
  text("Difficulty rises every 25 pts (max Level 4)", width/2,ly);
  ly+=24;
  text("Enemies will get faster and more numerous to a max of 5 enemies with each level", width/2,ly); 
  ly+=30;
  fill(100,200,255); textSize(20); text("Press ENTER to take off!",width/2,ly);
}

//Game over screen
void drawGameOver() {
  bg.display();
  fill(0,0,0,180); noStroke(); rect(0,0,width,height);
  textAlign(CENTER,CENTER);
  fill(255,60,60); 
  textSize(52); text("GAME OVER", width/2,height/2-95);
  fill(255);         
  textSize(22); text("Score: "+score, width/2,height/2-10); //current score
  text("Best: "+bestScore, width/2,height/2+34); //best score, when you close the program this gets reset
  text("Level: "+level, width/2,height/2+78);
  fill(255,255,100); 
  textSize(17); 
  text("Press ENTER to fly again",width/2,height/2+140);
}

//Main gameplay
void drawPlaying() {
  // Level-up check 
  int newLvl=1;
  for (int i=LEVEL_THRESHOLDS.length-1; i>=0; i--)
    if (score>=LEVEL_THRESHOLDS[i]) { newLvl=i+1; break; }
  if (newLvl!=level) {
    level=newLvl;
    levelFlashTimer=LEVEL_FLASH_DUR;
    // Upgrade existing enemies to new level stats immediately prevents spawning bug I had
    for (EnemyPlane e : enemies) { e.speed=lvlSpeed(level); e.shootDelay=lvlFire(level); }
  }

  // Background theme swap every 100 pts
  int band=score/100;
  if (band!=bgBand) { bgBand=band; bg.triggerCycle(); }

  // Spawn check if below cap, add one enemy, handles kills, level-ups, and start, this makes sure there is enough eneimes without going over the cap
  while (enemies.size() < lvlCount(level)) spawnEnemy();

  bg.update(); bg.display();
  player.handleInput(); player.update(); player.display();

  // Bullets
  for (int i=bullets.size()-1; i>=0; i--) {
    Bullet b=bullets.get(i);
    b.update(); b.display();
    if (b.offScreen()) { bullets.remove(i); continue; }
    //prevent eneimes from shooting eah other down
    if (b.friendly) {
      boolean hit=false;
      for (int j=0; j<enemies.size(); j++) {
        if (b.hits(enemies.get(j))) {
          if (enemies.get(j).hit(effects,explosionImg,greySmoke,blackSmoke)) {
            enemies.remove(j); score+=5; sfxExplosion.play();
          }
          hit=true; break;
        }
      }
      if (hit) bullets.remove(i);
    } else {
      if (b.hitsPlayer(player)) {
        bullets.remove(i); player.takeHit();
        if (player.hp<=0) { triggerDeath(); return; }
      }
    }
  }

  for (int i=0; i<enemies.size(); i++) { enemies.get(i).update(player,bullets); enemies.get(i).display(); }
  for (int i=effects.size()-1; i>=0; i--) { Explosion ex=effects.get(i); ex.update(); ex.display(); if(ex.done()) effects.remove(i); }

  drawHUD();
  drawLevelFlash(); //displays level number on screen to make it obvious 
}

// Death sequence 
void drawDying() {
  bg.update(); bg.display();
  for (int i=0; i<enemies.size(); i++) enemies.get(i).display();
  for (int i=effects.size()-1; i>=0; i--) { Explosion ex=effects.get(i); ex.update(); ex.display(); if(ex.done()) effects.remove(i); }
  player.updateDeath(); player.display();
  drawHUD();

  if (player.deathDone()) {
    if (lives<=0) {
      if (score>bestScore) bestScore=score;
      musicBg.stop(); sfxEngines.stop();
      gameState=STATE_GAMEOVER;
    } else {
      player=new Plane(120,height/2,pl1,pl2,pl3,plUp,plDown);
      bullets.clear(); gameState=STATE_PLAYING;
    }
  }
}

void triggerDeath() { lives--; sfxDiving.play(); player.startDeath(); gameState=STATE_DYING; }

// HUD
void drawHUD() {
  fill(0,0,0,150); noStroke(); rect(0,0,width,38);
  fill(255,220,50); textAlign(LEFT,CENTER); textSize(15); text("SCORE: "+score,12,19);
  float s=9, sp=6, tw=lives*(s*2+sp)-sp, sx=width/2-tw/2;
  for (int i=0; i<lives; i++) drawHeart(sx+i*(s*2+sp)+s,19,s);
  fill(180,255,180); textAlign(RIGHT,CENTER); textSize(15); text("LVL "+level+"   BEST: "+bestScore,width-12,19);
}

void drawHeart(float cx, float cy, float s) {
  fill(220,30,30); noStroke();
  ellipse(cx-s*.5,cy-s*.15,s*1.2,s*1.2); ellipse(cx+s*.5,cy-s*.15,s*1.2,s*1.2);
  triangle(cx-s,cy+s*.2, cx+s,cy+s*.2, cx,cy+s*1.2);
}

// Fades "LEVEL X" text on screen for LEVEL_FLASH_DUR frames after a level-up
void drawLevelFlash() {
  if (levelFlashTimer<=0) return;
  levelFlashTimer--;
  float p=levelFlashTimer/(float)LEVEL_FLASH_DUR;
  float a=(p>0.8)?map(p,1.0,0.8,0,255):(p<0.2)?map(p,0.2,0,255,0):255;
  int[] cr={100,255,255,255}, cg={220,220,140,50}, cb={100,50,30,50};
  int ci=constrain(level-1,0,3);
  textAlign(CENTER,CENTER); textSize(54);
  fill(0,0,0,a*.6); text("LEVEL "+level,width/2+3,height/2+3);
  fill(cr[ci],cg[ci],cb[ci],a); text("LEVEL "+level,width/2,height/2);
}

// ── Input ─────────────────────────────────────────────────────
void keyPressed() {
  if (keyCode==ENTER||keyCode==RETURN) {
    if (gameState==STATE_START) {
      musicVictory.stop(); musicBg.loop(); musicBg.amp(0.6);
      sfxEngines.loop(); sfxEngines.amp(0.25);
      resetGame(); gameState=STATE_PLAYING;
    } else if (gameState==STATE_GAMEOVER) {
      musicBg.loop(); musicBg.amp(0.6); sfxEngines.loop(); sfxEngines.amp(0.25);
      resetGame(); gameState=STATE_PLAYING;
    }
    return;
  }
  if (gameState!=STATE_PLAYING||player==null) return;
  if (key=='w'||keyCode==UP)    player.up=true;
  if (key=='s'||keyCode==DOWN)  player.down=true;
  if (key=='a'||keyCode==LEFT)  player.left=true;
  if (key=='d'||keyCode==RIGHT) player.right=true;
  if (key==' ')                 player.shooting=true;
}

void keyReleased() {
  if (gameState!=STATE_PLAYING||player==null) return;
  if (key=='w'||keyCode==UP)    player.up=false;
  if (key=='s'||keyCode==DOWN)  player.down=false;
  if (key=='a'||keyCode==LEFT)  player.left=false;
  if (key=='d'||keyCode==RIGHT) player.right=false;
  if (key==' ')                 player.shooting=false;
}
