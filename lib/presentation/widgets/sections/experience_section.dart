// lib/presentation/widgets/sections/experience_section.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/experience_model.dart';
import '../../../data/repositories/experience_data.dart';
import '../common/section_title.dart';

class ExperienceSection extends StatefulWidget {
  final ScrollController scrollController;

  const ExperienceSection({Key? key, required this.scrollController})
    : super(key: key);

  @override
  State<ExperienceSection> createState() => _ExperienceSectionState();
}

class _ExperienceSectionState extends State<ExperienceSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late List<AnimationController> _cardAnimationControllers;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;

  bool _hasAnimated = false;
  late GlobalKey _sectionKey;

  @override
  void initState() {
    super.initState();
    _sectionKey = GlobalKey();
    _setupAnimations();
    _setupScrollListener();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // Create individual animation controllers for each experience card
    _cardAnimationControllers = List.generate(
      ExperienceData.experiences.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1000 + (index * 150)),
        vsync: this,
      ),
    );

    // Create slide animations for each card
    _slideAnimations = _cardAnimationControllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(0, 0.8),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.elasticOut));
    }).toList();

    // Create scale animations for each card
    _scaleAnimations = _cardAnimationControllers.map((controller) {
      return Tween<double>(
        begin: 0.8,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    }).toList();

    // Auto-start animation after delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _startAnimations();
        }
      });
    });
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      if (!_hasAnimated && _isInView()) {
        _startAnimations();
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

    return position.dy < screenHeight * 0.9 &&
        position.dy > -renderBox.size.height * 0.3;
  }

  void _startAnimations() {
    if (mounted) {
      _animationController.forward();

      // Start card animations with staggered delay
      for (int i = 0; i < _cardAnimationControllers.length; i++) {
        Future.delayed(Duration(milliseconds: 200 + (i * 200)), () {
          if (mounted) {
            _cardAnimationControllers[i].forward();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _cardAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

    return Container(
      key: _sectionKey,
      width: double.infinity,
      // Black background for dramatic effect
      decoration: const BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [Color(0xFF000000), Color(0xFF1a1a1a), Color(0xFF000000)],
        //   stops: [0.0, 0.5, 1.0],
        // ),
        color: AppColors.offwhite,
      ),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppDimensions.paddingMedium
            : AppDimensions.paddingXLarge,
        vertical: AppDimensions.paddingXLarge * 1.5,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              children: [
                // Enhanced Section Title
                _buildEnhancedSectionTitle(isMobile),

                SizedBox(height: isMobile ? 60 : 100),

                // Experience Timeline
                _buildExperienceTimeline(isMobile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedSectionTitle(bool isMobile) {
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
          'EXPERIENCE',
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
          'Professional Journey & Milestones',
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

  Widget _buildExperienceTimeline(bool isMobile) {
    return Column(
      children: [
        for (int index = 0; index < ExperienceData.experiences.length; index++)
          SlideTransition(
            position: _slideAnimations[index],
            child: ScaleTransition(
              scale: _scaleAnimations[index],
              child: FadeTransition(
                opacity: _cardAnimationControllers[index],
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: index == ExperienceData.experiences.length - 1
                        ? 0
                        : (isMobile ? 40 : 60),
                  ),
                  child: _buildModernExperienceCard(
                    ExperienceData.experiences[index],
                    isMobile,
                    index,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildModernExperienceCard(
    ExperienceModel experience,
    bool isMobile,
    int index,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // White card with subtle shadow
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 0,
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Subtle gradient overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.grey.withOpacity(0.02)],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(isMobile ? 24 : 40),
            child: isMobile
                ? _buildModernMobileCardContent(experience, index)
                : _buildModernDesktopCardContent(experience, index),
          ),

          // Accent line
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black, Colors.grey.shade400, Colors.black],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDesktopCardContent(ExperienceModel experience, int index) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Enhanced company info
        SizedBox(
          width: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo with enhanced styling
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: experience.companyLogo != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          experience.companyLogo!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildModernDefaultLogo(experience.company);
                          },
                        ),
                      )
                    : _buildModernDefaultLogo(experience.company),
              ),

              const SizedBox(height: 24),

              // Duration with enhanced styling
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  experience.duration,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: AppFonts.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Job Type with modern styling
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: experience.isCurrentJob
                      ? Colors.black.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: experience.isCurrentJob
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  experience.type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: experience.isCurrentJob
                        ? Colors.black
                        : Colors.grey.shade600,
                    fontFamily: AppFonts.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      experience.location,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Right side - Job details with modern layout
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Position and Company with enhanced header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          experience.position,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: AppFonts.primary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          experience.company,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                            fontFamily: AppFonts.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (experience.isCurrentJob)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 0,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'CURRENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: AppFonts.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Divider
              Container(width: 60, height: 2, color: Colors.black),

              const SizedBox(height: 24),

              // Description with better typography
              Text(
                experience.description,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade700,
                  fontFamily: AppFonts.primary,
                  height: 1.7,
                  letterSpacing: 0.3,
                ),
              ),

              const SizedBox(height: 32),

              // Responsibilities with modern styling
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KEY RESPONSIBILITIES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: AppFonts.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...experience.responsibilities.map((responsibility) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 8, right: 16),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              responsibility,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade700,
                                fontFamily: AppFonts.primary,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),

              const SizedBox(height: 32),

              // Technologies with modern pill design
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TECHNOLOGIES',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: AppFonts.primary,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: experience.technologies.map((tech) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          tech,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            fontFamily: AppFonts.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernMobileCardContent(ExperienceModel experience, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced mobile header
        Row(
          children: [
            // Company Logo
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: experience.companyLogo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        experience.companyLogo!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildModernDefaultLogo(experience.company);
                        },
                      ),
                    )
                  : _buildModernDefaultLogo(experience.company),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    experience.position,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                      fontFamily: AppFonts.primary,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    experience.company,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                ],
              ),
            ),

            if (experience.isCurrentJob)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'CURRENT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontFamily: AppFonts.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // Duration and type
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                experience.duration,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: AppFonts.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                experience.type.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade700,
                  fontFamily: AppFonts.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Location
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              experience.location,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
                fontFamily: AppFonts.primary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Divider
        Container(width: 40, height: 2, color: Colors.black),

        const SizedBox(height: 20),

        // Description
        Text(
          experience.description,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
            fontFamily: AppFonts.primary,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 20),

        // Key responsibilities (mobile optimized)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'KEY RESPONSIBILITIES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: AppFonts.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            ...experience.responsibilities.take(3).map((responsibility) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6, right: 10),
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        responsibility,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey.shade700,
                          fontFamily: AppFonts.primary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),

        const SizedBox(height: 20),

        // Technologies (mobile optimized)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TECHNOLOGIES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontFamily: AppFonts.primary,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: experience.technologies.take(8).map((tech) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    tech,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModernDefaultLogo(String companyName) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.black, Colors.grey.shade800],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          companyName.substring(0, 1).toUpperCase(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontFamily: AppFonts.primary,
          ),
        ),
      ),
    );
  }
}

