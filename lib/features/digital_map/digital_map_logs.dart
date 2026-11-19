import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/core/javascript/map_script.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/features/digital_map/data/repositories/get_map_repo.dart';
import 'package:pakland/features/digital_map/filter/my_filter_sheet_map.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../core/theme/colors.dart';
import '../booking/presentation/screens/booking_screen.dart';

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/core/javascript/map_script.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';
import 'package:pakland/features/digital_map/data/repositories/get_map_repo.dart';
import 'package:pakland/features/digital_map/filter/my_filter_sheet_map.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import '../../core/theme/colors.dart';
import '../booking/presentation/screens/booking_screen.dart';

class DigitalMapScreen extends StatefulWidget {
  const DigitalMapScreen({super.key});

  @override
  State<DigitalMapScreen> createState() => _DigitalMapScreen();
}

class _DigitalMapScreen extends State<DigitalMapScreen>
    with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _branchCode;
  String? _blockNo;
  String? _projectName;
  String? _blockName;

  final DigitalMapRepo _repo = DigitalMapRepo();

  WebViewController? _controller;
  bool _isLoading = false;
  bool _hasError = false;
  int _horizontalQuarterTurns = 1;
  String _errorMessage = '';

  bool _isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= 600;
  }

  bool get _hasFilter => _branchCode != null && _branchCode!.isNotEmpty;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      openFilterSheet();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
  }
  Future<void> _onInterested(String raw) async {
    if (!mounted) return;
    try {
      final Map<String, dynamic> data =
      jsonDecode(raw) as Map<String, dynamic>;

      String clean(dynamic v) => (v ?? '').toString().trim();

      final String plotNo = clean(data['plotNo']);
      final String plotSize = clean(data['plotSize']);
      final String plotNature = clean(data['plotNature']);
      final String plotType = clean(data['plotType']);

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BookingScreen(
            initialBranchCode: _branchCode,
            initialProject: _projectName,
            initialBlockNo: _blockNo,
            initialBlock: _blockName,
            initialPlotNo: plotNo.isEmpty ? null : plotNo,
            initialPlotSize: plotSize.isEmpty ? null : plotSize,
            initialPlotNature: plotNature.isEmpty ? null : plotNature,
            initialPlotType: plotType.isEmpty ? null : plotType,
          ),
        ),
      );
      if (!mounted) return;
      await _controller?.runJavaScript(JavaScriptCode.resetCode);
    } catch (e) {
      debugPrint('[DigitalMap] _onInterested error: $e');
    }
  }

  Future<void> openFilterSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MyFilterSheetMapInventroy(
        filterSelectedBranchCode: _branchCode,
        filterSelectedBlockNo: _blockNo,
      ),
    );

    if (result == null || !mounted) return;

    final newBranchCode = result['branchCode'] as String?;
    final newBlockNo = result['blockNo'] as String?;
    final newProjectName = result['projectName'] as String?;
    final newBlockName = result['blockName'] as String?;

    if (newBranchCode == null) {
      setState(() {
        _branchCode = null;
        _blockNo = null;
        _projectName = null;
        _blockName = null;
        _controller = null;
        _hasError = false;
        _errorMessage = '';
      });
      return;
    }
    if (newBranchCode == _branchCode && newBlockNo == _blockNo) return;

    setState(() {
      _branchCode = newBranchCode;
      _blockNo = newBlockNo;
      _projectName = newProjectName;
      _blockName = newBlockName;
      _controller = null;
      _hasError = false;
      _errorMessage = '';
    });

    loadMapData();
  }

  Future<void> loadMapData() async {
    if (_branchCode == null || _branchCode!.isEmpty) return;

    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
          _errorMessage = '';
        });
      }

      final String htmlContent = await _repo.fetchMapWebView(
        branchCode: _branchCode!,
        blockNo: _blockNo ?? '',
      );

      late final PlatformWebViewControllerCreationParams params;
      if (WebViewPlatform.instance is WebKitWebViewPlatform) {
        params = WebKitWebViewControllerCreationParams(
          allowsInlineMediaPlayback: true,
          mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
        );
      } else {
        params = const PlatformWebViewControllerCreationParams();
      }
      final WebViewController controller =
      WebViewController.fromPlatformCreationParams(params);
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF003331))
        ..setUserAgent(JavaScriptCode.desktopUserAgent)
        ..addJavaScriptChannel(
          'InterestedChannel',
          onMessageReceived: (JavaScriptMessage message) {
            _onInterested(message.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) async {
              await controller.runJavaScript(JavaScriptCode.javascriptCode);
              if (mounted) setState(() => _isLoading = false);
            },
            onSslAuthError: (SslAuthError error) {
              if (Uri.parse(ApiConstants.baseUrl).host ==
                  'paklandhousingdemo.shesoft.com.pk') {
                error.proceed();
              } else {
                error.cancel();
              }
            },
            onWebResourceError: (WebResourceError error) {
              if (mounted && (error.isForMainFrame ?? true)) {
                setState(() {
                  _isLoading = false;
                  _hasError = true;
                  _errorMessage = error.description;
                });
              }
            },
          ),
        )
        ..loadHtmlString(htmlContent, baseUrl: ApiConstants.baseUrl);
      if (controller.platform is AndroidWebViewController) {
        if (kDebugMode) AndroidWebViewController.enableDebugging(true);
        (controller.platform as AndroidWebViewController)
            .setMediaPlaybackRequiresUserGesture(false);
      }
      if (mounted) setState(() => _controller = controller);
    } catch (e) {
      debugPrint('[DigitalMap] loadMapData error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = _isTablet(context);
    final bool isPhysicalLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final int effectiveTurns =
    (isTablet || isPhysicalLandscape) ? 0 : _horizontalQuarterTurns;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF003331),
      appBar: AppHeaderBar(
        title: const Text("Digital Map"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded, color: Colors.white),
            tooltip: 'Filter',
            onPressed: openFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            if (!_hasFilter)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        color: Colors.white.withOpacity(0.35),
                        size: 72,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Select a Project to view the map',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: openFilterSheet,
                        icon: const Icon(Icons.filter_list_rounded),
                        label: const Text('Show Map'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_controller != null)
              Positioned.fill(
                child:
                effectiveTurns == 0
                    ? WebViewWidget(
                  controller: _controller!,
                  gestureRecognizers: {
                    Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer(),
                    ),
                  },
                )
                    : ClipRect(
                  child: RotatedBox(
                    quarterTurns: effectiveTurns,
                    child: WebViewWidget(
                      controller: _controller!,
                      gestureRecognizers: {
                        Factory<OneSequenceGestureRecognizer>(
                              () => EagerGestureRecognizer(),
                        ),
                      },
                    ),
                  ),
                ),
              ),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            if (_hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white70,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load the map.',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      if (kDebugMode && _errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: loadMapData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            if (_controller != null && !isTablet && !isPhysicalLandscape)
              Positioned(
                bottom: 20,
                left: 20,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: AppColors.primaryColor,
                  onPressed: () {
                    setState(() {
                      _horizontalQuarterTurns =
                      (_horizontalQuarterTurns == 1) ? 3 : 1;
                    });
                  },
                  child: const Icon(Icons.screen_rotation, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}