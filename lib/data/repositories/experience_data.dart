import '../models/experience_model.dart';

class ExperienceData {
  static final List<ExperienceModel> experiences = [
    ExperienceModel(
      id: 'exp_001',
      company: 'TechFlow Solutions',
      position: 'Senior Flutter Developer',
      duration: 'Jan 2023 - Present',
      location: 'Remote',
      type: 'Full-time',
      description:
          'Leading mobile app development for enterprise clients, focusing on scalable Flutter applications with complex business logic.',
      responsibilities: [
        'Led development of 3 major Flutter applications serving 50k+ users',
        'Architected clean code solutions using MVVM and Repository patterns',
        'Mentored junior developers and conducted code reviews',
        'Implemented CI/CD pipelines reducing deployment time by 60%',
        'Collaborated with cross-functional teams including designers and product managers',
      ],
      technologies: [
        'Flutter',
        'Dart',
        'Firebase',
        'REST APIs',
        'Provider',
        'Bloc',
        'Git',
      ],
      companyLogo: 'assets/images/companies/techflow.png',
      companyWebsite: 'https://techflowsolutions.com',
      isCurrentJob: true,
    ),
    ExperienceModel(
      id: 'exp_002',
      company: 'Digital Innovate',
      position: 'Flutter Developer',
      duration: 'Mar 2022 - Dec 2022',
      location: 'Lahore, Pakistan',
      type: 'Full-time',
      description:
          'Developed cross-platform mobile applications for startups and small businesses, focusing on user experience and performance optimization.',
      responsibilities: [
        'Built 5+ mobile applications from concept to deployment',
        'Integrated third-party APIs and payment gateways',
        'Optimized app performance achieving 99% crash-free rate',
        'Collaborated with UI/UX designers to implement pixel-perfect designs',
        'Maintained and updated existing applications',
      ],
      technologies: [
        'Flutter',
        'Dart',
        'Firebase',
        'SQLite',
        'Provider',
        'HTTP',
      ],
      companyLogo: 'assets/images/companies/digital_innovate.png',
      companyWebsite: 'https://digitalinnovate.pk',
      isCurrentJob: false,
    ),
    ExperienceModel(
      id: 'exp_003',
      company: 'Freelance',
      position: 'Mobile App Developer',
      duration: 'Jun 2021 - Feb 2022',
      location: 'Remote',
      type: 'Freelance',
      description:
          'Worked with international clients to deliver custom mobile solutions, specializing in e-commerce and social media applications.',
      responsibilities: [
        'Delivered 8+ successful projects for international clients',
        'Provided end-to-end mobile app development services',
        'Implemented real-time features using WebSocket and Firebase',
        'Created responsive UI/UX following Material Design principles',
        'Managed project timelines and client communications',
      ],
      technologies: [
        'Flutter',
        'Dart',
        'Firebase',
        'Node.js',
        'MongoDB',
        'Socket.io',
      ],
      companyLogo: null,
      companyWebsite: null,
      isCurrentJob: false,
    ),
    ExperienceModel(
      id: 'exp_004',
      company: 'CodeCraft Academy',
      position: 'Junior Flutter Developer',
      duration: 'Sep 2020 - May 2021',
      location: 'Lahore, Pakistan',
      type: 'Full-time',
      description:
          'Started my professional journey as a Flutter developer, learning industry best practices and contributing to educational technology projects.',
      responsibilities: [
        'Developed learning management system mobile application',
        'Implemented user authentication and profile management',
        'Created interactive educational content modules',
        'Participated in agile development processes',
        'Wrote unit tests and maintained code documentation',
      ],
      technologies: [
        'Flutter',
        'Dart',
        'Firebase',
        'Provider',
        'Shared Preferences',
      ],
      companyLogo: 'assets/images/companies/codecraft.png',
      companyWebsite: 'https://codecraftacademy.com',
      isCurrentJob: false,
    ),
  ];

  // Helper methods
  static ExperienceModel? getExperienceById(String id) {
    try {
      return experiences.firstWhere((exp) => exp.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<ExperienceModel> getCurrentJobs() {
    return experiences.where((exp) => exp.isCurrentJob).toList();
  }

  static List<ExperienceModel> getExperiencesByType(String type) {
    return experiences.where((exp) => exp.type == type).toList();
  }

  static List<String> getAllTechnologies() {
    Set<String> allTechs = {};
    for (var exp in experiences) {
      allTechs.addAll(exp.technologies);
    }
    return allTechs.toList()..sort();
  }
}
