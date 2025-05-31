class SkillModel {
  final String name;
  final String category;
  final double proficiency; // 0.0 to 1.0
  final String logoPath; // Path to logo asset
  final String description;

  const SkillModel({
    required this.name,
    required this.category,
    required this.proficiency,
    required this.logoPath,
    required this.description,
  });

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      name: json['name'] as String,
      category: json['category'] as String,
      proficiency: (json['proficiency'] as num).toDouble(),
      logoPath: json['logoPath'] as String,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'proficiency': proficiency,
      'logoPath': logoPath,
      'description': description,
    };
  }

  // Helper method to get proficiency percentage
  String get proficiencyPercentage => '${(proficiency * 100).round()}%';

  // Helper method to get proficiency level
  String get proficiencyLevel {
    if (proficiency >= 0.9) return 'Expert';
    if (proficiency >= 0.8) return 'Advanced';
    if (proficiency >= 0.7) return 'Intermediate';
    if (proficiency >= 0.6) return 'Beginner';
    return 'Learning';
  }
}