// // lib/presentation/widgets/sections/experience_section.dart
// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';
// import '../../../data/models/experience_model.dart';
// import '../../../data/repositories/experience_data.dart';
// import '../common/section_title.dart';

// class ExperienceSection extends StatefulWidget {
//   final ScrollController scrollController;

//   const ExperienceSection({Key? key, required this.scrollController})
//     : super(key: key);

//   @override
//   State<ExperienceSection> createState() => _ExperienceSectionState();
// }

// class _ExperienceSectionState extends State<ExperienceSection>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late List<AnimationController> _cardAnimationControllers;
//   late List<Animation<Offset>> _slideAnimations;

//   bool _hasAnimated = false;
//   late GlobalKey _sectionKey;

//   @override
//   void initState() {
//     super.initState();
//     _sectionKey = GlobalKey();
//     _setupAnimations();
//     _setupScrollListener();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     // Create individual animation controllers for each experience card
//     _cardAnimationControllers = List.generate(
//       ExperienceData.experiences.length,
//       (index) => AnimationController(
//         duration: Duration(milliseconds: 800 + (index * 200)),
//         vsync: this,
//       ),
//     );

//     // Create slide animations for each card
//     _slideAnimations = _cardAnimationControllers.map((controller) {
//       return Tween<Offset>(
//         begin: const Offset(0.3, 0),
//         end: Offset.zero,
//       ).animate(
//         CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
//       );
//     }).toList();

