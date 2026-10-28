import 'package:pakland/core/widgets/loader.dart';
import 'package:pakland/core/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/core/widgets/asset_icon.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/features/feedback/presentation/controllers/add_feedback_controller.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/profile/presentation/screens/profile_screen.dart';

class HelpSupportScreen extends StatefulWidget {
  HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final FeedbackController _feedbackController = Get.put(FeedbackController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _phoneFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  Future<void> _handleSend() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final message = _messageController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || message.isEmpty) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please fill all required fields.",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    if (!_isValidEmail(email)) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please enter a valid email address.",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      showTopSnackBar(
        context,
        title: "Alert",
        "Please enter a valid phone number (10-15 digits).",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    final success = await _feedbackController.sendFeedback(
      context: context,
      name: name,
      email: email,
      phone: phone,
      message: message,
    );

    if (success) {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();

      showTopSnackBar(
        context,
        title: "Success",
        "Your message has been sent successfully!",
        Colors.green.withOpacity(0.7),
        icon: Icons.check_circle,
      );
    }
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    _emailFocusNode.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  static const Color _ink = Color(0xFF1B2733);
  static const Color _muted = Color(0xFF6B7785);
  static const Color _border = Color(0xFFE8ECF4);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.off(() => MainWrapper(initialIndex: 1));
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        appBar: AppHeaderBar(
          title: const Text('Help & Support'),
          subtitle: "We're here to help",
          onBackPressed: () => Get.off(() => MainWrapper(initialIndex: 1)),
          actions: [
            AppHeaderAction(
              assetIcon: ImageConstant.icHouse,
              tooltip: 'Home',
              onPressed: () => Get.offAll(() => MainWrapper(initialIndex: 0)),
            ),
          ],
        ),
        body: ResponsiveBody(
          maxWidth: 600,
          child: _buildPortraitLayout(context),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      );

  Widget _buildPortraitLayout(BuildContext context) {
    final bool keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return LayoutBuilder(
      builder: (context, c) {
        const double minContent = 540;
        final bool showIntro = !keyboardOpen && c.maxHeight >= 640;
        final bool showPrivacy = !keyboardOpen && c.maxHeight >= 700;
        final double contentH = c.maxHeight > minContent ? c.maxHeight : minContent;
        final bool canScroll = c.maxHeight < minContent;

        return SingleChildScrollView(
          physics: canScroll
              ? const ClampingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SizedBox(
            height: contentH,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showIntro) ...[
                      _buildIntroCard(),
                      const SizedBox(height: 12),
                    ],
                    Expanded(child: _buildFormCard()),
                    if (showPrivacy) ...[
                      const SizedBox(height: 10),
                      _buildPrivacyNote(),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.appColor,
                  Color.lerp(AppColors.appColor, Colors.black, 0.28)!,
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.appColor.withOpacity(0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AssetIcon(ImageConstant.icHeadset, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How can we help you?',
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: _ink),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    AssetIcon(ImageConstant.icClock, size: 12, color: _muted),
                    const SizedBox(width: 5),
                    const Expanded(
                      child: Text(
                        'Our team replies within 24 hours',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: _muted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.appColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: AssetIcon(ImageConstant.icMessage, color: AppColors.appColor, size: 19),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send us a message',
                      style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800, color: _ink),
                    ),
                    Text(
                      'Fields marked * are required',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF8A94A3)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _PolishedTextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            label: 'Name',
            isRequired: true,
            hintText: 'e.g. Ali Raza',
            prefixIcon: ImageConstant.authUser,
            accent: const Color(0xFF3B82F6),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          _PolishedTextField(
            controller: _phoneController,
            focusNode: _phoneFocusNode,
            label: 'Phone No.',
            isRequired: true,
            hintText: '03xxxxxxxxx',
            prefixIcon: ImageConstant.authPhone,
            accent: const Color(0xFF10B981),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d+\s-]')),
            ],
          ),
          const SizedBox(height: 12),
          _PolishedTextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            label: 'Email',
            isRequired: true,
            hintText: 'you@example.com',
            prefixIcon: ImageConstant.authMail,
            accent: const Color(0xFFF59E0B),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _PolishedTextField(
              controller: _messageController,
              label: 'Message',
              isRequired: true,
              hintText: 'Tell us how we can help...',
              prefixIcon: ImageConstant.icMessage,
              accent: const Color(0xFF8B5CF6),
              keyboardType: TextInputType.multiline,
              expands: true,
            ),
          ),
          const SizedBox(height: 14),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Obx(() {
      final loading = _feedbackController.isLoading.value;
      return Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.appColor,
              Color.lerp(AppColors.appColor, Colors.black, 0.25)!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withOpacity(0.32),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: loading ? null : _handleSend,
            child: Center(
              child: loading
                  ? const AppLoader(size: 22)
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AssetIcon(ImageConstant.icSend, color: Colors.white, size: 19),
                        const SizedBox(width: 10),
                        const Text(
                          'SEND MESSAGE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPrivacyNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetIcon(ImageConstant.icShield, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Your details are kept private and are only used to respond to your request.',
              style: TextStyle(fontSize: 12, height: 1.4, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidPhone(String phone) {
    String cleanedPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanedPhone.length < 10 || cleanedPhone.length > 15) {
      return false;
    }
    return RegExp(r'^\d{10,15}$').hasMatch(cleanedPhone);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
    );
    return emailRegex.hasMatch(email);
  }
}

class _PolishedTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final bool isRequired;
  final String hintText;
  final String prefixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final int? minLines;
  final bool expands;
  final TextInputAction? textInputAction;
  final Color? accent;

  const _PolishedTextField({
    required this.controller,
    this.focusNode,
    required this.label,
    this.isRequired = false,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.textInputAction,
    this.accent,
  });

  @override
  State<_PolishedTextField> createState() => _PolishedTextFieldState();
}

class _PolishedTextFieldState extends State<_PolishedTextField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;
  bool _ownsFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool expands = widget.expands;
    final bool isMultiline = expands || widget.maxLines > 1;
    final Color accent = widget.accent ?? AppColors.appColor;

    final Widget box = AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: _isFocused ? Colors.white : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isFocused ? accent : const Color(0xFFE2E8F0),
          width: _isFocused ? 1.6 : 1.2,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: accent.withOpacity(0.16),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          crossAxisAlignment:
              expands ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: expands ? 10 : 0),
              child: Align(
                alignment: expands ? Alignment.topCenter : Alignment.center,
                widthFactor: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(_isFocused ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AssetIcon(widget.prefixIcon, size: 17, color: accent),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                inputFormatters: widget.inputFormatters,
                textCapitalization: widget.textCapitalization,
                maxLines: expands ? null : widget.maxLines,
                minLines: expands ? null : widget.minLines,
                expands: expands,
                textAlignVertical:
                    expands ? TextAlignVertical.top : TextAlignVertical.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                cursorColor: accent,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFA0AAB8),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: isMultiline ? 14 : 11,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: expands ? MainAxisSize.max : MainAxisSize.min,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
            children: [
              TextSpan(text: widget.label),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(color: Color(0xFFE0577B)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        if (expands) Expanded(child: box) else box,
      ],
    );
  }
}
