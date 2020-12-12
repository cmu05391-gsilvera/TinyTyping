import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested - set this low for testing. Might be ~10 for the real bakeoff!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 120; //you will need to look up the DPI or PPI of your device to make sure you get the right scale. Or play around with this value.
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
PImage finger;

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

// Variables for keyboard
float TLx;  // x pos of top left corner of the keyboard
float TLy; // y pos of top left corner of the keyboard
boolean left_keyboard = true;
boolean mouse_down = false;
      
float clamp (float x, float lo, float hi){
   return min(hi, max(x, lo));
}

public class Key {
  char character;
  float x, y, size;
  float mag_size = 40;
  public Key (char c, float posx, float posy, float s){
    character = c;
    x = posx;
    y = posy;
    size = s;
  }
  
  boolean clicked(float x_offset){
    // returns true if mouse click within bounds, false otherwise
    return(mouseX > x + x_offset && mouseX < x + size+ x_offset && mouseY > y && mouseY < y + size); 
  }
  boolean is_special(){
    return (character == '_' || character == ' ' || character == '`'); 
  }
  void draw(float x_offset){
    float dx = x + x_offset;
    fill(66, 77, 88);
    rect(dx, y, size, size);
    fill(255);
    textSize(12);
    text("" + character, dx + size/8, y + size / 1.3);
    textSize(24);
    // also draw magnification on hover
    if(mouse_down){
      if (!is_special() && mouseX > dx && mouseX < dx + size && mouseY > y && mouseY < y + size){
        float mag_x = clamp(dx - mag_size / 2, TLx, TLx + sizeOfInputArea - mag_size);
        float mag_y = clamp(y - mag_size * 2, height / 2 - sizeOfInputArea/2, height / 2 + sizeOfInputArea/2);
        fill(30, 30, 99);
        rect(mag_x, mag_y, mag_size, mag_size);
        fill(255);
        textSize(mag_size);
        text("" + character, mag_x + mag_size / 8, mag_y + mag_size * 0.75);
        textSize(24);
      }
      else if (character == ' ' && mouseX > dx && mouseX < dx + size && mouseY > y && mouseY < y + size){
        fill(255, 255, 0, 50);
        if(!left_keyboard){
          rect(width/2 - sizeOfInputArea / 2, height/2 - sizeOfInputArea / 2, sizeOfInputArea / 2, sizeOfInputArea);
        }
        else{
          rect(width/2, height/2 - sizeOfInputArea / 2, sizeOfInputArea / 2, sizeOfInputArea);
        }
      }
    }
  }
}

