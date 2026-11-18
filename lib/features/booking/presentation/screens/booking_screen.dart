import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pakland/core/widgets/responsive_body.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:get/get.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/core/widgets/custom_buttons.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/company/presentation/controllers/get_projects_controller.dart';

class BookingScreen extends StatefulWidget {
  final String? initialBranchCode;
  final String? initialProject;
  final String? initialBlockNo;
  final String? initialBlock;
  final String? initialPlotSize;
  final String? initialPlotNature;
  final String? initialPlotType;

  const BookingScreen({
    super.key,
    this.initialBranchCode,
    this.initialProject,
    this.initialBlockNo,
    this.initialBlock,
    this.initialPlotSize,
    this.initialPlotNature,
    this.initialPlotType,
  });

  bool get hasPrefill =>
      (initialProject ?? '').isNotEmpty ||
          (initialBranchCode ?? '').isNotEmpty ||
          (initialPlotSize ?? '').isNotEmpty ||
          (initialPlotNature ?? '').isNotEmpty ||
          (initialPlotType ?? '').isNotEmpty;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  static const double _pagePadding = 14;
  static const double _cardPadding = 14;
  static const double _rowGap = 12;
  static const double _colGap = 12;
  static const double _labelHeight = 22;
  static const double _buttonHeight = 50;
  static const double _fieldRadius = 12;
  static const double _bannerHeight = 58;
  static const double _belowCardGap = 14;
  static const int _rowCount = 6;

  static const Color _fieldBorder = Color(0xFFDCE3EC);
  static const Color _fieldFill = Color(0xFFF8FAFC);

  String? selectedProject;
  String? selectedBlock;
  String? selectedPlotNatureCode;
  String? selectedPlotType;
  String? selectedPlotSize;

