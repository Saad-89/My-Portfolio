import 'package:flutter/material.dart';
import 'package:saad_website/data/repositories/skill_data.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/skill_model.dart';
import '../../../data/repositories/portfolio_data.dart';

class SkillsSection extends StatefulWidget {
  final ScrollController scrollController;

  const SkillsSection({Key? key, required this.scrollController})
    : super(key: key);

  @override
  State<SkillsSection> createState() => _SkillsSectionState();
}

class _SkillsSectionState extends State<SkillsSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late List<Animation<double>> _cardAnimations;

  bool _hasAnimated = false;
  late GlobalKey _sectionKey;

  List<SkillModel> _allSkills = [];

  @override
  void initState() {
    super.initState();
    _sectionKey = GlobalKey();
    _loadSkillsData();
    _setupAnimations();
    _setupScrollListener();
  }

  void _loadSkillsData() {
    _allSkills = PortfolioRepository.getSkillsByCategory('All');
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _setupCardAnimations();
  }

  void _setupCardAnimations() {
    _cardAnimations = List.generate(
      _allSkills.length,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            (index * 0.05).clamp(0.0, 0.7),
            ((index * 0.05) + 0.4).clamp(0.4, 1.0),
            curve: Curves.easeOutBack,
          ),
        ),
      ),
    );
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      if (!_hasAnimated && _isInView()) {
        _startAnimation();
        _hasAnimated = true;
      }
    });
  }

  bool _isInView() {
    if (_sectionKey.currentContext == null) return false;

    final RenderBox? renderBox =
        _sectionKey.currentContext!.findRenderObject() as RenderBox?;

    if (renderBox == null) return false;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    return position.dy < screenHeight * 0.8 &&
        position.dy > -renderBox.size.height * 0.3;
  }

  void _startAnimation() {
    if (mounted) {
      _animationController.forward();
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) {
          _cardAnimationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

    return Container(
      key: _sectionKey,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.pureWhite, Colors.grey.shade50],
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppDimensions.paddingMedium
            : AppDimensions.paddingXLarge,
        vertical: AppDimensions.paddingXLarge * 2,
      ),
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildSectionHeader(isMobile),
                  SizedBox(height: isMobile ? 50 : 70),
                  _buildSkillsGrid(isMobile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(bool isMobile) {
    return Column(
      children: [
        // Decorative line
        Container(
          width: 100,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.transparent, Colors.black, Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'TECHNICAL EXPERTISE',
          style: TextStyle(
            fontSize: isMobile ? 36 : 48,
            fontWeight: FontWeight.w200,
            color: Colors.black,
            fontFamily: AppFonts.primary,
            letterSpacing: 8,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'Technologies and tools I use to bring ideas to life with passion and precision',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w300,
            color: Colors.black.withOpacity(0.7),
            fontFamily: AppFonts.primary,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 32),

        // Decorative elements
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDecorator(),
            const SizedBox(width: 20),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 20),
            _buildDecorator(),
          ],
        ),
      ],
    );
  }

  Widget _buildDecorator() {
    return Container(
      width: 40,
      height: 1,
      color: Colors.black.withOpacity(0.3),
    );
  }

  // Widget _buildSectionHeader(bool isMobile) {
  //   return Column(
  //     children: [
  //       // Section Label with gradient
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  //         decoration: BoxDecoration(
  //           gradient: LinearGradient(
  //             begin: Alignment.topLeft,
  //             end: Alignment.bottomRight,
  //             colors: [Colors.black, Colors.grey.shade800],
  //           ),
  //           borderRadius: BorderRadius.circular(30),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.black.withOpacity(0.1),
  //               spreadRadius: 0,
  //               blurRadius: 15,
  //               offset: const Offset(0, 5),
  //             ),
  //           ],
  //         ),
  //         child: Text(
  //           'Skills & Technologies',
  //           style: TextStyle(
  //             fontSize: 14,
  //             fontWeight: AppFonts.semiBold,
  //             color: AppColors.pureWhite,
  //             fontFamily: AppFonts.primary,
  //             letterSpacing: 1.5,
  //           ),
  //         ),
  //       ),

  //       SizedBox(height: isMobile ? 25 : 30),

  //       // Main Title with improved styling
  //       ShaderMask(
  //         shaderCallback: (bounds) => LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Colors.black, Colors.grey.shade700],
  //         ).createShader(bounds),
  //         child: Text(
  //           'Technical Expertise',
  //           style: TextStyle(
  //             fontSize: isMobile ? 36 : 48,
  //             fontWeight: AppFonts.bold,
  //             color: Colors.white,
  //             fontFamily: AppFonts.primary,
  //             height: 1.1,
  //             letterSpacing: -0.5,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),

  //       SizedBox(height: isMobile ? 16 : 20),

  //       // Subtitle with better styling
  //       Container(
  //         constraints: BoxConstraints(maxWidth: isMobile ? 300 : 500),
  //         child: Text(
  //           'Technologies and tools I use to bring ideas to life with passion and precision',
  //           style: TextStyle(
  //             fontSize: isMobile ? 16 : 18,
  //             fontWeight: AppFonts.regular,
  //             color: AppColors.textSecondary,
  //             fontFamily: AppFonts.primary,
  //             height: 1.6,
  //           ),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildSkillsGrid(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount;
        double childAspectRatio;

        if (isMobile) {
          crossAxisCount = 2;
          childAspectRatio = 0.85;
        } else if (constraints.maxWidth < 900) {
          crossAxisCount = 3;
          childAspectRatio = 0.9;
        } else {
          crossAxisCount = 4;
          childAspectRatio = 0.95;
        }

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: isMobile ? 16 : 20,
            mainAxisSpacing: isMobile ? 16 : 20,
          ),
          itemCount: _allSkills.length,
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _cardAnimations.length > index
                  ? _cardAnimations[index]
                  : _cardAnimationController,
              builder: (context, child) {
                final animation = _cardAnimations.length > index
                    ? _cardAnimations[index]
                    : _cardAnimationController;

                return Transform.scale(
                  scale: animation.value,
                  child: Transform.translate(
                    offset: Offset(0, 30 * (1 - animation.value)),
                    child: Opacity(
                      opacity: animation.value,
                      child: _buildSkillCard(_allSkills[index], isMobile),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSkillCard(SkillModel skill, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.offwhite, AppColors.offwhite],
        ),
        border: Border.all(width: 1, color: AppColors.overlayBlack),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 25,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          // onTap: () => _showSkillDetail(skill),
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.black.withOpacity(0.1),
          highlightColor: Colors.black.withOpacity(0.05),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 20 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Container with improved styling
                Container(
                  width: isMobile ? 60 : 80,
                  height: isMobile ? 60 : 80,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.black.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildSkillIcon(skill, isMobile),
                  ),
                ),

                SizedBox(height: isMobile ? 16 : 20),

                // Skill Name with white color
                Text(
                  skill.name,
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: AppFonts.bold,
                    color: Colors.black,
                    fontFamily: AppFonts.primary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: isMobile ? 8 : 10),

                // Proficiency Level with light gray color
                Text(
                  skill.proficiencyLevel,
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: AppFonts.medium,
                    color: AppColors.textSecondary,
                    fontFamily: AppFonts.primary,
                  ),
                ),

                // SizedBox(height: isMobile ? 12 : 16),

                // Progress Bar with white styling
                // Column(
                //   children: [
                //     Row(
                //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //       children: [
                //         Text(
                //           'Proficiency',
                //           style: TextStyle(
                //             fontSize: 11,
                //             fontWeight: AppFonts.medium,
                //             color: Colors.black38,
                //             fontFamily: AppFonts.primary,
                //           ),
                //         ),
                //         Text(
                //           skill.proficiencyPercentage,
                //           style: TextStyle(
                //             fontSize: 11,
                //             fontWeight: AppFonts.bold,
                //             color: Colors.black,
                //             fontFamily: AppFonts.primary,
                //           ),
                //         ),
                //       ],
                //     ),
                //     const SizedBox(height: 8),
                //     Container(
                //       height: 4,
                //       decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(2),
                //         color: Colors.black.withOpacity(0.2),
                //       ),
                //       child: FractionallySizedBox(
                //         alignment: Alignment.centerLeft,
                //         widthFactor: skill.proficiency,
                //         child: Container(
                //           decoration: BoxDecoration(
                //             borderRadius: BorderRadius.circular(2),
                //             gradient: LinearGradient(
                //               colors: [Colors.black, AppColors.lightGray],
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkillIcon(SkillModel skill, bool isMobile) {
    return Image.asset(
      skill.logoPath,
      width: isMobile ? 36 : 44,
      height: isMobile ? 36 : 44,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Modern fallback icon instead of red error screen
        return Container(
          width: isMobile ? 36 : 44,
          height: isMobile ? 36 : 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.9), Colors.grey.shade200],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.code_rounded,
            size: isMobile ? 24 : 28,
            color: Colors.grey.shade700,
          ),
        );
      },
    );
  }

  void _showSkillDetail(SkillModel skill) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            constraints: const BoxConstraints(maxWidth: 420),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.black, Colors.grey.shade800],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0,
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _buildSkillIcon(skill, false),
                  ),
                ),

                const SizedBox(height: 24),

                // Skill Name
                Text(
                  skill.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: AppFonts.bold,
                    color: Colors.white,
                    fontFamily: AppFonts.primary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Proficiency Level
                Text(
                  skill.proficiencyLevel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: AppFonts.medium,
                    color: Colors.grey.shade300,
                    fontFamily: AppFonts.primary,
                  ),
                ),

                const SizedBox(height: 20),

                // Progress Bar
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Proficiency Level',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: AppFonts.medium,
                            color: Colors.grey.shade400,
                            fontFamily: AppFonts.primary,
                          ),
                        ),
                        Text(
                          skill.proficiencyPercentage,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: AppFonts.bold,
                            color: Colors.white,
                            fontFamily: AppFonts.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: skill.proficiency,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [Colors.white, Colors.grey.shade300],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: AppFonts.semiBold,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:saad_website/data/repositories/skill_data.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';
// import '../../../data/models/skill_model.dart';
// import '../../../data/repositories/portfolio_data.dart';

// class SkillsSection extends StatefulWidget {
//   final ScrollController scrollController;

//   const SkillsSection({Key? key, required this.scrollController})
//     : super(key: key);

//   @override
//   State<SkillsSection> createState() => _SkillsSectionState();
// }

// class _SkillsSectionState extends State<SkillsSection>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late AnimationController _cardAnimationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<Offset> _slideAnimation;
//   late List<Animation<double>> _cardAnimations;

//   bool _hasAnimated = false;
//   late GlobalKey _sectionKey;
//   String _selectedCategory = 'All';

//   List<SkillModel> _displayedSkills = [];
//   List<String> _categories = [];

//   @override
//   void initState() {
//     super.initState();
//     _sectionKey = GlobalKey();
//     _loadSkillsData();
//     _setupAnimations();
//     _setupScrollListener();
//   }

//   void _loadSkillsData() {
//     _categories = PortfolioRepository.getSkillCategories();
//     _displayedSkills = PortfolioRepository.getSkillsByCategory(
//       _selectedCategory,
//     );
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _cardAnimationController = AnimationController(
//       duration: const Duration(milliseconds: 1200),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
//       ),
//     );

//     _slideAnimation =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
//           ),
//         );

//     _setupCardAnimations();
//   }

//   void _setupCardAnimations() {
//     _cardAnimations = List.generate(
//       _displayedSkills.length,
//       (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//           parent: _cardAnimationController,
//           curve: Interval(
//             (index * 0.1).clamp(0.0, 0.8),
//             ((index * 0.1) + 0.3).clamp(0.3, 1.0),
//             curve: Curves.easeOutBack,
//           ),
//         ),
//       ),
//     );
//   }

//   void _setupScrollListener() {
//     widget.scrollController.addListener(() {
//       if (!_hasAnimated && _isInView()) {
//         _startAnimation();
//         _hasAnimated = true;
//       }
//     });
//   }

//   bool _isInView() {
//     if (_sectionKey.currentContext == null) return false;

//     final RenderBox? renderBox =
//         _sectionKey.currentContext!.findRenderObject() as RenderBox?;

//     if (renderBox == null) return false;

//     final position = renderBox.localToGlobal(Offset.zero);
//     final screenHeight = MediaQuery.of(context).size.height;

//     return position.dy < screenHeight * 0.8 &&
//         position.dy > -renderBox.size.height * 0.3;
//   }

//   void _startAnimation() {
//     if (mounted) {
//       _animationController.forward();
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           _cardAnimationController.forward();
//         }
//       });
//     }
//   }

//   void _onCategoryChanged(String category) {
//     setState(() {
//       _selectedCategory = category;
//       _displayedSkills = PortfolioRepository.getSkillsByCategory(category);
//     });

//     // Reset and restart card animations
//     _cardAnimationController.reset();
//     _setupCardAnimations();
//     _cardAnimationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _cardAnimationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Container(
//       key: _sectionKey,
//       width: double.infinity,
//       color: AppColors.pureWhite,
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile
//             ? AppDimensions.paddingMedium
//             : AppDimensions.paddingXLarge,
//         vertical: AppDimensions.paddingXLarge * 1.5,
//       ),
//       child: SlideTransition(
//         position: _slideAnimation,
//         child: FadeTransition(
//           opacity: _fadeAnimation,
//           child: Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 1200),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _buildSectionHeader(isMobile),
//                   SizedBox(height: isMobile ? 30 : 40),
//                   _buildCategoryFilter(isMobile),
//                   SizedBox(height: isMobile ? 30 : 50),
//                   _buildSkillsGrid(isMobile),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionHeader(bool isMobile) {
//     return Column(
//       children: [
//         // Section Label
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: AppColors.primaryBlack.withOpacity(0.05),
//             borderRadius: BorderRadius.circular(25),
//           ),
//           child: Text(
//             'Skills & Technologies',
//             style: TextStyle(
//               fontSize: 14,
//               fontWeight: AppFonts.medium,
//               color: AppColors.primaryBlack,
//               fontFamily: AppFonts.primary,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),

//         SizedBox(height: isMobile ? 20 : 24),

//         // Main Title
//         Text(
//           'Technical Expertise',
//           style: TextStyle(
//             fontSize: isMobile ? 32 : 42,
//             fontWeight: AppFonts.bold,
//             color: AppColors.primaryBlack,
//             fontFamily: AppFonts.primary,
//             height: 1.2,
//           ),
//           textAlign: TextAlign.center,
//         ),

//         SizedBox(height: isMobile ? 12 : 16),

//         // Subtitle
//         Text(
//           'Technologies and tools I use to bring ideas to life',
//           style: TextStyle(
//             fontSize: isMobile ? 16 : 18,
//             fontWeight: AppFonts.regular,
//             color: AppColors.textSecondary,
//             fontFamily: AppFonts.primary,
//             height: 1.5,
//           ),
//           textAlign: TextAlign.center,
//         ),
//       ],
//     );
//   }

//   Widget _buildCategoryFilter(bool isMobile) {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: _categories.map((category) {
//           final isSelected = category == _selectedCategory;
//           final skillCount =
//               PortfolioRepository.getSkillsCountByCategory()[category] ?? 0;

//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 6),
//             child: _buildCategoryChip(
//               category,
//               skillCount,
//               isSelected,
//               isMobile,
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildCategoryChip(
//     String category,
//     int count,
//     bool isSelected,
//     bool isMobile,
//   ) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _onCategoryChanged(category),
//           borderRadius: BorderRadius.circular(25),
//           child: Container(
//             padding: EdgeInsets.symmetric(
//               horizontal: isMobile ? 16 : 20,
//               vertical: isMobile ? 10 : 12,
//             ),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? AppColors.primaryBlack
//                   : AppColors.primaryBlack.withOpacity(0.05),
//               borderRadius: BorderRadius.circular(25),
//               border: Border.all(
//                 color: isSelected
//                     ? AppColors.primaryBlack
//                     : AppColors.primaryBlack.withOpacity(0.1),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   category,
//                   style: TextStyle(
//                     fontSize: isMobile ? 13 : 14,
//                     fontWeight: AppFonts.medium,
//                     color: isSelected
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     fontFamily: AppFonts.primary,
//                   ),
//                 ),
//                 if (count > 0) ...[
//                   const SizedBox(width: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 6,
//                       vertical: 2,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isSelected
//                           ? AppColors.pureWhite.withOpacity(0.2)
//                           : AppColors.primaryBlack.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: Text(
//                       count.toString(),
//                       style: TextStyle(
//                         fontSize: 11,
//                         fontWeight: AppFonts.medium,
//                         color: isSelected
//                             ? AppColors.pureWhite
//                             : AppColors.primaryBlack,
//                         fontFamily: AppFonts.primary,
//                       ),
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSkillsGrid(bool isMobile) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         int crossAxisCount;
//         double childAspectRatio;

//         if (isMobile) {
//           crossAxisCount = 2;
//           childAspectRatio = 0.85;
//         } else if (constraints.maxWidth < 900) {
//           crossAxisCount = 3;
//           childAspectRatio = 0.9;
//         } else {
//           crossAxisCount = 4;
//           childAspectRatio = 0.95;
//         }

//         return GridView.builder(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: crossAxisCount,
//             childAspectRatio: childAspectRatio,
//             crossAxisSpacing: isMobile ? 12 : 16,
//             mainAxisSpacing: isMobile ? 12 : 16,
//           ),
//           itemCount: _displayedSkills.length,
//           itemBuilder: (context, index) {
//             return AnimatedBuilder(
//               animation: _cardAnimations.length > index
//                   ? _cardAnimations[index]
//                   : _cardAnimationController,
//               builder: (context, child) {
//                 final animation = _cardAnimations.length > index
//                     ? _cardAnimations[index]
//                     : _cardAnimationController;

//                 return Transform.scale(
//                   scale: animation.value,
//                   child: Opacity(
//                     opacity: animation.value,
//                     child: _buildSkillCard(_displayedSkills[index], isMobile),
//                   ),
//                 );
//               },
//             );
//           },
//         );
//       },
//     );
//   }

//   Widget _buildSkillCard(SkillModel skill, bool isMobile) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.pureWhite,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryBlack.withOpacity(0.04),
//             spreadRadius: 0,
//             blurRadius: 20,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(
//           color: AppColors.primaryBlack.withOpacity(0.06),
//           width: 1,
//         ),
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: () => _showSkillDetail(skill),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: EdgeInsets.all(isMobile ? 16 : 20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 // Logo
//                 Container(
//                   width: isMobile ? 48 : 56,
//                   height: isMobile ? 48 : 56,
//                   decoration: BoxDecoration(
//                     color: AppColors.offwhite,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: Image.asset(
//                       skill.logoPath,
//                       width: isMobile ? 32 : 40,
//                       height: isMobile ? 32 : 40,
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) {
//                         // Fallback icon if image doesn't exist
//                         return Icon(
//                           Icons.code,
//                           size: isMobile ? 32 : 40,
//                           color: AppColors.darkGray,
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 SizedBox(height: isMobile ? 12 : 16),

//                 // Skill Name
//                 Text(
//                   skill.name,
//                   style: TextStyle(
//                     fontSize: isMobile ? 16 : 18,
//                     fontWeight: AppFonts.semiBold,
//                     color: AppColors.primaryBlack,
//                     fontFamily: AppFonts.primary,
//                   ),
//                   textAlign: TextAlign.center,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                 ),

//                 SizedBox(height: isMobile ? 6 : 8),

//                 // Proficiency Level
//                 Text(
//                   skill.proficiencyLevel,
//                   style: TextStyle(
//                     fontSize: isMobile ? 12 : 13,
//                     fontWeight: AppFonts.medium,
//                     color: AppColors.textSecondary,
//                     fontFamily: AppFonts.primary,
//                   ),
//                 ),

//                 SizedBox(height: isMobile ? 8 : 12),

//                 // Progress Bar
//                 Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Proficiency',
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: AppFonts.medium,
//                             color: AppColors.textSecondary,
//                             fontFamily: AppFonts.primary,
//                           ),
//                         ),
//                         Text(
//                           skill.proficiencyPercentage,
//                           style: TextStyle(
//                             fontSize: 11,
//                             fontWeight: AppFonts.semiBold,
//                             color: AppColors.primaryBlack,
//                             fontFamily: AppFonts.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     LinearProgressIndicator(
//                       value: skill.proficiency,
//                       backgroundColor: AppColors.primaryBlack.withOpacity(0.1),
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         AppColors.primaryBlack,
//                       ),
//                       minHeight: 3,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _showSkillDetail(SkillModel skill) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(24),
//             constraints: const BoxConstraints(maxWidth: 400),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Logo
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: AppColors.offwhite,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.circular(16),
//                     child: Image.asset(
//                       skill.logoPath,
//                       width: 60,
//                       height: 60,
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) {
//                         return const Icon(
//                           Icons.code,
//                           size: 60,
//                           color: AppColors.darkGray,
//                         );
//                       },
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Skill Name
//                 Text(
//                   skill.name,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: AppFonts.bold,
//                     color: AppColors.primaryBlack,
//                     fontFamily: AppFonts.primary,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 8),

//                 // Category
//                 // Category
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 6,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppColors.primaryBlack.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(15),
//                   ),
//                   child: Text(
//                     skill.category,
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: AppFonts.medium,
//                       color: AppColors.primaryBlack,
//                       fontFamily: AppFonts.primary,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Proficiency Level
//                 Text(
//                   skill.proficiencyLevel,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: AppFonts.medium,
//                     color: AppColors.textSecondary,
//                     fontFamily: AppFonts.primary,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Progress Bar with Percentage
//                 Column(
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Text(
//                           'Proficiency Level',
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: AppFonts.medium,
//                             color: AppColors.textSecondary,
//                             fontFamily: AppFonts.primary,
//                           ),
//                         ),
//                         Text(
//                           skill.proficiencyPercentage,
//                           style: const TextStyle(
//                             fontSize: 14,
//                             fontWeight: AppFonts.bold,
//                             color: AppColors.primaryBlack,
//                             fontFamily: AppFonts.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 10),
//                     LinearProgressIndicator(
//                       value: skill.proficiency,
//                       backgroundColor: AppColors.primaryBlack.withOpacity(0.1),
//                       valueColor: const AlwaysStoppedAnimation<Color>(
//                         AppColors.primaryBlack,
//                       ),
//                       minHeight: 6,
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // Description (if available)
//                 if (skill.description != null &&
//                     skill.description!.isNotEmpty) ...[
//                   Text(
//                     skill.description!,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: AppFonts.regular,
//                       color: AppColors.textSecondary,
//                       fontFamily: AppFonts.primary,
//                       height: 1.5,
//                     ),
//                     textAlign: TextAlign.center,
//                     maxLines: 3,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 20),
//                 ],

//                 // Close Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: () => Navigator.of(context).pop(),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: AppColors.primaryBlack,
//                       foregroundColor: AppColors.pureWhite,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 0,
//                     ),
//                     child: const Text(
//                       'Close',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: AppFonts.medium,
//                         fontFamily: AppFonts.primary,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