public class keyboard {
   ArrayList<Key> keys = new ArrayList<Key> ();
   // draw half the keys for Left side
   int[] keysL = new int[]{0, 1, 2, 3, 4, 10, 11, 12, 13, 14, 19, 20, 21, 22, 23};
   // draw other half for right side
   int[] keysR = new int[]{5, 6, 7, 8, 9, 14, 15, 16, 17, 18, 21, 22, 23, 24, 25};
   public keyboard(){
      // draw keyboard
      char[] qwerty = new char[]{'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', 'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'z', 'x', 'c', 'v', 'b', 'n', 'm'};
      TLx = width/2 - sizeOfInputArea/2;  // x pos of top left corner of the keyboard
      TLy = height/2 - 15; // y pos of top left corner of the keyboard
      float button_size = sizeOfInputArea/5;
      // first row of keyboard
      for (int i = 0; i < 10; i++){
        Key k = new Key(qwerty[i], TLx + button_size * i, TLy, button_size);
        keys.add(k);
      }
      // second row of the keyboard
      for (int i = 10; i < 19; i++){
        Key k = new Key(qwerty[i], TLx + button_size * (i - 10), TLy + button_size, button_size);
        keys.add(k);
      }
      // third (final) row of the keyboard
      for (int i = 19; i < 26; i++){
        Key k = new Key(qwerty[i], TLx + button_size * (i - 19), TLy + 2*button_size, button_size);
        keys.add(k);
      } 
      // special keys (delete & space & slide)
      Key slide = new Key(' ', TLx + 42, TLy - 43, 38);
      keys.add(slide);
      Key space = new Key('_', TLx, TLy - 45, 40);
      keys.add(space);
      Key del = new Key('`', TLx + 82, TLy - 45, 40);
      keys.add(del);
      
   }
  
  char get_inputs(){
    char c = 0;
    if(keys.get(keys.size() - 1).clicked(0)){
      c = keys.get(keys.size() - 1).character;
    }
    else if(keys.get(keys.size() - 2).clicked(0)){
      c = keys.get(keys.size() - 2).character;
    }
    else if(keys.get(keys.size() - 3).clicked(0)){
      left_keyboard = !left_keyboard; // toggle keyboard
    }
    else if (left_keyboard){
      for (int i = 0; i < 15; i++){
        if(keys.get(keysL[i]).clicked(0)){
          c = keys.get(keysL[i]).character;
          break;
        }
      }
    }
    else {
      for (int i = 0; i < 15; i++){
        float x_offset = -sizeOfInputArea;
        if (i < 5)
          x_offset = -sizeOfInputArea;
        else if (i < 10)
          x_offset = -sizeOfInputArea + 25;
        else 
          x_offset = -sizeOfInputArea + 73.5;
        if(keys.get(keysR[i]).clicked(x_offset)){
          c = keys.get(keysR[i]).character;
          break;
        }
      }
    }
    return c;
  }
  
  void draw(){
    keys.get(keys.size() - 1).draw(0); // space
    keys.get(keys.size() - 2).draw(0); // delete
    keys.get(keys.size() - 3).draw(0); // delete
    if (left_keyboard){
      for (int i = 0; i < 15; i++){
        keys.get(keysL[i]).draw(0);
      }
    }
    else {
      for (int i = 0; i < 15; i++){
        float x_offset = -sizeOfInputArea;
        if (i < 5)
          x_offset = -sizeOfInputArea;
        else if (i < 10)
          x_offset = -sizeOfInputArea + 25;
        else 
          x_offset = -sizeOfInputArea + 73.5;
        keys.get(keysR[i]).draw(x_offset);
      }
    }
  } 
}  

keyboard K;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  noCursor();
  watch = loadImage("watchhand3smaller.png");
  finger = loadImage("pngeggSmaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing

  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes
  K = new keyboard (); 
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"
  
  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label
    
    K.draw();
  }
 
   drawFinger(); //this is your "cursor"
}

  
////example design draw code
//fill(255, 0, 0); //red button
//rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw left red button
//fill(0, 255, 0); //green button
//rect(width/2-sizeOfInputArea/2+sizeOfInputArea/2, height/2-sizeOfInputArea/2+sizeOfInputArea/2, sizeOfInputArea/2, sizeOfInputArea/2); //draw right green button
//textAlign(CENTER);
//fill(200);
//text("" + currentLetter, width/2, height/2-sizeOfInputArea/4); //draw current letter
//}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}


// non as terrible implementation
void mousePressed()
{
  mouse_down = true;
  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}

void mouseReleased(){
  mouse_down = false; 
  char c = K.get_inputs();
  if (c != 0){
     currentLetter = c; 
    if (currentLetter=='_') //if underscore, consider that a space bar
      currentTyped+=" ";
    else if (currentLetter=='`' & currentTyped.length()>0) //if `, treat that as a delete command
      currentTyped = currentTyped.substring(0, currentTyped.length()-1);
    else if (currentLetter!='`') //if not any of the above cases, add the current letter to the typed string
      currentTyped+=currentLetter;
  }
}

void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}

//probably shouldn't touch this - should be same for all teams.
void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0; //normalizes the image size
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}

//probably shouldn't touch this - should be same for all teams.
void drawFinger()
{
  float fingerscale = DPIofYourDeviceScreen/150f; //normalizes the image size
  pushMatrix();
  translate(mouseX, mouseY);
  scale(fingerscale);
  imageMode(CENTER);
  image(finger,52,341);
  if (mousePressed)
     fill(0);
  else
     fill(255);
  ellipse(0,0,5,5);

  popMatrix();
}
  

//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
