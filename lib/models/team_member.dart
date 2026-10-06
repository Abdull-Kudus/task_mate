class TeamMember {
  final String id;
  String name;
  String role;

  TeamMember({required this.id, required this.name, required this.role});

  // First letters of the first two words, for the avatar circle.
  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        id: json['id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
      );
}

// Find a member's name from their id.
String memberName(List<TeamMember> members, String id) {
  for (final member in members) {
    if (member.id == id) return member.name;
  }
  return 'Unassigned';
}
