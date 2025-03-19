import 'package:flutter/material.dart';
import '../../domain/entities/home_action.dart';

class HomeActionModel extends HomeAction {
  final IconData icon;
  final Color color;

  HomeActionModel({
    required super.id,
    required super.title,
    required this.icon,
    required this.color,
  }) : super(
          iconKey: icon.toString(),
          colorHex: color.value.toRadixString(16),
        );
}