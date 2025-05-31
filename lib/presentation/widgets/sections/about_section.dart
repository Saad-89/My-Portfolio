import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';

class AboutSection extends StatefulWidget {
  final ScrollController scrollController;

  const AboutSection({Key? key, required this.scrollController})
    : super(key: key);

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _fadeAnimation;
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
      duration: const Duration(milliseconds: 800), // Faster animation
      vsync: this,
    );

    // Smoother, more subtle slide animations
    _imageSlideAnimation =
        Tween<Offset>(begin: const Offset(0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.1, 0.7, curve: Curves.easeOutQuart),
          ),
        );

    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart),
          ),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // Removed auto-start animation - will only trigger on scroll
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(_checkVisibility);
  }

  void _checkVisibility() {
    if (!_hasAnimated && _isInView()) {
      _startAnimation();
      _hasAnimated = true;
      // Remove listener after animation starts to improve performance
      widget.scrollController.removeListener(_checkVisibility);
    }
  }

  bool _isInView() {
    if (_sectionKey.currentContext == null) return false;

    final RenderBox? renderBox =
        _sectionKey.currentContext!.findRenderObject() as RenderBox?;

    if (renderBox == null) return false;

    final position = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    // More precise trigger - when 30% of section is visible
    return position.dy < screenHeight * 0.7 &&
        position.dy > -renderBox.size.height * 0.3;
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_checkVisibility);
    _animationController.dispose();
    super.dispose();
  }

  void _startAnimation() {
    if (mounted) {
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

    return Container(
      key: _sectionKey,
      width: double.infinity,
      color: AppColors.offwhite,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppDimensions.paddingMedium
            : AppDimensions.paddingXLarge,
        vertical: AppDimensions.paddingXLarge,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Left side - Text content
        Expanded(
          flex: 5,
          child: SlideTransition(
            position: _textSlideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildTextContent(),
            ),
          ),
        ),

        // Increased spacing between text and image
        const SizedBox(width: AppDimensions.paddingXLarge * 2),

        // Right side - Image
        Expanded(
          flex: 4,
          child: SlideTransition(
            position: _imageSlideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildImageContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Image first on mobile
        SlideTransition(
          position: _imageSlideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildImageContent(),
          ),
        ),

        // Increased spacing between image and text on mobile
        const SizedBox(height: AppDimensions.paddingXLarge * 1.5),

        // Text content
        SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: _buildTextContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildTextContent() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

    return RepaintBoundary(
      child: Column(
        crossAxisAlignment: isMobile
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          // Section Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlack.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'About Me',
              style: TextStyle(
                fontSize: 12,
                fontWeight: AppFonts.medium,
                color: AppColors.primaryBlack,
                fontFamily: AppFonts.primary,
                letterSpacing: 1.5,
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Name
          Text(
            'Muhammad\nAhsan',
            style: TextStyle(
              fontSize: isMobile ? 36 : 48,
              fontWeight: AppFonts.bold,
              color: AppColors.primaryBlack,
              fontFamily: AppFonts.primary,
              height: 1.1,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),

          const SizedBox(height: AppDimensions.paddingMedium),

          // Introduction
          Text(
            "Hello, I'm Muhammad Ahsan.\nI'm a Flutter developer passionate about creating beautiful cross-platform mobile experiences. I specialize in building high-performance apps that work seamlessly on both iOS and Android.",
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: AppFonts.regular,
              color: AppColors.darkGray,
              fontFamily: AppFonts.primary,
              height: 1.6,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),

          const SizedBox(height: AppDimensions.paddingSmall),

          // Skills/Experience brief
          Text(
            "My expertise includes Flutter, Dart, Firebase, REST APIs, and state management solutions like Provider and Bloc. I've worked with clients ranging from startups to established companies, delivering robust mobile solutions.",
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              fontWeight: AppFonts.regular,
              color: AppColors.lightGray,
              fontFamily: AppFonts.primary,
              height: 1.6,
            ),
            textAlign: isMobile ? TextAlign.center : TextAlign.left,
          ),

          const SizedBox(height: AppDimensions.paddingLarge),

          // Social Links
          Wrap(
            alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
            spacing: AppDimensions.paddingLarge,
            children: [
              _buildSocialLink('Instagram', () {}),
              _buildSocialLink('LinkedIn', () {}),
              _buildSocialLink('GitHub', () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

    return RepaintBoundary(
      child: Container(
        width: isMobile ? 280 : 400,
        height: isMobile ? 350 : 500,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryBlack.withOpacity(0.1),
              spreadRadius: 0,
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            color: AppColors.lightGray.withOpacity(0.3),
            child: const Center(
              child: Icon(Icons.person, size: 100, color: AppColors.darkGray),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLink(String title, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: AppFonts.medium,
                  color: AppColors.darkGray,
                  fontFamily: AppFonts.primary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 1,
                width: title.length * 6.0,
                color: AppColors.primaryBlack,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';

// class AboutSection extends StatefulWidget {
//   final ScrollController scrollController;

//   const AboutSection({Key? key, required this.scrollController})
//     : super(key: key);

//   @override
//   State<AboutSection> createState() => _AboutSectionState();
// }

// class _AboutSectionState extends State<AboutSection>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<Offset> _imageSlideAnimation;
//   late Animation<Offset> _textSlideAnimation;
//   late Animation<double> _fadeAnimation;
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
//       duration: const Duration(milliseconds: 1200), // Reduced duration
//       vsync: this,
//     );

//     _imageSlideAnimation =
//         Tween<Offset>(begin: const Offset(0.5, 0), end: Offset.zero).animate(
//           // Reduced slide distance
//           CurvedAnimation(
//             parent: _animationController,
//             curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
//           ),
//         );

//     _textSlideAnimation =
//         Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
//           // Reduced slide distance
//           CurvedAnimation(
//             parent: _animationController,
//             curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
//           ),
//         );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
//       ),
//     );

//     // Auto-start animation after a short delay
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted) {
//           _startAnimation();
//         }
//       });
//     });
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

//     // Trigger animation when section is 50% visible
//     return position.dy < screenHeight * 0.8 &&
//         position.dy > -renderBox.size.height * 0.5;
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _startAnimation() {
//     if (mounted) {
//       _animationController.forward();
//     }
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
//       child: Center(
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 1200),
//           child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
//         ),
//       ),
//     );
//   }

//   Widget _buildDesktopLayout() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // Left side - Text content
//         Expanded(
//           flex: 5,
//           child: SlideTransition(
//             position: _textSlideAnimation,
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildTextContent(),
//             ),
//           ),
//         ),

//         const SizedBox(width: AppDimensions.paddingXLarge),

//         // Right side - Image
//         Expanded(
//           flex: 4,
//           child: SlideTransition(
//             position: _imageSlideAnimation,
//             child: FadeTransition(
//               opacity: _fadeAnimation,
//               child: _buildImageContent(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildMobileLayout() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         // Image first on mobile
//         SlideTransition(
//           position: _imageSlideAnimation,
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: _buildImageContent(),
//           ),
//         ),

//         const SizedBox(height: AppDimensions.paddingLarge),

//         // Text content
//         SlideTransition(
//           position: _textSlideAnimation,
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: _buildTextContent(),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextContent() {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Column(
//       crossAxisAlignment: isMobile
//           ? CrossAxisAlignment.center
//           : CrossAxisAlignment.start,
//       children: [
//         // Section Label
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: AppColors.primaryBlack.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             'About Me',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: AppFonts.medium,
//               color: AppColors.primaryBlack,
//               fontFamily: AppFonts.primary,
//               letterSpacing: 1.5,
//             ),
//           ),
//         ),

//         const SizedBox(height: AppDimensions.paddingLarge),

//         // Name
//         Text(
//           'Muhammad\nAhsan',
//           style: TextStyle(
//             fontSize: isMobile ? 36 : 48,
//             fontWeight: AppFonts.bold,
//             color: AppColors.primaryBlack,
//             fontFamily: AppFonts.primary,
//             height: 1.1,
//           ),
//           textAlign: isMobile ? TextAlign.center : TextAlign.left,
//         ),

//         const SizedBox(height: AppDimensions.paddingMedium),

//         // Introduction
//         Text(
//           "Hello, I'm Muhammad Ahsan.\nI'm a Flutter developer passionate about creating beautiful cross-platform mobile experiences. I specialize in building high-performance apps that work seamlessly on both iOS and Android.",
//           style: TextStyle(
//             fontSize: isMobile ? 16 : 18,
//             fontWeight: AppFonts.regular,
//             color: AppColors.darkGray,
//             fontFamily: AppFonts.primary,
//             height: 1.6,
//           ),
//           textAlign: isMobile ? TextAlign.center : TextAlign.left,
//         ),

//         const SizedBox(height: AppDimensions.paddingSmall),

//         // Skills/Experience brief
//         Text(
//           "My expertise includes Flutter, Dart, Firebase, REST APIs, and state management solutions like Provider and Bloc. I've worked with clients ranging from startups to established companies, delivering robust mobile solutions.",
//           style: TextStyle(
//             fontSize: isMobile ? 14 : 16,
//             fontWeight: AppFonts.regular,
//             color: AppColors.lightGray,
//             fontFamily: AppFonts.primary,
//             height: 1.6,
//           ),
//           textAlign: isMobile ? TextAlign.center : TextAlign.left,
//         ),

//         const SizedBox(height: AppDimensions.paddingLarge),

//         // Social Links
//         Wrap(
//           alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
//           spacing: AppDimensions.paddingLarge,
//           children: [
//             _buildSocialLink('Instagram', () {}),
//             _buildSocialLink('LinkedIn', () {}),
//             _buildSocialLink('GitHub', () {}),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildImageContent() {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Container(
//       width: isMobile ? 280 : 400,
//       height: isMobile ? 350 : 500,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: AppColors.primaryBlack.withOpacity(0.1),
//             spreadRadius: 0,
//             blurRadius: 30,
//             offset: const Offset(0, 15),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(20),
//         child: Container(
//           color: AppColors.lightGray.withOpacity(0.3),
//           child: const Center(
//             child: Icon(Icons.person, size: 100, color: AppColors.darkGray),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildSocialLink(String title, VoidCallback onTap) {
//     return MouseRegion(
//       cursor: SystemMouseCursors.click,
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(4),
//         child: Padding(
//           padding: const EdgeInsets.all(4),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 14,
//                   fontWeight: AppFonts.medium,
//                   color: AppColors.darkGray,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),
//               const SizedBox(height: 4),
//               Container(
//                 height: 1,
//                 width: title.length * 6.0,
//                 color: AppColors.primaryBlack,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
