import 'package:flutter/material.dart';
import '../../domain/entities/home_action.dart';

class HomeActionModel extends HomeAction {
  final IconData icon;
  final Color color;

  HomeActionModel({
    required String id,
    required String title,
    required this.icon,
    required this.color,
  }) : super(
          id: id,
          title: title,
          iconKey: icon.toString(),
          colorHex: color.value.toRadixString(16),
        );
}