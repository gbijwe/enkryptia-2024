import 'package:flutter/material.dart';

class ShiftTimerProvider with ChangeNotifier {
  int _shiftTimer = 0;

  int get shiftTimer => _shiftTimer;

  void incrementTimer() {
    _shiftTimer++;
    notifyListeners();
  }

  void resetTimer() {
    _shiftTimer = 0;
    notifyListeners();
  }
}