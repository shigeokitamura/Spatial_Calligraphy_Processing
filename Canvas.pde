import msafluid.*;
import processing.net.*;

Server server;

final float FLUID_WIDTH = 50;

float invWidth, invHeight;
float aspectRatio, aspectRatio2;

float serverX = 0;
float serverY = 0;

MSAFluidSolver2D fluidSolver;

ParticleSystem particleSystem;

boolean drawFluid = false;
boolean splash = true;

PImage imgbuffer;

void setup() {
  size(640, 480, P3D);    // use OPENGL rendering for bilinear filtering on texture
  imgbuffer = createImage(width, height, RGB);
  for(int i = 0; i < imgbuffer.pixels.length; i++) {
    imgbuffer.pixels[i] = color(255, 255, 255);
  }
  image(imgbuffer, 0, 0);
  smooth();
  frameRate(60);
  
  server = new Server(this, 20000);
  
  invWidth = 1.0f/width;
  invHeight = 1.0f/height;
  aspectRatio = width * invHeight;
  aspectRatio2 = aspectRatio * aspectRatio;

  // create fluid and set options
  fluidSolver = new MSAFluidSolver2D((int)(FLUID_WIDTH), (int)(FLUID_WIDTH * height/width));
  fluidSolver.enableRGB(true).setFadeSpeed(1.0).setDeltaT(0.5).setVisc(0.005);

  // create particle system
  particleSystem = new ParticleSystem();
  
}

/*
void mouseMoved() {
  float mouseNormX = mouseX * invWidth;
  float mouseNormY = mouseY * invHeight;
  float mouseVelX = (mouseX - pmouseX) * invWidth;
  float mouseVelY = (mouseY - pmouseY) * invHeight;
  if(drawFluid == true) {
    addForce(mouseNormX, mouseNormY, mouseVelX, mouseVelY);
  }
}
*/

void draw() {
  fluidSolver.update();  
  receive();
}

/*
void mousePressed() {
  drawFluid ^= true;
}
*/

void receive() {
  Client c = server.available();
  if(c != null) {
    String s = c.readStringUntil('\n');
    if(s != null) {
      String[] data = splitTokens(s);
      drawFluid = boolean(data[3]);
      float NormX = float(data[0]) * invWidth;
      float NormY = float(data[1]) * invHeight;
      float VelX = (float(data[0]) - serverX) * invWidth;
      float VelY = (float(data[1]) - serverY) * invHeight;
      float power = float(data[2]) * 5;
      if(power > 6.0) {
        power = 6.0;
      }
      //println(power);
      if(drawFluid == true) {
        addForce(NormX, NormY, VelX, VelY, power);
        particleSystem.updateAndDraw();
        if(splash == true) {
          if(power > 0) {
            drawSplash(power);
          }else{
            splash = false;
          }
        }
      }else if(drawFluid == false){
        splash = true;
      }
      serverX = float(data[0]);
      serverY = float(data[1]);
      println(serverX, serverY, power, drawFluid);
    }
  }
}

void drawSplash(float power) {
  int circle_num = 100;//円の数

  float centerPointx[] = new float[circle_num];     //中心からのx軸方向ズレ用配列100枠用意
  float centerPointy[] = new float[circle_num];     //中心からのy軸方向ズレ用配列100枠用意
  float radiansx[] = new float[circle_num];         //円の直径（x）の配列
  float radiansy[] = new float[circle_num];         //円の直径（y）の配列
  
  float aroundcirclex[] = new float[circle_num/2];  //周りの飛び散った感の円用配列
  float aroundcircley[] = new float[circle_num/2];  //周りの飛び散った感の円用配列
  
  power *= 5;
  
  if(power < 0) power = 0;
  //println(power);
  for (int i = 0; i < circle_num; i++) {
    float rand1 = power;
    
    centerPointx[i] = random(-rand1, rand1);
    centerPointy[i] = random(-rand1, rand1);
    radiansx[i] = random(-30, 30);
    radiansy[i] = random(-30, 30);
    fill(33.0f/255.0f, 34.0f/255.0f, 34.0f/255.0f);
    ellipse(serverX + centerPointx[i], serverY + centerPointy[i], radiansx[i], radiansy[i]);
    
  }

  //周りの円描画
  for (int j = 0; j < 5; j++) {

    aroundcirclex[j] = random(-80, 80);
    aroundcircley[j] = random(-1, 20);
    fill(33.0f/255.0f, 34.0f/255.0f, 34.0f/255.0f);
    ellipse(serverX, serverY, aroundcirclex[j], aroundcircley[j]);
  }
  
  for (int i = 0; i < power; i++) {
    int rnd = (int)random(1, 10);
    fill(33.0f/255.0f, 34.0f/255.0f, 34.0f/255.0f);
    ellipse(serverX + random(-power*3, power*3), serverY + random(-power*3, power*3), rnd, rnd);    
  }
  splash = false;
}

// add force and dye to fluid, and create particles
void addForce(float x, float y, float dx, float dy, float power) {
    float speed = dx * dx  + dy * dy * aspectRatio2;    // balance the x and y components of speed with the screen aspect ratio

    if(speed > 0) {
        if(x<0) x = 0; 
        else if(x>1) x = 1;
        if(y<0) y = 0; 
        else if(y>1) y = 1;

        //float colorMult = 5;
        float velocityMult = 30.0f;

        int index = fluidSolver.getIndexForNormalizedPosition(x, y);


        color drawColor;

        colorMode(HSB, 360, 1, 1);
        float hue = ((x + y) * 180 + frameCount) % 360;
        drawColor = color(hue, 1, 1);
        colorMode(RGB, 1);  

        particleSystem.addParticles(x * width, y * height, 20, speed);
        fluidSolver.uOld[index] += dx * velocityMult;
        fluidSolver.vOld[index] += dy * velocityMult;
    }
}

void keyPressed() {
  saveFrame("####.jpg");
  background(255, 255, 255);
}
