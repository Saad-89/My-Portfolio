import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';
import '../../../core/constants/app_dimensions.dart';

class ContactSection extends StatefulWidget {
  final ScrollController scrollController;

  const ContactSection({Key? key, required this.scrollController})
    : super(key: key);

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _formAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late List<Animation<Offset>> _formFieldAnimations;

  bool _hasAnimated = false;
  late GlobalKey _sectionKey;

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  bool _isSubmitting = false;

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

    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1600),
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

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
      ),
    );

    // Form field animations
    _formFieldAnimations = List.generate(
      4,
      (index) =>
          Tween<Offset>(begin: const Offset(-0.5, 0), end: Offset.zero).animate(
            CurvedAnimation(
              parent: _formAnimationController,
              curve: Interval(
                (index * 0.1).clamp(0.0, 0.7),
                ((index * 0.1) + 0.4).clamp(0.4, 1.0),
                curve: Curves.easeOutCubic,
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
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          _formAnimationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _formAnimationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
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
          'LET\'S WORK TOGETHER',
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
          'Have a project in mind? Let\'s discuss how we can bring your ideas to life. I\'m always open to new opportunities and collaborations.',
          textAlign: TextAlign.center,
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

    return Container(
      key: _sectionKey,
      width: double.infinity,
      decoration: BoxDecoration(
        // gradient: LinearGradient(
        //   begin: Alignment.topCenter,
        //   end: Alignment.bottomCenter,
        //   colors: [Colors.grey.shade50, Colors.white, Colors.grey.shade100],
        // ),
        color: AppColors.offwhite,
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
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildSectionHeader(true),
        const SizedBox(height: 40),
        _buildContactInfo(true),
        const SizedBox(height: 40),
        _buildContactForm(true),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Column(
      children: [
        _buildSectionHeader(false),
        const SizedBox(height: 60),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 2, child: _buildContactInfo(false)),
            const SizedBox(width: 60),
            Expanded(flex: 3, child: _buildContactForm(false)),
          ],
        ),
      ],
    );
  }

  // Widget _buildSectionHeader(bool isMobile) {
  //   return Column(
  //     children: [
  //       // Section Label
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
  //           'Get In Touch',
  //           style: TextStyle(
  //             fontSize: 14,
  //             fontWeight: AppFonts.semiBold,
  //             color: Colors.white,
  //             fontFamily: AppFonts.primary,
  //             letterSpacing: 1.5,
  //           ),
  //         ),
  //       ),

  //       SizedBox(height: isMobile ? 25 : 30),

  //       // Main Title
  //       ShaderMask(
  //         shaderCallback: (bounds) => LinearGradient(
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //           colors: [Colors.black, Colors.grey.shade700],
  //         ).createShader(bounds),
  //         child: Text(
  //           'Let\'s Work Together',
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

  //       // Subtitle
  //       Container(
  //         constraints: BoxConstraints(maxWidth: isMobile ? 300 : 600),
  //         child: Text(
  //           'Have a project in mind? Let\'s discuss how we can bring your ideas to life. I\'m always open to new opportunities and collaborations.',
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

  Widget _buildContactInfo(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Information',
          style: TextStyle(
            fontSize: isMobile ? 24 : 28,
            fontWeight: AppFonts.bold,
            color: AppColors.primaryBlack,
            fontFamily: AppFonts.primary,
          ),
        ),

        SizedBox(height: isMobile ? 16 : 20),

        Text(
          'Feel free to reach out through any of these channels. I typically respond within 24 hours.',
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: AppFonts.regular,
            color: AppColors.textSecondary,
            fontFamily: AppFonts.primary,
            height: 1.5,
          ),
        ),

        SizedBox(height: isMobile ? 30 : 40),

        _buildContactItem(
          icon: Icons.email_rounded,
          title: 'Email',
          subtitle: 'your.email@example.com',
          onTap: () => _launchEmail('your.email@example.com'),
          isMobile: isMobile,
        ),

        SizedBox(height: isMobile ? 20 : 24),

        _buildContactItem(
          icon: Icons.phone_rounded,
          title: 'Phone',
          subtitle: '+1 (555) 123-4567',
          onTap: () => _launchPhone('+15551234567'),
          isMobile: isMobile,
        ),

        SizedBox(height: isMobile ? 20 : 24),

        _buildContactItem(
          icon: Icons.location_on_rounded,
          title: 'Location',
          subtitle: 'San Francisco, CA',
          onTap: null,
          isMobile: isMobile,
        ),

        SizedBox(height: isMobile ? 30 : 40),

        // Social Links
        _buildSocialLinks(isMobile),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    required bool isMobile,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                spreadRadius: 0,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.black, Colors.grey.shade800],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: AppFonts.semiBold,
                        color: AppColors.primaryBlack,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        fontWeight: AppFonts.regular,
                        color: AppColors.textSecondary,
                        fontFamily: AppFonts.primary,
                      ),
                    ),
                  ],
                ),
              ),

              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialLinks(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Follow Me',
          style: TextStyle(
            fontSize: isMobile ? 18 : 20,
            fontWeight: AppFonts.semiBold,
            color: AppColors.primaryBlack,
            fontFamily: AppFonts.primary,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            _buildSocialButton(
              icon: Icons.link_rounded,
              label: 'LinkedIn',
              onTap: () => _launchSocial('linkedin'),
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              icon: Icons.code_rounded,
              label: 'GitHub',
              onTap: () => _launchSocial('github'),
            ),
            const SizedBox(width: 12),
            _buildSocialButton(
              icon: Icons.alternate_email_rounded,
              label: 'Twitter',
              onTap: () => _launchSocial('twitter'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppColors.primaryBlack),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: AppFonts.medium,
                  color: AppColors.primaryBlack,
                  fontFamily: AppFonts.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactForm(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send Message',
              style: TextStyle(
                fontSize: isMobile ? 24 : 28,
                fontWeight: AppFonts.bold,
                color: AppColors.primaryBlack,
                fontFamily: AppFonts.primary,
              ),
            ),

            SizedBox(height: isMobile ? 24 : 30),

            // Name Field
            SlideTransition(
              position: _formFieldAnimations[0],
              child: _buildFormField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your full name',
                icon: Icons.person_outline_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
                isMobile: isMobile,
              ),
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Email Field
            SlideTransition(
              position: _formFieldAnimations[1],
              child: _buildFormField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email address',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
                isMobile: isMobile,
              ),
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Subject Field
            SlideTransition(
              position: _formFieldAnimations[2],
              child: _buildFormField(
                controller: _subjectController,
                label: 'Subject',
                hint: 'What is this about?',
                icon: Icons.subject_rounded,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subject';
                  }
                  return null;
                },
                isMobile: isMobile,
              ),
            ),

            SizedBox(height: isMobile ? 16 : 20),

            // Message Field
            SlideTransition(
              position: _formFieldAnimations[3],
              child: _buildFormField(
                controller: _messageController,
                label: 'Message',
                hint: 'Tell me about your project...',
                icon: Icons.message_outlined,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your message';
                  }
                  if (value.length < 10) {
                    return 'Message should be at least 10 characters';
                  }
                  return null;
                },
                isMobile: isMobile,
              ),
            ),

            SizedBox(height: isMobile ? 24 : 30),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade400,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.send_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Send Message',
                            style: TextStyle(
                              fontSize: isMobile ? 16 : 17,
                              fontWeight: AppFonts.semiBold,
                              fontFamily: AppFonts.primary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isMobile,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: AppFonts.semiBold,
            color: AppColors.primaryBlack,
            fontFamily: AppFonts.primary,
          ),
        ),

        const SizedBox(height: 8),

        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20),
            hintStyle: TextStyle(
              color: AppColors.textSecondary,
              fontFamily: AppFonts.primary,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 16 : 14,
            ),
          ),
          style: TextStyle(
            fontFamily: AppFonts.primary,
            fontSize: 14,
            color: AppColors.primaryBlack,
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message sent successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );

        // Clear form
        _nameController.clear();
        _emailController.clear();
        _subjectController.clear();
        _messageController.clear();
      }
    }
  }

  void _launchEmail(String email) {
    // Implement email launcher
    print('Opening email: $email');
  }

  void _launchPhone(String phone) {
    // Implement phone dialer
    print('Calling: $phone');
  }

  void _launchSocial(String platform) {
    // Implement social media links
    print('Opening $platform');
  }
}