//     // Auto-start animation after delay
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           _startAnimations();
//         }
//       });
//     });
//   }

//   void _setupScrollListener() {
//     widget.scrollController.addListener(() {
//       if (!_hasAnimated && _isInView()) {
//         _startAnimations();
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
//         position.dy > -renderBox.size.height * 0.5;
//   }

//   void _startAnimations() {
//     if (mounted) {
//       _animationController.forward();

//       // Start card animations with staggered delay
//       for (int i = 0; i < _cardAnimationControllers.length; i++) {
//         Future.delayed(Duration(milliseconds: i * 150), () {
//           if (mounted) {
//             _cardAnimationControllers[i].forward();
//           }
//         });
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     for (var controller in _cardAnimationControllers) {
//       controller.dispose();
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Container(
//       key: _sectionKey,
//       width: double.infinity,
//       color: AppColors.offwhite,
//       constraints: BoxConstraints(
//         minHeight: MediaQuery.of(context).size.height,
//       ),
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile
//             ? AppDimensions.paddingMedium
//             : AppDimensions.paddingXLarge,
//         vertical: AppDimensions.paddingXLarge,
//       ),
//       child: FadeTransition(
//         opacity: _fadeAnimation,
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 1200),
//             child: Column(
//               children: [
//                 // Section Title
//                 SectionTitle(
//                   title: 'Experience',
//                   subtitle: 'My Professional Journey',
//                   isDark: true,
//                 ),

//                 SizedBox(height: isMobile ? 40 : 60),

//                 // Experience Timeline
//                 _buildExperienceTimeline(isMobile),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildExperienceTimeline(bool isMobile) {
//     return Column(
//       children: [
//         for (int index = 0; index < ExperienceData.experiences.length; index++)
//           SlideTransition(
//             position: _slideAnimations[index],
//             child: FadeTransition(
//               opacity: _cardAnimationControllers[index],
//               child: Container(
//                 margin: EdgeInsets.only(
//                   bottom: index == ExperienceData.experiences.length - 1
//                       ? 0
//                       : (isMobile ? 30 : 40),
//                 ),
//                 child: _buildExperienceCard(
//                   ExperienceData.experiences[index],
//                   isMobile,
//                   index,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildExperienceCard(
//     ExperienceModel experience,
//     bool isMobile,
//     int index,
//   ) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: AppColors.pureWhite,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryBlack.withOpacity(0.08),
//             spreadRadius: 0,
//             blurRadius: 20,
//             offset: const Offset(0, 8),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.all(isMobile ? 20 : 32),
//         child: isMobile
//             ? _buildMobileCardContent(experience)
//             : _buildDesktopCardContent(experience),
//       ),
//     );
//   }

//   Widget _buildDesktopCardContent(ExperienceModel experience) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Left side - Company logo and duration
//         SizedBox(
//           width: 200,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Company Logo
//               Container(
//                 width: 60,
//                 height: 60,
//                 decoration: BoxDecoration(
//                   color: AppColors.offwhite,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.lightGray.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: experience.companyLogo != null
//                     ? ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.asset(
//                           experience.companyLogo!,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) {
//                             return _buildDefaultLogo(experience.company);
//                           },
//                         ),
//                       )
//                     : _buildDefaultLogo(experience.company),
//               ),

//               const SizedBox(height: 16),

//               // Duration
//               Text(
//                 experience.duration,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: AppFonts.medium,
//                   color: AppColors.primaryBlue,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               // Job Type
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: experience.isCurrentJob
//                       ? AppColors.primaryBlue.withOpacity(0.1)
//                       : AppColors.lightGray.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: experience.isCurrentJob
//                         ? AppColors.primaryBlue.withOpacity(0.3)
//                         : AppColors.lightGray.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: Text(
//                   experience.type,
//                   style: TextStyle(
//                     fontSize: 11,
//                     fontWeight: AppFonts.medium,
//                     color: experience.isCurrentJob
//                         ? AppColors.primaryBlue
//                         : AppColors.darkGray,
//                     fontFamily: AppFonts.primary,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(width: 32),

//         // Right side - Job details
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Position and Company
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           experience.position,
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: AppFonts.bold,
//                             color: AppColors.primaryBlack,
//                             fontFamily: AppFonts.primary,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           '${experience.company} • ${experience.location}',
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: AppFonts.medium,
//                             color: AppColors.textSecondary,
//                             fontFamily: AppFonts.primary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   if (experience.isCurrentJob)
//                     Container(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 12,
//                         vertical: 6,
//                       ),
//                       decoration: BoxDecoration(
//                         color: AppColors.primaryBlue.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(20),
//                         border: Border.all(
//                           color: AppColors.primaryBlue.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: const Text(
//                         'Current',
//                         style: TextStyle(
//                           fontSize: 12,
//                           fontWeight: AppFonts.medium,
//                           color: AppColors.primaryBlue,
//                           fontFamily: AppFonts.primary,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),

//               const SizedBox(height: 16),

//               // Description
//               Text(
//                 experience.description,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: AppFonts.regular,
//                   color: AppColors.darkGray,
//                   fontFamily: AppFonts.primary,
//                   height: 1.6,
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // Responsibilities
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Key Responsibilities:',
//                     style: TextStyle(
//                       fontSize: 14,
//                       fontWeight: AppFonts.medium,
//                       color: AppColors.primaryBlack,
//                       fontFamily: AppFonts.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   ...experience.responsibilities.map((responsibility) {
//                     return Padding(
//                       padding: const EdgeInsets.only(bottom: 8),
//                       child: Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             margin: const EdgeInsets.only(top: 8, right: 12),
//                             width: 4,
//                             height: 4,
//                             decoration: const BoxDecoration(
//                               color: AppColors.primaryBlue,
//                               shape: BoxShape.circle,
//                             ),
//                           ),
//                           Expanded(
//                             child: Text(
//                               responsibility,
//                               style: const TextStyle(
//                                 fontSize: 14,
//                                 fontWeight: AppFonts.regular,
//                                 color: AppColors.textSecondary,
//                                 fontFamily: AppFonts.primary,
//                                 height: 1.5,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   }).toList(),
//                 ],
//               ),

//               const SizedBox(height: 20),

//               // Technologies
//               Wrap(
//                 spacing: 8,
//                 runSpacing: 8,
//                 children: experience.technologies.map((tech) {
//                   return Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 6,
//                     ),
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryBlue.withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(
//                         color: AppColors.primaryBlue.withOpacity(0.2),
//                         width: 1,
//                       ),
//                     ),
//                     child: Text(
//                       tech,
//                       style: const TextStyle(
//                         fontSize: 12,
//                         fontWeight: AppFonts.medium,
//                         color: AppColors.primaryBlue,
//                         fontFamily: AppFonts.primary,
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMobileCardContent(ExperienceModel experience) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Header with logo and current badge
//         Row(
//           children: [
//             // Company Logo
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: AppColors.offwhite,
//                 borderRadius: BorderRadius.circular(10),
//                 border: Border.all(
//                   color: AppColors.lightGray.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: experience.companyLogo != null
//                   ? ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.asset(
//                         experience.companyLogo!,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return _buildDefaultLogo(experience.company);
//                         },
//                       ),
//                     )
//                   : _buildDefaultLogo(experience.company),
//             ),

//             const SizedBox(width: 12),

//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     experience.position,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: AppFonts.bold,
//                       color: AppColors.primaryBlack,
//                       fontFamily: AppFonts.primary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     experience.company,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: AppFonts.medium,
//                       color: AppColors.textSecondary,
//                       fontFamily: AppFonts.primary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             if (experience.isCurrentJob)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 4,
//                 ),
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryBlue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: AppColors.primaryBlue.withOpacity(0.3),
//                     width: 1,
//                   ),
//                 ),
//                 child: const Text(
//                   'Current',
//                   style: TextStyle(
//                     fontSize: 10,
//                     fontWeight: AppFonts.medium,
//                     color: AppColors.primaryBlue,
//                     fontFamily: AppFonts.primary,
//                   ),
//                 ),
//               ),
//           ],
//         ),

//         const SizedBox(height: 16),

//         // Duration and location
//         Row(
//           children: [
//             Expanded(
//               child: Text(
//                 experience.duration,
//                 style: const TextStyle(
//                   fontSize: 13,
//                   fontWeight: AppFonts.medium,
//                   color: AppColors.primaryBlue,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),
//             ),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: AppColors.lightGray.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 experience.type,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   fontWeight: AppFonts.medium,
//                   color: AppColors.darkGray,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),
//             ),
//           ],
//         ),

//         const SizedBox(height: 4),

//         Text(
//           experience.location,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: AppFonts.regular,
//             color: AppColors.textSecondary,
//             fontFamily: AppFonts.primary,
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Description
//         Text(
//           experience.description,
//           style: const TextStyle(
//             fontSize: 14,
//             fontWeight: AppFonts.regular,
//             color: AppColors.darkGray,
//             fontFamily: AppFonts.primary,
//             height: 1.6,
//           ),
//         ),

//         const SizedBox(height: 16),

//         // Key responsibilities (show only first 3 on mobile)
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Key Responsibilities:',
//               style: TextStyle(
//                 fontSize: 13,
//                 fontWeight: AppFonts.medium,
//                 color: AppColors.primaryBlack,
//                 fontFamily: AppFonts.primary,
//               ),
//             ),
//             const SizedBox(height: 8),
//             ...experience.responsibilities.take(3).map((responsibility) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 6),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       margin: const EdgeInsets.only(top: 6, right: 8),
//                       width: 3,
//                       height: 3,
//                       decoration: const BoxDecoration(
//                         color: AppColors.primaryBlue,
//                         shape: BoxShape.circle,
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         responsibility,
//                         style: const TextStyle(
//                           fontSize: 12,
//                           fontWeight: AppFonts.regular,
//                           color: AppColors.textSecondary,
//                           fontFamily: AppFonts.primary,
//                           height: 1.4,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }).toList(),
//           ],
//         ),

//         const SizedBox(height: 16),

//         // Technologies (show fewer on mobile)
//         Wrap(
//           spacing: 6,
//           runSpacing: 6,
//           children: experience.technologies.take(6).map((tech) {
//             return Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               decoration: BoxDecoration(
//                 color: AppColors.primaryBlue.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.primaryBlue.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Text(
//                 tech,
//                 style: const TextStyle(
//                   fontSize: 10,
//                   fontWeight: AppFonts.medium,
//                   color: AppColors.primaryBlue,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildDefaultLogo(String companyName) {
//     return Container(
//       decoration: BoxDecoration(
//         color: AppColors.primaryBlue.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Text(
//           companyName.substring(0, 1).toUpperCase(),
//           style: const TextStyle(
//             fontSize: 24,
//             fontWeight: AppFonts.bold,
//             color: AppColors.primaryBlue,
//             fontFamily: AppFonts.primary,
//           ),
//         ),
//       ),
//     );
//   }
// }
