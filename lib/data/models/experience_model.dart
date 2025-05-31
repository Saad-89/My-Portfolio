class ExperienceModel {
  final String id;
  final String company;
  final String position;
  final String duration;
  final String location;
  final String type; // "Full-time", "Part-time", "Freelance", "Contract"
  final String description;
  final List<String> responsibilities;
  final List<String> technologies;
  final String? companyLogo;
  final String? companyWebsite;
  final bool isCurrentJob;

  ExperienceModel({
    required this.id,
    required this.company,
    required this.position,
    required this.duration,
    required this.location,
    required this.type,
    required this.description,
    required this.responsibilities,
    required this.technologies,
    this.companyLogo,
    this.companyWebsite,
    this.isCurrentJob = false,
  });

  factory ExperienceModel.fromJson(Map<String, dynamic> json) {
    return ExperienceModel(
      id: json['id'],
      company: json['company'],
      position: json['position'],
      duration: json['duration'],
      location: json['location'],
      type: json['type'],
      description: json['description'],
      responsibilities: List<String>.from(json['responsibilities']),
      technologies: List<String>.from(json['technologies']),
      companyLogo: json['companyLogo'],
      companyWebsite: json['companyWebsite'],
      isCurrentJob: json['isCurrentJob'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company': company,
      'position': position,
      'duration': duration,
      'location': location,
      'type': type,
      'description': description,
      'responsibilities': responsibilities,
      'technologies': technologies,
      'companyLogo': companyLogo,
      'companyWebsite': companyWebsite,
      'isCurrentJob': isCurrentJob,
    };
  }
}
