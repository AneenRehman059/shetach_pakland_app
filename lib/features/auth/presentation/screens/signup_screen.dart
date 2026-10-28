import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/auth/presentation/controllers/signup_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/communication_policy_controller.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';
import 'package:pakland/features/auth/data/models/signup_model.dart';
import 'package:pakland/features/auth/presentation/screens/verify_otp_screen.dart';

import 'package:pakland/core/services/get_device_info.dart';
import 'package:pakland/core/services/video_background_service.dart';
import 'package:video_player/video_player.dart';

import '../../auth_widget/auth_wdget.dart';

class SignUpNScreen extends StatefulWidget {
  SignUpNScreen({super.key});

  @override
  State<SignUpNScreen> createState() => _SignUpNScreenState();
}

class _SignUpNScreenState extends State<SignUpNScreen>
    with VideoSoundMixin<SignUpNScreen> {
  final cnicController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final mobileNoController = TextEditingController();
  final emailController = TextEditingController();
  final userNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();

  final _signUpController = Get.put(SignUpController());
  final _communicationPolicyController = Get.put(CommunicationPolicyController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final _videoService = VideoBackgroundService.instance;
  bool _videoReady = false;

  // Only one OTP method is ever shown - driven by
  // /api/MobileAPi/GetCommunicationPolicy's key_code:
  //   via_WABA / whatsapp -> WHATSAPP
  //   itel / telenor      -> SMS
  //   email               -> EMAIL
  String get _otpMethod => _communicationPolicyController.otpMethod.value.value;
  String _passwordStrength = '';
  Color _passwordStrengthColor = Colors.grey;
  String _confirmPasswordStrength = '';
  Color _confirmPasswordStrengthColor = Colors.grey;

  Map<String, String> _fieldErrors = {
    'firstName': '',
    'lastName': '',
    'cnic': '',
    'phone': '',
    'email': '',
    'password': '',
    'confirmPassword': '',
  };

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    int length = password.length;

    int characterTypesCount = 0;
    if (hasUppercase) characterTypesCount++;
    if (hasLowercase) characterTypesCount++;
    if (hasNumber) characterTypesCount++;
    if (hasSpecialChar) characterTypesCount++;

    if (length > 8 && characterTypesCount == 4) {
      setState(() {
        _passwordStrength = 'Strong';
        _passwordStrengthColor = Colors.green;
      });
    } else if (length == 8) {
      setState(() {
        _passwordStrength = 'Average';
        _passwordStrengthColor = Colors.orange;
      });
    } else if (length > 8 && characterTypesCount >= 2) {
      setState(() {
        _passwordStrength = 'Average';
        _passwordStrengthColor = Colors.orange;
      });
    } else if (length > 0) {
      setState(() {
        _passwordStrength = 'Weak';
        _passwordStrengthColor = Colors.red;
      });
    } else {
      setState(() {
        _passwordStrength = '';
        _passwordStrengthColor = Colors.grey;
      });
    }
  }

  void _checkConfirmPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _confirmPasswordStrength = '';
        _confirmPasswordStrengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    int length = password.length;

    int characterTypesCount = 0;
    if (hasUppercase) characterTypesCount++;
    if (hasLowercase) characterTypesCount++;
    if (hasNumber) characterTypesCount++;
    if (hasSpecialChar) characterTypesCount++;

    if (length > 8 && characterTypesCount == 4) {
      setState(() {
        _confirmPasswordStrength = 'Strong';
        _confirmPasswordStrengthColor = Colors.green;
      });
    } else if (length == 8) {
      setState(() {
        _confirmPasswordStrength = 'Average';
        _confirmPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 8 && characterTypesCount >= 2) {
      setState(() {
        _confirmPasswordStrength = 'Average';
        _confirmPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 0) {
      setState(() {
        _confirmPasswordStrength = 'Weak';
        _confirmPasswordStrengthColor = Colors.red;
      });
    } else {
      setState(() {
        _confirmPasswordStrength = '';
        _confirmPasswordStrengthColor = Colors.grey;
      });
    }
  }

  bool _validateFields() {
    bool isValid = true;
    _fieldErrors = {
      'firstName': '',
      'lastName': '',
      'cnic': '',
      'phone': '',
      'email': '',
      'password': '',
      'confirmPassword': '',
    };

    if (userNameController.text.isEmpty) {
      _fieldErrors['firstName'] = 'Please enter your first name';
      isValid = false;
    }

    if (lastNameController.text.isEmpty) {
      _fieldErrors['lastName'] = 'Please enter your last name';
      isValid = false;
    }

    if (cnicController.text.isEmpty) {
      _fieldErrors['cnic'] = 'Please enter your User Id';
      isValid = false;
    }

    if (mobileNoController.text.isEmpty) {
      _fieldErrors['phone'] = 'Please enter your phone number';
      isValid = false;
    }

    if (emailController.text.isEmpty) {
      _fieldErrors['email'] = 'Please enter your email';
      isValid = false;
    }

    final password = passwordController.text;
    if (password.isEmpty) {
      _fieldErrors['password'] = 'Please enter a password';
      isValid = false;
    } else {
      bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
      bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
      bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
      bool hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

      if (!(hasUppercase && hasLowercase && hasNumber && hasSpecialChar)) {
        _fieldErrors['password'] = 'Password must be at least 8 characters, (include uppercase, lowercase, number, and a special character)';
        isValid = false;
      }
    }

    if (confirmPasswordController.text.isEmpty) {
      _fieldErrors['confirmPassword'] = 'Please confirm your password';
      isValid = false;
    } else if (confirmPasswordController.text != passwordController.text) {
      _fieldErrors['confirmPassword'] = 'Passwords do not match';
      isValid = false;
    }

    setState(() {});
    return isValid;
  }

  Future<void> _submitForm() async {
    if (_validateFields()) {
      Map<String, String> deviceInfo = await DeviceInfoService.getDeviceInfo();
      final signUpData = SignUpRequestModel(
        cnic: cnicController.text,
        password: passwordController.text,
        mobileNo: mobileNoController.text,
        emailAddress: emailController.text,
        address: "lahore",
        userName: userNameController.text,
        otp: "string",
        otpVia: _otpMethod,
        deviceId: '',
        deviceModel: "string",
        platform: "string",
        osVersion: "string",
        latitude: "string",
        longitude: "string",
        manufacturer: "string",
        operatingSystem: "string",
        webViewVersion: "string",
      );
      _signUpController.signUp(context,signUpData);
    }
  }

  void _initBackgroundVideo() {
    _videoService.initialize();
    _videoReady = _videoService.isReady;
    _videoService.controller.addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    final ready = _videoService.isReady;
    if (ready != _videoReady && mounted) {
      setState(() => _videoReady = ready);
    }
  }

  void _onPasswordChanged() {
    _checkPasswordStrength(passwordController.text);
    if (confirmPasswordController.text.isNotEmpty) {
      _checkConfirmPasswordStrength(confirmPasswordController.text);
    }
  }

  void _onConfirmPasswordChanged() {
    _checkConfirmPasswordStrength(confirmPasswordController.text);
  }

  @override
  void initState() {
    super.initState();
    _initBackgroundVideo();
    passwordController.addListener(_onPasswordChanged);
    confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    passwordController.removeListener(_onPasswordChanged);
    confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    _videoService.controller.removeListener(_onVideoUpdate);
    cnicController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    mobileNoController.dispose();
    emailController.dispose();
    userNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    super.dispose();
  }

  void _clearError(String key) {
    if ((_fieldErrors[key] ?? '').isNotEmpty) {
      setState(() => _fieldErrors[key] = '');
    }
  }

  void _goToLogin() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Get.off(() => LoginScreen());
    }
  }


  Widget _buildStrengthBar(String strength, Color color) {
    final int level = strength == 'Strong' ? 3 : (strength == 'Average' ? 2 : 1);
    return Padding(
      padding: const EdgeInsets.only(left: 4, right: 4, top: 10),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 5),
                    decoration: BoxDecoration(
                      color: i < level ? color : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            strength,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchRow() {
    final match = passwordController.text == confirmPasswordController.text;
    final color = match ? Colors.greenAccent.shade400 : AppColors.softCorelRedColor;
    return Padding(
      padding: const EdgeInsets.only(left: 6, top: 8),
      child: Row(
        children: [
          Icon(match ? Icons.check_circle : Icons.error_outline, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            match ? 'Passwords match' : 'Passwords do not match',
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double gap = 16;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _videoReady
                ? FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoService.controller.value.size.width,
                height: _videoService.controller.value.size.height,
                child: VideoPlayer(_videoService.controller),
              ),
            )
                : Image.asset(
              ImageConstant.welcome,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: Column(
                    children: [
                      AuthFadeSlide(
                        child: AuthHeader(
                          logoPath: ImageConstant.logo,
                          logoSize: 72,
                          title: 'Create Account',
                          subtitle: 'Join us to explore your dream place to live',
                        ),
                      ),
                      const SizedBox(height: 22),
                      AuthGlassCard(
                        delayMs: 120,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AuthSectionLabel('Personal information'),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: AuthTextField(
                                    controller: userNameController,
                                    textInputAction: TextInputAction.next,
                                    hintText: 'First name',
                                    assetIcon: ImageConstant.authUser,
                                    maxLength: 35,
                                    errorText: _fieldErrors['firstName'],
                                    onChanged: (_) => _clearError('firstName'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: AuthTextField(
                                    controller: lastNameController,
                                    textInputAction: TextInputAction.next,
                                    hintText: 'Last name',
                                    assetIcon: ImageConstant.authUser,
                                    maxLength: 35,
                                    errorText: _fieldErrors['lastName'],
                                    onChanged: (_) => _clearError('lastName'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: gap),
                            AuthTextField(
                              controller: dobController,
                              keyboardType: TextInputType.none,
                              hintText: 'Date of birth (optional)',
                              assetIcon: ImageConstant.authCake,
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),

                            const SizedBox(height: 26),
                            const AuthSectionLabel('Account details'),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: cnicController,
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              hintText: 'User ID',
                              assetIcon: ImageConstant.authIdCard,
                              errorText: _fieldErrors['cnic'],
                              onChanged: (_) => _clearError('cnic'),
                            ),
                            const SizedBox(height: gap),
                            AuthTextField(
                              controller: mobileNoController,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                              hintText: 'Mobile number',
                              assetIcon: ImageConstant.authPhone,
                              maxLength: 15,
                              errorText: _fieldErrors['phone'],
                              onChanged: (_) => _clearError('phone'),
                            ),
                            const SizedBox(height: gap),
                            AuthTextField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              hintText: 'abc@gmail.com',
                              assetIcon: ImageConstant.authMail,
                              maxLength: 200,
                              errorText: _fieldErrors['email'],
                              onChanged: (_) => _clearError('email'),
                            ),

                            const SizedBox(height: 26),
                            const AuthSectionLabel('Security'),
                            const SizedBox(height: 14),
                            AuthTextField(
                              controller: passwordController,
                              textInputAction: TextInputAction.next,
                              hintText: 'Password',
                              assetIcon: ImageConstant.authLock,
                              isPassword: true,
                              maxLength: 20,
                              errorText: _fieldErrors['password'],
                              onChanged: (_) => _clearError('password'),
                            ),
                            if (_passwordStrength.isNotEmpty)
                              _buildStrengthBar(_passwordStrength, _passwordStrengthColor),
                            const SizedBox(height: gap),
                            AuthTextField(
                              controller: confirmPasswordController,
                              textInputAction: TextInputAction.done,
                              hintText: 'Confirm password',
                              assetIcon: ImageConstant.authLock,
                              isPassword: true,
                              maxLength: 20,
                              errorText: _fieldErrors['confirmPassword'],
                              onChanged: (_) => _clearError('confirmPassword'),
                            ),
                            if (confirmPasswordController.text.isNotEmpty) _buildMatchRow(),

                            const SizedBox(height: 26),
                            const AuthSectionLabel('Select OTP method'),
                            const SizedBox(height: 14),
                            Obx(() {
                              if (_communicationPolicyController.isLoading.value) {
                                return const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: AppLoader(),
                                  ),
                                );
                              }
                              final method = _communicationPolicyController.otpMethod.value;
                              return Row(
                                children: [
                                  // Already selected + locked: user change nahi kar sakta
                                  IgnorePointer(
                                    child: Checkbox(
                                      value: true,
                                      onChanged: (_) {},
                                      activeColor: Colors.white,
                                      checkColor: AppColors.appColor,
                                      side: const BorderSide(color: Colors.white),
                                    ),
                                  ),
                                  Text(
                                    method.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              );
                            }),

                            const SizedBox(height: 28),
                            Obx(() => AuthPrimaryButton(
                              text: 'Create Account',
                              onPressed: _signUpController.isLoading.value
                                  ? () {}
                                  : _submitForm,
                              isLoading: _signUpController.isLoading.value,
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      AuthFadeSlide(
                        delayMs: 240,
                        child: TextButton(
                          onPressed: _goToLogin,
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already have an account?  ',
                              style: TextStyle(color: Colors.white70, fontSize: 13.5),
                              children: [
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 8,
                  left: 12,
                  child: AuthGlassCircle(
                    size: 40,
                    onTap: _goToLogin,
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final d = pickedDate.day.toString().padLeft(2, '0');
      final m = pickedDate.month.toString().padLeft(2, '0');
      setState(() {
        dobController.text = "$d-$m-${pickedDate.year}";
      });
    }
  }
}