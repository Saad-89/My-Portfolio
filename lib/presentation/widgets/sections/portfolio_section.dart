// lib/presentation/widgets/sections/portfolio_section.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/project_model.dart';
import '../../../data/repositories/portfolio_data.dart';
import '../dialogs/project_video_dialog.dart';
import '../common/section_title.dart';

class PortfolioSection extends StatefulWidget {
  final ScrollController scrollController;
  const PortfolioSection({Key? key, required this.scrollController})
    : super(key: key);

  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _currentIndex = 2; // Start with middle item as center
  bool _hasAnimated = false;
  late GlobalKey _sectionKey;

  @override
  void initState() {
    super.initState();
    _setupScrollListener();
    _sectionKey = GlobalKey();
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.6, // Reduced from 0.8 to make center card narrower
    );

    _setupAnimations();
  }

  void _setupScrollListener() {
    widget.scrollController.addListener(() {
      if (!_hasAnimated && _isInView()) {
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

    // Trigger animation when section is 50% visible
    return position.dy < screenHeight * 0.8 &&
        position.dy > -renderBox.size.height * 0.5;
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Auto-start animation after delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _animationController.forward();
        }
      });
    });
  }

  void _openProjectDialog(ProjectModel project) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProjectVideoDialog(project: project),
    );
  }

  void _nextProject() {
    if (_currentIndex < PortfolioData.projects.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousProject() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
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
          'PORTFOLIO',
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
          'Featured Projects & Case Studies',
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

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;
    final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;

    return Container(
      key: _sectionKey,
      width: double.infinity,
      color: AppColors.pureWhite,
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile
            ? AppDimensions.paddingMedium
            : AppDimensions.paddingXLarge,
        vertical: AppDimensions.paddingXLarge,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Section Title
            _buildEnhancedSectionTitle(isMobile),

            // SectionTitle(
            //   title: 'Portfolio',
            //   subtitle: 'Featured Projects & Case Studies',
            //   isDark: true,
            // ),
            SizedBox(height: isMobile ? 24 : 30),

            // Portfolio Carousel
            SizedBox(
              height: isMobile ? 500 : 700, // Fixed height for mobile
              child: isMobile ? _buildMobileView() : _buildDesktopView(),
            ),

            const SizedBox(height: 20),

            // Navigation Indicators
            _buildIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopView() {
    return Stack(
      children: [
        // Main Carousel
        Center(
          child: SizedBox(
            // height: 500,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: PortfolioData.projects.length,
              itemBuilder: (context, index) {
                final project = PortfolioData.projects[index];
                final isCenter = index == _currentIndex;

                return TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 400),
                  tween: Tween(begin: 0.0, end: isCenter ? 0.5 : 0.0),
                  curve: Curves.easeInOut,
                  builder: (context, animation, child) {
                    final scale = 0.85 + (0.15 * animation);
                    final opacity = 0.6 + (0.4 * animation);

                    return Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: opacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildProjectCard(project, isCenter),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),

        // Navigation Arrows
        _buildNavigationArrows(),
      ],
    );
  }

  Widget _buildMobileView() {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: PortfolioData.projects.length,
          itemBuilder: (context, index) {
            final project = PortfolioData.projects[index];
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildProjectCard(project, true, isMobile: true),
            );
          },
        ),

        // Mobile Navigation Arrows
        _buildMobileNavigationArrows(),
      ],
    );
  }

  Widget _buildProjectCard(
    ProjectModel project,
    bool isCenter, {
    bool isMobile = false,
  }) {
    return GestureDetector(
      onTap: () => _openProjectDialog(project),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlack.withOpacity(
                  isCenter ? 0.15 : 0.08,
                ),
                spreadRadius: 0,
                blurRadius: isCenter ? 30 : 15,
                offset: Offset(0, isCenter ? 15 : 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Project Image - Increased proportion
                Expanded(
                  flex: 3, // Increased from 3 to 4 for more image space
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(
                      12,
                    ), // Add margin for white border effect
                    decoration: BoxDecoration(
                      color: AppColors.offwhite,
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage(project.thumbnailUrl),
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          // Handle image loading error
                        },
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Gradient overlay
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),

                        // Category Badge
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              project.category,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: AppFonts.medium,
                                color: AppColors.primaryBlack,
                                fontFamily: AppFonts.primary,
                              ),
                            ),
                          ),
                        ),

                        // Play button overlay
                        if (project.videoUrl != null)
                          Center(
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.pureWhite.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: AppColors.primaryBlack,
                                size: 30,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Project Info - Reduced proportion
                Expanded(
                  flex: isMobile
                      ? 2
                      : 1, // Reduced proportion for desktop, kept same for mobile
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isMobile ? 16 : 24,
                      isMobile ? 8 : 12,
                      isMobile ? 16 : 24,
                      isMobile ? 16 : 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Project Title
                            Text(
                              project.title,
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 20,
                                fontWeight: AppFonts.bold,
                                color: AppColors.primaryBlack,
                                fontFamily: AppFonts.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 8),

                            // Project Description
                            Text(
                              project.detailedDescription,
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                fontWeight: AppFonts.regular,
                                color: AppColors.textSecondary,
                                fontFamily: AppFonts.primary,
                                height: 1.4,
                              ),
                              maxLines: isMobile
                                  ? 2
                                  : 2, // Reduced lines for desktop
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),

                        // Technologies
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: project.technologies
                              .take(isMobile ? 2 : 3)
                              .map((tech) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBlack.withOpacity(
                                      0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppColors.primaryBlack.withOpacity(
                                        0.2,
                                      ),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    tech,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: AppFonts.medium,
                                      color: AppColors.primaryBlack,
                                      fontFamily: AppFonts.primary,
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _leftArrowScale = 1.0;
  double _rightArrowScale = 1.0;

  Widget _buildNavigationArrows() {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Arrow
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: GestureDetector(
              onTap: _previousProject,
              onTapDown: (_) {
                setState(() => _leftArrowScale = 0.85);
              },
              onTapUp: (_) {
                setState(() => _leftArrowScale = 1.0);
              },
              onTapCancel: () {
                setState(() => _leftArrowScale = 1.0);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedScale(
                  scale: _leftArrowScale,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _currentIndex > 0
                          ? AppColors.pureWhite
                          : AppColors.pureWhite.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlack.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: _currentIndex > 0
                          ? AppColors.primaryBlack
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Next Arrow
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: _nextProject,
              onTapDown: (_) {
                setState(() => _rightArrowScale = 0.85);
              },
              onTapUp: (_) {
                setState(() => _rightArrowScale = 1.0);
              },
              onTapCancel: () {
                setState(() => _rightArrowScale = 1.0);
              },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: AnimatedScale(
                  scale: _rightArrowScale,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _currentIndex < PortfolioData.projects.length - 1
                          ? AppColors.pureWhite
                          : AppColors.pureWhite.withOpacity(0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlack.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: _currentIndex < PortfolioData.projects.length - 1
                          ? AppColors.primaryBlack
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileNavigationArrows() {
    return Positioned.fill(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Arrow - Mobile
          GestureDetector(
            onTap: _previousProject,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: _currentIndex > 0
                    ? AppColors.pureWhite.withOpacity(0.9)
                    : AppColors.pureWhite.withOpacity(0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlack.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_left,
                color: _currentIndex > 0
                    ? AppColors.primaryBlack
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),

          // Next Arrow - Mobile
          GestureDetector(
            onTap: _nextProject,
            child: Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: _currentIndex < PortfolioData.projects.length - 1
                    ? AppColors.pureWhite.withOpacity(0.9)
                    : AppColors.pureWhite.withOpacity(0.5),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlack.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_right,
                color: _currentIndex < PortfolioData.projects.length - 1
                    ? AppColors.primaryBlack
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        PortfolioData.projects.length,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: index == _currentIndex ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: index == _currentIndex
                ? AppColors.primaryBlack
                : AppColors.primaryBlack.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
