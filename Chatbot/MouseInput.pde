boolean keyboard = false;  // for Android pop-up keyboard
int mouseButtonAlert = 0;

void mousePressed() {
  //System.out.println("mouseX="+mouseX+" mouseY="+mouseY);
  if (!keyboard) {
    openKeyboard();  // opens soft keyboard
    keyboard = true;
  } else {
    closeKeyboard();  // closes soft keyboard
    keyboard = false;
  }
  if (mouseButton == LEFT) {
    //if (DEBUG) println("LEFT");
    mouseButtonAlert = LEFT;
  } else if (mouseButton == RIGHT) {
    //if (DEBUG) println("RIGHT");
    if (DEBUG) println(mouseButton);
    mouseButtonAlert = RIGHT;
  } else {
    //if (DEBUG) println("CENTER");
    mouseButtonAlert = CENTER;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) {
    lastKeyCode = KEYCODE_DOWN;
    lastKey = 0;
  } else if (e < 0) {
    lastKeyCode = KEYCODE_UP;
    lastKey = 0;
  }
}
