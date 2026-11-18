import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pakland/features/booking/data/repositories/booking_repo.dart';

import '../../../core/theme/colors.dart';

class MyFilterSheetMapInventroy extends StatefulWidget {
  final String? filterSelectedBranchCode;
  final String? filterSelectedBlockNo;

  const MyFilterSheetMapInventroy({
    super.key,
    this.filterSelectedBranchCode,
    this.filterSelectedBlockNo,
  });

  @override
  State<MyFilterSheetMapInventroy> createState() =>
      _MyFilterSheetMapInventroyState();
}

class _MyFilterSheetMapInventroyState extends State<MyFilterSheetMapInventroy> {
  final BookingRepository _repo = BookingRepository();
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _blocks = [];
  Map<String, dynamic>? _tmpBranch;
  Map<String, dynamic>? _tmpBlock;

  bool _isLoadingBranches = false;
  bool _isLoadingBlocks = false;

  bool get _hasSelection =>
      _tmpBlock != null &&
          (_tmpBlock!['block_name']?.toString().isNotEmpty ?? false);

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _fetchBranches();
    if (!mounted) return;

    if (widget.filterSelectedBranchCode != null && _branches.isNotEmpty) {
      _tmpBranch = _branches.firstWhere(
            (b) => b['brn_code']?.toString() == widget.filterSelectedBranchCode,
        orElse: () => <String, dynamic>{},
      );
      if (_tmpBranch!.isNotEmpty) {
        await _fetchBlocks(_tmpBranch!['brn_code'].toString());
        if (!mounted) return;

        if (widget.filterSelectedBlockNo != null && _blocks.isNotEmpty) {
          _tmpBlock = _blocks.firstWhere(
                (b) => b['block_code']?.toString() == widget.filterSelectedBlockNo,
            orElse: () => <String, dynamic>{},
          );
          if (_tmpBlock!.isEmpty) _tmpBlock = null;
        }
      } else {
        _tmpBranch = null;
      }
      if (mounted) setState(() {});
    }
  }

  Future<void> _fetchBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      final data = await _repo.getBranches();
      if (mounted) {
        setState(() {
          _branches = data.length > 1 ? data.sublist(1) : data;
        });
      }
    } catch (e) {
      debugPrint('[FilterSheet] fetchBranches error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  Future<void> _fetchBlocks(String branchCode) async {
    setState(() {
      _isLoadingBlocks = true;
      _blocks = [];
      _tmpBlock = null;
    });
    try {
      final data = await _repo.fetchBlocks(branchCode);
      if (mounted) setState(() => _blocks = data);
    } catch (e) {
      debugPrint('[FilterSheet] fetchBlocks error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingBlocks = false);
    }
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFDCE3EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF3993AD), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final projectDropdown = DropdownButtonFormField<String>(
      value: _tmpBranch?['brn_name']?.toString().trim(),
      isExpanded: true,
      decoration: _decoration(
        _isLoadingBranches ? 'Loading...' : 'Select Project',
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      items:
      _branches.map((branch) {
        final name = branch['brn_name']?.toString().trim() ?? '';
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged:
      _isLoadingBranches
          ? null
          : (value) {
        setState(() {
          _tmpBranch = _branches.firstWhere(
                (b) => b['brn_name']?.toString().trim() == value,
            orElse: () => <String, dynamic>{},
          );
          if (_tmpBranch!.isEmpty) _tmpBranch = null;

          _tmpBlock = null;
          _blocks = [];
        });

        final code = _tmpBranch?['brn_code']?.toString();
        if (code != null && code.isNotEmpty) {
          _fetchBlocks(code);
        }
      },
    );

    final blockDropdown = DropdownButtonFormField<String>(
      value: _tmpBlock?['block_name']?.toString().trim(),
      isExpanded: true,
      decoration: _decoration(
        _isLoadingBlocks
            ? 'Loading...'
            : (_tmpBranch == null ? 'Select Project first' : 'Select Block'),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      items:
      _blocks.map((block) {
        final name = block['block_name']?.toString().trim() ?? '';
        return DropdownMenuItem<String>(
          value: name,
          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged:
      (_tmpBranch == null || _isLoadingBlocks)
          ? null
          : (value) {
        setState(() {
          _tmpBlock = _blocks.firstWhere(
                (b) => b['block_name']?.toString().trim() == value,
            orElse: () => <String, dynamic>{},
          );
          if (_tmpBlock!.isEmpty) _tmpBlock = null;
        });
      },
    );

    return SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // FIX: use Navigator, not Get.back
                    Navigator.of(context).pop(<String, dynamic>{
                      'branchCode': null,
                      'blockNo': null,
                      'projectName': null,
                      'blockName': null,
                    });
                  },
                  child: Text(
                    'Clear Filters',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 1,
                    right: 1,
                    top: 2,
                    bottom: 2,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextHeader('Project'),
                      projectDropdown,
                      buildTextHeader('Block/Floor'),
                      blockDropdown,
                    ],
                  ),
                ),
              ),
            ),
            Divider(color: Colors.grey.shade300, thickness: 1, height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _hasSelection
                      ? AppColors.primaryColor
                      : Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed:
                _hasSelection
                    ? () {
                  Navigator.of(context).pop(<String, dynamic>{
                    'branchCode': _tmpBranch?['brn_code']?.toString(),
                    'blockNo':
                    _tmpBlock?['block_code']?.toString() ??
                        _tmpBlock?['block_no']?.toString(),
                    'projectName': _tmpBranch?['brn_name']?.toString(),
                    'blockName': _tmpBlock?['block_name']?.toString(),
                  });
                }
                    : null,
                child: const Text(
                  'Show Map',
                  style: TextStyle(fontSize: 16,color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextHeader(
      String text, {
        double? fontSize,
        EdgeInsetsGeometry? margin,
        Alignment? alignment,
        FontWeight? fontWeight,
        Color? color,
      }) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: fontWeight ?? FontWeight.w500,
        fontSize: fontSize,
        color: color ?? Colors.black,
      ),
    );
  }
}