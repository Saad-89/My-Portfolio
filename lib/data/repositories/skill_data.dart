import '../models/skill_model.dart';

class PortfolioRepository {
  static const Map<String, dynamic> _skillsData = {
    "skills": [
      // Mobile Development
      {
        "name": "Flutter",
        "category": "Mobile Development",
        "proficiency": 0.95,
        "logoPath": "assets/images/logos/flutter_logo.png",
        "description":
            "Cross-platform mobile app development with beautiful UIs",
      },
      {
        "name": "Dart",
        "category": "Mobile Development",
        "proficiency": 0.90,
        "logoPath": "assets/images/logos/dart_logo.png",
        "description": "Primary programming language for Flutter development",
      },
      {
        "name": "React Native",
        "category": "Mobile Development",
        "proficiency": 0.75,
        "logoPath": "assets/images/logos/react_native_logo.png",
        "description": "Cross-platform mobile development with JavaScript",
      },
      {
        "name": "iOS Swift",
        "category": "Mobile Development",
        "proficiency": 0.70,
        "logoPath": "assets/images/logos/swift_logo.png",
        "description": "Native iOS app development",
      },
      {
        "name": "Android Kotlin",
        "category": "Mobile Development",
        "proficiency": 0.75,
        "logoPath": "assets/images/logos/kotlin_logo.png",
        "description": "Native Android app development",
      },

      // Backend & APIs
      {
        "name": "Firebase",
        "category": "Backend & APIs",
        "proficiency": 0.90,
        "logoPath": "assets/images/logos/firebase_logo.png",
        "description": "Backend-as-a-Service platform for mobile apps",
      },
      {
        "name": "Node.js",
        "category": "Backend & APIs",
        "proficiency": 0.80,
        "logoPath": "assets/images/logos/nodejs_logo.png",
        "description": "Server-side JavaScript runtime environment",
      },
      {
        "name": "REST APIs",
        "category": "Backend & APIs",
        "proficiency": 0.85,
        "logoPath": "assets/images/logos/api_logo.png",
        "description": "RESTful web services integration and development",
      },
      {
        "name": "GraphQL",
        "category": "Backend & APIs",
        "proficiency": 0.75,
        "logoPath": "assets/images/logos/graphql_logo.png",
        "description": "Query language and runtime for APIs",
      },
      {
        "name": "MongoDB",
        "category": "Backend & APIs",
        "proficiency": 0.70,
        "logoPath": "assets/images/logos/mongodb_logo.png",
        "description": "NoSQL database for modern applications",
      },

      // Frontend Development
      {
        "name": "React",
        "category": "Frontend Development",
        "proficiency": 0.85,
        "logoPath": "assets/images/logos/react_logo.png",
        "description": "JavaScript library for building user interfaces",
      },
      {
        "name": "JavaScript",
        "category": "Frontend Development",
        "proficiency": 0.90,
        "logoPath": "assets/images/logos/javascript_logo.png",
        "description": "Dynamic programming language for web development",
      },
      // {
      //   "name": "TypeScript",
      //   "category": "Frontend Development",
      //   "proficiency": 0.80,
      //   "logoPath": "assets/images/logos/typescript_logo.png",
      //   "description": "Typed superset of JavaScript",
      // },
      // {
      //   "name": "HTML5",
      //   "category": "Frontend Development",
      //   "proficiency": 0.95,
      //   "logoPath": "assets/images/logos/html5_logo.png",
      //   "description": "Markup language for creating web pages",
      // },
      // {
      //   "name": "CSS3",
      //   "category": "Frontend Development",
      //   "proficiency": 0.90,
      //   "logoPath": "assets/images/logos/css3_logo.png",
      //   "description": "Stylesheet language for designing web pages",
      // },

      // // State Management
      // {
      //   "name": "Provider",
      //   "category": "State Management",
      //   "proficiency": 0.95,
      //   "logoPath": "assets/images/logos/provider_logo.png",
      //   "description": "Simple and efficient state management for Flutter",
      // },
      // {
      //   "name": "Bloc/Cubit",
      //   "category": "State Management",
      //   "proficiency": 0.90,
      //   "logoPath": "assets/images/logos/bloc_logo.png",
      //   "description": "Business logic component pattern for Flutter",
      // },
      // {
      //   "name": "Riverpod",
      //   "category": "State Management",
      //   "proficiency": 0.85,
      //   "logoPath": "assets/images/logos/riverpod_logo.png",
      //   "description": "Modern state management framework for Flutter",
      // },
      // {
      //   "name": "GetX",
      //   "category": "State Management",
      //   "proficiency": 0.80,
      //   "logoPath": "assets/images/logos/getx_logo.png",
      //   "description": "Lightweight and powerful state management",
      // },
      // {
      //   "name": "Redux",
      //   "category": "State Management",
      //   "proficiency": 0.75,
      //   "logoPath": "assets/images/logos/redux_logo.png",
      //   "description": "Predictable state container for JavaScript apps",
      // },

      // // Tools & DevOps
      // {
      //   "name": "Git",
      //   "category": "Tools & DevOps",
      //   "proficiency": 0.95,
      //   "logoPath": "assets/images/logos/git_logo.png",
      //   "description": "Distributed version control system",
      // },
      // {
      //   "name": "GitHub",
      //   "category": "Tools & DevOps",
      //   "proficiency": 0.90,
      //   "logoPath": "assets/images/logos/github_logo.png",
      //   "description": "Web-based Git repository hosting service",
      // },
      // {
      //   "name": "Docker",
      //   "category": "Tools & DevOps",
      //   "proficiency": 0.70,
      //   "logoPath": "assets/images/logos/docker_logo.png",
      //   "description": "Containerization platform for applications",
      // },
      // {
      //   "name": "VS Code",
      //   "category": "Tools & DevOps",
      //   "proficiency": 0.95,
      //   "logoPath": "assets/images/logos/vscode_logo.png",
      //   "description": "Lightweight and powerful code editor",
      // },
      // {
      //   "name": "Postman",
      //   "category": "Tools & DevOps",
      //   "proficiency": 0.85,
      //   "logoPath": "assets/images/logos/postman_logo.png",
      //   "description": "API development and testing platform",
      // },

      // // Cloud & Databases
      // {
      //   "name": "AWS",
      //   "category": "Cloud & Databases",
      //   "proficiency": 0.70,
      //   "logoPath": "assets/images/logos/aws_logo.png",
      //   "description": "Amazon Web Services cloud platform",
      // },
      // {
      //   "name": "Google Cloud",
      //   "category": "Cloud & Databases",
      //   "proficiency": 0.75,
      //   "logoPath": "assets/images/logos/gcp_logo.png",
      //   "description": "Google Cloud Platform services",
      // },
      // {
      //   "name": "PostgreSQL",
      //   "category": "Cloud & Databases",
      //   "proficiency": 0.80,
      //   "logoPath": "assets/images/logos/postgresql_logo.png",
      //   "description": "Advanced open-source relational database",
      // },
      // {
      //   "name": "SQLite",
      //   "category": "Cloud & Databases",
      //   "proficiency": 0.85,
      //   "logoPath": "assets/images/logos/sqlite_logo.png",
      //   "description": "Lightweight embedded database engine",
      // },
    ],
  };

