// This file contains patch fixes for fl_chart to work with the current Flutter version
import 'package:flutter/material.dart';

// Override function to patch boldTextOverride issue
bool boldTextOverrideCompat(BuildContext context) {
  // Default to false since the original function is not available
  return false;
}