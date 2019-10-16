import java.util.List;
import java.util.ArrayList;
import controlP5.*;

ControlP5 slidert1;
ControlP5 slidert2;
ControlP5 slidert3;
ControlP5 sliderspeed;
ControlP5 sliderr1;
ControlP5 sliderr2;
ControlP5 sliderr3;
ControlP5 slidercenter;
ControlP5 slideravoid;

float t1 = 10;
float t2 = 20;
float t3 = 30;
float r1;
float r2;
float r3;
float SPEED = 3;
float CENTER_PULL_FACTOR = 100;
float AVOID = 1;
List<Fish> flock = new ArrayList<Fish>();

void setup(){
  size(800, 800);
  frameRate(30);
  background(255);

  int num = 100;
  for(int i=0;i<num;i++){
    flock.add(new Fish(random(0,width),random(0,width),i));
  }

  PFont font = createFont("Arial", 30);  //この際に最大サイズを決める
  textFont(font);  //設定したフォントを使用

  slidert1 = new ControlP5(this);
  slidert2 = new ControlP5(this);
  slidert3 = new ControlP5(this);
  sliderr1 = new ControlP5(this);
  sliderr2 = new ControlP5(this);
  sliderr3 = new ControlP5(this);
  sliderspeed = new ControlP5(this);
  slidercenter = new ControlP5(this);
  slideravoid = new ControlP5(this);
  slidert1.addSlider("slidert1").setRange(1,30).setPosition(10,10).setValue(t1).setColorCaptionLabel(0);;
  slidert2.addSlider("slidert2").setRange(1,20).setPosition(10,20).setValue(10).setColorCaptionLabel(0);;
  slidert3.addSlider("slidert3").setRange(1,20).setPosition(10,30).setValue(20).setColorCaptionLabel(0);;
  sliderspeed.addSlider("sliderspeed").setLabel("speed").setRange(1,10).setPosition(10,40).setValue(SPEED).setColorCaptionLabel(0);
  sliderr1.addSlider("sliderr1").setRange(0.1,1).setPosition(10,50).setValue(1.0).setColorCaptionLabel(0);;
  sliderr2.addSlider("sliderr2").setRange(0.1,1).setPosition(10,60).setValue(0.8).setColorCaptionLabel(0);;
  sliderr3.addSlider("sliderr3").setRange(0.1,1).setPosition(10,70).setValue(0.1).setColorCaptionLabel(0);;;
  slidercenter.addSlider("slidercenter").setRange(30,200).setPosition(10,80).setValue(100).setColorCaptionLabel(0);
  slideravoid.addSlider("slideravoid").setRange(0.1,5).setPosition(10,90).setValue(1).setColorCaptionLabel(0);

}

void draw(){

  valueupdate();
  noStroke();
  fill(255, 255,255, 50);
  rect(0, 0, width, height);
  for(Fish fish:flock){
    fish.update();
    fish.display();
  }
}

void valueupdate(){
  t1 = slidert1.getValue("slidert1");
  t2 = t1+slidert2.getValue("slidert2");
  t3 = t2+slidert3.getValue("slidert3");
  SPEED = sliderspeed.getValue("sliderspeed");
  r1 = sliderr1.getValue("sliderr1");
  r2 = sliderr2.getValue("sliderr2");
  r3 = sliderr3.getValue("sliderr3");
  CENTER_PULL_FACTOR = slidercenter.getValue("slidercenter");
  AVOID = slideravoid.getValue("slideravoid");
}


class Fish{
  float x,y;
  float vx,vy;
  int id;
  PVector v1 = new PVector(0,0);
  PVector v2 = new PVector(0,0);
  PVector v3 = new PVector(0,0);

  Fish(float x,float y,int id){
    this.x = x;
    this.y = y;
    this.vx = random(-5, 5);
    this.vy = random(-5, 5);
    this.id = id;
  }

  void display(){
    stroke(0);
    strokeWeight(3);
    point(x%width,y%width);

    // textSize(12);  // フォントの表示サイズ
    // fill(0);
    // text("*ぶ",x%width,y%width);
  }

  void update(){

    clearVector();
    check();

    vx += r1*v1.x+r2*v2.x+r3*v3.x;
    vy += r1*v1.y+r2*v2.y+r3*v3.y;


    float movement = sqrt(this.vx * this.vx + this.vy * this.vy);
    // 移動距離が一定以上だったら
    if(movement > SPEED) {
      // 減速させる
      vx = (vx / movement) * SPEED;
      vy = (vy / movement) * SPEED;
    }

    x += vx;
    y += vy;


  }

  void check(){
    center();
    avoid();
    average();
  }

  void center(){
    int count = 0;
    float len;
    for(Fish fish:flock){
      if(fish.id==this.id){
        continue;
      }
      len = dist(this.x, this.y, fish.x, fish.y);
      if(len > t2 && len < t3){
        this.v1.x += fish.x;
        this.v1.y += fish.y;
        count++;
      }
    }
    if(count>0){
      v1.div(count);
      v1.x = (this.v1.x - this.x) / CENTER_PULL_FACTOR;
      v1.y = (this.v1.y - this.y) / CENTER_PULL_FACTOR;
    }
  }

  void avoid(){
    for(Fish fish:flock){
      if(fish.id==this.id){
        continue;
      }
      if(dist(this.x, this.y, fish.x, fish.y) < t1) {
        // 離れるために、逆方向に動く
        this.v2.x -= (fish.x - this.x)/AVOID;
        this.v2.y -= (fish.y - this.y)/AVOID;
      }
    }
  }

  void average(){
    int count = 0;
    float len;
    for(Fish fish:flock){
      if(fish.id==this.id){
        continue;
      }
      len = dist(this.x, this.y, fish.x, fish.y);
      if(len > t1 && len < t2){
        this.v3.x += fish.x;
        this.v3.y += fish.y;
        count++;
      }
    }
    if(count>0){
      v3.div(count);
      v3.x = (this.v3.x - this.x) / CENTER_PULL_FACTOR;
      v3.y = (this.v3.y - this.y) / CENTER_PULL_FACTOR;
    }
  }

  void clearVector(){
    v1.set(0,0);
    v2.set(0,0);
    v3.set(0,0);
  }

}