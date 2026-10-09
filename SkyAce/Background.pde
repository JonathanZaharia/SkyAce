// Background.pde with Three-layer parallax with slide transition
// Layers: base (slow), clouds (mid), other clouds (fast)
// My pride and joy of this project, but this caused so many bugs, and performance issues
// With it, it looks cool and and performs at a reasonale pace, without it all other functions perfrom quicker as framerate goes up
// Lower end hardware will suffer, and higher end hardware will suffer for differint reasons. 
class Background {
  PImage dayBase, dayClouds, dayFG; 
  PImage sunsetBase, sunsetClouds, sunsetFG;
  PImage titleBg;
  PImage currBase, currClouds, currFG;
  PImage nextBase, nextClouds; //loading next image

  float baseX=0, cloudsX=0, fgX=0;  // current panel offsets
  float baseX_next=0, cloudsX_next=0;  // incoming panel offsets

  final float BASE_SPD=1.0, CLOUDS_SPD=1.6, FG_SPD=2.4;

  int w, h;
  boolean transitioning=false, inTitle=true;
  float titleX=0;
  final float ocean8Y=280; // Ocean8 sits lower; solid sky fills the gap above this  was done 
                          //have to image assets better aligned as all backgrounds used had differint settings.

  Background(int w, int h) {
    this.w=w; this.h=h;
    titleBg      = loadImage("Ocean4.5.png"); //title page background this has all layers baked into one image 
                                              //(this methods would have been best for performance but looked less cool
    dayBase      = loadImage("Ocean8.1.png"); //base layer
    dayClouds    = loadImage("Ocean8.3.png"); //high clouds
    dayFG        = loadImage("Ocean8.4.png"); //low clouds
    sunsetBase   = loadImage("Ocean5.1.png"); //base layer
    sunsetClouds = loadImage("Ocean5.3.png"); //high clouds
    sunsetFG     = loadImage("Ocean5.4.png"); //low clouds
    inTitle=true;
  }

  // Called on ENTER switch from title image to game layers
  void startGame() {
    inTitle=false;
    currBase=dayBase; currClouds=dayClouds; currFG=dayFG;
    baseX=cloudsX=fgX=0; nextBase=nextClouds=null; transitioning=false;
  }

  // Toggle day/sunset every 100 pts
  void triggerCycle() {
    if (transitioning) return;
    if (currBase==dayBase) { nextBase=sunsetBase; nextClouds=sunsetClouds; }
    else { nextBase=dayBase; nextClouds=dayClouds;    }
    baseX_next=cloudsX_next=w; transitioning=true;
  }

  void update() {
    if (inTitle) { titleX=wrapOffset(titleX-BASE_SPD, titleBg!=null?titleBg.width:w); return; }

    baseX   = wrapOffset(baseX - BASE_SPD, currBase !=null?currBase.width:w);
    cloudsX = wrapOffset(cloudsX - CLOUDS_SPD, currClouds!=null?currClouds.width:w);
    fgX     = wrapOffset(fgX - FG_SPD, currFG !=null?currFG.width:w);

    if (transitioning) {
      baseX_next -= BASE_SPD;
      cloudsX_next -= CLOUDS_SPD;
      if (baseX_next<=0) {
        // Incoming panel reaches screen edge then promote to current
        currBase=nextBase; currClouds=nextClouds;
        currFG=(nextBase==dayBase)?dayFG:sunsetFG;
        baseX=wrapOffset(baseX_next,currBase.width);
        cloudsX=wrapOffset(cloudsX_next,currClouds.width);
        fgX=0; nextBase=nextClouds=null; transitioning=false;
      }
    }
  }

  void display() {
    if (inTitle) { drawLayer(titleBg,titleX); return; }

    // Base ocean layer
    if (currBase==dayBase) drawOcean8(baseX); else drawLayer(currBase,baseX);
    if (transitioning) {
      if (nextBase==dayBase) drawOcean8(baseX_next); else drawLayer(nextBase,baseX_next);
    }

    // Cloud layers on top
    drawLayer(currClouds,cloudsX);
    if (transitioning) drawLayer(nextClouds,cloudsX_next);

    // FG clouds only outside transition (saves 1-2 draw calls during slide)
    if (!transitioning) drawLayer(currFG,fgX);
  }

  // Tile image horizontally to fill screen width
  void drawLayer(PImage img, float ox) {
    if (img==null) return;
    int copies=ceil((float)w/img.width)+1;
    for (int i=0; i<copies; i++) image(img,ox+i*img.width,0,img.width,h);
  }

  // Ocean8 special solid sky colour above ocean8Y, image moved below it to match the other ocean background
  void drawOcean8(float ox) {
    fill(135,206,250); noStroke(); rect(0,0,w,(int)ocean8Y);
    int copies=ceil((float)w/dayBase.width)+1;
    for (int i=0; i<copies; i++) image(dayBase,ox+i*dayBase.width,ocean8Y,dayBase.width,h-ocean8Y);
  }

  // Keeps scroll offset in (-tileW, 0] — prevents drift on any image size
  float wrapOffset(float v, int tileW) {
    if (tileW<=0) return v;
    v=v%tileW; if (v>0) v-=tileW; return v;
  }
}
