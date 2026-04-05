import 'package:flutter/material.dart';
import '../../domain/entities/weapon.dart';

/// 7 màu sharpness từ đỏ → tím (theo thứ tự trong mảng sharpness[]).
const kSharpnessColors = [
  Color(0xFFE53935), // red
  Color(0xFFFB8C00), // orange
  Color(0xFFFFD600), // yellow
  Color(0xFF43A047), // green
  Color(0xFF1E88E5), // blue
  Color(0xFFFFFFFF), // white
  Color(0xFF8E24AA), // purple
];

const kSharpnessLabels = [
  'Red',
  'Orange',
  'Yellow',
  'Green',
  'Blue',
  'White',
  'Purple',
];

Color elementColor(WeaponElement? el) => switch (el) {
  WeaponElement.fire => const Color(0xFFE53935),
  WeaponElement.water => const Color(0xFF1E88E5),
  WeaponElement.thunder => const Color(0xFFFFD600),
  WeaponElement.ice => const Color(0xFF80DEEA),
  WeaponElement.dragon => const Color(0xFF8E24AA),
  WeaponElement.poison => const Color(0xFF7B1FA2),
  WeaponElement.paralyze => const Color(0xFFFDD835),
  WeaponElement.sleep => const Color(0xFF90CAF9),
  WeaponElement.blast => const Color(0xFFFF6F00),
  null => const Color(0xFF9E9E9E),
};

/// Rarity màu sắc (1–7).
Color rarityColor(int rarity) => switch (rarity) {
  1 => const Color(0xFF9E9E9E),
  2 => const Color(0xFF4CAF50),
  3 => const Color(0xFF2196F3),
  4 => const Color(0xFF9C27B0),
  5 => const Color(0xFFFF9800),
  6 => const Color(0xFFF44336),
  7 => const Color(0xFFFFD700),
  _ => const Color(0xFF9E9E9E),
};
