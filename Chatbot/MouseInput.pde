boolean keyboard = false;

void mousePressed() {
  //System.out.println("mouseX="+mouseX+" mouseY="+mouseY);
  if (!keyboard) {
    openKeyboard();  // opens soft keyboard
    keyboard = true;
  } else {
    closeKeyboard();  // closes soft keyboard
    keyboard = false;
  }
}

void mouseWheel(MouseEvent event) {
  float e = event.getCount();
  if (e > 0) { 
    lastKeyCode = KEYCODE_DOWN;
    lastKey = 0;
  }
  else if (e < 0) {
    lastKeyCode = KEYCODE_UP;
    lastKey = 0;
  } 
  //else {
  //lastKey = 0;
  //lastKeyCode = 0;
  //}
  //println(event);
}
