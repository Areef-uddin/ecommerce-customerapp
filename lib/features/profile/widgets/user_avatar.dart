import 'dart:convert';

import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.avatar,
    required this.name,
    required this.radius,
    this.backgroundColor = const Color(0xFF334155),
    this.foregroundColor = const Color(0xFFFFD700),
  });

  final String avatar;
  final String name;
  final double radius;
  final Color backgroundColor;
  final Color foregroundColor;

  ImageProvider<Object>? _imageProvider() {
    final value = avatar.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    try {
      final encoded = value.startsWith('data:image')
          ? value.substring(value.indexOf(',') + 1)
          : value;
      return MemoryImage(base64Decode(encoded));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = _imageProvider();
    final initial = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();
    final diameter = radius * 2;
    return ClipOval(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: provider == null
            ? _fallback(initial)
            : Image(
                image: provider,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _fallback(initial),
              ),
      ),
    );
  }

  Widget _fallback(String initial) => Container(
    color: backgroundColor,
    alignment: Alignment.center,
    child: Text(
      initial,
      style: TextStyle(
        color: foregroundColor,
        fontSize: radius * 0.9,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
}
