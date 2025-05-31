import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';

class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
  final ScrollController scrollController;
  // Add section keys for dynamic position detection
  final GlobalKey? heroKey;
  final GlobalKey? aboutKey;
  final GlobalKey? portfolioKey;
  final GlobalKey? experienceKey;
  final GlobalKey? skillsKey;
  final GlobalKey? contactKey;

  const CustomNavBar({
    Key? key,
    required this.scrollController,
    this.heroKey,
    this.aboutKey,
    this.portfolioKey,
    this.experienceKey,
    this.skillsKey,
    this.contactKey,
  }) : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();

  @override
  Size get preferredSize => const Size.fromHeight(AppDimensions.navHeight);
}

class _CustomNavBarState extends State<CustomNavBar>
    with TickerProviderStateMixin {
  bool _isScrolled = false;
  String _activeSection = 'Hero';
  bool _isMobileMenuOpen = false;
  late AnimationController _drawerController;
  late Animation<Offset> _drawerAnimation;

  final List<String> _navItems = [
    'About',
    'Portfolio',
    'Experience',
    'Skills',
    'Contact',
  ];

  // Map sections to their keys for dynamic position detection
  Map<String, GlobalKey?> get _sectionKeys => {
    'Hero': widget.heroKey,
    'About': widget.aboutKey,
    'Portfolio': widget.portfolioKey,
    'Experience': widget.experienceKey,
    'Skills': widget.skillsKey,
    'Contact': widget.contactKey,
  };

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);

    _drawerController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _drawerAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut),
        );
  }

  void _onScroll() {
    final offset = widget.scrollController.offset;

    // Update scroll state for navbar background
    if (offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }

    // Determine active section based on viewport intersection
    String newActiveSection = _determineActiveSection();

    if (newActiveSection != _activeSection) {
      setState(() {
        _activeSection = newActiveSection;
      });
    }
  }

  String _determineActiveSection() {
    if (!mounted) return _activeSection;

    try {
      final currentScrollOffset = widget.scrollController.offset;
      final screenHeight = MediaQuery.of(context).size.height;
      final navHeight = AppDimensions.navHeight;

      // Define viewport bounds considering navbar height
      final viewportTop = currentScrollOffset + navHeight;
      final viewportCenter =
          currentScrollOffset + (screenHeight * 0.3); // Top 30% of screen

      // Special case: if we're near the very top, always show Hero
      if (currentScrollOffset < 100) {
        return 'Hero';
      }

      // Get all section positions sorted by their position
      List<MapEntry<String, double>> sectionPositions = [];

      for (final entry in _sectionKeys.entries) {
        final sectionName = entry.key;
        final sectionKey = entry.value;

        if (sectionKey?.currentContext != null) {
          try {
            final RenderBox? renderBox =
                sectionKey!.currentContext!.findRenderObject() as RenderBox?;

            if (renderBox != null && renderBox.hasSize) {
              final sectionPosition = renderBox.localToGlobal(Offset.zero);
              final adjustedPosition = sectionPosition.dy + currentScrollOffset;
              sectionPositions.add(MapEntry(sectionName, adjustedPosition));
            }
          } catch (e) {
            continue;
          }
        }
      }

      if (sectionPositions.isEmpty) return _activeSection;

      // Sort sections by position
      sectionPositions.sort((a, b) => a.value.compareTo(b.value));

      // Find the active section based on viewport center
      String activeSection = sectionPositions.first.key;

      for (int i = 0; i < sectionPositions.length; i++) {
        final currentSection = sectionPositions[i];
        final nextSection = i + 1 < sectionPositions.length
            ? sectionPositions[i + 1]
            : null;

        // Check if viewport center is between current and next section
        if (viewportCenter >= currentSection.value) {
          if (nextSection == null || viewportCenter < nextSection.value) {
            activeSection = currentSection.key;
            break;
          }
        }
      }

      // Special handling for the last section
      final lastSection = sectionPositions.last;
      final maxScrollExtent = widget.scrollController.position.maxScrollExtent;

      // If we're near the bottom, activate the last section
      if (currentScrollOffset > maxScrollExtent - 200) {
        activeSection = lastSection.key;
      }

      return activeSection;
    } catch (e) {
      print('Error determining active section: $e');
      return _activeSection;
    }
  }

  void _toggleMobileMenu() {
    setState(() {
      _isMobileMenuOpen = !_isMobileMenuOpen;
    });

    if (_isMobileMenuOpen) {
      _drawerController.forward();
    } else {
      _drawerController.reverse();
    }
  }

  void _scrollToSection(String section) {
    setState(() {
      _isMobileMenuOpen = false;
    });

    _drawerController.reverse();

    // Immediately update active section for visual feedback
    setState(() {
      _activeSection = section;
    });

    // Special case for Hero section
    if (section == 'Hero') {
      widget.scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    // Use GlobalKey for accurate positioning
    final sectionKey = _sectionKeys[section];
    if (sectionKey?.currentContext != null) {
      try {
        final RenderBox renderBox =
            sectionKey!.currentContext!.findRenderObject() as RenderBox;

        if (renderBox.hasSize) {
          final position = renderBox.localToGlobal(Offset.zero);

          // Calculate target position considering navbar height
          final targetPosition =
              position.dy +
              widget.scrollController.offset -
              AppDimensions.navHeight -
              20; // Small padding

          // Ensure we don't scroll beyond bounds
          final clampedPosition = targetPosition.clamp(
            0.0,
            widget.scrollController.position.maxScrollExtent,
          );

          widget.scrollController.animateTo(
            clampedPosition,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
          );

          return;
        }
      } catch (e) {
        print('Error scrolling to section $section: $e');
      }
    }

    print(
      'Warning: Could not find section $section. Make sure GlobalKey is properly assigned.',
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

    return Stack(
      children: [
        // Main Navbar
        Container(
          height: AppDimensions.navHeight,
          decoration: BoxDecoration(
            color: _isScrolled
                ? AppColors.primaryBlack.withOpacity(0.95)
                : Colors.transparent,
          ),
          child: _isScrolled
              ? ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: _buildNavContent(isMobile),
                  ),
                )
              : _buildNavContent(isMobile),
        ),

        // Mobile Drawer Overlay
        if (isMobile && _isMobileMenuOpen)
          GestureDetector(
            onTap: _toggleMobileMenu,
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(0.5),
            ),
          ),

        // Mobile Drawer
        if (isMobile)
          Positioned(
            top: 0,
            right: 0,
            bottom: 0,
            child: SlideTransition(
              position: _drawerAnimation,
              child: Container(
                width: screenSize.width * 0.75,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlack,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(-5, 0),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drawer Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.darkGray.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Menu',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: AppFonts.bold,
                                color: AppColors.pureWhite,
                                fontFamily: AppFonts.primary,
                              ),
                            ),
                            GestureDetector(
                              onTap: _toggleMobileMenu,
                              child: Icon(
                                Icons.close,
                                color: AppColors.pureWhite,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Menu Items
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(top: 20),
                          children: [
                            _buildDrawerItem('Hero'),
                            ..._navItems
                                .map((item) => _buildDrawerItem(item))
                                .toList(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDrawerItem(String item) {
    bool isActive = _activeSection == item;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _scrollToSection(item),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.pureWhite.withOpacity(0.1)
                : Colors.transparent,
            border: Border(
              bottom: BorderSide(
                color: AppColors.darkGray.withOpacity(0.2),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Active indicator line
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.pureWhite : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isActive ? AppFonts.semiBold : AppFonts.medium,
                  color: isActive ? AppColors.pureWhite : AppColors.lightGray,
                  fontFamily: AppFonts.primary,
                ),
                child: Text(item),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavContent(bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppDimensions.paddingMedium
            : AppDimensions.paddingLarge,
        vertical: AppDimensions.paddingSmall,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/Name
          GestureDetector(
            onTap: () => _scrollToSection('Hero'),
            child: TweenAnimationBuilder(
              duration: const Duration(milliseconds: 800),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Text(
                      'M',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: AppFonts.bold,
                        color: _isScrolled
                            ? AppColors.pureWhite
                            : AppColors.primaryBlack,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Navigation Items or Hamburger Menu
          if (isMobile) _buildMobileMenu() else _buildDesktopNavigation(),
        ],
      ),
    );
  }

  Widget _buildDesktopNavigation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;

        // Calculate responsive spacing
        double getHorizontalSpacing() {
          if (screenWidth < 1024) return 16.0;
          if (screenWidth < 1440) return 24.0;
          return 32.0;
        }

        double getFontSize() {
          if (screenWidth < 1024) return 13.0;
          if (screenWidth < 1440) return 14.0;
          return 15.0;
        }

        final horizontalSpacing = getHorizontalSpacing();
        final fontSize = getFontSize();

        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: _navItems.asMap().entries.map((entry) {
            int index = entry.key;
            String item = entry.value;
            bool isActive = _activeSection == item;

            return TweenAnimationBuilder(
              duration: Duration(milliseconds: 800 + (index * 100)),
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalSpacing / 2,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: InkWell(
                          onTap: () => _scrollToSection(item),
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 300),
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: isActive
                                        ? AppFonts.semiBold
                                        : AppFonts.medium,
                                    color: _isScrolled
                                        ? (isActive
                                              ? AppColors.pureWhite
                                              : AppColors.pureWhite.withOpacity(
                                                  0.7,
                                                ))
                                        : (isActive
                                              ? AppColors.primaryBlack
                                              : AppColors.darkGray),
                                    fontFamily: AppFonts.primary,
                                  ),
                                  child: Text(
                                    item,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Active underline indicator - FIXED
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  height: 2,
                                  width: isActive
                                      ? 40
                                      : 0, // Fixed width instead of text-based calculation
                                  decoration: BoxDecoration(
                                    color: _isScrolled
                                        ? AppColors.pureWhite
                                        : AppColors.primaryBlack,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildMobileMenu() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _toggleMobileMenu,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 40,
          height: 40,
          padding: const EdgeInsets.all(5),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.identity()
                  ..translate(0.0, _isMobileMenuOpen ? 14.0 : 4.0)
                  ..rotateZ(_isMobileMenuOpen ? 0.785398 : 0),
                child: Container(
                  height: 2,
                  width: 30,
                  decoration: BoxDecoration(
                    color: _isScrolled
                        ? AppColors.pureWhite
                        : AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isMobileMenuOpen ? 0 : 1,
                child: Container(
                  margin: const EdgeInsets.only(top: 14),
                  height: 2,
                  width: 30,
                  decoration: BoxDecoration(
                    color: _isScrolled
                        ? AppColors.pureWhite
                        : AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                transform: Matrix4.identity()
                  ..translate(0.0, _isMobileMenuOpen ? 14.0 : 24.0)
                  ..rotateZ(_isMobileMenuOpen ? -0.785398 : 0),
                child: Container(
                  height: 2,
                  width: 30,
                  decoration: BoxDecoration(
                    color: _isScrolled
                        ? AppColors.pureWhite
                        : AppColors.primaryBlack,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'dart:ui';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';

// class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
//   final ScrollController scrollController;
//   // Add section keys for dynamic position detection
//   final GlobalKey? heroKey;
//   final GlobalKey? aboutKey;
//   final GlobalKey? portfolioKey;
//   final GlobalKey? experienceKey;
//   final GlobalKey? skillsKey;
//   final GlobalKey? contactKey;

//   const CustomNavBar({
//     Key? key,
//     required this.scrollController,
//     this.heroKey,
//     this.aboutKey,
//     this.portfolioKey,
//     this.experienceKey,
//     this.skillsKey,
//     this.contactKey,
//   }) : super(key: key);

//   @override
//   State<CustomNavBar> createState() => _CustomNavBarState();

//   @override
//   Size get preferredSize => const Size.fromHeight(AppDimensions.navHeight);
// }

// class _CustomNavBarState extends State<CustomNavBar>
//     with TickerProviderStateMixin {
//   bool _isScrolled = false;
//   String _activeSection = 'Hero';
//   bool _isMobileMenuOpen = false;
//   late AnimationController _drawerController;
//   late Animation<Offset> _drawerAnimation;

//   final List<String> _navItems = [
//     'About',
//     'Portfolio',
//     'Experience',
//     'Skills',
//     'Contact',
//   ];

//   // Map sections to their keys for dynamic position detection
//   Map<String, GlobalKey?> get _sectionKeys => {
//     'Hero': widget.heroKey,
//     'About': widget.aboutKey,
//     'Portfolio': widget.portfolioKey,
//     'Experience': widget.experienceKey,
//     'Skills': widget.skillsKey,
//     'Contact': widget.contactKey,
//   };

//   @override
//   void initState() {
//     super.initState();
//     widget.scrollController.addListener(_onScroll);

//     _drawerController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _drawerAnimation =
//         Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
//           CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut),
//         );
//   }

//   void _onScroll() {
//     final offset = widget.scrollController.offset;

//     // Update scroll state for navbar background
//     if (offset > 50 && !_isScrolled) {
//       setState(() => _isScrolled = true);
//     } else if (offset <= 50 && _isScrolled) {
//       setState(() => _isScrolled = false);
//     }

//     // Determine active section based on viewport intersection
//     String newActiveSection = _determineActiveSection();

//     if (newActiveSection != _activeSection) {
//       setState(() {
//         _activeSection = newActiveSection;
//       });
//     }
//   }

//   String _determineActiveSection() {
//     if (!mounted) return _activeSection;

//     try {
//       final currentScrollOffset = widget.scrollController.offset;
//       final screenHeight = MediaQuery.of(context).size.height;

//       // Define the viewport bounds
//       final viewportTop = currentScrollOffset;
//       final viewportBottom = currentScrollOffset + screenHeight;
//       final viewportCenter = currentScrollOffset + (screenHeight / 2);

//       // Special case: if we're at the very top, always show Hero
//       if (currentScrollOffset < 100) {
//         return 'Hero';
//       }

//       // Get all section positions and calculate which one is most visible
//       Map<String, double> sectionVisibility = {};
//       Map<String, double> sectionPositions = {};

//       for (final entry in _sectionKeys.entries) {
//         final sectionName = entry.key;
//         final sectionKey = entry.value;

//         if (sectionKey?.currentContext != null) {
//           try {
//             final RenderBox? renderBox =
//                 sectionKey!.currentContext!.findRenderObject() as RenderBox?;

//             if (renderBox != null && renderBox.hasSize) {
//               // Get section bounds
//               final sectionPosition = renderBox.localToGlobal(Offset.zero);
//               final sectionTop = sectionPosition.dy;
//               final sectionBottom = sectionTop + renderBox.size.height;

//               sectionPositions[sectionName] = sectionTop;

//               // Calculate intersection with viewport
//               final intersectionTop = sectionTop > viewportTop
//                   ? sectionTop
//                   : viewportTop;
//               final intersectionBottom = sectionBottom < viewportBottom
//                   ? sectionBottom
//                   : viewportBottom;

//               if (intersectionBottom > intersectionTop) {
//                 // Section is visible - calculate visibility percentage
//                 final visibleHeight = intersectionBottom - intersectionTop;
//                 final sectionHeight = renderBox.size.height;
//                 final visibilityPercentage = visibleHeight / sectionHeight;

//                 // Give bonus to sections that contain the viewport center
//                 double centerBonus = 0;
//                 if (sectionTop <= viewportCenter &&
//                     viewportCenter <= sectionBottom) {
//                   centerBonus = 0.5; // 50% bonus for containing viewport center
//                 }

//                 sectionVisibility[sectionName] =
//                     visibilityPercentage + centerBonus;
//               }
//             }
//           } catch (e) {
//             // Skip sections we can't measure
//             continue;
//           }
//         }
//       }

//       // Find the section with highest visibility score
//       if (sectionVisibility.isNotEmpty) {
//         String mostVisibleSection = sectionVisibility.entries
//             .reduce((a, b) => a.value > b.value ? a : b)
//             .key;

//         return mostVisibleSection;
//       }

//       // Fallback: find closest section based on scroll position
//       if (sectionPositions.isNotEmpty) {
//         final sortedSections = sectionPositions.entries.toList()
//           ..sort((a, b) => a.value.compareTo(b.value));

//         String closestSection = 'Hero';
//         for (final section in sortedSections) {
//           if (viewportCenter >= section.value - 200) {
//             // 200px buffer
//             closestSection = section.key;
//           }
//         }
//         return closestSection;
//       }

//       return _activeSection;
//     } catch (e) {
//       print('Error determining active section: $e');
//       return _activeSection;
//     }
//   }

//   void _toggleMobileMenu() {
//     setState(() {
//       _isMobileMenuOpen = !_isMobileMenuOpen;
//     });

//     if (_isMobileMenuOpen) {
//       _drawerController.forward();
//     } else {
//       _drawerController.reverse();
//     }
//   }

//   void _scrollToSection(String section) {
//     setState(() {
//       _isMobileMenuOpen = false;
//     });

//     _drawerController.reverse();

//     // Always try to use GlobalKey for accurate positioning
//     final sectionKey = _sectionKeys[section];
//     if (sectionKey?.currentContext != null) {
//       try {
//         final RenderBox renderBox =
//             sectionKey!.currentContext!.findRenderObject() as RenderBox;

//         if (renderBox.hasSize) {
//           final position = renderBox.localToGlobal(Offset.zero);

//           // Calculate target position considering navbar height and some padding
//           final targetPosition =
//               position.dy +
//               widget.scrollController.offset -
//               AppDimensions.navHeight -
//               20; // 20px padding

//           // Ensure we don't scroll beyond bounds
//           final clampedPosition = targetPosition.clamp(
//             0.0,
//             widget.scrollController.position.maxScrollExtent,
//           );

//           widget.scrollController.animateTo(
//             clampedPosition,
//             duration: const Duration(milliseconds: 800),
//             curve: Curves.easeInOutCubic,
//           );

//           // Update active section immediately for visual feedback
//           setState(() {
//             _activeSection = section;
//           });

//           return;
//         }
//       } catch (e) {
//         print('Error scrolling to section $section: $e');
//       }
//     }

//     // If GlobalKey method fails, scroll to top for Hero or show error for others
//     if (section == 'Hero') {
//       widget.scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.easeInOutCubic,
//       );
//       setState(() {
//         _activeSection = 'Hero';
//       });
//     } else {
//       // Show a message that the section couldn't be found
//       print(
//         'Warning: Could not find section $section. Make sure GlobalKey is properly assigned.',
//       );
//     }
//   }

//   @override
//   void dispose() {
//     widget.scrollController.removeListener(_onScroll);
//     _drawerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Stack(
//       children: [
//         // Main Navbar
//         Container(
//           height: AppDimensions.navHeight,
//           decoration: BoxDecoration(
//             color: _isScrolled
//                 ? AppColors.primaryBlack.withOpacity(0.95)
//                 : Colors.transparent,
//           ),
//           child: _isScrolled
//               ? ClipRect(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                     child: _buildNavContent(isMobile),
//                   ),
//                 )
//               : _buildNavContent(isMobile),
//         ),

//         // Mobile Drawer Overlay
//         if (isMobile && _isMobileMenuOpen)
//           GestureDetector(
//             onTap: _toggleMobileMenu,
//             child: Container(
//               width: double.infinity,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.black.withOpacity(0.5),
//             ),
//           ),

//         // Mobile Drawer
//         if (isMobile)
//           Positioned(
//             top: 0,
//             right: 0,
//             bottom: 0,
//             child: SlideTransition(
//               position: _drawerAnimation,
//               child: Container(
//                 width: screenSize.width * 0.75,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryBlack,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(-5, 0),
//                     ),
//                   ],
//                 ),
//                 child: SafeArea(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Drawer Header
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: AppColors.darkGray.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Menu',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: AppFonts.bold,
//                                 color: AppColors.pureWhite,
//                                 fontFamily: AppFonts.primary,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: _toggleMobileMenu,
//                               child: Icon(
//                                 Icons.close,
//                                 color: AppColors.pureWhite,
//                                 size: 24,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Menu Items
//                       Expanded(
//                         child: ListView(
//                           padding: const EdgeInsets.only(top: 20),
//                           children: [
//                             _buildDrawerItem('Hero'),
//                             ..._navItems
//                                 .map((item) => _buildDrawerItem(item))
//                                 .toList(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildDrawerItem(String item) {
//     bool isActive = _activeSection == item;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _scrollToSection(item),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? AppColors.pureWhite.withOpacity(0.1)
//                 : Colors.transparent,
//             border: Border(
//               bottom: BorderSide(
//                 color: AppColors.darkGray.withOpacity(0.2),
//                 width: 0.5,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               // Active indicator line
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 curve: Curves.easeInOutCubic,
//                 width: 4,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: isActive ? AppColors.pureWhite : Colors.transparent,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               AnimatedDefaultTextStyle(
//                 duration: const Duration(milliseconds: 200),
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: isActive ? AppFonts.semiBold : AppFonts.medium,
//                   color: isActive ? AppColors.pureWhite : AppColors.lightGray,
//                   fontFamily: AppFonts.primary,
//                 ),
//                 child: Text(item),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavContent(bool isMobile) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile
//             ? AppDimensions.paddingMedium
//             : AppDimensions.paddingLarge,
//         vertical: AppDimensions.paddingSmall,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Logo/Name
//           GestureDetector(
//             onTap: () => _scrollToSection('Hero'),
//             child: TweenAnimationBuilder(
//               duration: const Duration(milliseconds: 800),
//               tween: Tween<double>(begin: 0, end: 1),
//               builder: (context, double value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: Text(
//                       'M',
//                       style: TextStyle(
//                         fontSize: isMobile ? 24 : 28,
//                         fontWeight: AppFonts.bold,
//                         color: _isScrolled
//                             ? AppColors.pureWhite
//                             : AppColors.primaryBlack,
//                         fontFamily: AppFonts.primary,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Navigation Items or Hamburger Menu
//           if (isMobile) _buildMobileMenu() else _buildDesktopNavigation(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDesktopNavigation() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = MediaQuery.of(context).size.width;

//         // Calculate responsive spacing
//         double getHorizontalSpacing() {
//           if (screenWidth < 1024) return 16.0;
//           if (screenWidth < 1440) return 24.0;
//           return 32.0;
//         }

//         double getFontSize() {
//           if (screenWidth < 1024) return 13.0;
//           if (screenWidth < 1440) return 14.0;
//           return 15.0;
//         }

//         final horizontalSpacing = getHorizontalSpacing();
//         final fontSize = getFontSize();

//         return Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           mainAxisSize: MainAxisSize.min,
//           children: _navItems.asMap().entries.map((entry) {
//             int index = entry.key;
//             String item = entry.value;
//             bool isActive = _activeSection == item;

//             return TweenAnimationBuilder(
//               duration: Duration(milliseconds: 800 + (index * 100)),
//               tween: Tween<double>(begin: 0, end: 1),
//               builder: (context, double value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: horizontalSpacing / 2,
//                       ),
//                       child: MouseRegion(
//                         cursor: SystemMouseCursors.click,
//                         child: InkWell(
//                           onTap: () => _scrollToSection(item),
//                           borderRadius: BorderRadius.circular(8),
//                           child: Padding(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 8,
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 AnimatedDefaultTextStyle(
//                                   duration: const Duration(milliseconds: 200),
//                                   style: TextStyle(
//                                     fontSize: fontSize,
//                                     fontWeight: isActive
//                                         ? AppFonts.semiBold
//                                         : AppFonts.medium,
//                                     color: _isScrolled
//                                         ? (isActive
//                                               ? AppColors.pureWhite
//                                               : AppColors.pureWhite.withOpacity(
//                                                   0.7,
//                                                 ))
//                                         : (isActive
//                                               ? AppColors.primaryBlack
//                                               : AppColors.darkGray),
//                                     fontFamily: AppFonts.primary,
//                                   ),
//                                   child: Text(
//                                     item,
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 4),
//                                 // Active underline indicator
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeInOutCubic,
//                                   height: 2,
//                                   width: isActive ? item.length * 8.0 : 0,
//                                   decoration: BoxDecoration(
//                                     color: _isScrolled
//                                         ? AppColors.pureWhite
//                                         : AppColors.primaryBlack,
//                                     borderRadius: BorderRadius.circular(1),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildMobileMenu() {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: _toggleMobileMenu,
//         borderRadius: BorderRadius.circular(4),
//         child: Container(
//           width: 40,
//           height: 40,
//           padding: const EdgeInsets.all(5),
//           child: Stack(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 transform: Matrix4.identity()
//                   ..translate(0.0, _isMobileMenuOpen ? 14.0 : 4.0)
//                   ..rotateZ(_isMobileMenuOpen ? 0.785398 : 0),
//                 child: Container(
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//               AnimatedOpacity(
//                 duration: const Duration(milliseconds: 300),
//                 opacity: _isMobileMenuOpen ? 0 : 1,
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 14),
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 transform: Matrix4.identity()
//                   ..translate(0.0, _isMobileMenuOpen ? 14.0 : 24.0)
//                   ..rotateZ(_isMobileMenuOpen ? -0.785398 : 0),
//                 child: Container(
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'dart:ui';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';

// class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
//   final ScrollController scrollController;
//   // Add section keys for dynamic position detection
//   final GlobalKey? heroKey;
//   final GlobalKey? aboutKey;
//   final GlobalKey? portfolioKey;
//   final GlobalKey? experienceKey;
//   final GlobalKey? skillsKey;
//   final GlobalKey? contactKey;

//   const CustomNavBar({
//     Key? key,
//     required this.scrollController,
//     this.heroKey,
//     this.aboutKey,
//     this.portfolioKey,
//     this.experienceKey,
//     this.skillsKey,
//     this.contactKey,
//   }) : super(key: key);

//   @override
//   State<CustomNavBar> createState() => _CustomNavBarState();

//   @override
//   Size get preferredSize => const Size.fromHeight(AppDimensions.navHeight);
// }

// class _CustomNavBarState extends State<CustomNavBar>
//     with TickerProviderStateMixin {
//   bool _isScrolled = false;
//   String _activeSection = 'Hero';
//   bool _isMobileMenuOpen = false;
//   late AnimationController _drawerController;
//   late Animation<Offset> _drawerAnimation;

//   final List<String> _navItems = [
//     'About',
//     'Portfolio',
//     'Experience',
//     'Skills',
//     'Contact',
//   ];

//   // Map sections to their keys for dynamic position detection
//   Map<String, GlobalKey?> get _sectionKeys => {
//     'Hero': widget.heroKey,
//     'About': widget.aboutKey,
//     'Portfolio': widget.portfolioKey,
//     'Experience': widget.experienceKey,
//     'Skills': widget.skillsKey,
//     'Contact': widget.contactKey,
//   };

//   @override
//   void initState() {
//     super.initState();
//     widget.scrollController.addListener(_onScroll);

//     _drawerController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _drawerAnimation =
//         Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
//           CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut),
//         );
//   }

//   void _onScroll() {
//     final offset = widget.scrollController.offset;

//     // Update scroll state for navbar background
//     if (offset > 50 && !_isScrolled) {
//       setState(() => _isScrolled = true);
//     } else if (offset <= 50 && _isScrolled) {
//       setState(() => _isScrolled = false);
//     }

//     // Dynamic section detection based on actual widget positions
//     String newActiveSection = _determineActiveSection(offset);

//     if (newActiveSection != _activeSection) {
//       setState(() {
//         _activeSection = newActiveSection;
//       });
//     }
//   }

//   String _determineActiveSection(double scrollOffset) {
//     // If no keys are provided, fall back to viewport-based detection
//     if (_sectionKeys.values.every((key) => key == null)) {
//       return _determineActiveSectionByViewport(scrollOffset);
//     }

//     // Get screen height for threshold calculation
//     final screenHeight = MediaQuery.of(context).size.height;
//     final threshold = screenHeight * 0.3; // 30% of screen height

//     String closestSection = 'Hero';
//     double closestDistance = double.infinity;

//     // Check each section's position
//     for (final entry in _sectionKeys.entries) {
//       final sectionName = entry.key;
//       final sectionKey = entry.value;

//       if (sectionKey?.currentContext != null) {
//         final RenderBox renderBox =
//             sectionKey!.currentContext!.findRenderObject() as RenderBox;
//         final position = renderBox.localToGlobal(Offset.zero);
//         final sectionTop = position.dy;

//         // Calculate distance from current scroll position
//         final distance = (sectionTop - threshold - scrollOffset).abs();

//         // Find the section closest to the threshold
//         if (sectionTop <= scrollOffset + threshold &&
//             distance < closestDistance) {
//           closestDistance = distance;
//           closestSection = sectionName;
//         }
//       }
//     }

//     return closestSection;
//   }

//   String _determineActiveSectionByViewport(double scrollOffset) {
//     // Fallback method using responsive viewport calculations
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     // Adjust section heights based on screen size
//     double getResponsiveHeight(double baseMultiplier) {
//       if (screenWidth < 600) {
//         // Mobile: sections might be taller due to different layouts
//         return screenHeight * (baseMultiplier * 1.2);
//       } else if (screenWidth < 1024) {
//         // Tablet: moderate adjustment
//         return screenHeight * (baseMultiplier * 1.1);
//       } else {
//         // Desktop: use base multiplier
//         return screenHeight * baseMultiplier;
//       }
//     }

//     if (scrollOffset >= getResponsiveHeight(6.5)) {
//       return 'Contact';
//     } else if (scrollOffset >= getResponsiveHeight(5.0)) {
//       return 'Skills';
//     } else if (scrollOffset >= getResponsiveHeight(3.0)) {
//       return 'Experience';
//     } else if (scrollOffset >= getResponsiveHeight(1.8)) {
//       return 'Portfolio';
//     } else if (scrollOffset >= getResponsiveHeight(0.8)) {
//       return 'About';
//     }

//     return 'Hero';
//   }

//   void _toggleMobileMenu() {
//     setState(() {
//       _isMobileMenuOpen = !_isMobileMenuOpen;
//     });

//     if (_isMobileMenuOpen) {
//       _drawerController.forward();
//     } else {
//       _drawerController.reverse();
//     }
//   }

//   void _scrollToSection(String section) {
//     setState(() {
//       _activeSection = section;
//       _isMobileMenuOpen = false;
//     });

//     _drawerController.reverse();

//     // Try to scroll to actual widget position first
//     final sectionKey = _sectionKeys[section];
//     if (sectionKey?.currentContext != null) {
//       final RenderBox renderBox =
//           sectionKey!.currentContext!.findRenderObject() as RenderBox;
//       final position = renderBox.localToGlobal(Offset.zero);
//       final targetPosition =
//           position.dy +
//           widget.scrollController.offset -
//           100; // Offset for navbar

//       widget.scrollController.animateTo(
//         targetPosition.clamp(
//           0.0,
//           widget.scrollController.position.maxScrollExtent,
//         ),
//         duration: const Duration(milliseconds: 800),
//         curve: Curves.easeInOutCubic,
//       );
//       return;
//     }

//     // Fallback to calculated positions
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     double getResponsiveTargetPosition(String targetSection) {
//       switch (targetSection) {
//         case 'Hero':
//           return 0;
//         case 'About':
//           return screenWidth < 600 ? screenHeight * 0.9 : screenHeight * 0.8;
//         case 'Portfolio':
//           return screenWidth < 600 ? screenHeight * 2.1 : screenHeight * 1.8;
//         case 'Experience':
//           return screenWidth < 600 ? screenHeight * 3.4 : screenHeight * 3.0;
//         case 'Skills':
//           return screenWidth < 600 ? screenHeight * 5.5 : screenHeight * 5.0;
//         case 'Contact':
//           return screenWidth < 600 ? screenHeight * 7.0 : screenHeight * 6.5;
//         default:
//           return 0;
//       }
//     }

//     final targetPosition = getResponsiveTargetPosition(section);

//     widget.scrollController.animateTo(
//       targetPosition.clamp(
//         0.0,
//         widget.scrollController.position.maxScrollExtent,
//       ),
//       duration: const Duration(milliseconds: 800),
//       curve: Curves.easeInOutCubic,
//     );
//   }

//   @override
//   void dispose() {
//     _drawerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Stack(
//       children: [
//         // Main Navbar
//         Container(
//           height: AppDimensions.navHeight,
//           decoration: BoxDecoration(
//             color: _isScrolled
//                 ? AppColors.primaryBlack.withOpacity(0.95)
//                 : Colors.transparent,
//           ),
//           child: _isScrolled
//               ? ClipRect(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                     child: _buildNavContent(isMobile),
//                   ),
//                 )
//               : _buildNavContent(isMobile),
//         ),

//         // Mobile Drawer Overlay
//         if (isMobile && _isMobileMenuOpen)
//           GestureDetector(
//             onTap: _toggleMobileMenu,
//             child: Container(
//               width: double.infinity,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.black.withOpacity(0.5),
//             ),
//           ),

//         // Mobile Drawer
//         if (isMobile)
//           Positioned(
//             top: 0,
//             right: 0,
//             bottom: 0,
//             child: SlideTransition(
//               position: _drawerAnimation,
//               child: Container(
//                 width: screenSize.width * 0.75,
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryBlack,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(-5, 0),
//                     ),
//                   ],
//                 ),
//                 child: SafeArea(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Drawer Header
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: AppColors.darkGray.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Menu',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: AppFonts.bold,
//                                 color: AppColors.pureWhite,
//                                 fontFamily: AppFonts.primary,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: _toggleMobileMenu,
//                               child: Icon(
//                                 Icons.close,
//                                 color: AppColors.pureWhite,
//                                 size: 24,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Menu Items
//                       Expanded(
//                         child: ListView(
//                           padding: const EdgeInsets.only(top: 20),
//                           children: [
//                             _buildDrawerItem('Hero'),
//                             ..._navItems
//                                 .map((item) => _buildDrawerItem(item))
//                                 .toList(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildDrawerItem(String item) {
//     bool isActive = _activeSection == item;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _scrollToSection(item),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? AppColors.pureWhite.withOpacity(0.1)
//                 : Colors.transparent,
//             border: Border(
//               bottom: BorderSide(
//                 color: AppColors.darkGray.withOpacity(0.2),
//                 width: 0.5,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: isActive ? AppColors.pureWhite : Colors.transparent,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 item,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: isActive ? AppFonts.semiBold : AppFonts.medium,
//                   color: isActive ? AppColors.pureWhite : AppColors.lightGray,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavContent(bool isMobile) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: isMobile
//             ? AppDimensions.paddingMedium
//             : AppDimensions.paddingLarge,
//         vertical: AppDimensions.paddingSmall,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Logo/Name
//           GestureDetector(
//             onTap: () => _scrollToSection('Hero'),
//             child: TweenAnimationBuilder(
//               duration: const Duration(milliseconds: 800),
//               tween: Tween<double>(begin: 0, end: 1),
//               builder: (context, double value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: Text(
//                       'M',
//                       style: TextStyle(
//                         fontSize: isMobile ? 24 : 28,
//                         fontWeight: AppFonts.bold,
//                         color: _isScrolled
//                             ? AppColors.pureWhite
//                             : AppColors.primaryBlack,
//                         fontFamily: AppFonts.primary,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Navigation Items or Hamburger Menu
//           if (isMobile) _buildMobileMenu() else _buildDesktopNavigation(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDesktopNavigation() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final screenWidth = MediaQuery.of(context).size.width;
//         final availableWidth =
//             screenWidth - 200; // Account for logo and padding

//         // Calculate responsive item width based on screen size
//         double getItemWidth() {
//           if (screenWidth < 1024) {
//             return (availableWidth / _navItems.length).clamp(50.0, 90.0);
//           } else if (screenWidth < 1440) {
//             return (availableWidth / _navItems.length).clamp(70.0, 110.0);
//           } else {
//             return (availableWidth / _navItems.length).clamp(80.0, 140.0);
//           }
//         }

//         final itemWidth = getItemWidth();
//         final fontSize = screenWidth < 1024 ? 12.0 : 14.0;

//         return Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: _navItems.asMap().entries.map((entry) {
//             int index = entry.key;
//             String item = entry.value;
//             bool isActive = _activeSection == item;

//             return TweenAnimationBuilder(
//               duration: Duration(milliseconds: 800 + (index * 100)),
//               tween: Tween<double>(begin: 0, end: 1),
//               builder: (context, double value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: Container(
//                       width: itemWidth,
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: MouseRegion(
//                         cursor: SystemMouseCursors.click,
//                         child: InkWell(
//                           onTap: () => _scrollToSection(item),
//                           borderRadius: BorderRadius.circular(8),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   item,
//                                   style: TextStyle(
//                                     fontSize: fontSize,
//                                     fontWeight: isActive
//                                         ? AppFonts.semiBold
//                                         : AppFonts.medium,
//                                     color: _isScrolled
//                                         ? AppColors.pureWhite
//                                         : AppColors.darkGray,
//                                     fontFamily: AppFonts.primary,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOutCubic,
//                                   height: 2,
//                                   width: isActive ? itemWidth * 0.8 : 0,
//                                   decoration: BoxDecoration(
//                                     color: _isScrolled
//                                         ? AppColors.pureWhite
//                                         : AppColors.primaryBlack,
//                                     borderRadius: BorderRadius.circular(1),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildMobileMenu() {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: _toggleMobileMenu,
//         borderRadius: BorderRadius.circular(4),
//         child: Container(
//           width: 40,
//           height: 40,
//           padding: const EdgeInsets.all(5),
//           child: Stack(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 transform: Matrix4.identity()
//                   ..translate(0.0, _isMobileMenuOpen ? 14.0 : 4.0)
//                   ..rotateZ(_isMobileMenuOpen ? 0.785398 : 0),
//                 child: Container(
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//               AnimatedOpacity(
//                 duration: const Duration(milliseconds: 300),
//                 opacity: _isMobileMenuOpen ? 0 : 1,
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 14),
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 transform: Matrix4.identity()
//                   ..translate(0.0, _isMobileMenuOpen ? 14.0 : 24.0)
//                   ..rotateZ(_isMobileMenuOpen ? -0.785398 : 0),
//                 child: Container(
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }



/// version 111111111111111111111111111111111111111111111111111111111111111111111111111

// import 'package:flutter/material.dart';
// import 'dart:ui';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/constants/app_fonts.dart';
// import '../../../core/constants/app_dimensions.dart';

// class CustomNavBar extends StatefulWidget implements PreferredSizeWidget {
//   final ScrollController scrollController;

//   const CustomNavBar({Key? key, required this.scrollController})
//     : super(key: key);

//   @override
//   State<CustomNavBar> createState() => _CustomNavBarState();

//   @override
//   Size get preferredSize => const Size.fromHeight(AppDimensions.navHeight);
// }

// class _CustomNavBarState extends State<CustomNavBar>
//     with TickerProviderStateMixin {
//   bool _isScrolled = false;
//   String _activeSection = 'Hero';
//   bool _isMobileMenuOpen = false;
//   late AnimationController _drawerController;
//   late Animation<Offset> _drawerAnimation;

//   final List<String> _navItems = [
//     'About',
//     'Portfolio',
//     'Experience',
//     'Skills',
//     'Contact',
//   ];

//   @override
//   void initState() {
//     super.initState();
//     widget.scrollController.addListener(_onScroll);

//     _drawerController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _drawerAnimation =
//         Tween<Offset>(
//           begin: const Offset(1.0, 0.0), // Start from right
//           end: Offset.zero, // End at normal position
//         ).animate(
//           CurvedAnimation(parent: _drawerController, curve: Curves.easeInOut),
//         );
//   }

//   void _onScroll() {
//     final offset = widget.scrollController.offset;

//     // Update scroll state for navbar background
//     if (offset > 50 && !_isScrolled) {
//       setState(() => _isScrolled = true);
//     } else if (offset <= 50 && _isScrolled) {
//       setState(() => _isScrolled = false);
//     }

//     // Determine active section based on scroll position
//     String newActiveSection = 'Hero';
//     final screenHeight = MediaQuery.of(context).size.height;

//     if (offset >= screenHeight * 6.9) {
//       newActiveSection = 'Contact';
//     } else if (offset >= screenHeight * 5.9) {
//       newActiveSection = 'Skills';
//     } else if (offset >= screenHeight * 3.14) {
//       newActiveSection = 'Experience'; // Covers 2.0 to 6.0
//     } else if (offset >= screenHeight * 1.9) {
//       newActiveSection = 'Portfolio';
//     } else if (offset >= screenHeight * 0.9) {
//       newActiveSection = 'About';
//     }

//     if (newActiveSection != _activeSection) {
//       setState(() {
//         _activeSection = newActiveSection;
//       });
//     }
//   }

//   void _toggleMobileMenu() {
//     setState(() {
//       _isMobileMenuOpen = !_isMobileMenuOpen;
//     });

//     if (_isMobileMenuOpen) {
//       _drawerController.forward();
//     } else {
//       _drawerController.reverse();
//     }
//   }

//   void _scrollToSection(String section) {
//     setState(() {
//       _activeSection = section;
//       _isMobileMenuOpen = false;
//     });

//     _drawerController.reverse();

//     final screenHeight = MediaQuery.of(context).size.height;
//     double targetPosition = 0;

//     switch (section) {
//       case 'Hero':
//         targetPosition = 0;
//         break;
//       case 'About':
//         targetPosition = screenHeight * 0.9;
//         break;
//       case 'Portfolio':
//         targetPosition = screenHeight * 1.9;
//         break;
//       case 'Experience':
//         targetPosition = screenHeight * 3.14;
//         break;
//       case 'Skills':
//         targetPosition = screenHeight * 6.8;
//         break;
//       case 'Contact':
//         targetPosition = screenHeight * 8.4;
//         break;
//     }

//     widget.scrollController.animateTo(
//       targetPosition,
//       duration: const Duration(milliseconds: 800),
//       curve: Curves.easeInOutCubic,
//     );
//   }

//   @override
//   void dispose() {
//     _drawerController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenSize = MediaQuery.of(context).size;
//     final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;

//     return Stack(
//       children: [
//         // Main Navbar
//         Container(
//           height: AppDimensions.navHeight,
//           decoration: BoxDecoration(
//             color: _isScrolled
//                 ? AppColors.primaryBlack.withOpacity(0.95)
//                 : Colors.transparent,
//           ),
//           child: _isScrolled
//               ? ClipRect(
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                     child: _buildNavContent(isMobile),
//                   ),
//                 )
//               : _buildNavContent(isMobile),
//         ),

//         // Mobile Drawer Overlay
//         if (isMobile && _isMobileMenuOpen)
//           GestureDetector(
//             onTap: _toggleMobileMenu,
//             child: Container(
//               width: double.infinity,
//               height: MediaQuery.of(context).size.height,
//               color: Colors.black.withOpacity(0.5),
//             ),
//           ),

//         // Mobile Drawer
//         if (isMobile)
//           Positioned(
//             top: 0,
//             right: 0,
//             bottom: 0,
//             child: SlideTransition(
//               position: _drawerAnimation,
//               child: Container(
//                 width: screenSize.width * 0.75, // 75% of screen width
//                 decoration: BoxDecoration(
//                   color: AppColors.primaryBlack,
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.3),
//                       blurRadius: 10,
//                       offset: const Offset(-5, 0),
//                     ),
//                   ],
//                 ),
//                 child: SafeArea(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Drawer Header
//                       Container(
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           border: Border(
//                             bottom: BorderSide(
//                               color: AppColors.darkGray.withOpacity(0.3),
//                               width: 1,
//                             ),
//                           ),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               'Menu',
//                               style: TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: AppFonts.bold,
//                                 color: AppColors.pureWhite,
//                                 fontFamily: AppFonts.primary,
//                               ),
//                             ),
//                             GestureDetector(
//                               onTap: _toggleMobileMenu,
//                               child: Icon(
//                                 Icons.close,
//                                 color: AppColors.pureWhite,
//                                 size: 24,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Menu Items
//                       Expanded(
//                         child: ListView(
//                           padding: const EdgeInsets.only(top: 20),
//                           children: [
//                             // Add Hero section to mobile menu
//                             _buildDrawerItem('Hero'),
//                             ..._navItems
//                                 .map((item) => _buildDrawerItem(item))
//                                 .toList(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildDrawerItem(String item) {
//     bool isActive = _activeSection == item;

//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: () => _scrollToSection(item),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//           decoration: BoxDecoration(
//             color: isActive
//                 ? AppColors.pureWhite.withOpacity(0.1)
//                 : Colors.transparent,
//             border: Border(
//               bottom: BorderSide(
//                 color: AppColors.darkGray.withOpacity(0.2),
//                 width: 0.5,
//               ),
//             ),
//           ),
//           child: Row(
//             children: [
//               Container(
//                 width: 4,
//                 height: 20,
//                 decoration: BoxDecoration(
//                   color: isActive ? AppColors.pureWhite : Colors.transparent,
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Text(
//                 item,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: isActive ? AppFonts.semiBold : AppFonts.medium,
//                   color: isActive ? AppColors.pureWhite : AppColors.lightGray,
//                   fontFamily: AppFonts.primary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildNavContent(bool isMobile) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppDimensions.paddingLarge,
//         vertical: AppDimensions.paddingSmall,
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Logo/Name
//           GestureDetector(
//             onTap: () => _scrollToSection('Hero'),
//             child: TweenAnimationBuilder(
//               duration: const Duration(milliseconds: 800),
//               tween: Tween<double>(begin: 0, end: 1),
//               builder: (context, double value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: Text(
//                       'M',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: AppFonts.bold,
//                         color: _isScrolled
//                             ? AppColors.pureWhite
//                             : AppColors.primaryBlack,
//                         fontFamily: AppFonts.primary,
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Navigation Items or Hamburger Menu
//           if (isMobile) _buildMobileMenu() else _buildDesktopNavigation(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDesktopNavigation() {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final availableWidth = MediaQuery.of(context).size.width - 200;
//         final itemWidth = (availableWidth / _navItems.length).clamp(
//           60.0,
//           120.0,
//         );

//         return Row(
//           mainAxisAlignment: MainAxisAlignment.end,
//           children: _navItems.asMap().entries.map((entry) {
//             int index = entry.key;
//             String item = entry.value;
//             bool isActive = _activeSection == item;

//             return TweenAnimationBuilder(
//               duration: Duration(milliseconds: 800 + (index * 100)),
//               tween: Tween<double>(begin: 0, end: 1),
//               builder: (context, double value, child) {
//                 return Transform.translate(
//                   offset: Offset(0, 20 * (1 - value)),
//                   child: Opacity(
//                     opacity: value,
//                     child: Container(
//                       width: itemWidth,
//                       padding: const EdgeInsets.symmetric(horizontal: 4),
//                       child: MouseRegion(
//                         cursor: SystemMouseCursors.click,
//                         child: InkWell(
//                           onTap: () => _scrollToSection(item),
//                           borderRadius: BorderRadius.circular(8),
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 4,
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   item,
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: isActive
//                                         ? AppFonts.semiBold
//                                         : AppFonts.medium,
//                                     color: _isScrolled
//                                         ? AppColors.pureWhite
//                                         : AppColors.darkGray,
//                                     fontFamily: AppFonts.primary,
//                                   ),
//                                   textAlign: TextAlign.center,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 4),
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   curve: Curves.easeOutCubic,
//                                   height: 2,
//                                   width: isActive ? itemWidth * 0.8 : 0,
//                                   decoration: BoxDecoration(
//                                     color: _isScrolled
//                                         ? AppColors.pureWhite
//                                         : AppColors.primaryBlack,
//                                     borderRadius: BorderRadius.circular(1),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             );
//           }).toList(),
//         );
//       },
//     );
//   }

//   Widget _buildMobileMenu() {
//     return Material(
//       color: Colors.transparent,
//       child: InkWell(
//         onTap: _toggleMobileMenu,
//         borderRadius: BorderRadius.circular(4),
//         child: Container(
//           width: 40,
//           height: 40,
//           padding: const EdgeInsets.all(5),
//           child: Stack(
//             children: [
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 transform: Matrix4.identity()
//                   ..translate(0.0, _isMobileMenuOpen ? 14.0 : 4.0)
//                   ..rotateZ(_isMobileMenuOpen ? 0.785398 : 0),
//                 child: Container(
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//               AnimatedOpacity(
//                 duration: const Duration(milliseconds: 300),
//                 opacity: _isMobileMenuOpen ? 0 : 1,
//                 child: Container(
//                   margin: const EdgeInsets.only(top: 14),
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//               AnimatedContainer(
//                 duration: const Duration(milliseconds: 300),
//                 transform: Matrix4.identity()
//                   ..translate(0.0, _isMobileMenuOpen ? 14.0 : 24.0)
//                   ..rotateZ(_isMobileMenuOpen ? -0.785398 : 0),
//                 child: Container(
//                   height: 2,
//                   width: 30,
//                   decoration: BoxDecoration(
//                     color: _isScrolled
//                         ? AppColors.pureWhite
//                         : AppColors.primaryBlack,
//                     borderRadius: BorderRadius.circular(1),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
