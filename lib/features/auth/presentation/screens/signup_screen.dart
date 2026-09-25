import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/features/auth/presentation/controllers/signup_controller.dart';
import 'package:pakland/features/auth/presentation/controllers/communication_policy_controller.dart';
import 'package:pakland/features/auth/presentation/screens/login_screen.dart';
import 'package:pakland/features/auth/data/models/signup_model.dart';
import 'package:pakland/core/widgets/app_bar.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/custom_fields.dart';
import 'package:pakland/features/auth/presentation/screens/verify_otp_screen.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import 'package:pakland/core/services/get_device_info.dart';

class SignUpNScreen extends StatefulWidget {
  SignUpNScreen({super.key});

  @override
  State<SignUpNScreen> createState() => _SignUpNScreenState();
}

class _SignUpNScreenState extends State<SignUpNScreen> {
  final cnicController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final mobileNoController = TextEditingController();
  final emailController = TextEditingController();
  final userNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();

  String _fullPhoneNumber = '';
  bool _isPhoneValid = false;

  final _signUpController = Get.put(SignUpController());
  final _communicationPolicyController = Get.put(CommunicationPolicyController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _otpMethod = 'sms'; // Default OTP method
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

    // Count how many character types are included
    int characterTypesCount = 0;
    if (hasUppercase) characterTypesCount++;
    if (hasLowercase) characterTypesCount++;
    if (hasNumber) characterTypesCount++;
    if (hasSpecialChar) characterTypesCount++;

    // Determine strength level
    if (length > 8 && characterTypesCount == 4) {
      // Strong: More than 8 characters and includes all character types
      setState(() {
        _passwordStrength = 'Strong';
        _passwordStrengthColor = Colors.green;
      });
    } else if (length == 8) {
      // Average: Exactly 8 characters (always show as Average regardless of character types)
      setState(() {
        _passwordStrength = 'Average';
        _passwordStrengthColor = Colors.orange;
      });
    } else if (length > 8 && characterTypesCount >= 2) {
      // Average: More than 8 characters with at least 2 character types
      setState(() {
        _passwordStrength = 'Average';
        _passwordStrengthColor = Colors.orange;
      });
    } else if (length > 0) {
      // Weak: Less than 8 characters or doesn't meet above criteria
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

    // Count how many character types are included
    int characterTypesCount = 0;
    if (hasUppercase) characterTypesCount++;
    if (hasLowercase) characterTypesCount++;
    if (hasNumber) characterTypesCount++;
    if (hasSpecialChar) characterTypesCount++;

    // Determine strength level
    if (length > 8 && characterTypesCount == 4) {
      // Strong: More than 8 characters and includes all character types
      setState(() {
        _confirmPasswordStrength = 'Strong';
        _confirmPasswordStrengthColor = Colors.green;
      });
    } else if (length == 8) {
      // Average: Exactly 8 characters (always show as Average regardless of character types)
      setState(() {
        _confirmPasswordStrength = 'Average';
        _confirmPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 8 && characterTypesCount >= 2) {
      // Average: More than 8 characters with at least 2 character types
      setState(() {
        _confirmPasswordStrength = 'Average';
        _confirmPasswordStrengthColor = Colors.orange;
      });
    } else if (length > 0) {
      // Weak: Less than 8 characters or doesn't meet above criteria
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
    // else if (!RegExp(r'^\d{5}-\d{7}-\d$').hasMatch(cnicController.text)) {
    //   _fieldErrors['cnic'] = 'Please enter a valid CNIC (XXXXX-XXXXXXX-X)';
    //   isValid = false;
    // }

    if (_fullPhoneNumber.isEmpty) {
      _fieldErrors['phone'] = 'Please enter your phone number';
      isValid = false;
    }
    // else if (!RegExp(r'^92\d{10}$').hasMatch(mobileNoController.text)) {
    //   _fieldErrors['phone'] = 'Please enter a valid 12-digit number starting with 92';
    //   isValid = false;
    // }

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

      // Remove the leading "+" so the number is sent as e.g. "923014230204"
      final String formattedMobileNo = _fullPhoneNumber.startsWith('+')
          ? _fullPhoneNumber.substring(1)
          : _fullPhoneNumber;

      final signUpData = SignUpRequestModel(
        cnic: cnicController.text,
        password: passwordController.text,
        mobileNo: formattedMobileNo,
        emailAddress: emailController.text,
        address: "lahore",
        userName: userNameController.text,
        otp: "string",
        otpVia: _otpMethod,
        // deviceId: deviceInfo['deviceId']!,
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
      _signUpController.signUp(context, signUpData);
    }
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() {
      _checkPasswordStrength(passwordController.text);
      // Also update confirm password strength when password changes
      if (confirmPasswordController.text.isNotEmpty) {
        _checkConfirmPasswordStrength(confirmPasswordController.text);
      }
    });

    confirmPasswordController.addListener(() {
      _checkConfirmPasswordStrength(confirmPasswordController.text);
    });
  }

  @override
  void dispose() {
    passwordController.removeListener(() {});
    confirmPasswordController.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstant.sc),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 15,),
              Image.asset(ImageConstant.logo,height: 120,width: 120,),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width < 400 ? 16.0 : 24.0,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create your account to explore your dream place to live across the whole world',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth < 400 ? 16.0 : 24.0,
                        vertical: 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: userNameController,
                                label: 'First Name*',
                                labelStyle: TextStyle(color: AppColors.whiteBg),
                                hintText: 'First Name',
                                imagePath: 'assets/images/user.png',
                                borderRadius: 30,
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),

                              if (_fieldErrors['firstName']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    _fieldErrors['firstName']!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: lastNameController,
                                label: 'Last Name*',
                                labelStyle: TextStyle(color: AppColors.whiteBg),
                                hintText: 'Last Name',
                                imagePath: 'assets/images/user.png',
                                borderRadius: 30,
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),
                              if (_fieldErrors['lastName']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    _fieldErrors['lastName']!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: cnicController,
                                keyboardType: TextInputType.text,
                                label: 'User Id*',
                                labelStyle: TextStyle(color: AppColors.whiteBg),
                                hintText: 'XXXXX-XXXXXXX-X',
                                imagePath: 'assets/images/cnic.png',
                                borderRadius: 30,
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),

                              if (_fieldErrors['cnic']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    _fieldErrors['cnic']!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mobile No*',
                                style: TextStyle(color: AppColors.whiteBg, fontSize: 14),
                              ),
                              SizedBox(height: 6),
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child:
                                IntlPhoneField(
                                  controller: mobileNoController,
                                  style: TextStyle(fontSize: 14, color: Colors.black),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                    hintText: 'Phone number',
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  dropdownTextStyle: TextStyle(fontSize: 14, color: Colors.black),
                                  flagsButtonPadding: EdgeInsets.symmetric(horizontal: 4),
                                  dropdownIconPosition: IconPosition.trailing,
                                  showDropdownIcon: true,
                                  initialCountryCode: 'PK',
                                  disableLengthCheck: false,
                                  onChanged: (phone) {
                                    setState(() {
                                      _fullPhoneNumber = phone.completeNumber;
                                      _isPhoneValid = true;
                                    });
                                  },
                                  onCountryChanged: (country) {
                                    setState(() {
                                      _isPhoneValid = false;
                                    });
                                  },
                                  invalidNumberMessage: 'Please enter a valid phone number',
                                ),
                              ),
                              if (_fieldErrors['phone']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text(
                                    _fieldErrors['phone']!,
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: emailController,
                                label: 'Email*',
                                labelStyle: TextStyle(color: AppColors.whiteBg),
                                hintText: 'example@domain.com',
                                imagePath: 'assets/images/mail.png',
                                keyboardType: TextInputType.emailAddress,
                                borderRadius: 30,
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),
                              if (_fieldErrors['email']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    _fieldErrors['email']!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          CustomTextField(
                            controller: dobController,
                            label: 'Date of Birth',
                            labelStyle: TextStyle(color: AppColors.whiteBg),
                            hintText: 'DD-MM-YYYY',
                            imagePath: 'assets/images/birthday.png',
                            keyboardType: TextInputType.none,
                            readOnly: true,
                            onTap: () {
                              _selectDate(context);
                            },
                            borderRadius: 30,
                            height: MediaQuery.of(context).size.height * 0.05,
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: passwordController,
                                label: 'Password*',
                                labelStyle: TextStyle(color: AppColors.whiteBg),
                                hintText: 'XXXXXXXX',
                                imagePath: 'assets/images/password.png',
                                obscureText: true,
                                showVisibilityIcon: true,
                                borderRadius: 30,
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),

                              // Password Strength Indicator
                              if (_passwordStrength.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Strength: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70, // Changed for better visibility
                                        ),
                                      ),
                                      Text(
                                        _passwordStrength,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _passwordStrengthColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_fieldErrors['password']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    _fieldErrors['password']!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextField(
                                controller: confirmPasswordController,
                                label: 'Confirm Password*',
                                labelStyle: TextStyle(color: AppColors.whiteBg),
                                hintText: 'XXXXXXXX',
                                imagePath: 'assets/images/password.png',
                                obscureText: true,
                                showVisibilityIcon: true,
                                borderRadius: 30,
                                height: MediaQuery.of(context).size.height * 0.05,
                              ),

                              // Confirm Password Strength Indicator
                              if (_confirmPasswordStrength.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Row(
                                    children: [
                                      Text(
                                        'Strength: ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white70,
                                        ),
                                      ),
                                      Text(
                                        _confirmPasswordStrength,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: _confirmPasswordStrengthColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (confirmPasswordController.text.isNotEmpty)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        passwordController.text == confirmPasswordController.text
                                            ? Icons.check_circle
                                            : Icons.error,
                                        color: passwordController.text == confirmPasswordController.text
                                            ? Colors.green
                                            : Colors.red,
                                        size: 16,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        passwordController.text == confirmPasswordController.text
                                            ? 'Passwords match'
                                            : 'Passwords do not match',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: passwordController.text == confirmPasswordController.text
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_fieldErrors['confirmPassword']?.isNotEmpty ?? false)
                                Padding(
                                  padding: EdgeInsets.only(left: 8, top: 4),
                                  child: Text(
                                    _fieldErrors['confirmPassword']!,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 15),
                          Text(
                            'Select OTP Method:',
                            style: TextStyle(
                              color: AppColors.whiteBg,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Obx(() {
                            // Only one OTP method is ever shown - driven by
                            // /api/MobileAPi/GetCommunicationPolicy's key_code:
                            //   via_WABA / whatsapp -> WHATSAPP
                            //   itel / telenor      -> SMS
                            //   email               -> EMAIL
                            final resolvedMethod = _communicationPolicyController.otpMethod.value;
                            String resolvedValue;
                            String label;
                            if (resolvedMethod == OtpMethodOption.whatsapp) {
                              resolvedValue = 'whatsapp';
                              label = 'WHATSAPP';
                            } else if (resolvedMethod == OtpMethodOption.email) {
                              resolvedValue = 'email';
                              label = 'EMAIL';
                            } else {
                              resolvedValue = 'sms';
                              label = 'SMS';
                            }

                            if (_otpMethod != resolvedValue) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    _otpMethod = resolvedValue;
                                  });
                                }
                              });
                            }

                            if (_communicationPolicyController.isLoading.value) {
                              return const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              );
                            }

                            return Row(
                              children: [
                                Radio<String>(
                                  value: resolvedValue,
                                  groupValue: _otpMethod,
                                  onChanged: (value) {
                                    setState(() {
                                      _otpMethod = value!;
                                    });
                                  },
                                  activeColor: AppColors.whiteBg,
                                  fillColor: MaterialStateProperty.all(Colors.white),
                                ),
                                Text(
                                  label,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            );
                          }),

                          SizedBox(height: 30),
                          Obx(() => Center(
                            child: CustomButton(
                              text: 'Register',
                              onPressed: _submitForm,
                              isLoading: _signUpController.isLoading.value,
                              autoWidth: true,
                              borderRadius: 30,
                            ),
                          )),
                          SizedBox(height: 20),
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>  LoginScreen(),
                                  ),
                                );
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: 'Already have an account? ',
                                  style: const TextStyle(color: Colors.white70), // Changed for better visibility
                                  children: [
                                    TextSpan(
                                      text: 'Sign In',
                                      style: TextStyle(
                                        color: Colors.white, // Changed for better visibility
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
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
      setState(() {
        dobController.text = "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
      });
    }
  }
}