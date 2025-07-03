// lib/core/models/rive_model.dart

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class RiveUtils {
  static StateMachineController getRiveController(Artboard artboard, {String? stateMachineName}) {
    StateMachineController? controller = StateMachineController.fromArtboard(artboard, stateMachineName ?? 'State Machine 1');
    if (controller == null) {
      throw Exception('Could not find Rive StateMachineController');
    }
    artboard.addController(controller);
    return controller;
  }
}

class RiveModel {
  final String src;
  final String artboard;
  final String stateMachineName;
  final String title;
  late SMIBool? input;

  RiveModel({
    required this.src,
    required this.artboard,
    required this.stateMachineName,
    required this.title,
  });

  set setInput(SMIBool status) {
    input = status;
  }
}
