import 'package:flutter/material.dart';

//?  when defining MaterialColor you must start from 50, 
//?  then 100 and increments in interval of 100 to 800 is 
//?  enough to allow you to use it without null check errors.
MaterialColor myColor = MaterialColor(
  const Color(0xFFf44c71).value,
  const <int, Color>{
    0: Color(0xFFf44c71),
    50: Color(0xFFf44c71),
    100: Color(0xFFf44c71),
    200: Color(0xFFf44c71),
    300: Color(0xFFf44c71),
    400: Color(0xFFf44c71),
    500: Color(0xFFf44c71),
    600: Color(0xFFf44c71),
    700: Color(0xFFf44c71),
    800: Color(0xFFf44c71),
  },
);