boolean keyboard = false;  // for Android pop-up keyboard
int mouseButtonAlert = 0;

void mousePressed() {
  //System.out.println("mouseX="+mouseX+" mouseY="+mouseY);
  first = false;
  if (!keyboard) {
    openKeyboard();  // opens soft keyboard
    keyboard = true;
  } else {
    closeKeyboard();  // closes soft keyboard
    keyboard = false;
  }
  if (mouseButton == LEFT) {
    //logger("LEFT");
    mouseButtonAlert = LEFT;
  } else if (mouseButton == RIGHT) {
    //logger("RIGHT");
    logger(str(mouseButton));
    mouseButtonAlert = RIGHT;
  } else {
    //logger("CENTER");
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
