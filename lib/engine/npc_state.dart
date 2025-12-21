class NpcState {
  int mood;

  NpcState({this.mood = 50}); // Start with a neutral mood

  NpcState clone() {
    return NpcState(mood: mood);
  }
}
