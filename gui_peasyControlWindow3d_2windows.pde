/*
  graphic interface controlling 2 windows display 3D contents with camera manipulation when mouse over
  2017-12-29 Anderson Sudario 
*/

import peasy.*;
import controlP5.*;

PeasyCam cam;
ControlP5 gui;

PMatrix cameraMatrix;
Contents contentsA, contentsB;

void setup() {
  size(800, 400, P3D);
  PGraphics window3d = createGraphics(300, 300, P3D);
  cam = new PeasyCam(this, 300);
  gui = new ControlP5(this);
  gui.setAutoDraw(false);
  gui.addButton("colorA").setSize(40, 40).setPosition(30, 30);
  gui.addButton("colorB").setSize(40, 40).setPosition(400, 30);
  gui.addCanvas(contentsA = new Contents(50, 60, window3d));
  gui.addCanvas(contentsB = new Contents(400, 60, window3d).setLockRotation(true));
  gui.addLabel("Free Camera").setPosition(160, 70);
  gui.addLabel("Pan/Zoom Camera").setPosition(510, 70);
  gui.addFrameRate();
}

void colorA() {
  contentsA.setCubeColor ( (color) random(#000000) );
}
void colorB() {
  contentsB.setCubeColor ( (color) random(#000000) );
}


void draw() {
  background(200);
  updateCameraMatrix();
  contentsA.update();
  contentsB.update();
  hint(DISABLE_DEPTH_TEST);
  cam.beginHUD();
  
  gui.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void updateCameraMatrix() {
  cameraMatrix = g.getMatrix((PMatrix3D)null);
}


class Contents extends controlP5.Canvas {
  int cubeColor = -1;
  int x, y;
  PGraphics graphic;
  PMatrix lastMatrix;
  PMatrix activeMatrix;
  CameraState camState;
  boolean updateCamera = true;
  boolean holdCamera = false;
  boolean lockRotation = false;

  public Contents(int x, int y, PGraphics graphic) {
    //this.name = name;
    this.x = x;
    this.y = y;
    this.graphic = graphic;
    getCamera();
    setMode(0);
  }
  
  public void update(){
    manageActiveWindow();
  }
  
  
  public void draw(PGraphics pg) {
    drawContents();
    pg.image(graphic, x, y);
  }
  void drawContents() {
    graphic.beginDraw();
    graphic.setMatrix(activeMatrix);
    graphic.background(color(-1, (isMouseOver())?50:20));
    graphic.fill(cubeColor);
    graphic.box(100);
    graphic.pushMatrix();
    graphic.translate(120, 0);
    graphic.box(100);
    graphic.popMatrix();
    graphic.endDraw();
  }

  void manageActiveWindow() {
    if (isMouseOver() || updateCamera) {
      if(lockRotation) {
         cam.setLeftDragHandler(cam.getPanDragHandler());
      }else{
        cam.setLeftDragHandler(cam.getRotateDragHandler());
      }
      if (holdCamera) {
        holdCamera = false;
        setCamera();
      }
      activeMatrix = cameraMatrix ;
      getCamera();
      updateCamera = false;
    } else {
      holdCamera = true;
      activeMatrix = lastMatrix;
    }
  }

  void getCamera() {
    lastMatrix = cameraMatrix;
    camState  = cam.getState();
  }

  void setCamera() {
    cam.setState(camState, 0);
    updateCameraMatrix();
  }

  Contents setCubeColor(int c) {
    cubeColor = c;
    return this;
  }
  
  Contents setLockRotation(boolean b){
    lockRotation = b;
    return this;
  }

  boolean isMouseOver() {
    return (mouseX > x && mouseX < x + graphic.width) && (mouseY > y && mouseY < y + graphic.height);
  }
}