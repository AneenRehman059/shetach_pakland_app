import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:pakland/core/constants/image_constant.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/billing/presentation/screens/online_payments_screen.dart';
import 'package:pakland/features/billing/presentation/screens/pay_now_screen.dart';
import 'package:pakland/features/billing/presentation/screens/user_files_screen.dart';
import 'package:pakland/features/billing/presentation/screens/view_bill_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pakland/core/widgets/bottom_app_bar.dart';
import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/files_info_card_screen.dart';
import 'package:pakland/features/company/presentation/controllers/get_company_controller.dart';
import 'package:pakland/features/billing/presentation/controllers/pay_online_controller.dart';
import 'package:pakland/core/widgets/toast_message.dart';
import 'package:pakland/features/customer_portal/presentation/screens/customer_portal_screen.dart';
import 'package:pakland/core/utils/screen_helper.dart';
import 'package:pakland/features/billing/presentation/screens/get_account_statement_screen.dart';
import 'package:pakland/features/billing/presentation/screens/get_receipt_statement_screen.dart';
import 'package:pakland/features/profile/data/models/client_detail_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PayOnlineScreen extends StatefulWidget {
  final String brnCode;
  final String brnName;
  const PayOnlineScreen({
    super.key,
    required this.brnCode,
    required this.brnName,
  });

  @override
  State<PayOnlineScreen> createState() => _PayOnlineScreenState();
}

