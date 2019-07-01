import processing.sound.*;
SinOsc morseSignal;

/* An array of morse code waiting to be played */
char[] character_queue = new char[0];

// Length of the current morse signal in ms
int signal_length = 0;

// Delay until the next morse signal in ms
int pause_length = 0;

/* Duration of dots and dashes, using common morse practices */

final int dot = 100;
final int pause = dot;
final int dash = dot * 3;
final int separator_length = dot * 7;

/* Special characters: character separator and word separator */
final char char_separator = ' ';
final char word_separator = '/';

/* Hashmap of numbers 0-9 */
HashMap<Character, String> code = new HashMap<Character, String>();

void setupMorseSignal() {
  morseSignal = new SinOsc(this);
  morseSignal.amp(.25);
  morseSignal.freq(300);
  //morseSignal.play();
}

void setupMorseChars() {
  code.put('0', "-----");
  code.put('1', ".----");
  code.put('2', "..---");
  code.put('3', "...--");
  code.put('4', "....-");
  code.put('5', ".....");
  code.put('6', "-....");
  code.put('7', "--...");
  code.put('8', "---..");
  code.put('9', "----.");
}

// Plays back a number as morse code
void enqueueMorseCode(String number) {

  // Store the number in a char array
  char[] chars = number.toCharArray();

  // Loop through the digits of the number
  for (int i = 0; i < chars.length; i++) {
    String morse = code.get(chars[i]);
    //println(morse);

    // For each digit, loop through the morse representation and add it to the morse queue
    for (int j = 0; j < morse.length(); j++) {
      character_queue = append(character_queue, morse.charAt(j));
    }

    // Add a space at the end of each digit, except the last
    if (i < chars.length -1) {
      character_queue = append(character_queue, char_separator);
    }
  }

  // Add a separator at the end of each number
  character_queue = append(character_queue, word_separator);


  //println(character_queue);

  return;
}

void morsePlayback() {
  println("watching morse queue...");
  while (true) {

    // If there are no characters in the queue, abort and try again later.
    while (character_queue.length == 0) {
      //println("character queue length zero");
      delay(100);
    }

    // The current character to be played
    //println(character_queue[0]);
    switch(character_queue[0]) {
    case '-':
      signal_length = dash;
      pause_length = pause;
      break;
    case '.':
      signal_length = dot;
      pause_length = pause;
      break;
    case ' ':
      signal_length = 0;
      pause_length = dash;
      break;
    case '/':
      signal_length = 0;
      pause_length = separator_length;
      break;
    }

    // Remove the element we just used via some reversing and shortening
    character_queue = reverse(character_queue);
    character_queue = shorten(character_queue);
    character_queue = reverse(character_queue);

    // Start signal for duration x, then stop
    if (signal_length > 0) {
      //println("Start signal playback");
      morseSignal.play();
    }

    delay(signal_length);
    //println("Stop signal playback");
    morseSignal.stop();

    // Wait the right amount of time until next signal
    delay(pause_length);
  }
}
