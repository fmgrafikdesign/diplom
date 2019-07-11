ArrayList<Track> tracks = new ArrayList<Track>();
ArrayList<Effect> effects = new ArrayList<Effect>();
IntList unplayed_tracks = new IntList();

float amp_change = 0.01;
int frames_since_last_effect = 0;
int min_time_between_effects = 5 * 30;
float effect_threshold = .8;
// DEBUG variable for quicker loading
boolean skip_tracks = true;
boolean skip_effects = false;
boolean skip_tracks_and_effects = true;

// Initializes Tracks. The 3rd and 4th parameter are the intensity range they're played in. 
void initializeTracks() {
  if ((skip_tracks || skip_tracks_and_effects) && production == 0) {
    println("INFO: Skipped tracks due to debug variables");
    return;
  } else {
    int start = millis();
    tracks.add(new Track(this, "01_Bass.mp3", 0, 1));
    tracks.add(new Track(this, "02_Gitarre_Ruhig_Netter.mp3", 0, 0.3));
    tracks.add(new Track(this, "03_Gitarre_Nett.mp3", 0.05, 0.5));
    tracks.add(new Track(this, "04_Gitarre_Ruhig_Boeser.mp3", 0.3, 1.0));
    tracks.add(new Track(this, "05_Gitarre_Ominoes.mp3", 0.4, 0.8));
    tracks.add(new Track(this, "06_Bass_Unbehaglich.mp3", 0.5, 1.0));
    tracks.add(new Track(this, "07_Gitarre_Gefaehrlich.mp3", 0.7, 1.0));
    tracks.add(new Track(this, "08_Gitarre_Gefaehrlicher.mp3", 0.80, 1.0));
    tracks.add(new Track(this, "09_Gitarre_Gefaehrlicher_Add.mp3", 0.85, 1.0));
    println("added ", tracks.size(), "tracks in", (millis()-start)/1000.0, "s");
  }

  // Mute and play all tracks
  for (int i = 0; i < tracks.size(); i++) {
    Track track = tracks.get(i);
    track.setVolume(0.001);
    track.loop();
  }

}

// Check and process if there'll be a sound effect
void potentialSoundEffect() {
  // skipped initializing tracks? Abort.
  if ((skip_effects || skip_tracks_and_effects) && production == 0) return;

  // Intensity too low? Abort.
  if (intensity < effect_threshold) return;

  // Been too short since another effect started playing? Abort.
  if (frames_since_last_effect < min_time_between_effects) return;      

  // Alright, we're in. Check if there are unplayed effects left, if not start over
  if (unplayed_tracks.size() == 0) {
    for (int i = 0; i < effects.size(); i++) {
      unplayed_tracks.append(i);
    }
  }

  // Chose effect
  int effect_id = int(random(unplayed_tracks.size()));

  effects.get(effect_id).play();
  unplayed_tracks.remove(effect_id);
  
  //println(effects.get(effect_id).getTrackName());

  // Reset recent effect timer
  frames_since_last_effect = 0;
}

void initializeEffects() {
  if ((skip_effects || skip_tracks_and_effects) && production == 0) {
    println("INFO: Skipped effects due to debug variables");
    return;
  } else {
    int start = millis();
    effects.add(new Effect(this, "boom.mp3"));
    effects.add(new Effect(this, "crack.mp3"));
    effects.add(new Effect(this, "cymbals.mp3"));
    effects.add(new Effect(this, "daemon.mp3"));
    effects.add(new Effect(this, "daemon2.mp3"));
    effects.add(new Effect(this, "daemon3.mp3"));
    effects.add(new Effect(this, "daemon4.mp3"));
    effects.add(new Effect(this, "scratch.mp3"));
    effects.add(new Effect(this, "slide.mp3"));
    effects.add(new Effect(this, "spiders.mp3"));
    effects.add(new Effect(this, "tony.mp3"));
    effects.add(new Effect(this, "Spooky Ghosts Ominous.mp3"));
    effects.add(new Effect(this, "SpiritHaunted MON01_91_4.mp3"));
    effects.add(new Effect(this, "SnakeKingRattles AT065703.mp3"));
    effects.add(new Effect(this, "SpaceShipCloakOn HYP054001.mp3"));
    effects.add(new Effect(this, "SpiritHaunted MON01_91_1.mp3"));
    effects.add(new Effect(this, "SCI-FI-WHOOSH_GEN-HDF-20881.mp3"));
    effects.add(new Effect(this, "MetalFx DE01_96_2.mp3"));
    effects.add(new Effect(this, "Ominous Feelings Spell.mp3"));
    effects.add(new Effect(this, "Horror Transition 13.mp3"));
    effects.add(new Effect(this, "Industrial Horror Whoosh.mp3"));
    effects.add(new Effect(this, "Haunting Darkness 03.mp3"));
    effects.add(new Effect(this, "Haunting Darkness 04.mp3"));
    effects.add(new Effect(this, "Horror Power Slice.mp3"));
    effects.add(new Effect(this, "Haunting Darkness 01.mp3"));
    effects.add(new Effect(this, "Haunting Darkness 02.mp3"));
    effects.add(new Effect(this, "Ghosts - Haunting Slimers.mp3"));
    effects.add(new Effect(this, "Evil Ominous Transition 09.mp3"));
    effects.add(new Effect(this, "Door of Horror.mp3"));
    effects.add(new Effect(this, "Eerie Gong_1.mp3"));
    effects.add(new Effect(this, "20733 violin horror detune effect-full_1_1.mp3"));
    effects.add(new Effect(this, "Dark Spooky Accent 03.mp3"));
    effects.add(new Effect(this, "17846 metallic horror whoosh-full_1.mp3"));

    for (int i = 0; i < effects.size(); i++) {
      unplayed_tracks.append(i);
    }
    
      println("added", effects.size(), "effects in", (millis()-start)/1000.0, "s");
  }
}

class Effect {
  SoundFile track;
  String name;
  boolean played = false;

  Effect(PApplet app, String _trackpath) {
    track = new SoundFile(app, "audio/effects/" + _trackpath);
    name = _trackpath;
  }

  boolean play() {
    track.play();
    played = true;
    return played;
  }

  boolean reset() {
    return played = false;
  }

  boolean hasPlayed() {
    return played;
  }
  
  String getTrackName() {
    return name;
  }
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