class _PayOnlineScreenState extends State<PayOnlineScreen> {
  final _storage = const FlutterSecureStorage();
  String? userId;
  late final PayOnlineController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<PayOnlineController>()) {
      controller = Get.find<PayOnlineController>();
    } else {
      controller = Get.put(PayOnlineController());
    }
    _loadUserId();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserId() async {
    final id = await _storage.read(key: "user_id");
    if (id != null && id.isNotEmpty) {
      setState(() {
        userId = id;
      });

      controller.fetchClientDetails(
        username: id,
        brnCode: "000000",
        blockNo: 'a',
        plotNo: '2',
      );
    } else {
      showTopSnackBar(
          context,
          title: "Alert",
          "User ID not found",
          Colors.red.withOpacity(0.7),
          icon: Icons.warning
      );
    }
  }

  static List<_VideoItem> _videos = [
    _VideoItem(
      videoUrl: 'https://www.youtube.com/watch?v=2Fa2HC8X3lc',
      thumbAsset: ImageConstant.thumb1,
    ),
    _VideoItem(
      videoUrl: 'https://www.youtube.com/watch?v=ZZBPJOSGsLU',
      thumbAsset: ImageConstant.thumb2,
    ),
    _VideoItem(
      videoUrl: 'https://www.youtube.com/watch?v=1h0Xm6UHofE',
      thumbAsset: ImageConstant.thumb3,
    ),
  ];

  _VideoItem _videoForIndex(int index) => _videos[index % _videos.length];

  String? _youTubeThumbUrl(String url) {
    final m = RegExp(r'(?:v=|youtu\.be/|embed/|shorts/|live/)([A-Za-z0-9_-]{11})')
        .firstMatch(url);
    if (m == null) return null;
    return 'https://img.youtube.com/vi/${m.group(1)}/hqdefault.jpg';
  }

  Widget _buildVideoThumb(_VideoItem video) {
    final fallback = Image.asset('assets/images/thumb1.png',
        fit: BoxFit.fill, width: double.infinity);

    if (video.thumbAsset != null) {
      return Image.asset(video.thumbAsset!,
          fit: BoxFit.fill,
          width: double.infinity,
          errorBuilder: (_, __, ___) => fallback);
    }

    final thumb = _youTubeThumbUrl(video.videoUrl);
    if (thumb == null) return fallback;
    return Image.network(
      thumb,
      key: ValueKey(thumb),
      fit: BoxFit.fill,
      width: double.infinity,
      errorBuilder: (_, __, ___) => fallback,
      loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
    );
  }

  Future<void> _launchYouTubeVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final padding = mediaQuery.padding;
    final textScaleFactor = mediaQuery.textScaleFactor;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: AppColors.appColor,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState(size, padding, isTV);
          }

          if (controller.clientDetailModel.value == null ||
              controller.clientDetailModel.value!.obj.clientDetailList == null ||
              controller.clientDetailModel.value!.obj.clientDetailList!.isEmpty) {
            return _buildNoDataState(size, padding, isTV);
          }

          return isTV
              ? _buildTVContent(size, padding, mediaQuery)
              : _buildContent(size, padding, textScaleFactor, mediaQuery);
        }),
      ),
    );
  }

  Widget _buildLoadingState(Size size, EdgeInsets padding, bool isTV) {
    if (isTV) {
      return Column(
        children: [
          _buildTVAppBar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/images/loading.json', width: 180, height: 180),
                  const SizedBox(height: 16),
                  const Text(
                    'Fetching your account…',
                    style: TextStyle(color: Colors.black45, fontWeight: FontWeight.w500, fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        _buildHeader(size, padding),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                'assets/images/loading.json',
                width: 150,
                height: 150,
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Fetching your account…',
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.w500,
                  fontSize: size.width * 0.033,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNoDataState(Size size, EdgeInsets padding, bool isTV) {
    if (isTV) {
      return Column(
        children: [
          _buildTVAppBar(),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          AppColors.appColor.withOpacity(0.12),
                          AppColors.appColor.withOpacity(0.02),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.folder_off_outlined, size: 56, color: AppColors.appColor),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No records found',
                    style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800, fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We couldn\'t find any files linked to your account.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black45, fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        _buildHeader(size, padding),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(size.width * 0.06),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.appColor.withOpacity(0.12),
                      AppColors.appColor.withOpacity(0.02),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_off_outlined,
                  size: size.width * 0.14,
                  color: AppColors.appColor,
                ),
              ),
              SizedBox(height: size.height * 0.024),
              Text(
                'No records found',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w800,
                  fontSize: size.width * 0.046,
                ),
              ),
              SizedBox(height: size.height * 0.008),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.14),
                child: Text(
                  'We couldn\'t find any files linked to your account.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black45,
                    fontSize: size.width * 0.033,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTVAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, Color.lerp(AppColors.appColor, Colors.black, 0.28)!],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.appColor.withOpacity(0.35), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: SafeArea(
        bottom: false,
        child: Row(children: [
          _TVIconBtn(icon: Icons.arrow_back, onTap: () => Get.to(CustomerPortalScreen())),
          const Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Pay Online',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2),
                Text(
                  'Manage & settle your dues in one tap',
                  style: TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _TVIconBtn(icon: Icons.home_rounded, onTap: () => Get.offAll(() => MainWrapper(initialIndex: 0))),
        ]),
      ),
    );
  }

  Widget _buildTVContent(Size size, EdgeInsets padding, MediaQueryData mediaQuery) {
    final clientDetails = controller.clientDetailModel.value!.obj.clientDetailList!;

    return Column(children: [
      _buildTVAppBar(),
      Expanded(
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: clientDetails.asMap().entries.map((entry) {
                final index = entry.key;
                final client = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Expanded(flex: 5, child: _buildProfileCardTV(client)),
                        const SizedBox(width: 20),
                        Expanded(flex: 5, child: _buildInfoCardsTV(client)),
                      ]),
                      const SizedBox(height: 14),
                      _buildActionButtonsTV(client, mediaQuery),
                      const SizedBox(height: 14),
                      _buildVideoPreviewTV(index),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    ]);
  }

  Color _getStatusColorTV(String? statusCode) => _getStatusColor(statusCode);

  String? _googleDriveDirectUrl(String url) {
    if (!url.contains('drive.google.com') &&
        !url.contains('docs.google.com') &&
        !url.contains('googleusercontent.com')) {
      return null;
    }
    final match = RegExp(r'/d/([a-zA-Z0-9_-]+)').firstMatch(url) ??
        RegExp(r'[?&]id=([a-zA-Z0-9_-]+)').firstMatch(url);
    if (match == null) return null;
    return 'https://drive.google.com/thumbnail?id=${match.group(1)}&sz=w400';
  }

  String? _resolveClientImageUrl(ClientDetail client) {
    final candidates = [client.imagePath, client.image];
    for (final c in candidates) {
      final raw = c?.toString().trim() ?? '';
      if (raw.isEmpty || raw.toLowerCase() == 'null') continue;

      final drive = _googleDriveDirectUrl(raw);
      if (drive != null) return drive;

      if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;

      var path = raw.replaceAll('\\', '/');
      if (path.startsWith('~')) path = path.substring(1);
      return '${ApiConstants.baseUrl}${path.startsWith('/') ? path : '/$path'}';
    }
    debugPrint('PayOnline: image nahi mila -> imagePath=${client.imagePath}, '
        'image=${client.image}');
    return null;
  }

  Widget _buildClientThumb(ClientDetail client,
      {required double dimension, required double radius, required double leftGap}) {
    final url = _resolveClientImageUrl(client);

    final placeholder = Center(
      child: Icon(Icons.person_outline,
          color: AppColors.appColor.withOpacity(0.5), size: dimension * 0.5),
    );

    return Padding(
      padding: EdgeInsets.only(left: leftGap),
      child: Container(
        width: dimension,
        height: dimension,

        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius - 2),
          child: url == null
              ? placeholder
              : Image.network(
            url,
            fit: BoxFit.fill,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : Center(
              child: SizedBox(
                width: 16,
                height: 16,
                child: AppLoader(),
              ),
            ),
            errorBuilder: (context, error, stackTrace) {
              debugPrint('PayOnline: image load fail $url -> $error');
              return placeholder;
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCardTV(ClientDetail client) {
    final statusText = _getRegistrationStatusText(client.registrationStatus);
    final statusColor = _getStatusColorTV(client.registrationStatus);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.88)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.appColor.withOpacity(0.28), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            child: Image.asset(ImageConstant.logo),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.brnName ?? widget.brnName,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: Colors.white, letterSpacing: 0.2),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          _buildClientThumb(client, dimension: 64, radius: 14, leftGap: 14),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Column(children: [
            _buildFormRowTV('Customer Name', client.memberName ?? ''),
            Divider(height: 12, color: Colors.white.withOpacity(0.12)),
            _buildRegNoRowTV(client.registrationNo ?? '', statusText, statusColor),
            Divider(height: 12, color: Colors.white.withOpacity(0.12)),
            _buildUnitSizeRowTV(client),
          ]),
        ),
      ]),
    );
  }

  String _cleanText(dynamic v) {
    final t = v?.toString().trim() ?? '';
    return t.toLowerCase() == 'null' ? '' : t;
  }

  Widget _buildStatusChip(
      String text,
      Color color, {
        required double fontSize,
        required double dot,
        required double hPad,
        required double vPad,
        required double radius,
        required double gap,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: dot,
          height: dot,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color.withOpacity(0.6), blurRadius: 4)],
          ),
        ),
        SizedBox(width: gap),
        Text(
          text,
          maxLines: 1,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
      ]),
    );
  }

  Widget _buildRegNoRowTV(String value, String statusText, Color statusColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Text('Reg No.',
            style: TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildStatusChip(statusText, statusColor,
            fontSize: 13, dot: 8, hPad: 10, vPad: 3, radius: 14, gap: 7),
      ]),
    );
  }

  Widget _buildRegNoRow(String value, String statusText, Color statusColor, Size size) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * 0.003),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Text(
          'Reg No.',
          style: TextStyle(
            fontSize: size.width * 0.032,
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(width: size.width * 0.02),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                fontSize: size.width * 0.034,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: size.width * 0.02),
        _buildStatusChip(
          statusText,
          statusColor,
          fontSize: size.width * 0.028,
          dot: size.width * 0.016,
          hPad: size.width * 0.024,
          vPad: size.height * 0.003,
          radius: size.width * 0.03,
          gap: size.width * 0.014,
        ),
      ]),
    );
  }

  String _blockUnitText(ClientDetail client) {
    final block = _cleanText(client.blockNo);
    final unit = _cleanText(client.unit);
    return [block, unit].where((e) => e.isNotEmpty).join(' & ');
  }

  Widget _unitInfoItem(String label, String value, TextStyle labelStyle,
      TextStyle valueStyle, double gap) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: label, style: labelStyle),
        WidgetSpan(child: SizedBox(width: gap)),
        TextSpan(text: value, style: valueStyle),
      ]),
    );
  }

  Widget _unitInfoRow(List<Widget> items, double itemGap, EdgeInsets padding) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: itemGap,
          runSpacing: 2,
          children: items,
        ),
      ),
    );
  }

  Widget _buildUnitSizeRowTV(ClientDetail client) {
    const labelStyle =
    TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w600);
    const valueStyle =
    TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white);

    return _unitInfoRow(
      [
        _unitInfoItem('Block & Unit No', _blockUnitText(client), labelStyle, valueStyle, 10),
        _unitInfoItem('Unit Size', _cleanText(client.paymentCode), labelStyle, valueStyle, 10),
      ],
      20,
      const EdgeInsets.symmetric(vertical: 4),
    );
  }

  Widget _buildUnitSizeRow(ClientDetail client, Size size) {
    final labelStyle = TextStyle(
      fontSize: size.width * 0.032,
      color: Colors.white70,
      fontWeight: FontWeight.w600,
    );
    final valueStyle = TextStyle(
      fontSize: size.width * 0.034,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );
    final gap = size.width * 0.015;

    return _unitInfoRow(
      [
        _unitInfoItem('Block & Unit No:', _blockUnitText(client), labelStyle, valueStyle, gap),
        _unitInfoItem('Unit Size:', _cleanText(client.paymentCode), labelStyle, valueStyle, gap),
      ],
      size.width * 0.03,
      EdgeInsets.symmetric(vertical: size.height * 0.003),
    );
  }

  Widget _buildFormRowTV(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        SizedBox(width: 170, child: Text(label, style: const TextStyle(fontSize: 15, color: Colors.white70, fontWeight: FontWeight.w600))),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ]),
    );
  }

  Widget _buildInfoCardsTV(ClientDetail client) {
    final totalOutstanding = _calculateTotalOutstanding(client);
    final totalOverDue = _calculateTotalOverDue(client);
    final totalReceived = _calculateTotalReceived(client);
    final totalAmount = double.tryParse(client.totDueAmt) ?? 0;
    const tvSize = Size(300, 516);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: InfoCard(title: 'Tot Price', amount: 'Rs. ${_formatAmount(totalAmount)}/-', percent: 100, size: tvSize)),
          Expanded(child: InfoCard(title: 'Tot Received', amount: 'Rs.${_formatAmount(totalReceived)}/-', percent: _calculateTotalReceivedPercent(client, totalReceived), size: tvSize)),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: InfoCard(title: 'Tot Outstanding', amount: 'Rs.${_formatAmount(totalOutstanding)}/-', percent: _calculateTotalOSPercent(client, totalOutstanding), size: tvSize)),
          Expanded(child: InfoCard(title: 'Tot Overdue', amount: 'Rs.${_formatAmount(totalOverDue)}/-', percent: _calculateTotalOverDuePercent(client, totalOverDue), size: tvSize)),
        ]),
      ]),
    );
  }

  Widget _buildActionButtonsTV(ClientDetail client, MediaQueryData mediaQuery) {
    final companyController = Get.find<CompanyController>();
    return Row(children: [
      Expanded(child: _TVFocusButton(label: 'View Statement', assetIcon: ImageConstant.statemnt, isPrimary: true, onTap: () {
        if (_canNavigateToStatement(client, companyController)) {
          Get.to(() => AccountStatementScreen(registrationNo: client.registrationNo ?? '', brnCode: client.brnCode ?? '', plotType: client.plotType ?? 'Normal', idNo: client.cnic ?? ''));
        } else {
          _showCloseStatusAlert(context, client);
        }
      })),
      const SizedBox(width: 16),
      Expanded(child: _TVFocusButton(label: 'View Receipt', assetIcon: ImageConstant.receipt, isPrimary: true, onTap: () {
        Get.to(() => ReceiptTableView(registrationNo: client.registrationNo ?? '', brnCode: client.brnCode ?? '', plotType: client.plotType ?? 'Normal', memberName: client.memberName ?? '', idNo: client.cnic));
      })),
      const SizedBox(width: 16),
      Expanded(
        child: _TVFocusButton(
          label: 'Pay Now',
          assetIcon: ImageConstant.pay_now,
          isPrimary: true,
          onTap: () {
            if (!_canNavigateToStatement(client, companyController)) {
              _showCloseStatusAlert(context, client);
              return;
            }
            final totalOutstanding = _calculateTotalOutstanding(client);
            final totalOverDue = _calculateTotalOverDue(client);
            Get.to(() => PaymentScreen(
              registrationNo: client.registrationNo ?? '',
              paymentCode: client.paymentCode ?? '',
              brnCode: client.brnCode ?? '',
              brnName: client.brnName ?? '',
              memberName: client.memberName ?? '',
              overDueAmount: totalOverDue,
              totalOutstanding: totalOutstanding,
              formattedTotalOutstanding: _formatAmount(totalOutstanding),
              formattedTotalOverDue: _formatAmount(totalOverDue),
              clientId: client.cnic,
              blockNo: _cleanText(client.blockNo),
              unitNo: _cleanText(client.unit),
            ));
          },
        ),
      ),
    ]);
  }

  Widget _buildVideoPreviewTV(int index) {
    final video = _videoForIndex(index);
    return _TVFocusContainer(
      onTap: () => _launchYouTubeVideo(video.videoUrl),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 14, offset: const Offset(0, 6))],
        ),
        child: Stack(alignment: Alignment.center, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: _buildVideoThumb(video),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.92),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10)],
            ),
            padding: const EdgeInsets.all(20),
            child: Icon(Icons.play_arrow_rounded, color: AppColors.appColor, size: 56),
          ),
          Positioned(
            bottom: 16,
            left: 20,
            child: Text(
              'Watch Tutorial',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18, shadows: const [Shadow(color: Colors.black45, blurRadius: 4)]),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildContent(Size size, EdgeInsets padding, double textScaleFactor, MediaQueryData mediaQuery) {
    final clientDetails = controller.clientDetailModel.value!.obj.clientDetailList!;

    return Stack(
      children: [
        _buildHeader(size, padding),

        Padding(
          padding: EdgeInsets.only(
            top: size.height * 0.22 - size.height * 0.1,
            bottom: padding.bottom + size.height * 0.02,
          ),
          child: ListView.builder(
            padding: EdgeInsets.only(
              top: size.height * 0.01,
              bottom: padding.bottom + size.height * 0.02,
            ),
            itemCount: clientDetails.length,
            itemBuilder: (context, index) {
              final client = clientDetails[index];
              final isFirstItem = index == 0;

              return _AnimatedEntrance(
                delay: Duration(milliseconds: 60 * index),
                child: Column(
                  children: [
                    SizedBox(height: isFirstItem ? size.height * 0.008 : size.height * 0.016),
                    _buildProfileCard(client, size),
                    _buildInfoCards(client, size),
                    SizedBox(height: size.height * 0.01),
                    _buildActionButtons(client, mediaQuery),
                    SizedBox(height: size.height * 0.012),
                    _buildVideoPreview(size, index),
                    SizedBox(height: size.height * 0.03),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(Size size, EdgeInsets padding) {
    return Container(
      height: size.height * 0.20,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.appColor,
            AppColors.appColor.withOpacity(0.82),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -size.width * 0.2,
            right: -size.width * 0.15,
            child: Container(
              width: size.width * 0.55,
              height: size.width * 0.55,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -size.width * 0.25,
            left: -size.width * 0.1,
            child: Container(
              width: size.width * 0.4,
              height: size.width * 0.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: size.width * 0.03, bottom: size.width * 0.07),
                    child: _buildHeaderIconButton(
                      icon: Icons.arrow_back,
                      size: size,
                      onPressed: () => Get.to(CustomerPortalScreen()),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: size.width * 0.07),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Pay Online',
                          style: TextStyle(
                            fontSize: size.width * 0.054,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: size.height * 0.003),
                        Text(
                          'Manage & settle your dues in one tap',
                          style: TextStyle(
                            fontSize: size.width * 0.028,
                            color: Colors.white.withOpacity(0.75),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: size.height * 0.001),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: EdgeInsets.only(right: size.width * 0.03, bottom: size.width * 0.07),
                    child: _buildHeaderIconButton(
                      icon: Icons.home_rounded,
                      size: size,
                      onPressed: () {
                        Get.offAll(() => MainWrapper(initialIndex: 0));
                      },
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

  Widget _buildHeaderIconButton({
    required IconData icon,
    required Size size,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.white.withOpacity(0.16),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.022),
          child: Icon(icon, color: Colors.white, size: size.width * 0.055),
        ),
      ),
    );
  }

  Widget _buildProfileCard(ClientDetail client, Size size) {
    final statusText = _getRegistrationStatusText(client.registrationStatus);
    final statusColor = _getStatusColor(client.registrationStatus);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: size.width * 0.04),
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.appColor,
            AppColors.appColor.withOpacity(0.88),
          ],
        ),
        borderRadius: BorderRadius.circular(size.width * 0.045),
        boxShadow: [
          BoxShadow(
            color: AppColors.appColor.withOpacity(0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: size.width * 0.16,
                height: size.width * 0.16,
                padding: EdgeInsets.all(size.width * 0.022),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(ImageConstant.logo),
              ),
              SizedBox(width: size.width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.brnName ?? widget.brnName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: size.width * 0.045,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              _buildClientThumb(client,
                  dimension: size.width * 0.15,
                  radius: size.width * 0.03,
                  leftGap: size.width * 0.025),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.032,
              vertical: size.height * 0.006,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(size.width * 0.035),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
            ),
            child: Column(
              children: [
                _buildFormRow('Customer Name:', client.memberName ?? '', size),
                Divider(height: size.height * 0.01, color: Colors.white.withOpacity(0.12)),
                _buildRegNoRow(client.registrationNo ?? '', statusText, statusColor, size),
                Divider(height: size.height * 0.01, color: Colors.white.withOpacity(0.12)),
                _buildUnitSizeRow(client, size),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? statusCode) {
    switch (statusCode?.toUpperCase()) {
      case 'N':
        return const Color(0xFF2ECC71);
      case 'L':
      case 'NLC':
        return const Color(0xFFF39C12);
      case 'C':
      case 'NC':
        return const Color(0xFFE74C3C);
      case 'F':
      case 'R':
        return const Color(0xFF9B59B6);
      default:
        return const Color(0xFFBDC3C7);
    }
  }

  Widget _buildFormRow(String label, String value, Size size) => Padding(
    padding: EdgeInsets.symmetric(vertical: size.height * 0.003),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size.width * 0.3,
          child: Text(
            label,
            style: TextStyle(
              fontSize: size.width * 0.032,
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: size.width * 0.034,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  Widget _sectionLabel({
    required String title,
    required IconData icon,
    required Size size,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: size.width * 0.05,
        bottom: size.height * 0.006,
      ),
      child: Row(
        children: [
          Icon(icon, size: size.width * 0.04, color: AppColors.appColor),
          SizedBox(width: size.width * 0.018),
          Text(
            title,
            style: TextStyle(
              fontSize: size.width * 0.034,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCards(ClientDetail client, Size size) {
    final totalOutstanding = _calculateTotalOutstanding(client);
    final totalOverDue = _calculateTotalOverDue(client);
    final totalReceived = _calculateTotalReceived(client);
    final totalAmount = double.tryParse(client.totDueAmt) ?? 0;

    final totalReceivedPercent = _calculateTotalReceivedPercent(client, totalReceived);
    final totalOSPercent = _calculateTotalOSPercent(client, totalOutstanding);
    final totalOverDuePercent = _calculateTotalOverDuePercent(client, totalOverDue);
    final totalPercent = 100;

    final cardSize = Size(size.width, size.height * 0.86);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.01),
        _sectionLabel(title: 'Account Summary', icon: Icons.pie_chart_outline_rounded, size: size),
        Container(
          margin: EdgeInsets.symmetric(horizontal: size.width * 0.015),
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.01,
            horizontal: size.width * 0.006,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(size.width * 0.04),
            border: Border.all(color: Colors.black.withOpacity(0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InfoCard(
                title: 'Tot Price',
                amount: 'Rs. ${_formatAmount(totalAmount)}/-',
                percent: totalPercent,
                size: cardSize,
              ),
              InfoCard(
                title: 'Tot Received',
                amount: 'Rs.${_formatAmount(totalReceived)}/-',
                percent: totalReceivedPercent,
                size: cardSize,
              ),
              InfoCard(
                title: 'Tot Outstanding',
                amount: 'Rs.${_formatAmount(totalOutstanding)}/-',
                percent: totalOSPercent,
                size: cardSize,
              ),
              InfoCard(
                title: 'Tot Overdue',
                amount: 'Rs.${_formatAmount(totalOverDue)}/-',
                percent: totalOverDuePercent,
                size: cardSize,
              ),
            ],
          ),
        ),
      ],
    );
  }

  double _calculateTotalOutstanding(ClientDetail client) {
    try {
      final totDueAmt = double.tryParse(client.totDueAmt) ?? 0;
      final totRecievedAmt = double.tryParse(client.totRecievedAmt) ?? 0;
      final totRebatAmt = double.tryParse(client.totRebatAmt) ?? 0;

      return totDueAmt - totRecievedAmt - totRebatAmt;
    } catch (e) {
      return 0;
    }
  }

  double _calculateTotalOverDue(ClientDetail client) {
    try {
      return client.overDueAmount.toDouble();
    } catch (e) {
      return 0;
    }
  }

  double _calculateTotalReceived(ClientDetail client) {
    try {
      final totRecievedAmt = double.tryParse(client.totRecievedAmt) ?? 0;
      return totRecievedAmt;
    } catch (e) {
      return 0;
    }
  }

  int _calculateTotalReceivedPercent(ClientDetail client, double totalReceived) {
    try {
      final netPrice = client.netPrice.toDouble();
      final osAmount = client.osAmount.toDouble();

      if (netPrice + osAmount == 0) return 0;

      final percent = (totalReceived / (netPrice + osAmount)) * 100;
      return percent.round().clamp(0, 100);
    } catch (e) {
      return 0;
    }
  }

  int _calculateTotalOSPercent(ClientDetail client, double totalOutstanding) {
    try {
      final dueAmt = double.tryParse(client.totDueAmt) ?? 0;

      if (dueAmt == 0) return 0;

      final percent = (totalOutstanding / dueAmt) * 100;
      return percent.round().clamp(0, 100);
    } catch (e) {
      return 0;
    }
  }

  int _calculateTotalOverDuePercent(ClientDetail client, double totalOverDue) {
    try {
      final dueTillToday = double.tryParse(client.dueTillToday) ?? 0;

      if (dueTillToday == 0) return 0;

      final percent = (totalOverDue / dueTillToday) * 100;
      return percent.round().clamp(0, 100);
    } catch (e) {
      return 0;
    }
  }

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  Widget _buildActionButtons(ClientDetail client, MediaQueryData mediaQuery) {
    final size = mediaQuery.size;
    final isSmallScreen = size.width < 360;

    final companyController = Get.find<CompanyController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(title: 'Quick Actions', icon: Icons.flash_on_rounded, size: size),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildButton(
                      'View Statement',
                      assetIcon: ImageConstant.statemnt,
                      size: size,
                      isPrimary: true,
                      onPressed: () {
                        if (_canNavigateToStatement(client, companyController)) {
                          Get.to(() => AccountStatementScreen(
                            registrationNo: client.registrationNo ?? '',
                            brnCode: client.brnCode ?? '',
                            plotType: client.plotType ?? 'Normal',
                            idNo: client.cnic ?? '',
                          ));
                        } else {
                          _showCloseStatusAlert(context, client);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: isSmallScreen ? size.width * 0.03 : size.width * 0.04),
                  Expanded(
                    child: _buildButton(
                      'View Receipt',
                      assetIcon: ImageConstant.receipt,
                      size: size,
                      isPrimary: true,
                      onPressed: () {
                        Get.to(() => ReceiptTableView(
                          registrationNo: client.registrationNo ?? '',
                          brnCode: client.brnCode ?? '',
                          plotType: client.plotType ?? 'Normal',
                          memberName: client.memberName ?? '',
                          idNo: client.cnic,
                        ));
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.01),

              LayoutBuilder(builder: (context, constraints) {
                final gap = isSmallScreen ? size.width * 0.03 : size.width * 0.04;
                final buttonWidth = (constraints.maxWidth - gap) / 2;
                return Center(
                  child: SizedBox(
                    width: buttonWidth,
                    child: _buildButton(
                      'Pay Now',
                      assetIcon: ImageConstant.pay_now,
                      size: size,
                      isPrimary: true,
                      onPressed: () {
                        if (!_canNavigateToStatement(client, companyController)) {
                          _showCloseStatusAlert(context, client);
                          return;
                        }
                        final totalOutstanding = _calculateTotalOutstanding(client);
                        final totalOverDue = _calculateTotalOverDue(client);

                        Get.to(() => PaymentScreen(
                          registrationNo: client.registrationNo ?? '',
                          paymentCode: client.paymentCode ?? '',
                          brnCode: client.brnCode ?? '',
                          brnName: client.brnName ?? '',
                          memberName: client.memberName ?? '',
                          overDueAmount: totalOverDue,
                          totalOutstanding: totalOutstanding,
                          formattedTotalOutstanding: _formatAmount(totalOutstanding),
                          formattedTotalOverDue: _formatAmount(totalOverDue),
                          clientId: client.cnic,
                          blockNo: _cleanText(client.blockNo),
                          unitNo: _cleanText(client.unit),
                        ));
                      },
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  bool _canNavigateToStatement(ClientDetail client, CompanyController companyController) {
    if (!companyController.showCloseStatus) {
      return true;
    }

    final status = client.registrationStatus?.toUpperCase() ?? '';
    return status == 'N';
  }

  void _showCloseStatusAlert(BuildContext context, ClientDetail client) {
    final companyController = Get.find<CompanyController>();
    final alterMessage = companyController.alterMessage.value.isNotEmpty
        ? companyController.alterMessage.value
        : 'This file is canceled/locked. Please contact support department for more details.';

    showTopSnackBar(
      context,
      title: "Access Denied",
      "File Status: ${_getRegistrationStatusText(client.registrationStatus)}. $alterMessage",
      Colors.red.withOpacity(0.7),
      icon: Icons.warning,
    );
  }

  Widget _buildButton(
      String text, {
        required Size size,
        IconData? icon,
        String? assetIcon,
        bool isPrimary = true,
        bool fullWidth = false,
        VoidCallback? onPressed,
      }) {
    final borderRadius = BorderRadius.circular(size.width * 0.05);

    if (isPrimary) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              AppColors.appColor,
              AppColors.appColor.withOpacity(0.75),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.appColor.withOpacity(0.4),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: borderRadius,
          child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: size.height * 0.015,
                horizontal: size.width * 0.02,
              ),
              child: _buildButtonContent(text, icon, size, Colors.white, emphasize: fullWidth, assetIcon: assetIcon),
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.appColor.withOpacity(0.35), width: 1.3),
          ),
          padding: EdgeInsets.symmetric(
            vertical: size.height * 0.016,
            horizontal: size.width * 0.02,
          ),
          child: _buildButtonContent(text, icon, size, AppColors.appColor, assetIcon: assetIcon),
        ),
      ),
    );
  }

  Widget _buildButtonContent(String text, IconData? icon, Size size, Color color,
      {bool emphasize = false, String? assetIcon}) {
    if (icon == null && assetIcon == null) {
      return Text(
        text,
        style: TextStyle(

          fontSize: size.width * 0.03,
          letterSpacing: 0.3,
          color: color,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
      );
    }

    final iconSize = emphasize ? size.width * 0.065 : size.width * 0.06;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (assetIcon != null)
          Image.asset(
            assetIcon,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          )
        else
          Icon(icon!, size: iconSize, color: color),
        SizedBox(width: size.width * 0.018),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: emphasize ? size.width * 0.042 : size.width * 0.036,
              letterSpacing: 0.2,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPreview(Size size, int index) {
    final video = _videoForIndex(index);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(title: 'Learn More', icon: Icons.play_circle_outline_rounded, size: size),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
          child: GestureDetector(
            onTap: () => _launchYouTubeVideo(video.videoUrl),
            child: Container(
              height: size.height * 0.22,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size.width * 0.04),
                color: Colors.grey[200],
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * 0.04),
                    child: _buildVideoThumb(video),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * 0.04),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.4),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: size.height * 0.012,
                    right: size.width * 0.03,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.025,
                        vertical: size.height * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(size.width * 0.02),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.ondemand_video_rounded, color: Colors.white, size: size.width * 0.032),
                          SizedBox(width: size.width * 0.01),
                          Text(
                            'Video Guide',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: size.width * 0.026,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.92),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(size.width * 0.038),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.appColor,
                      size: size.width * 0.1,
                    ),
                  ),
                  Positioned(
                    bottom: size.height * 0.014,
                    left: size.width * 0.035,
                    child: Text(
                      'Watch Tutorial',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: size.width * 0.035,
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _fmtDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _getRegistrationStatusText(String? statusCode) {
    switch (statusCode?.toUpperCase()) {
      case 'N':
        return 'Active';
      case 'L':
        return 'Locked';
      case 'C':
        return 'Cancelled';
      case 'D':
        return 'Division';
      case 'F':
        return 'Refunded';
      case 'G':
        return 'Amalgamation';
      case 'M':
        return 'Merged';
      case 'NC':
        return 'Normal+Cancel';
      case 'NLC':
        return 'Normal+Lock+Cancel';
      case 'P':
        return 'Purchased';
      case 'A':
        return 'ALL';
      case 'ALL':
        return 'ALL';
      case 'R':
        return 'Mark Refunded';
      default:
        return statusCode ?? 'Unknown';
    }
  }
}

class _AnimatedEntrance extends StatelessWidget {
  final Widget child;
  final Duration delay;

  const _AnimatedEntrance({required this.child, this.delay = Duration.zero});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420) + delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _TVFocusButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final String? assetIcon;
  final bool isPrimary;
  final VoidCallback onTap;
  const _TVFocusButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.assetIcon,
    this.isPrimary = false,
  });
  @override
  State<_TVFocusButton> createState() => _TVFocusButtonState();
}

class _TVFocusButtonState extends State<_TVFocusButton> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    final fgColor = widget.isPrimary
        ? Colors.white
        : (_isFocused ? Colors.white : AppColors.appColor);

    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 64,
          decoration: BoxDecoration(
            gradient: widget.isPrimary
                ? LinearGradient(colors: [AppColors.appColor, AppColors.appColor.withOpacity(0.75)])
                : null,
            color: widget.isPrimary
                ? null
                : (_isFocused ? AppColors.appColor : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isFocused ? Colors.white : AppColors.appColor.withOpacity(0.25),
              width: _isFocused ? 2.5 : 1.3,
            ),
            boxShadow: _isFocused
                ? [BoxShadow(color: AppColors.appColor.withOpacity(0.4), blurRadius: 14, spreadRadius: 1)]
                : [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.assetIcon != null) ...[
                  Image.asset(
                    widget.assetIcon!,
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                ] else if (widget.icon != null) ...[
                  Icon(widget.icon, size: 20, color: fgColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(color: fgColor, fontWeight: FontWeight.w800, fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TVFocusContainer extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _TVFocusContainer({required this.child, required this.onTap});
  @override
  State<_TVFocusContainer> createState() => _TVFocusContainerState();
}

class _TVFocusContainerState extends State<_TVFocusContainer> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _isFocused ? AppColors.appColor : Colors.transparent, width: 3),
            boxShadow: _isFocused
                ? [BoxShadow(color: AppColors.appColor.withOpacity(0.4), blurRadius: 14)]
                : [],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TVIconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TVIconBtn({required this.icon, required this.onTap});
  @override
  State<_TVIconBtn> createState() => _TVIconBtnState();
}

class _TVIconBtnState extends State<_TVIconBtn> {
  bool _isFocused = false;
  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (f) => setState(() => _isFocused = f),
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter)) {
          widget.onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: _isFocused ? Colors.white : Colors.transparent, width: 2),
          ),
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _VideoItem {
  final String videoUrl;
  final String? thumbAsset;
  const _VideoItem({required this.videoUrl, this.thumbAsset});
}