  // Get all skills
  static List<SkillModel> getAllSkills() {
    final skillsList = _skillsData['skills'] as List<dynamic>;
    return skillsList.map((skill) => SkillModel.fromJson(skill)).toList();
  }

  // Get skills by category
  static List<SkillModel> getSkillsByCategory(String category) {
    final allSkills = getAllSkills();
    if (category == 'All') return allSkills;
    return allSkills.where((skill) => skill.category == category).toList();
  }

  // Get all unique categories
  static List<String> getSkillCategories() {
    final allSkills = getAllSkills();
    final categories = allSkills
        .map((skill) => skill.category)
        .toSet()
        .toList();
    categories.insert(0, 'All');
    return categories;
  }

  // Get skills count by category
  static Map<String, int> getSkillsCountByCategory() {
    final allSkills = getAllSkills();
    final Map<String, int> categoryCount = {'All': allSkills.length};

    for (final skill in allSkills) {
      categoryCount[skill.category] = (categoryCount[skill.category] ?? 0) + 1;
    }

    return categoryCount;
  }

  // Get top skills (highest proficiency)
  static List<SkillModel> getTopSkills({int limit = 6}) {
    final allSkills = getAllSkills();
    allSkills.sort((a, b) => b.proficiency.compareTo(a.proficiency));
    return allSkills.take(limit).toList();
  }
}
