ArrayList<Track> tracks = new ArrayList<Track>();

float amp_change = 0.01;

// DEBUG variable for quicker loading
boolean skip_tracks = true;

// Initializes Tracks. The 3rd and 4th parameter are the intensity range they're played in. 

void initializeTracks() {
  if(skip_tracks) {
    println("INFO: Skipped tracks due to debug variable 'skip_tracks'");
    return;
  }
  else {
  tracks.add(new Track(this, "01_Bass.mp3", 0, 1));
  tracks.add(new Track(this, "02_Gitarre_Ruhig_Netter.mp3", 0, 0.3));
  tracks.add(new Track(this, "03_Gitarre_Nett.mp3", 0.05, 0.5));
  tracks.add(new Track(this, "04_Gitarre_Ruhig_Boeser.mp3", 0.3, 1.0));
  tracks.add(new Track(this, "05_Gitarre_Ominoes.mp3", 0.4, 0.8));
  tracks.add(new Track(this, "06_Bass_Unbehaglich.mp3", 0.5, 1.0));
  tracks.add(new Track(this, "07_Gitarre_Gefaehrlich.mp3", 0.7, 1.0));
  tracks.add(new Track(this, "08_Gitarre_Gefaehrlicher.mp3", 0.80, 1.0));
  tracks.add(new Track(this, "09_Gitarre_Gefaehrlicher_Add.mp3", 0.85, 1.0));
  }
  println("finished adding tracks");

  // Mute and play all tracks
  for (int i = 0; i < tracks.size(); i++) {
    Track track = tracks.get(i);
    track.setVolume(0.001);
    track.loop();
  }

  println("finished muting and playing");
}

class Track {
  SoundFile track;
  float amplitude = 0;
  float maxamp = 0;
  float range_min, range_max = 0;

  Track(PApplet app, String _trackpath, float _range_min, float _range_max) {
    track = new SoundFile(app, "audio/" + _trackpath);

    range_min = _range_min;
    range_max = _range_max;
  }

  Track(PApplet app, String _trackpath, float _range_min, float _range_max, float max_amp) {
    track = new SoundFile(app, "audio/" + _trackpath);
    maxamp = max_amp;
    range_min = _range_min;
    range_max = _range_max;
  }

  boolean play() {
    track.play();
    return true;
  }

  boolean loop() {
    track.loop();
    return true;
  }

  float setVolume(float volume) {
    track.amp(volume);
    return volume;
  }

  void adjustVolume () {
    // If in area, increase volume
    if (intensity >= range_min && intensity <= range_max) {
      amplitude += amp_change;
    }

    // If not in intensity area, decrease volume
    else {
      amplitude -= amp_change;
    }
    
    amplitude = constrain(amplitude, 0.001, 1);
    track.amp(amplitude);
  }
}

void adjustVolume() {
  for (int i = 0; i < tracks.size(); i++) {
    tracks.get(i).adjustVolume();
  }
}
