// lib/presentation/widgets/dialogs/project_video_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../data/models/project_model.dart';

class ProjectVideoDialog extends StatefulWidget {
  final ProjectModel project;

  const ProjectVideoDialog({Key? key, required this.project}) : super(key: key);

  @override
  State<ProjectVideoDialog> createState() => _ProjectVideoDialogState();
}

class _ProjectVideoDialogState extends State<ProjectVideoDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _scaleController.forward();
    });
  }

  Future<void> _closeDialog() async {
    await Future.wait([_scaleController.reverse(), _fadeController.reverse()]);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < AppDimensions.mobileBreakpoint;
    final isTablet = screenSize.width < AppDimensions.tabletBreakpoint;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.black.withOpacity(0.8),
        child: GestureDetector(
          onTap: _closeDialog,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isMobile
                        ? screenSize.width * 0.95
                        : isTablet
                        ? screenSize.width * 0.85
                        : 900,
                    maxHeight: screenSize.height * 0.9,
                  ),
                  child: GestureDetector(
                    onTap: () {}, // Prevent dialog close when tapping content
                    child: Container(
                      margin: EdgeInsets.all(isMobile ? 16 : 24),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildHeader(isMobile),
                            Flexible(
                              child: SingleChildScrollView(
                                padding: EdgeInsets.all(isMobile ? 20 : 32),
                                child: isMobile
                                    ? _buildMobileContent()
                                    : _buildDesktopContent(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: const BoxDecoration(
        color: AppColors.offwhite,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.project.title,
              style: TextStyle(
                fontSize: isMobile ? 20 : 24,
                fontWeight: AppFonts.bold,
                color: AppColors.primaryBlack,
                fontFamily: AppFonts.primary,
              ),
            ),
          ),
          IconButton(
            onPressed: _closeDialog,
            icon: const Icon(Icons.close, color: AppColors.darkGray, size: 24),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.pureWhite,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Section
        Expanded(flex: 3, child: _buildVideoSection()),

        const SizedBox(width: 32),

        // Details Section
        Expanded(flex: 2, child: _buildDetailsSection()),
      ],
    );
  }

  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVideoSection(),
        const SizedBox(height: 24),
        _buildDetailsSection(),
      ],
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video Player Placeholder
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            color: AppColors.primaryBlack,
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(widget.project.thumbnailUrl),
              fit: BoxFit.cover,
              onError: (exception, stackTrace) {
                // Handle image loading error
              },
            ),
          ),
          child: Stack(
            children: [
              // Play button overlay
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    size: 40,
                    color: AppColors.primaryBlack,
                  ),
                ),
              ),

              // Video placeholder text
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Demo Video',
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 12,
                      fontWeight: AppFonts.medium,
                      fontFamily: AppFonts.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Technologies
        Text(
          'Technologies',
          style: TextStyle(
            fontSize: 16,
            fontWeight: AppFonts.semiBold,
            color: AppColors.primaryBlack,
            fontFamily: AppFonts.primary,
          ),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.project.technologies.map((tech) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.offwhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.lightGray.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                tech,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: AppFonts.medium,
                  color: AppColors.darkGray,
                  fontFamily: AppFonts.primary,
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Category and Date
        Row(
          children: [
            Expanded(
              child: _buildInfoItem('Category', widget.project.category),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoItem(
                'Completed',
                '${widget.project.completionDate.month}/${widget.project.completionDate.year}',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Description
        Text(
          'Project Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: AppFonts.semiBold,
            color: AppColors.primaryBlack,
            fontFamily: AppFonts.primary,
          ),
        ),

        const SizedBox(height: 12),

        // Markdown content for rich text
        MarkdownBody(
          data: widget.project.detailedDescription,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(
              fontSize: 14,
              color: AppColors.darkGray,
              fontFamily: AppFonts.primary,
              height: 1.6,
            ),
            strong: const TextStyle(
              fontWeight: AppFonts.semiBold,
              color: AppColors.primaryBlack,
            ),
            listBullet: const TextStyle(color: AppColors.primaryBlack),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: AppFonts.medium,
            color: AppColors.lightGray,
            fontFamily: AppFonts.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: AppFonts.semiBold,
            color: AppColors.primaryBlack,
            fontFamily: AppFonts.primary,
          ),
        ),
      ],
    );
  }
}