  bool _submitted = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  // Focus nodes: rebuild ke bawajood focus barqarar rakhte hain
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  final BookingController bookingController = Get.put(BookingController());
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _resetForm();
    _loadUserDetails();
    if (widget.hasPrefill) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyPrefill());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    cityController.dispose();
    contactController.dispose();
    emailController.dispose();
    _nameFocus.dispose();
    _mobileFocus.dispose();
    _cityFocus.dispose();
    _emailFocus.dispose();
    super.dispose();
  }

  void _resetForm() {
    selectedProject = null;
    selectedBlock = null;
    selectedPlotNatureCode = null;
    selectedPlotType = null;
    selectedPlotSize = null;
    _submitted = false;

    nameController.clear();
    cityController.clear();
    contactController.clear();
    emailController.clear();

    bookingController.selectedBranchName.value = "";
    bookingController.selectedBranchCode.value = "";
    bookingController.selectedBlockName.value = "";
    bookingController.selectedBlockCode.value = "";
    bookingController.blocks.clear();
    bookingController.plotSizes.clear();
  }

  Future<void> _loadUserDetails() async {
    try {
      final userId = await _storage.read(key: "user_id");
      if (userId == null || userId.trim().isEmpty) return; // not logged in

      final name = (await _storage.read(key: "user_name") ?? '').trim();
      final mobile = (await _storage.read(key: "mobile_no1") ?? '').trim();
      final email = (await _storage.read(key: "email_no1") ?? '').trim();
      final address = (await _storage.read(key: "address") ?? '').trim();
      final city = _extractCity(address);

      if (!mounted) return;
      setState(() {
        if (nameController.text.isEmpty && name.isNotEmpty) {
          nameController.text = _limit(name, 35);
        }
        if (contactController.text.isEmpty && mobile.isNotEmpty) {
          contactController.text = _limit(mobile, 15);
        }
        if (cityController.text.isEmpty && city.isNotEmpty) {
          cityController.text = _limit(city, 100);
        }
        if (emailController.text.isEmpty && email.isNotEmpty) {
          emailController.text = _limit(email, 200);
        }
      });
    } catch (e) {
      debugPrint('Error loading user details: $e');
    }
  }

  String _extractCity(String address) {
    if (address.isEmpty) return '';
    final parts = address
        .split(RegExp(r'[,\n]'))
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';

    if (parts.length > 1 && _norm(parts.last) == 'pakistan') {
      parts.removeLast();
    }
    return parts.length > 1 ? parts.last : '';
  }

  String _limit(String s, int max) => s.length > max ? s.substring(0, max) : s;

  Future<bool> _waitFor(
      bool Function() condition, {
        int timeoutMs = 8000,
      }) async {
    final stopwatch = Stopwatch()..start();
    while (!condition()) {
      if (!mounted || stopwatch.elapsedMilliseconds > timeoutMs) return false;
      await Future.delayed(const Duration(milliseconds: 100));
    }
    return mounted;
  }

  String _norm(String? s) => (s ?? '').trim().toLowerCase();

  String? _matchIgnoreCase(Iterable<String> options, String? wanted) {
    final w = _norm(wanted);
    if (w.isEmpty) return null;
    for (final o in options) {
      if (_norm(o) == w) return o;
    }
    return null;
  }

  Future<void> _applyPrefill() async {
    final hasProject = (widget.initialProject ?? '').isNotEmpty ||
        (widget.initialBranchCode ?? '').isNotEmpty;

    if (hasProject) {
      final loaded =
      await _waitFor(() => bookingController.branches.length > 1);
      if (!loaded) return;

      String? projectName;
      for (final branch in bookingController.branches.sublist(1)) {
        final name = (branch["brn_name"] ?? "").toString().trim();
        final code = (branch["brn_code"] ?? "").toString().trim();
        if ((_norm(name) == _norm(widget.initialProject) && name.isNotEmpty) ||
            (_norm(code) == _norm(widget.initialBranchCode) &&
                code.isNotEmpty)) {
          projectName = name;
          break;
        }
      }

      if (projectName != null) {
        setState(() {
          selectedProject = projectName;
          selectedBlock = null;
          selectedPlotSize = null;
        });
        bookingController.plotSizes.clear();
        bookingController.selectedBlockName.value = "";
        bookingController.selectedBlockCode.value = "";
        bookingController.selectBranch(projectName);
        if ((widget.initialBlock ?? '').isNotEmpty) {
          final hasBlocks = await _waitFor(
                  () => bookingController.blocks.isNotEmpty,
              timeoutMs: 5000);
          if (hasBlocks && mounted) {
            final blockNames = bookingController.blocks
                .map((b) => (b["block_name"] ?? "").toString());
            final match = _matchIgnoreCase(blockNames, widget.initialBlock);
            if (match != null) {
              setState(() => selectedBlock = match);
              bookingController.plotSizes.clear();
              bookingController.selectBlock(match);
              // give controller a moment to refresh plot sizes for the block
              await Future.delayed(const Duration(milliseconds: 300));
            }
          }
        }
        if ((widget.initialPlotSize ?? '').isNotEmpty) {
          final hasSizes = await _waitFor(
                  () => bookingController.plotSizes.isNotEmpty,
              timeoutMs: 6000);
          if (hasSizes && mounted) {
            final codes = bookingController.plotSizes
                .map((p) => (p["plot_size_code"] ?? "").toString())
                .where((c) => c.isNotEmpty);
            final match = _matchIgnoreCase(codes, widget.initialPlotSize);
            if (match != null) setState(() => selectedPlotSize = match);
          }
        }
      }
    }

    if (!mounted) return;
    final nature = _norm(widget.initialPlotNature);
    if (nature.isNotEmpty) {
      String? mapped;
      if (nature.contains('comm')) {
        mapped = 'Commercial';
      } else if (nature.contains('resi')) {
        mapped = 'Residential';
      }
      if (mapped != null) setState(() => selectedPlotNatureCode = mapped);
    }
    if ((widget.initialPlotType ?? '').isNotEmpty) {
      final hasTypes = await _waitFor(
              () => bookingController.plotTypes.isNotEmpty,
          timeoutMs: 5000);
      if (hasTypes && mounted) {
        for (final type in bookingController.plotTypes) {
          final code = (type["plot_type"] ?? "").toString();
          final desc = (type["plot_type_desc"] ?? "").toString();
          if (_norm(code) == _norm(widget.initialPlotType) ||
              _norm(desc) == _norm(widget.initialPlotType)) {
            setState(() => selectedPlotType = type["plot_type"]);
            break;
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const bool isSmallScreen = false;
    const bool isTablet = false;

    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppHeaderBar(
        title: const Text("Booking Form"),
        centerTitle: true,
      ),
      body: ResponsiveBody(
        child: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageConstant.book),
                opacity: 0.08,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // FIX 1: Keyboard khulne par maxHeight chhoti ho jati hai.
                // Keyboard ki height wapas add kar ke "stable" height nikalte
                // hain, taake showBanner / fieldHeight keyboard se na badlein.
                final double keyboard = MediaQuery.of(context).viewInsets.bottom;
                final double stableMaxHeight = constraints.maxHeight + keyboard;

                final double fixedSpace = (_pagePadding * 2) +
                    (_cardPadding * 2) +
                    (_labelHeight * _rowCount) +
                    (_rowGap * (_rowCount - 1)) +
                    _belowCardGap +
                    _buttonHeight;

                const double maxField = isTablet ? 56.0 : 50.0;
                const double minField = 38.0;

                final double withBanner =
                    (stableMaxHeight - fixedSpace - _bannerHeight - _rowGap) /
                        _rowCount;
                final bool showBanner = withBanner >= 42;

                final double available = stableMaxHeight -
                    fixedSpace -
                    (showBanner ? _bannerHeight + _rowGap : 0);
                final double fieldHeight =
                (available / _rowCount).clamp(minField, maxField).toDouble();

                const double fontSize =
                isSmallScreen ? 12.5 : (isTablet ? 15 : 13.5);

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                        maxWidth: isTablet ? 640 : double.infinity),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.all(_pagePadding),
                      child: Obx(
                              () => _buildForm(fieldHeight, fontSize, showBanner)),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(double h, double fontSize, bool showBanner) {
    final loading = bookingController.isLoading.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // FIX 2: Visibility use kiya hai taake Column ke children ki
        // position kabhi shift na ho (warna card ka state reset hota hai).
        Visibility(
          visible: showBanner,
          child: Column(
            children: [
              _buildBanner(),
              const SizedBox(height: _rowGap),
            ],
          ),
        ),

        Container(
          padding: const EdgeInsets.all(_cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.appColor.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _field(
                label: 'Project',
                isRequired: true,
                child: _dropdown(
                  height: h,
                  fontSize: fontSize,
                  icon: Icons.domain_rounded,
                  hint: loading ? "Loading projects..." : "Select Project",
                  value: selectedProject,
                  hasError: _submitted && selectedProject == null,
                  items: bookingController.branches.length > 1
                      ? bookingController.branches.sublist(1).map((branch) {
                    final name = branch["brn_name"]?.trim() ?? "";
                    return DropdownMenuItem<String>(
                      value: name,
                      child: _ellipsis(name, fontSize),
                    );
                  }).toList()
                      : [],
                  onChanged: loading
                      ? null
                      : (value) {
                    setState(() {
                      selectedProject = value;
                      selectedBlock = null;
                      selectedPlotSize = null;
                    });
                    bookingController.plotSizes.clear();
                    bookingController.selectedBlockName.value = "";
                    bookingController.selectedBlockCode.value = "";
                    bookingController.selectBranch(value ?? "");
                  },
                ),
              ),
              const SizedBox(height: _rowGap),

              _twoColumns(
                _field(
                  label: 'Block/Floor',
                  child: _dropdown(
                    height: h,
                    fontSize: fontSize,
                    icon: Icons.layers_rounded,
                    hint: loading ? "Loading..." : "Select Block",
                    value: selectedBlock,
                    items: bookingController.blocks.map((block) {
                      final name = (block["block_name"] ?? "").toString();
                      return DropdownMenuItem<String>(
                        value: name,
                        child: _ellipsis(name, fontSize),
                      );
                    }).toList(),
                    onChanged: loading
                        ? null
                        : (value) {
                      setState(() => selectedBlock = value);
                      bookingController.selectBlock(value ?? "");
                    },
                  ),
                ),
                _field(
                  label: 'Plot/Unit Size',
                  isRequired: true,
                  child: _dropdown(
                    height: h,
                    fontSize: fontSize,
                    icon: Icons.straighten_rounded,
                    hint: loading ? "Loading..." : "Select Size",
                    value: selectedPlotSize,
                    hasError: _submitted && selectedPlotSize == null,
                    items: bookingController.plotSizes
                        .map((plot) =>
                        (plot["plot_size_code"] ?? "").toString())
                        .where((code) => code.isNotEmpty)
                        .toSet()
                        .map((code) => DropdownMenuItem<String>(
                      value: code,
                      child: _ellipsis(code, fontSize),
                    ))
                        .toList(),
                    onChanged: loading
                        ? null
                        : (value) => setState(() => selectedPlotSize = value),
                  ),
                ),
              ),
              const SizedBox(height: _rowGap),

              _twoColumns(
                _field(
                  label: 'Plot/Unit Nature',
                  isRequired: true,
                  child: _dropdown(
                    height: h,
                    fontSize: fontSize,
                    icon: Icons.category_rounded,
                    hint: "Select Nature",
                    value: selectedPlotNatureCode,
                    hasError: _submitted && selectedPlotNatureCode == null,
                    items: [
                      for (final nature in const ["Commercial", "Residential"])
                        DropdownMenuItem<String>(
                          value: nature,
                          child: _ellipsis(nature, fontSize),
                        ),
                    ],
                    onChanged: (value) =>
                        setState(() => selectedPlotNatureCode = value),
                  ),
                ),
                _field(
                  label: 'Plot/Unit Preference',
                  isRequired: true,
                  child: _dropdown(
                    height: h,
                    fontSize: fontSize,
                    icon: Icons.star_rounded,
                    hint: loading ? "Loading..." : "Select Preference",
                    value: selectedPlotType,
                    hasError: _submitted && selectedPlotType == null,
                    items: bookingController.plotTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type["plot_type"],
                        child: _ellipsis(
                          (type["plot_type_desc"] ?? "").toString(),
                          fontSize,
                        ),
                      );
                    }).toList(),
                    onChanged: loading
                        ? null
                        : (value) => setState(() => selectedPlotType = value),
                  ),
                ),
              ),
              const SizedBox(height: _rowGap),

              _field(
                label: 'Name',
                isRequired: true,
                child: _textField(
                  height: h,
                  fontSize: fontSize,
                  icon: Icons.person_outline_rounded,
                  controller: nameController,
                  focusNode: _nameFocus,
                  hint: 'Add Name',
                  maxLength: 35,
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  hasError: _submitted && nameController.text.trim().isEmpty,
                ),
              ),
              const SizedBox(height: _rowGap),

              _twoColumns(
                _field(
                  label: 'Mobile No.',
                  isRequired: true,
                  child: _textField(
                    height: h,
                    fontSize: fontSize,
                    icon: Icons.phone_android_rounded,
                    controller: contactController,
                    focusNode: _mobileFocus,
                    hint: 'Add Mobile No.',
                    maxLength: 15,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    hasError:
                    _submitted && contactController.text.trim().isEmpty,
                  ),
                ),
                _field(
                  label: 'City',
                  child: _textField(
                    height: h,
                    fontSize: fontSize,
                    icon: Icons.location_city_rounded,
                    controller: cityController,
                    focusNode: _cityFocus,
                    hint: 'Add City',
                    maxLength: 100,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: _rowGap),

              _field(
                label: 'Email',
                child: _textField(
                  height: h,
                  fontSize: fontSize,
                  icon: Icons.mail_outline_rounded,
                  controller: emailController,
                  focusNode: _emailFocus,
                  hint: 'Add Email',
                  maxLength: 200,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  isEmail: true,
                  hasError: _submitted && !_isEmailValidOrEmpty(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: _belowCardGap),

        SizedBox(
          height: _buttonHeight,
          child: CustomButton(
            text: 'Submit',
            onPressed: _submitForm,
            isLoading: loading,
            borderRadius: _fieldRadius + 2,
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: _bannerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, AppColors.lightAppColor],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_work_rounded,
                color: Colors.white, size: 21),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Reserve Your Plot / Unit",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Our sales team will contact you shortly.",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoColumns(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: _colGap),
        Expanded(child: right),
      ],
    );
  }

  Widget _field({
    required String label,
    required Widget child,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: _labelHeight,
          child: Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 5),
            child: Text.rich(
              TextSpan(
                text: label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2B3A42),
                ),
                children: [
                  if (isRequired)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.iconColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        child,
      ],
    );
  }

  Widget _ellipsis(String text, double fontSize) => Text(
    text,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(fontSize: fontSize, color: Colors.black87),
  );

  BoxDecoration _boxDecoration({bool hasError = false, bool filled = false}) =>
      BoxDecoration(
        borderRadius: BorderRadius.circular(_fieldRadius),
        color: _fieldFill,
        border: Border.all(
          color: hasError
              ? Colors.red.shade400
              : (filled ? AppColors.appColor.withOpacity(0.6) : _fieldBorder),
          width: hasError ? 1.4 : 1,
        ),
      );

  Widget _dropdown({
    required double height,
    required double fontSize,
    required IconData icon,
    required String hint,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?>? onChanged,
    bool hasError = false,
  }) {
    final bool disabled = onChanged == null;

    // Safety: DropdownButton asserts if value isn't in items.
    final String? safeValue =
    (value != null && items.any((i) => i.value == value)) ? value : null;

    Widget withIcon(Widget child, Color color) => Row(
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 8),
        Expanded(child: child),
      ],
    );

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: withIcon(
          Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: fontSize,
              color: disabled ? Colors.black38 : Colors.black45,
            ),
          ),
          Colors.grey.shade500,
        ),
        selectedItemBuilder: (context) => items
            .map((item) => withIcon(item.child, AppColors.appColor))
            .toList(),
        items: items,
        value: safeValue,
        onChanged: onChanged,
        buttonStyleData: ButtonStyleData(
          height: height,
          width: double.infinity,
          padding: const EdgeInsets.only(left: 12, right: 6),
          decoration:
          _boxDecoration(hasError: hasError, filled: safeValue != null),
          elevation: 0,
        ),
        iconStyleData: IconStyleData(
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconSize: 22,
          iconEnabledColor: AppColors.appColor,
          iconDisabledColor: Colors.grey.shade400,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_fieldRadius),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          offset: const Offset(0, -4),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(5),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }

  Widget _textField({
    required double height,
    required double fontSize,
    required IconData icon,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required int maxLength,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool isEmail = false,
    bool hasError = false,
  }) {
    final String text = controller.text;
    final bool emailValid =
        isEmail && text.isNotEmpty && _emailRegex.hasMatch(text);
    final bool emailInvalid =
        isEmail && text.isNotEmpty && !_emailRegex.hasMatch(text);
    hasError = hasError || emailInvalid;

    final double verticalPad = ((height - 22) / 2).clamp(4.0, 14.0).toDouble();

    OutlineInputBorder border(Color color, double width) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );

    final Color idle = hasError ? Colors.red.shade400 : _fieldBorder;

    return SizedBox(
      height: height,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textCapitalization: textCapitalization,
        maxLength: maxLength,
        maxLines: 1,
        textAlignVertical: TextAlignVertical.center,
        cursorColor: AppColors.appColor,
        onChanged: (_) {
          if (_submitted || isEmail) setState(() {});
        },
        style: TextStyle(color: Colors.black87, fontSize: fontSize),
        decoration: InputDecoration(
          isDense: true,
          counterText: '',
          prefixIcon: Icon(icon, size: 17, color: Colors.grey.shade500),
          prefixIconConstraints:
          const BoxConstraints(minWidth: 38, minHeight: 20),
          suffixIcon: emailValid
              ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
              : emailInvalid
              ? const Icon(Icons.error, color: Colors.red, size: 20)
              : null,
          hintText: hint,
          hintMaxLines: 1,
          hintStyle: TextStyle(
            color: Colors.black38,
            fontSize: fontSize,
            overflow: TextOverflow.ellipsis,
          ),
          filled: true,
          fillColor: _fieldFill,
          contentPadding: EdgeInsets.only(
            left: 0,
            right: 12,
            top: verticalPad,
            bottom: verticalPad,
          ),
          border: border(idle, hasError ? 1.4 : 1),
          enabledBorder: border(idle, hasError ? 1.4 : 1),
          focusedBorder: border(
            hasError ? Colors.red.shade400 : AppColors.appColor,
            1.6,
          ),
        ),
      ),
    );
  }

  static final RegExp _emailRegex =
  RegExp(r'^[\w\.\-]+@[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}$');

  bool _isEmailValidOrEmpty() {
    final email = emailController.text;
    return email.isEmpty || _emailRegex.hasMatch(email);
  }

  void _submitForm() {
    if (selectedProject == null ||
        selectedPlotType == null ||
        selectedPlotSize == null ||
        selectedPlotNatureCode == null ||
        nameController.text.isEmpty ||
        contactController.text.isEmpty) {
      setState(() => _submitted = true);
      showTopSnackBar(
        context,
        title: "Alert",
        "Please fill all required fields",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    if (!_isEmailValidOrEmpty()) {
      setState(() => _submitted = true);
      showTopSnackBar(
        context,
        title: "Alert",
        "Please enter a valid email address",
        Colors.red.withOpacity(0.7),
        icon: Icons.warning,
      );
      return;
    }

    bookingController.submitBooking(
      brnCode: bookingController.selectedBranchCode.value,
      selectedProject: selectedProject ?? "",
      contactName: nameController.text.trim(),
      contactNo: contactController.text.trim(),
      plotSizeCode: selectedPlotSize ?? "",
      blockNo: bookingController.selectedBlockCode.value,
      email: emailController.text.trim(),
      plotNature: selectedPlotNatureCode ?? "",
      plotType: selectedPlotType ?? "",
      context: context,
    );
  }
}