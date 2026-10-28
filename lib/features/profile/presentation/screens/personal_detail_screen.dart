import 'package:pakland/core/widgets/loader.dart';
import 'package:pakland/core/widgets/responsive_body.dart';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pakland/features/billing/presentation/controllers/pay_online_controller.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/customer_portal/presentation/controllers/get_customer_portal_controller.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/core/widgets/message_field.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/profile/presentation/controllers/update_profile_controller.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/core/widgets/asset_icon.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _storage = const FlutterSecureStorage();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _hintName;
  String? _hintMobile;
  String? _hintEmail;
  String? _hintAddress;
  String? _profileImagePath;
  String? _cachedClientImageUrl;

  final PayOnlineController payOnlineController =
      Get.isRegistered<PayOnlineController>()
          ? Get.find<PayOnlineController>()
          : Get.put(PayOnlineController());

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadCachedClientImageUrl();
    _loadClientImage();
  }

  Future<void> _loadCachedClientImageUrl() async {
    final saved = await _storage.read(key: "cached_client_image_url");
    if (saved != null && saved.isNotEmpty && mounted) {
      setState(() => _cachedClientImageUrl = saved);
    }
  }

  Future<void> _loadClientImage() async {
    if (payOnlineController.clientDetailModel.value != null) return;
    final username = await _storage.read(key: "user_id") ?? "";
    if (username.isEmpty) return;
    await payOnlineController.fetchClientDetails(
      username: username,
      brnCode: '0000',
      blockNo: '',
      plotNo: '',
    );
    final resolved = _resolveClientImageUrl();
    if (resolved != null) {
      await _storage.write(key: "cached_client_image_url", value: resolved);
      if (mounted) setState(() => _cachedClientImageUrl = resolved);
    }
  }

  String? _resolveClientImageUrl() {
    final clientImage = payOnlineController.clientDetailModel.value?.obj.image;
    if (clientImage == null || clientImage.isEmpty) return null;
    final normalizedPath = clientImage.replaceAll('\\', '/');
    final rawUrl = normalizedPath.startsWith('http')
        ? normalizedPath
        : '${ApiConstants.baseUrl}/$normalizedPath'
            .replaceAll(RegExp(r'(?<!:)//+'), '/');
    return Uri.encodeFull(rawUrl);
  }

  ImageProvider _getProfileImage() {
    final freshUrl = _resolveClientImageUrl();
    if (freshUrl != null) return CachedNetworkImageProvider(freshUrl);

    if (_cachedClientImageUrl != null && _cachedClientImageUrl!.isNotEmpty) {
      return CachedNetworkImageProvider(_cachedClientImageUrl!);
    }

    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      return AssetImage(ImageConstant.user_profile);
    }
    if (_profileImagePath!.startsWith('http')) {
      return CachedNetworkImageProvider(_profileImagePath!);
    }
    return CachedNetworkImageProvider(
        '${ApiConstants.baseUrl}/${_profileImagePath!.replaceAll('\\', '/')}');
  }

  Future<void> _loadUserData() async {
    try {
      final name = await _storage.read(key: "user_name") ?? "";
      final mobile = await _storage.read(key: "mobile_no1") ?? "";
      final email = await _storage.read(key: "email_no1") ?? "";
      final address = await _storage.read(key: "address") ?? "";
      final profileImagePath = await _storage.read(key: "profile_image_path") ?? "";
      final customerAddress = await _storage.read(key: "customer_address") ?? "";

      setState(() {
        _hintName = name.isNotEmpty ? name : "Enter your name";
        _hintMobile = mobile.isNotEmpty ? mobile : "Enter your mobile number";
        _hintEmail = email.isNotEmpty ? email : "Enter your email";

        final displayAddress = customerAddress.isNotEmpty
            ? customerAddress
            : (address.isNotEmpty ? address : "Enter your address");

        _hintAddress = displayAddress;
      });

      setState(() {
        nameController.text = name;
        mobileController.text = mobile;
        emailController.text = email;

        addressController.text = customerAddress.isNotEmpty
            ? customerAddress
            : address;

        _profileImagePath = profileImagePath;
      });
    } catch (e) {
      setState(() {
        nameController.text = "";
        mobileController.text = "";
        emailController.text = "";
        addressController.text = "";
        _hintAddress = "Enter your address";
        _profileImagePath = null;
      });
    }
  }

  String _getProfileImageUrl() {
    if (_profileImagePath == null || _profileImagePath!.isEmpty) {
      return '';
    }

    if (_profileImagePath!.startsWith('http')) {
      return _profileImagePath!;
    }

    return '${ApiConstants.baseUrl}/${_profileImagePath!.replaceAll('\\', '/')}';
  }

  static const Color _ink = Color(0xFF1B2733);
  static const Color _muted = Color(0xFF6B7785);
  static const Color _border = Color(0xFFE8ECF4);

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
          title: const Text('View Profile'),
          subtitle: 'Your personal information',
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
          child: LayoutBuilder(
            builder: (context, c) {
              final bool compact = c.maxHeight < 700;
              final double gap = compact ? 12 : 16;
              return SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16,
                  compact ? 12 : 20,
                  16,
                  16 + MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroCard(compact: compact),
                    SizedBox(height: gap),
                    _buildDetailsCard(compact: compact),
                    SizedBox(height: gap),
                    _buildReadOnlyNote(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard({bool compact = false}) {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    final Widget avatar = Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, AppColors.lightAppColor],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.30),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(2.5),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: _buildProfileImage(sizeOverride: compact ? 64 : 96),
      ),
    );

    final Widget nameText = Text(
      name.isEmpty ? 'Your Name' : name,
      textAlign: compact ? TextAlign.start : TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: compact ? 17 : 19,
        fontWeight: FontWeight.w800,
        color: _ink,
      ),
    );

    final Widget emailText = Text(
      email,
      textAlign: compact ? TextAlign.start : TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13, color: _muted),
    );

    if (compact) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  nameText,
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    emailText,
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          avatar,
          const SizedBox(height: 12),
          nameText,
          if (email.isNotEmpty) ...[
            const SizedBox(height: 4),
            emailText,
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard({bool compact = false}) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, compact ? 14 : 18, 16, compact ? 2 : 6),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.appColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : 8),
          _infoRow(
            icon: AssetIcon(ImageConstant.authUser,
                size: 20, color: AppColors.appColor),
            label: 'Full Name',
            value: nameController.text,
            compact: compact,
          ),
          _divider(),
          _infoRow(
            icon: AssetIcon(ImageConstant.authPhone,
                size: 20, color: AppColors.appColor),
            label: 'Mobile No.',
            value: mobileController.text,
            compact: compact,
          ),
          _divider(),
          _infoRow(
            icon: AssetIcon(ImageConstant.authMail,
                size: 20, color: AppColors.appColor),
            label: 'Email',
            value: emailController.text,
            compact: compact,
          ),
          _divider(),
          _infoRow(
            icon: Icon(Icons.location_on_outlined,
                size: 21, color: AppColors.appColor),
            label: 'Address',
            value: addressController.text,
            compact: compact,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Padding(
        padding: const EdgeInsets.only(left: 54),
        child: Divider(height: 1, color: Colors.grey.shade200),
      );

  Widget _infoRow({
    required Widget icon,
    required String label,
    required String value,
    bool compact = false,
  }) {
    final bool empty = value.trim().isEmpty;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 8 : 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: compact ? 38 : 42,
            height: compact ? 38 : 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.appColor.withOpacity(0.09),
              borderRadius: BorderRadius.circular(13),
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  empty ? 'Not provided' : value.trim(),
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: empty ? FontWeight.w500 : FontWeight.w700,
                    color: empty ? Colors.grey.shade400 : _ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadOnlyNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AssetIcon(ImageConstant.icInfo,
              size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'These details are shown for viewing only.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage({double? sizeOverride}) {
    final double size = sizeOverride ??
        (MediaQuery.of(context).size.width * 0.30).clamp(96.0, 130.0);

    return Obx(() {
      final provider = _getProfileImage();
      return ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: Image(
            image: provider,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Image.asset(
              ImageConstant.user_profile,
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
            frameBuilder: (context, child, frame, wasSyncLoaded) {
              if (wasSyncLoaded || frame != null) return child;
              return Center(
                child: AppLoader(size: 22),
              );
            },
          ),
        ),
      );
    });
  }
}
