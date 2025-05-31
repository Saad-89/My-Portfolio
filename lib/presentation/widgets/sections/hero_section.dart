import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';
import 'dart:math' as math;

class HeroSection extends StatefulWidget {
  final GlobalKey? contactKey;
  final ScrollController? scrollController;

  const HeroSection({Key? key, this.contactKey, this.scrollController})
    : super(key: key);

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _typewriterController;
  late AnimationController _floatingController;
  late AnimationController _glowController;

  late Animation<double> _greetingFade;
  late Animation<Offset> _greetingSlide;
  late Animation<double> _nameFade;
  late Animation<Offset> _nameSlide;
  late Animation<double> _titleFade;
  late Animation<Offset> _titleSlide;
  late Animation<double> _quoteFade;
  late Animation<Offset> _quoteSlide;
  late Animation<double> _ctaFade;
  late Animation<Offset> _ctaSlide;
  late Animation<double> _floatingAnimation;
  late Animation<double> _glowAnimation;

  String _displayedQuote = '';
  final String _fullQuote =
      'Crafting digital experiences with passion & precision.';
  int _currentIndex = 0;
  bool _showCursor = true;
  bool _isAnimationStarted = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // Add error handling for post-frame callback
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startAnimations();
      }
    });
  }

  void _setupAnimations() {
    try {
      // Initialize animation controllers with error handling
      _mainController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      _typewriterController = AnimationController(
        duration: Duration(milliseconds: _fullQuote.length * 30),
        vsync: this,
      );

      _floatingController = AnimationController(
        duration: const Duration(milliseconds: 3000),
        vsync: this,
      );

      _glowController = AnimationController(
        duration: const Duration(milliseconds: 2500),
        vsync: this,
      );

      // Setup animations with null safety
      _greetingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
        ),
      );

      _greetingSlide =
          Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _mainController,
              curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
            ),
          );

      _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
        ),
      );

      _nameSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _mainController,
              curve: const Interval(0.15, 0.5, curve: Curves.easeOutCubic),
            ),
          );

      _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
        ),
      );

      _titleSlide =
          Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _mainController,
              curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
            ),
          );

      _quoteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
        ),
      );

      _quoteSlide =
          Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _mainController,
              curve: const Interval(0.5, 0.85, curve: Curves.easeOutCubic),
            ),
          );

      _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
        ),
      );

      _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
          .animate(
            CurvedAnimation(
              parent: _mainController,
              curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic),
            ),
          );

      _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
      );

      _glowAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
      );

      _typewriterController.addListener(_updateTypewriter);
    } catch (e) {
      debugPrint('Error setting up animations: $e');
      // Provide fallback behavior
      _isAnimationStarted = true;
    }
  }

  void _updateTypewriter() {
    try {
      final progress = _typewriterController.value;
      final targetIndex = (progress * _fullQuote.length).floor();

      if (targetIndex != _currentIndex && targetIndex <= _fullQuote.length) {
        if (mounted) {
          setState(() {
            _currentIndex = targetIndex;
            _displayedQuote = _fullQuote.substring(0, _currentIndex);
          });
        }
      }

      // Cursor blinking logic
      if (_typewriterController.isCompleted) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            setState(() {
              _showCursor = !_showCursor;
            });
          }
        });
      }
    } catch (e) {
      debugPrint('Error updating typewriter: $e');
    }
  }

  void _startAnimations() {
    if (_isAnimationStarted) return;

    try {
      _isAnimationStarted = true;
      _mainController.forward();

      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _typewriterController.forward();
        }
      });

      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _floatingController.repeat(reverse: true);
          _glowController.repeat(reverse: true);
        }
      });
    } catch (e) {
      debugPrint('Error starting animations: $e');
    }
  }

  void _scrollToContact() {
    try {
      if (widget.contactKey?.currentContext != null &&
          widget.scrollController != null &&
          widget.scrollController!.hasClients) {
        final RenderBox renderBox =
            widget.contactKey!.currentContext!.findRenderObject() as RenderBox;

        if (renderBox.hasSize) {
          final position = renderBox.localToGlobal(Offset.zero);
          final screenSize = MediaQuery.of(context).size;
          final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;
          final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;

          // Calculate responsive offset based on device type
          double customOffset;
          if (isMobile) {
            customOffset = 750;
            // screenSize.height * 0.15; // 15% of screen height for mobile
          } else if (isTablet) {
            customOffset = 1150;
            // screenSize.height * 0.20; // 20% of screen height for tablet
          } else {
            customOffset = 150; // Fixed offset for desktop
          }

          final targetPosition =
              position.dy + widget.scrollController!.offset - customOffset;

          // Ensure we don't scroll beyond bounds
          final clampedPosition = targetPosition.clamp(
            0.0,
            widget.scrollController!.position.maxScrollExtent,
          );

          widget.scrollController!.animateTo(
            clampedPosition,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
          );
          return;
        }
      } else if (widget.scrollController != null &&
          widget.scrollController!.hasClients) {
        // Fallback: scroll to near bottom with responsive offset
        final screenSize = MediaQuery.of(context).size;
        final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;
        final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;

        final maxScroll = widget.scrollController!.position.maxScrollExtent;

        // Calculate responsive fallback offset
        double fallbackOffset;
        if (isMobile) {
          fallbackOffset = 750;
          // screenSize.height * 0.25; // 25% of screen height for mobile
        } else if (isTablet) {
          fallbackOffset = 1150;
          // screenSize.height * 0.30; // 30% of screen height for tablet
        } else {
          fallbackOffset = 350; // Fixed offset for desktop
        }

        final targetScroll = maxScroll - fallbackOffset;

        widget.scrollController!.animateTo(
          targetScroll.clamp(0.0, maxScroll),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } else {
        debugPrint('Contact scrolling not available - missing dependencies');
      }
    } catch (e) {
      debugPrint('Error scrolling to contact: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to scroll to contact section'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
  // void _scrollToContact() {
  //   try {
  //     if (widget.contactKey?.currentContext != null &&
  //         widget.scrollController != null &&
  //         widget.scrollController!.hasClients) {
  //       final RenderBox renderBox =
  //           widget.contactKey!.currentContext!.findRenderObject() as RenderBox;

  //       if (renderBox.hasSize) {
  //         final position = renderBox.localToGlobal(Offset.zero);

  //         // Calculate target position with custom offset
  //         final customOffset = 150; // Increase this to scroll less far down
  //         final targetPosition =
  //             position.dy +
  //             widget.scrollController!.offset -
  //             customOffset; // Your custom offset instead of just navHeight

  //         // Ensure we don't scroll beyond bounds
  //         final clampedPosition = targetPosition.clamp(
  //           0.0,
  //           widget.scrollController!.position.maxScrollExtent,
  //         );

  //         widget.scrollController!.animateTo(
  //           clampedPosition,
  //           duration: const Duration(milliseconds: 800),
  //           curve: Curves.easeInOut,
  //         );
  //         return;
  //       }
  //     } else if (widget.scrollController != null &&
  //         widget.scrollController!.hasClients) {
  //       // Fallback: scroll to near bottom (not all the way)
  //       final maxScroll = widget.scrollController!.position.maxScrollExtent;
  //       final targetScroll = maxScroll - 340; // Stop 200px before the bottom

  //       widget.scrollController!.animateTo(
  //         targetScroll.clamp(0.0, maxScroll),
  //         duration: const Duration(milliseconds: 800),
  //         curve: Curves.easeInOut,
  //       );
  //     } else {
  //       debugPrint('Contact scrolling not available - missing dependencies');
  //     }
  //   } catch (e) {
  //     debugPrint('Error scrolling to contact: $e');
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text('Unable to scroll to contact section'),
  //           duration: Duration(seconds: 2),
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  void dispose() {
    try {
      _typewriterController.removeListener(_updateTypewriter);
      _mainController.dispose();
      _typewriterController.dispose();
      _floatingController.dispose();
      _glowController.dispose();
    } catch (e) {
      debugPrint('Error disposing controllers: $e');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final screenSize = MediaQuery.of(context).size;
      final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;
      final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

      return Container(
        width: double.infinity,
        height: screenSize.height,
        decoration: _buildBackgroundGradient(),
        child: Stack(
          children: [
            // Animated background elements
            _buildAnimatedBackground(screenSize, isMobile),

            // Main content
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: isMobile ? screenSize.width * 0.9 : 800,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 20 : 40,
                  vertical: 20,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildGreeting(isMobile, isTablet),
                    const SizedBox(height: 12),
                    _buildName(isMobile, isTablet),
                    const SizedBox(height: 8),
                    _buildTitle(isMobile, isTablet),
                    const SizedBox(height: 32),
                    _buildQuote(isMobile, isTablet, screenSize),
                    const SizedBox(height: 48),
                    _buildCTAButton(isMobile),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error building HeroSection: $e');
      // Return a simple fallback UI
      return Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Muhammad',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Full Stack Developer',
                style: TextStyle(fontSize: 24, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }
  }

  BoxDecoration _buildBackgroundGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: const [0.0, 0.4, 0.8, 1.0],
        colors: [
          Colors.white,
          const Color(0xFFF8F8F8),
          const Color(0xFFE8E8E8),
          const Color(0xFFD8D8D8),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground(Size screenSize, bool isMobile) {
    return AnimatedBuilder(
      animation: Listenable.merge([_floatingAnimation, _glowAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Main glow effect
            Positioned(
              top: screenSize.height * 0.15,
              right: screenSize.width * 0.1,
              child: Transform.translate(
                offset: Offset(
                  10 * math.sin(_floatingAnimation.value * 2 * math.pi),
                  8 * math.cos(_floatingAnimation.value * 2 * math.pi),
                ),
                child: Container(
                  width: isMobile ? 150 : 220,
                  height: isMobile ? 150 : 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withOpacity(0.03 * _glowAnimation.value),
                        Colors.grey.withOpacity(0.02 * _glowAnimation.value),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Secondary glow
            Positioned(
              bottom: screenSize.height * 0.15,
              left: screenSize.width * 0.1,
              child: Transform.translate(
                offset: Offset(
                  -8 * math.sin(_floatingAnimation.value * 2 * math.pi),
                  -6 * math.cos(_floatingAnimation.value * 2 * math.pi),
                ),
                child: Container(
                  width: isMobile ? 100 : 160,
                  height: isMobile ? 100 : 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.04 * _glowAnimation.value),
                        Colors.grey.shade600.withOpacity(
                          0.02 * _glowAnimation.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGreeting(bool isMobile, bool isTablet) {
    return SlideTransition(
      position: _greetingSlide,
      child: FadeTransition(
        opacity: _greetingFade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '👋 Hello, I\'m',
                style: TextStyle(
                  fontSize: isMobile ? 14 : 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkGray,
                  fontFamily: AppFonts.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildName(bool isMobile, bool isTablet) {
    return SlideTransition(
      position: _nameSlide,
      child: FadeTransition(
        opacity: _nameFade,
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Colors.black, Colors.grey.shade800],
          ).createShader(bounds),
          child: Text(
            'Muhammad',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile
                  ? 42
                  : isTablet
                  ? 52
                  : 64,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              fontFamily: AppFonts.primary,
              letterSpacing: -2,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(bool isMobile, bool isTablet) {
    return SlideTransition(
      position: _titleSlide,
      child: FadeTransition(
        opacity: _titleFade,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.grey.shade100, Colors.grey.shade200],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Text(
            'Full Stack Developer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile
                  ? 18
                  : isTablet
                  ? 22
                  : 26,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
              fontFamily: AppFonts.primary,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuote(bool isMobile, bool isTablet, Size screenSize) {
    return SlideTransition(
      position: _quoteSlide,
      child: FadeTransition(
        opacity: _quoteFade,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenSize.width * 0.9 : 600,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  _displayedQuote,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isMobile
                        ? 16
                        : isTablet
                        ? 18
                        : 20,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkGray.withOpacity(0.9),
                    fontFamily: AppFonts.primary,
                    letterSpacing: 0.3,
                    height: 1.6,
                  ),
                ),
              ),
              if (_showCursor || _typewriterController.isAnimating)
                AnimatedOpacity(
                  opacity: _showCursor ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 400),
                  child: Container(
                    width: 2,
                    height: isMobile ? 20 : 24,
                    color: Colors.black,
                    margin: const EdgeInsets.only(left: 2),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTAButton(bool isMobile) {
    return SlideTransition(
      position: _ctaSlide,
      child: FadeTransition(
        opacity: _ctaFade,
        child: AnimatedBuilder(
          animation: _floatingAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                0,
                3 * math.sin(_floatingAnimation.value * 2 * math.pi),
              ),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _scrollToContact,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 28 : 36,
                      vertical: isMobile ? 14 : 18,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black, Colors.grey.shade800],
                      ),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Let\'s Connect',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: AppFonts.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: isMobile ? 16 : 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';
// import 'dart:math' as math;

// class HeroSection extends StatefulWidget {
//   const HeroSection({Key? key}) : super(key: key);

//   @override
//   State<HeroSection> createState() => _HeroSectionState();
// }

// class _HeroSectionState extends State<HeroSection>
//     with TickerProviderStateMixin {
//   late AnimationController _mainController;
//   late AnimationController _typewriterController;
//   late AnimationController _floatingController;
//   late AnimationController _particleController;
//   late AnimationController _glowController;

//   late Animation<double> _greetingFade;
//   late Animation<Offset> _greetingSlide;
//   late Animation<double> _nameFade;
//   late Animation<Offset> _nameSlide;
//   late Animation<double> _titleFade;
//   late Animation<Offset> _titleSlide;
//   late Animation<double> _quoteFade;
//   late Animation<Offset> _quoteSlide;
//   late Animation<double> _ctaFade;
//   late Animation<Offset> _ctaSlide;
//   late Animation<double> _floatingAnimation;
//   late Animation<double> _particleAnimation;
//   late Animation<double> _glowAnimation;

//   String _displayedQuote = '';
//   final String _fullQuote =
//       'Crafting digital experiences with passion & precision.';
//   int _currentIndex = 0;
//   bool _showCursor = true;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       _startAnimations();
//     });
//   }

//   void _setupAnimations() {
//     // Optimized animation controllers with reduced complexity
//     _mainController = AnimationController(
//       duration: const Duration(milliseconds: 2000), // Reduced duration
//       vsync: this,
//     );

//     _typewriterController = AnimationController(
//       duration: Duration(milliseconds: _fullQuote.length * 40), // Faster typing
//       vsync: this,
//     );

//     _floatingController = AnimationController(
//       duration: const Duration(milliseconds: 4000), // Slower, smoother float
//       vsync: this,
//     );

//     _particleController = AnimationController(
//       duration: const Duration(milliseconds: 6000),
//       vsync: this,
//     );

//     _glowController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     );

//     // Smooth entrance animations with easeOutCubic
//     _greetingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
//       ),
//     );

//     _greetingSlide =
//         Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.0, 0.4, curve: Curves.easeOutCubic),
//           ),
//         );

//     _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
//       ),
//     );

//     _nameSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.2, 0.6, curve: Curves.easeOutCubic),
//           ),
//         );

//     _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
//       ),
//     );

//     _titleSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
//           ),
//         );

//     _quoteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
//       ),
//     );

//     _quoteSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.6, 1.0, curve: Curves.easeOutCubic),
//           ),
//         );

//     _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
//       ),
//     );

//     _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
//           ),
//         );

//     // Smooth floating animation
//     _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
//     );

//     _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _particleController, curve: Curves.linear),
//     );

//     _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
//       CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
//     );

//     // Optimized typewriter effect
//     _typewriterController.addListener(_updateTypewriter);
//   }

//   void _updateTypewriter() {
//     final progress = _typewriterController.value;
//     final targetIndex = (progress * _fullQuote.length).floor();

//     if (targetIndex != _currentIndex && targetIndex <= _fullQuote.length) {
//       setState(() {
//         _currentIndex = targetIndex;
//         _displayedQuote = _fullQuote.substring(0, _currentIndex);
//       });
//     }

//     // Cursor blinking logic
//     if (_typewriterController.isCompleted) {
//       Future.delayed(const Duration(milliseconds: 500), () {
//         if (mounted) {
//           setState(() {
//             _showCursor = !_showCursor;
//           });
//         }
//       });
//     }
//   }

//   void _startAnimations() {
//     _mainController.forward();

//     // Staggered animation start
//     Future.delayed(const Duration(milliseconds: 1200), () {
//       if (mounted) {
//         _typewriterController.forward();
//       }
//     });

//     Future.delayed(const Duration(milliseconds: 800), () {
//       if (mounted) {
//         _floatingController.repeat(reverse: true);
//         _particleController.repeat();
//         _glowController.repeat(reverse: true);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _typewriterController.removeListener(_updateTypewriter);
//     _mainController.dispose();
//     _typewriterController.dispose();
//     _floatingController.dispose();
//     _particleController.dispose();
//     _glowController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Container(
//       width: double.infinity,
//       height: screenSize.height,
//       decoration: _buildBackgroundGradient(),
//       child: Stack(
//         children: [
//           // Animated background elements
//           _buildAnimatedBackground(screenSize, isMobile),

//           // Main content - Properly centered
//           Center(
//             child: Container(
//               constraints: BoxConstraints(
//                 maxWidth: isMobile ? screenSize.width * 0.9 : 800,
//               ),
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile ? 20 : 40,
//                 vertical: 20,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   _buildGreeting(isMobile, isTablet),
//                   const SizedBox(height: 12),
//                   _buildName(isMobile, isTablet),
//                   const SizedBox(height: 8),
//                   _buildTitle(isMobile, isTablet),
//                   const SizedBox(height: 32),
//                   _buildQuote(isMobile, isTablet, screenSize),
//                   const SizedBox(height: 48),
//                   _buildCTAButton(isMobile),
//                 ],
//               ),
//             ),
//           ),

//           // Floating particles
//           _buildFloatingParticles(screenSize, isMobile),
//         ],
//       ),
//     );
//   }

//   BoxDecoration _buildBackgroundGradient() {
//     return BoxDecoration(
//       gradient: LinearGradient(
//         begin: Alignment.topLeft,
//         end: Alignment.bottomRight,
//         stops: const [0.0, 0.4, 0.8, 1.0],
//         colors: [
//           Colors.white,
//           const Color(0xFFF8F8F8),
//           const Color(0xFFE8E8E8),
//           const Color(0xFFD8D8D8),
//         ],
//       ),
//     );
//   }

//   Widget _buildAnimatedBackground(Size screenSize, bool isMobile) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([_floatingAnimation, _glowAnimation]),
//       builder: (context, child) {
//         return Stack(
//           children: [
//             // Main glow effect
//             Positioned(
//               top: screenSize.height * 0.15,
//               right: screenSize.width * 0.1,
//               child: Transform.translate(
//                 offset: Offset(
//                   15 * math.sin(_floatingAnimation.value * 2 * math.pi),
//                   10 * math.cos(_floatingAnimation.value * 2 * math.pi),
//                 ),
//                 child: Container(
//                   width: isMobile ? 180 : 280,
//                   height: isMobile ? 180 : 280,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         Colors.black.withOpacity(0.05 * _glowAnimation.value),
//                         Colors.grey.withOpacity(0.03 * _glowAnimation.value),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),

//             // Secondary glow
//             Positioned(
//               bottom: screenSize.height * 0.15,
//               left: screenSize.width * 0.1,
//               child: Transform.translate(
//                 offset: Offset(
//                   -12 * math.sin(_floatingAnimation.value * 2 * math.pi),
//                   -8 * math.cos(_floatingAnimation.value * 2 * math.pi),
//                 ),
//                 child: Container(
//                   width: isMobile ? 140 : 220,
//                   height: isMobile ? 140 : 220,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30),
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.black.withOpacity(0.08 * _glowAnimation.value),
//                         Colors.grey.shade600.withOpacity(
//                           0.04 * _glowAnimation.value,
//                         ),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildGreeting(bool isMobile, bool isTablet) {
//     return SlideTransition(
//       position: _greetingSlide,
//       child: FadeTransition(
//         opacity: _greetingFade,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           decoration: BoxDecoration(
//             color: Colors.white.withOpacity(0.8),
//             borderRadius: BorderRadius.circular(25),
//             border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 10,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 8,
//                 height: 8,
//                 decoration: const BoxDecoration(
//                   color: Colors.green,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Text(
//                 '👋 Hello, I\'m',
//                 style: TextStyle(
//                   fontSize: isMobile ? 14 : 16,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.darkGray,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildName(bool isMobile, bool isTablet) {
//     return SlideTransition(
//       position: _nameSlide,
//       child: FadeTransition(
//         opacity: _nameFade,
//         child: ShaderMask(
//           shaderCallback: (bounds) => LinearGradient(
//             colors: [Colors.black, Colors.grey.shade800],
//           ).createShader(bounds),
//           child: Text(
//             'Muhammad',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: isMobile
//                   ? 42
//                   : isTablet
//                   ? 52
//                   : 64,
//               fontWeight: FontWeight.w800,
//               color: Colors.white,
//               fontFamily: AppFonts.primary,
//               letterSpacing: -2,
//               height: 1.0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTitle(bool isMobile, bool isTablet) {
//     return SlideTransition(
//       position: _titleSlide,
//       child: FadeTransition(
//         opacity: _titleFade,
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Colors.grey.shade100, Colors.grey.shade200],
//             ),
//             borderRadius: BorderRadius.circular(30),
//             border: Border.all(color: Colors.grey.shade300, width: 1),
//           ),
//           child: Text(
//             'Full Stack Developer',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: isMobile
//                   ? 18
//                   : isTablet
//                   ? 22
//                   : 26,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade700,
//               fontFamily: AppFonts.primary,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildQuote(bool isMobile, bool isTablet, Size screenSize) {
//     return SlideTransition(
//       position: _quoteSlide,
//       child: FadeTransition(
//         opacity: _quoteFade,
//         child: Container(
//           constraints: BoxConstraints(
//             maxWidth: isMobile ? screenSize.width * 0.9 : 600,
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Flexible(
//                 child: Text(
//                   _displayedQuote,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: isMobile
//                         ? 16
//                         : isTablet
//                         ? 18
//                         : 20,
//                     fontWeight: FontWeight.w400,
//                     color: AppColors.darkGray.withOpacity(0.9),
//                     fontFamily: AppFonts.primary,
//                     letterSpacing: 0.3,
//                     height: 1.6,
//                   ),
//                 ),
//               ),
//               if (_showCursor || _typewriterController.isAnimating)
//                 AnimatedOpacity(
//                   opacity: _showCursor ? 1.0 : 0.0,
//                   duration: const Duration(milliseconds: 500),
//                   child: Container(
//                     width: 2,
//                     height: isMobile ? 20 : 24,
//                     color: Colors.black,
//                     margin: const EdgeInsets.only(left: 2),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildCTAButton(bool isMobile) {
//     return SlideTransition(
//       position: _ctaSlide,
//       child: FadeTransition(
//         opacity: _ctaFade,
//         child: AnimatedBuilder(
//           animation: _floatingAnimation,
//           builder: (context, child) {
//             return Transform.translate(
//               offset: Offset(
//                 0,
//                 4 * math.sin(_floatingAnimation.value * 2 * math.pi),
//               ),
//               child: MouseRegion(
//                 cursor: SystemMouseCursors.click,
//                 child: GestureDetector(
//                   onTap: () {
//                     // Add your navigation logic here
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isMobile ? 28 : 36,
//                       vertical: isMobile ? 14 : 18,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [Colors.black, Colors.grey.shade800],
//                       ),
//                       borderRadius: BorderRadius.circular(35),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.2),
//                           blurRadius: 15,
//                           offset: const Offset(0, 6),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'Let\'s Connect',
//                           style: TextStyle(
//                             fontSize: isMobile ? 16 : 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.white,
//                             fontFamily: AppFonts.primary,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             Icons.arrow_forward_rounded,
//                             color: Colors.white,
//                             size: isMobile ? 16 : 18,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildFloatingParticles(Size screenSize, bool isMobile) {
//     return AnimatedBuilder(
//       animation: _particleAnimation,
//       builder: (context, child) {
//         return Stack(
//           children: List.generate(5, (index) {
//             // Create smooth linear movement from left to right
//             final progress = (_particleAnimation.value + (index * 0.2)) % 1.0;

//             // Start positions (left side of screen)
//             final startX = -20.0;
//             final startY = screenSize.height * (0.2 + index * 0.15);

//             // End positions (right side of screen)
//             final endX = screenSize.width + 20.0;
//             final endY = screenSize.height * (0.3 + index * 0.12);

//             // Current position using smooth interpolation
//             final currentX = startX + (endX - startX) * progress;
//             final currentY = startY + (endY - startY) * progress;

//             // Add subtle vertical wave motion
//             final waveY = currentY + (15 * math.sin(progress * 4 * math.pi));

//             return Positioned(
//               left: currentX,
//               top: waveY,
//               child: Opacity(
//                 opacity: 0.6,
//                 child: Container(
//                   width: isMobile ? 3 : 4,
//                   height: isMobile ? 3 : 4,
//                   decoration: BoxDecoration(
//                     gradient: RadialGradient(
//                       colors: [
//                         Colors.black.withOpacity(0.8),
//                         Colors.black.withOpacity(0.4),
//                         Colors.transparent,
//                       ],
//                     ),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             );
//           }),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';
// import 'dart:math' as math;

// class HeroSection extends StatefulWidget {
//   const HeroSection({Key? key}) : super(key: key);

//   @override
//   State<HeroSection> createState() => _HeroSectionState();
// }

// class _HeroSectionState extends State<HeroSection>
//     with TickerProviderStateMixin {
//   late AnimationController _mainController;
//   late AnimationController _typewriterController;
//   late AnimationController _floatingController;

//   late Animation<double> _greetingFade;
//   late Animation<Offset> _greetingSlide;
//   late Animation<double> _nameFade;
//   late Animation<Offset> _nameSlide;
//   late Animation<double> _titleFade;
//   late Animation<Offset> _titleSlide;
//   late Animation<double> _quoteFade;
//   late Animation<Offset> _quoteSlide;
//   late Animation<double> _ctaFade;
//   late Animation<Offset> _ctaSlide;
//   late Animation<double> _floatingAnimation;

//   String _displayedQuote = '';
//   final String _fullQuote = 'Building digital experiences that matter.';
//   int _currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       _startAnimations();
//     });
//   }

//   void _setupAnimations() {
//     // Main animation controller for entrance animations
//     _mainController = AnimationController(
//       duration: const Duration(milliseconds: 2500),
//       vsync: this,
//     );

//     // Typewriter effect controller
//     _typewriterController = AnimationController(
//       duration: Duration(milliseconds: _fullQuote.length * 50),
//       vsync: this,
//     );

//     // Floating animation controller
//     _floatingController = AnimationController(
//       duration: const Duration(milliseconds: 3000),
//       vsync: this,
//     );

//     // Greeting animations
//     _greetingFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
//       ),
//     );

//     _greetingSlide =
//         Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
//           ),
//         );

//     // Name animations
//     _nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
//       ),
//     );

//     _nameSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.2, 0.5, curve: Curves.easeOutCubic),
//           ),
//         );

//     // Title animations
//     _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
//       ),
//     );

//     _titleSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.4, 0.7, curve: Curves.easeOutCubic),
//           ),
//         );

//     // Quote animations
//     _quoteFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
//       ),
//     );

//     _quoteSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
//           ),
//         );

//     // CTA animations
//     _ctaFade = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _mainController,
//         curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _ctaSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
//         .animate(
//           CurvedAnimation(
//             parent: _mainController,
//             curve: const Interval(0.8, 1.0, curve: Curves.easeOutCubic),
//           ),
//         );

//     // Floating animation
//     _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
//     );

//     // Typewriter animation listener
//     _typewriterController.addListener(() {
//       final progress = _typewriterController.value;
//       final targetIndex = (progress * _fullQuote.length).floor();

//       if (targetIndex != _currentIndex && targetIndex <= _fullQuote.length) {
//         setState(() {
//           _currentIndex = targetIndex;
//           _displayedQuote = _fullQuote.substring(0, _currentIndex);
//         });
//       }
//     });
//   }

//   void _startAnimations() {
//     _mainController.forward();

//     // Start typewriter effect after main animations
//     Future.delayed(const Duration(milliseconds: 1800), () {
//       if (mounted) {
//         _typewriterController.forward();
//       }
//     });

//     // Start floating animation
//     Future.delayed(const Duration(milliseconds: 2000), () {
//       if (mounted) {
//         _floatingController.repeat(reverse: true);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _mainController.dispose();
//     _typewriterController.dispose();
//     _floatingController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Container(
//       width: double.infinity,
//       height: screenSize.height,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             AppColors.pureWhite,
//             AppColors.pureWhite.withOpacity(0.95),
//             AppColors.lightGray.withOpacity(0.1),
//           ],
//         ),
//       ),
//       child: Stack(
//         children: [
//           // Background decorative elements
//           _buildBackgroundDecorations(screenSize, isMobile),

//           // Main content
//           Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isMobile
//                     ? AppDimensions.paddingMedium
//                     : AppDimensions.paddingLarge,
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Greeting
//                   SlideTransition(
//                     position: _greetingSlide,
//                     child: FadeTransition(
//                       opacity: _greetingFade,
//                       child: Text(
//                         'Hello, I\'m',
//                         style: TextStyle(
//                           fontSize: isMobile
//                               ? 18
//                               : isTablet
//                               ? 20
//                               : 24,
//                           fontWeight: AppFonts.medium,
//                           color: AppColors.darkGray,
//                           fontFamily: AppFonts.primary,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 8),

//                   // Name
//                   SlideTransition(
//                     position: _nameSlide,
//                     child: FadeTransition(
//                       opacity: _nameFade,
//                       child: Text(
//                         'Muhammad',
//                         style: TextStyle(
//                           fontSize: isMobile
//                               ? 48
//                               : isTablet
//                               ? 56
//                               : 72,
//                           fontWeight: AppFonts.bold,
//                           color: AppColors.primaryBlack,
//                           fontFamily: AppFonts.primary,
//                           letterSpacing: -1,
//                           height: 1.1,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 4),

//                   // Title/Role
//                   SlideTransition(
//                     position: _titleSlide,
//                     child: FadeTransition(
//                       opacity: _titleFade,
//                       child: Text(
//                         'Full Stack Developer',
//                         style: TextStyle(
//                           fontSize: isMobile
//                               ? 24
//                               : isTablet
//                               ? 28
//                               : 36,
//                           fontWeight: AppFonts.medium,
//                           color: AppColors.darkGray.withOpacity(0.8),
//                           fontFamily: AppFonts.primary,
//                           letterSpacing: 0.5,
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 24),

//                   // Quote with typewriter effect
//                   SlideTransition(
//                     position: _quoteSlide,
//                     child: FadeTransition(
//                       opacity: _quoteFade,
//                       child: Container(
//                         constraints: BoxConstraints(
//                           maxWidth: isMobile ? screenSize.width * 0.9 : 600,
//                         ),
//                         child: Row(
//                           children: [
//                             Text(
//                               _displayedQuote,
//                               style: TextStyle(
//                                 fontSize: isMobile
//                                     ? 16
//                                     : isTablet
//                                     ? 18
//                                     : 20,
//                                 fontWeight: AppFonts.regular,
//                                 color: AppColors.darkGray.withOpacity(0.9),
//                                 fontFamily: AppFonts.primary,
//                                 letterSpacing: 0.3,
//                                 height: 1.5,
//                               ),
//                             ),
//                             // Blinking cursor
//                             AnimatedBuilder(
//                               animation: _typewriterController,
//                               builder: (context, child) {
//                                 return AnimatedOpacity(
//                                   opacity: _typewriterController.isAnimating
//                                       ? (DateTime.now().millisecondsSinceEpoch ~/
//                                                         500) %
//                                                     2 ==
//                                                 0
//                                             ? 1.0
//                                             : 0.0
//                                       : 0.0,
//                                   duration: const Duration(milliseconds: 100),
//                                   child: Container(
//                                     width: 2,
//                                     height: isMobile ? 20 : 24,
//                                     color: AppColors.primaryBlack,
//                                     margin: const EdgeInsets.only(left: 2),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // CTA Button
//                   SlideTransition(
//                     position: _ctaSlide,
//                     child: FadeTransition(
//                       opacity: _ctaFade,
//                       child: AnimatedBuilder(
//                         animation: _floatingAnimation,
//                         builder: (context, child) {
//                           return Transform.translate(
//                             offset: Offset(
//                               0,
//                               3 *
//                                   Math.sin(
//                                     _floatingAnimation.value * 2 * Math.pi,
//                                   ),
//                             ),
//                             child: MouseRegion(
//                               cursor: SystemMouseCursors.click,
//                               child: AnimatedContainer(
//                                 duration: const Duration(milliseconds: 200),
//                                 child: InkWell(
//                                   onTap: () {
//                                     // Add scroll to next section or contact logic
//                                   },
//                                   borderRadius: BorderRadius.circular(30),
//                                   child: Container(
//                                     padding: EdgeInsets.symmetric(
//                                       horizontal: isMobile ? 24 : 32,
//                                       vertical: isMobile ? 12 : 16,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color: AppColors.primaryBlack,
//                                       borderRadius: BorderRadius.circular(30),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: AppColors.primaryBlack
//                                               .withOpacity(0.2),
//                                           blurRadius: 12,
//                                           offset: const Offset(0, 4),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Row(
//                                       mainAxisSize: MainAxisSize.min,
//                                       children: [
//                                         Text(
//                                           'Let\'s Connect',
//                                           style: TextStyle(
//                                             fontSize: isMobile ? 14 : 16,
//                                             fontWeight: AppFonts.medium,
//                                             color: AppColors.pureWhite,
//                                             fontFamily: AppFonts.primary,
//                                             letterSpacing: 0.5,
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Icon(
//                                           Icons.arrow_forward_rounded,
//                                           color: AppColors.pureWhite,
//                                           size: isMobile ? 16 : 18,
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBackgroundDecorations(Size screenSize, bool isMobile) {
//     return Stack(
//       children: [
//         // Top-right decorative circle
//         Positioned(
//           top: -50,
//           right: -50,
//           child: AnimatedBuilder(
//             animation: _floatingAnimation,
//             builder: (context, child) {
//               return Transform.translate(
//                 offset: Offset(
//                   10 * Math.sin(_floatingAnimation.value * 2 * Math.pi),
//                   5 * Math.cos(_floatingAnimation.value * 2 * Math.pi),
//                 ),
//                 child: Container(
//                   width: isMobile ? 150 : 200,
//                   height: isMobile ? 150 : 200,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: RadialGradient(
//                       colors: [
//                         AppColors.lightGray.withOpacity(0.1),
//                         AppColors.lightGray.withOpacity(0.05),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),

//         // Bottom-left decorative element
//         Positioned(
//           bottom: -30,
//           left: -30,
//           child: AnimatedBuilder(
//             animation: _floatingAnimation,
//             builder: (context, child) {
//               return Transform.translate(
//                 offset: Offset(
//                   -8 * Math.sin(_floatingAnimation.value * 2 * Math.pi),
//                   -3 * Math.cos(_floatingAnimation.value * 2 * Math.pi),
//                 ),
//                 child: Container(
//                   width: isMobile ? 100 : 150,
//                   height: isMobile ? 100 : 150,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(20),
//                     gradient: LinearGradient(
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         AppColors.darkGray.withOpacity(0.05),
//                         Colors.transparent,
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }

// // Math class for sine and cosine calculations
// class Math {
//   static double sin(double x) => math.sin(x);
//   static double cos(double x) => math.cos(x);
//   static const double pi = math.pi;
// }

// import 'package:flutter/material.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';

// class HeroSection extends StatefulWidget {
//   const HeroSection({Key? key}) : super(key: key);

//   @override
//   State<HeroSection> createState() => _HeroSectionState();
// }

// class _HeroSectionState extends State<HeroSection>
//     with TickerProviderStateMixin {
//   late AnimationController _animationController;
//   late List<Animation<Offset>> _slideAnimations;
//   late List<Animation<double>> _fadeAnimations;

//   final List<String> _heroTexts = ["I Don't", "Just Think.", "I DO."];

//   @override
//   void initState() {
//     super.initState();
//     _setupAnimations();
//     _startAnimations();
//   }

//   void _setupAnimations() {
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _slideAnimations = List.generate(3, (index) {
//       return Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
//         CurvedAnimation(
//           parent: _animationController,
//           curve: Interval(
//             index * 0.2,
//             0.6 + (index * 0.2),
//             curve: Curves.easeOutCubic,
//           ),
//         ),
//       );
//     });

//     _fadeAnimations = List.generate(3, (index) {
//       return Tween<double>(begin: 0.0, end: 1.0).animate(
//         CurvedAnimation(
//           parent: _animationController,
//           curve: Interval(
//             index * 0.2,
//             0.6 + (index * 0.2),
//             curve: Curves.easeOut,
//           ),
//         ),
//       );
//     });
//   }

//   void _startAnimations() {
//     Future.delayed(const Duration(milliseconds: 500), () {
//       _animationController.forward();
//     });
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Container(
//       width: double.infinity,
//       height: screenSize.height,
//       color: AppColors.pureWhite,
//       child: Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(
//             horizontal: isMobile
//                 ? AppDimensions.paddingMedium
//                 : AppDimensions.paddingLarge,
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: _heroTexts.asMap().entries.map((entry) {
//               int index = entry.key;
//               String text = entry.value;

//               return SlideTransition(
//                 position: _slideAnimations[index],
//                 child: FadeTransition(
//                   opacity: _fadeAnimations[index],
//                   child: Padding(
//                     padding: const EdgeInsets.only(bottom: 8),
//                     child: Text(
//                       text,
//                       style: TextStyle(
//                         fontSize: isMobile
//                             ? 48
//                             : isTablet
//                             ? 56
//                             : 72,
//                         fontWeight: index == 2
//                             ? AppFonts.bold
//                             : AppFonts.medium,
//                         color: index == 2
//                             ? AppColors.primaryBlack
//                             : AppColors.darkGray,
//                         fontFamily: AppFonts.primary,
//                         letterSpacing: 4,
//                         height: 1.1,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ),
//     );
//   }
// }
