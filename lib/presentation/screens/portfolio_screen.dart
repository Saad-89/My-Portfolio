import 'package:flutter/material.dart';
import 'package:saad_website/presentation/widgets/sections/contact_me_section.dart';
import 'package:saad_website/presentation/widgets/sections/experience_section.dart';
import 'package:saad_website/presentation/widgets/sections/portfolio_section.dart';
import 'package:saad_website/presentation/widgets/sections/skill_section.dart';
import '../widgets/common/custom_navbar.dart';
import '../widgets/sections/hero_section.dart';
import '../widgets/sections/about_section.dart';

final GlobalKey heroKey = GlobalKey();
final GlobalKey aboutKey = GlobalKey();
final GlobalKey portfolioKey = GlobalKey();
final GlobalKey experienceKey = GlobalKey();
final GlobalKey skillsKey = GlobalKey();
final GlobalKey contactKey = GlobalKey();

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Container(
                  key: heroKey,
                  child: HeroSection(
                    scrollController: _scrollController,
                    key: contactKey,
                  ),
                ),
                Container(
                  key: aboutKey,
                  child: AboutSection(scrollController: _scrollController),
                ),
                Container(
                  key: portfolioKey,
                  child: PortfolioSection(scrollController: _scrollController),
                ),
                Container(
                  key: experienceKey,
                  child: ExperienceSection(scrollController: _scrollController),
                ),
                Container(
                  key: skillsKey,
                  child: SkillsSection(scrollController: _scrollController),
                ),
                Container(
                  key: contactKey,
                  child: ContactSection(scrollController: _scrollController),
                ),

                // Other sections will be added here
                // Make sure to pass scrollController to them as well
              ],
            ),
          ),

          // Fixed Navigation - Higher z-index
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: CustomNavBar(
                scrollController: _scrollController,
                heroKey: heroKey,
                aboutKey: aboutKey,
                portfolioKey: portfolioKey,
                experienceKey: experienceKey,
                skillsKey: skillsKey,
                contactKey: contactKey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../widgets/common/custom_navbar.dart';
// import '../widgets/sections/hero_section.dart';
// import '../widgets/sections/about_section.dart';

// class PortfolioScreen extends StatelessWidget {
//   const PortfolioScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Main Content
//           const SingleChildScrollView(
//             child: Column(
//               children: [
//                 HeroSection(),
//                 AboutSection(),
//                 // Other sections will be added here
//               ],
//             ),
//           ),

//           // Fixed Navigation
//           const Positioned(top: 0, left: 0, right: 0, child: CustomNavBar()),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import '../widgets/common/custom_navbar.dart';
// import '../widgets/sections/hero_section.dart';

// class PortfolioScreen extends StatelessWidget {
//   const PortfolioScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Main Content
//           const SingleChildScrollView(
//             child: Column(
//               children: [
//                 HeroSection(),
//                 // Other sections will be added here
//               ],
//             ),
//           ),

//           // Fixed Navigation
//           const Positioned(top: 0, left: 0, right: 0, child: CustomNavBar()),
//         ],
//       ),
//     );
//   }
// }
