library flashcards_app.frontend.screen;

import 'dart:async';

import 'package:flashcards_app/app.dart';
import 'package:flashcards_app/src/frontend/dialogs.dart';
import 'package:flashcards_app/src/frontend/push_pop.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

abstract class Screen<ScreenResult> extends StatefulWidget
    with PushPop<ScreenResult> {
  const Screen({super.key});

  /// get the route for the review screen
  MaterialPageRoute<ScreenResult> get route => MaterialPageRoute(
        builder: (context) => this,
      );

  /// get the delegate to pass around
  @override
  ScreenState<Screen<ScreenResult>, ScreenResult> createState();
}

/// class includes a bunch of would-be boilerplate for
abstract class ScreenState<ScreenType extends Screen<ScreenResult>,
    ScreenResult> extends State<ScreenType> {

  /// function that locks the ui while performing operations
  ///
  /// also catches exceptions in the operations and alerts the user to them
  int disabled = 0;
  @nonVirtual
  Future<T> lock<T>(Future<T> Function() f) {
    setState(() {
      disabled++;
    });
    return f().catchError((e) {
      Dialogs.alert(e.toString());
    }).whenComplete(() {
      if (mounted) {
        setState(() => disabled--);
      }
    });
  }

  /// function calls Navigator.push
  ///
  /// makes sure the widget is mounted
  @nonVirtual
  Future<PushScreenResult?> pushRoute<PushScreenResult>(
      MaterialPageRoute<PushScreenResult> route) async {
    if (mounted) {
      return Navigator.push(context, route);
    }
    return null;
  }

  /// function calls Navigator.pop with return value
  ///
  /// makes sure the widget is mounted
  @nonVirtual
  popRoute([ScreenResult? result]) {
    if (mounted) {
      Navigator.pop<ScreenResult>(context, result);
    }
  }

  @override
  @nonVirtual
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: disabled > 0,
        child: buildScreen(context), // needs to be scaffold
      );

  /// builds the screen
  Scaffold buildScreen(BuildContext context);
}

/// carries around screen functions so they can be passed to children
class ScreenDelegate<ScreenResult> {
  Future<T> Function<T>(Future<T> Function() f) lock;
  Future<PushScreenResult?> Function<PushScreenResult>(
      MaterialPageRoute<PushScreenResult> route) pushRoute;
  Function([ScreenResult? result]) popRoute;
  ScreenDelegate({
    required this.lock,
    required this.pushRoute,
    required this.popRoute,
  });
}
