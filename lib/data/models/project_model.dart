class ProjectModel {
  final String id;
  final String title;
  final String shortDescription;
  final String detailedDescription;
  final String thumbnailUrl;
  final String videoUrl;
  final List<String> technologies;
  final String category;
  final DateTime completionDate;

  const ProjectModel({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.detailedDescription,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.technologies,
    required this.category,
    required this.completionDate,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      title: json['title'],
      shortDescription: json['shortDescription'],
      detailedDescription: json['detailedDescription'],
      thumbnailUrl: json['thumbnailUrl'],
      videoUrl: json['videoUrl'],
      technologies: List<String>.from(json['technologies']),
      category: json['category'],
      completionDate: DateTime.parse(json['completionDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'shortDescription': shortDescription,
      'detailedDescription': detailedDescription,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'technologies': technologies,
      'category': category,
      'completionDate': completionDate.toIso8601String(),
    };
  }
}
