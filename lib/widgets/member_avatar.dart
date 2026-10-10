import 'package:flutter/material.dart';

import '../models/team_member.dart';

// Initials in a circle. Each member gets their own colour pair.
class MemberAvatar extends StatelessWidget {
  final List<TeamMember> members;
  final String? memberId;
  final double radius;

  const MemberAvatar({
    super.key,
    required this.members,
    required this.memberId,
    this.radius = 20,
  });

  static const _backgrounds = [
    Color(0xFFCDEFCB),
    Color(0xFFFFE3A3),
    Color(0xFFE8DDF7),
    Color(0xFFFAD4D0),
    Color(0xFFFFDCC2),
  ];
  static const _foregrounds = [
    Color(0xFF0F3D1E),
    Color(0xFF5A3B00),
    Color(0xFF4A2C7A),
    Color(0xFF7A1F18),
    Color(0xFF7A3A0A),
  ];

  @override
  Widget build(BuildContext context) {
    final index = members.indexWhere((m) => m.id == memberId);
    final colour = index < 0 ? 0 : index % _backgrounds.length;
    return CircleAvatar(
      radius: radius,
      backgroundColor: _backgrounds[colour],
      child: index < 0 
        ? Text('?', style: TextStyle(color: _foregrounds[colour], fontSize: radius * 0.7))
        : ClipOval(
            child: Image.network(
              'https://api.dicebear.com/8.x/bottts/png?seed=${members[index].name}&backgroundColor=transparent',
              width: radius * 2,
              height: radius * 2,
              fit: BoxFit.cover,
            ),
          ),
    );
  }
}
