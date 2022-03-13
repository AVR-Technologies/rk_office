struct TimeE {
  int hour;
  int minute;
  int second;
  TimeE() {}
  TimeE(int _hour, int _minute, int _second): hour(_hour), minute(_minute), second(_second) {}
  void from(TimeE _time) {
    hour = _time.hour;
    minute = _time.minute;
    second = _time.second;
  }
  void from(DateTime _time) {
    hour = _time.hour();
    minute = _time.minute();
    second = _time.second();
  }
  void from(const char* buff) {
    sscanf(buff, "%d:%d:%d", &hour, &minute, &second);
  }
  void add(TimeE _time) {
    second += _time.second;
    minute += _time.minute;
    hour += _time.second;
    if (second > 60) {
      minute += second % 60;
      second = second % 60;
    }
    if (minute > 60) {
      hour += minute / 60;
      minute = minute % 60;
    }
    if (hour > 24) {
      hour %= 24;
    }
  }
  void print() {
    char buff[9];
    sprintf(buff, "%.2d:%.2d:%.2d", hour, minute, second);
    Serial.print(buff);
  }
  bool isCrossed(TimeE &after) {
    char _currentTime[7];
    char _afterTime[7];
    sprintf(_currentTime, "%.2d%.2d%.2d", hour, minute, second);
    sprintf(_afterTime, "%.2d%.2d%.2d", after.hour, after.minute, after.second);
    return String(_currentTime) >= String(_afterTime);
  }
};
