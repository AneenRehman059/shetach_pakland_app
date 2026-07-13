import 'package:flutter/material.dart';
import 'package:pakland/colors.dart';
import '../../function/screen_helper.dart';

class DepartmentBarChartBody extends StatefulWidget {
  final Map<String, Map<String, int>> deptStatusData;
  final List<String> statusTypes;
  final Map<String, Color> statusColors;
  final List<String> departments;
  final TextStyle headingTextStyle;

  const DepartmentBarChartBody({super.key, required this.deptStatusData, required this.statusTypes, required this.statusColors, required this.departments, required this.headingTextStyle});

  @override
  State<DepartmentBarChartBody> createState() => _DepartmentBarChartBodyState();
}

class _DepartmentBarChartBodyState extends State<DepartmentBarChartBody> with SingleTickerProviderStateMixin {
  late String _activeTab;
  String _sortMode = 'Descending';
  bool _dropdownOpen = false;
  late AnimationController _tabAnimCtrl;
  late Animation<double> _tabFade;
  OverlayEntry? _overlayEntry;
  final GlobalKey _dropdownKey = GlobalKey();

  // TV pe bade, mobile pe same
  double get _chartHeight => ScreenHelper.isTV(context) ? 300.0 : 200.0;
  double get _barWidth => ScreenHelper.isTV(context) ? 52.0 : 36.0;
  double get _barSpacing => ScreenHelper.isTV(context) ? 20.0 : 16.0;
  static const double _yAxisWidth = 36.0;
  static const double _xLabelHeight = 48.0;

  @override
  void initState() {
    super.initState();
    _activeTab = widget.statusTypes.first;
    _tabAnimCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _tabFade = CurvedAnimation(parent: _tabAnimCtrl, curve: Curves.easeOut);
    _tabAnimCtrl.forward();
  }

  @override
  void dispose() {
    _removeOverlay();
    _tabAnimCtrl.dispose();
    super.dispose();
  }

  List<String> get _sortedDepartments {
    final deps = List<String>.from(widget.departments);
    if (_sortMode == 'Ascending') {
      deps.sort((a, b) => (widget.deptStatusData[a]?[_activeTab] ?? 0).compareTo(widget.deptStatusData[b]?[_activeTab] ?? 0));
    } else if (_sortMode == 'Descending') {
      deps.sort((a, b) => (widget.deptStatusData[b]?[_activeTab] ?? 0).compareTo(widget.deptStatusData[a]?[_activeTab] ?? 0));
    }
    return deps;
  }

  double get _maxCount {
    double max = 1;
    for (final dept in widget.departments) {
      final val = (widget.deptStatusData[dept]?[_activeTab] ?? 0).toDouble();
      if (val > max) max = val;
    }
    return max;
  }

  void _switchTab(String tab) { setState(() => _activeTab = tab); _tabAnimCtrl.forward(from: 0); }

  void _removeOverlay() {
    _overlayEntry?.remove(); _overlayEntry = null;
    if (mounted) setState(() => _dropdownOpen = false);
  }

  void _toggleDropdown() {
    if (_dropdownOpen) { _removeOverlay(); return; }
    final RenderBox renderBox = _dropdownKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    final color = Colors.grey.shade600;
    final options = ['Default', 'Ascending', 'Descending'];

    _overlayEntry = OverlayEntry(builder: (ctx) => Stack(children: [
      Positioned.fill(child: GestureDetector(onTap: _removeOverlay, behavior: HitTestBehavior.translucent, child: const SizedBox.expand())),
      Positioned(
        left: offset.dx, top: offset.dy + size.height + 4, width: 168,
        child: Material(
          elevation: 0, color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2)), boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)), BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))]),
            child: Column(mainAxisSize: MainAxisSize.min, children: options.map((opt) {
              final selected = opt == _sortMode;
              final IconData icon = opt == 'Default' ? Icons.shuffle_rounded : opt == 'Ascending' ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
              return InkWell(
                onTap: () { setState(() => _sortMode = opt); _removeOverlay(); },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(color: selected ? Colors.grey.withOpacity(0.08) : Colors.transparent, borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [
                    Icon(icon, size: 15, color: selected ? color : Colors.grey.shade400),
                    const SizedBox(width: 10),
                    Text(opt, style: TextStyle(fontSize: 12, fontWeight: selected ? FontWeight.w700 : FontWeight.w500, color: selected ? color : Colors.grey.shade500)),
                    if (selected) ...[const Spacer(), Icon(Icons.check_rounded, size: 13, color: color)],
                  ]),
                ),
              );
            }).toList()),
          ),
        ),
      ),
    ]));
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _dropdownOpen = true);
  }

  Widget _buildSortButton() {
    final color = Colors.grey.shade600;
    return GestureDetector(
      key: _dropdownKey, onTap: _toggleDropdown,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: color.withOpacity(0.35))),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.sort_rounded, size: 14, color: color),
          const SizedBox(width: 5),
          Text(_sortMode, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(width: 4),
          Icon(_dropdownOpen ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, size: 14, color: color),
        ]),
      ),
    );
  }

  Widget _buildTab(String status) {
    final isActive = _activeTab == status;
    final color = widget.statusColors[status] ?? Colors.grey;
    return GestureDetector(
      onTap: () => _switchTab(status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220), curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: isActive ? color : color.withOpacity(0.08), borderRadius: BorderRadius.circular(20), border: Border.all(color: isActive ? color : color.withOpacity(0.25), width: isActive ? 1.5 : 1), boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))] : []),
        child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? Colors.white : color, letterSpacing: 0.2)),
      ),
    );
  }

  Widget _buildYAxis(double maxVal) {
    const steps = 5;
    final barsAreaHeight = _chartHeight;
    return SizedBox(
      width: _yAxisWidth,
      height: barsAreaHeight + _xLabelHeight + 18,
      child: Stack(children: List.generate(steps, (i) {
        final frac = i / (steps - 1);
        final label = (maxVal * (1 - frac)).round();
        final top = frac * barsAreaHeight;
        return Positioned(top: top.clamp(0, barsAreaHeight - 14), right: 4, child: Text('$label', style: TextStyle(fontSize: 9, color: Colors.grey.shade500, fontWeight: FontWeight.w500)));
      })),
    );
  }

  Widget _buildGridLines(double totalWidth) {
    const steps = 5;
    return SizedBox(
      width: totalWidth, height: _chartHeight,
      child: Stack(children: List.generate(steps, (i) {
        final frac = i / (steps - 1);
        return Positioned(top: frac * _chartHeight, left: 0, right: 0, child: Container(height: 0.5, color: Colors.grey.withOpacity(i == steps - 1 ? 0.35 : 0.15)));
      })),
    );
  }

  Widget _buildVerticalBar(String dept, int value, double maxVal) {
    final bool isTV = ScreenHelper.isTV(context);
    final color = widget.statusColors[_activeTab] ?? AppColors.primaryColor;
    final ratio = maxVal > 0 ? (value / maxVal).clamp(0.0, 1.0) : 0.0;
    final shortName = dept.length > 8 ? '${dept.substring(0, 7)}…' : dept;

    return SizedBox(
      width: _barWidth + _barSpacing,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          height: _chartHeight, width: _barWidth,
          child: Align(alignment: Alignment.bottomCenter, child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: ratio), duration: const Duration(milliseconds: 700), curve: Curves.easeOutCubic,
            builder: (ctx, animRatio, _) {
              final barH = (animRatio * _chartHeight).clamp(value > 0 ? 2.0 : 0.0, _chartHeight);
              return Stack(alignment: Alignment.bottomCenter, children: [
                Container(height: _chartHeight, width: _barWidth, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.grey.withOpacity(0.18), width: 0.5))),
                if (barH > 0) Container(height: barH, width: _barWidth, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [color.withOpacity(0.78), color]), borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: color.withOpacity(0.28), blurRadius: 6, offset: const Offset(0, 3))])),
              ]);
            },
          )),
        ),
        Container(height: 1, color: Colors.grey.withOpacity(0.25)),
        const SizedBox(height: 5),
        SizedBox(
          width: _barWidth + _barSpacing, height: _xLabelHeight - 6,
          child: Tooltip(message: dept, child: Text(shortName, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: isTV ? 12 : 10, fontWeight: FontWeight.w500, color: Colors.black87))),
        ),
      ]),
    );
  }

  Widget _buildBarsContent(List<String> sorted, double maxVal) {
    final activeColor = widget.statusColors[_activeTab] ?? AppColors.primaryColor;
    final contentWidth = sorted.length * (_barWidth + _barSpacing) + _barSpacing;
    return SizedBox(
      width: contentWidth,
      child: Stack(children: [
        Positioned(top: 20, left: 0, right: 0, height: _chartHeight - 20, child: _buildGridLines(contentWidth)),
        Positioned(top: _chartHeight, left: 0, right: 0, child: Container(height: 1, color: activeColor.withOpacity(0.25))),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: _barSpacing / 2),
          ...sorted.map((dept) => _buildVerticalBar(dept, widget.deptStatusData[dept]?[_activeTab] ?? 0, maxVal)),
        ]),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);
    final sorted = _sortedDepartments;
    final maxVal = _maxCount;
    final activeColor = widget.statusColors[_activeTab] ?? AppColors.primaryColor;
    final needsScroll = sorted.length > (isTV ? 6 : 4);

    if (sorted.isEmpty) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Departments Status Progress', style: widget.headingTextStyle),
        const SizedBox(height: 32),
        Center(child: Column(children: [Icon(Icons.bar_chart_rounded, size: 44, color: Colors.grey.shade300), const SizedBox(height: 8), Text('No data available', style: TextStyle(color: Colors.grey.shade500))])),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Departments Status Progress', style: widget.headingTextStyle),
      const SizedBox(height: 14),
      // Tabs + Sort — TV pe side by side always
      Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Expanded(child: Wrap(spacing: isTV ? 10 : 6, runSpacing: 6, children: widget.statusTypes.map(_buildTab).toList())),
        const SizedBox(width: 8),
        _buildSortButton(),
      ]),
      const SizedBox(height: 16),
      FadeTransition(
        opacity: _tabFade,
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildYAxis(maxVal),
          Expanded(child: needsScroll
              ? Theme(
            data: Theme.of(context).copyWith(scrollbarTheme: ScrollbarThemeData(thumbVisibility: WidgetStateProperty.all(true), trackVisibility: WidgetStateProperty.all(true), thickness: WidgetStateProperty.all(isTV ? 8 : 5), radius: const Radius.circular(8), thumbColor: WidgetStateProperty.all(activeColor.withOpacity(0.5)), trackColor: WidgetStateProperty.all(activeColor.withOpacity(0.1)), trackBorderColor: WidgetStateProperty.all(Colors.transparent))),
            child: Scrollbar(child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.only(bottom: 8), child: _buildBarsContent(sorted, maxVal))),
          )
              : _buildBarsContent(sorted, maxVal)),
        ]),
      ),
      const SizedBox(height: 12),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: isTV ? 10 : 7),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade600.withOpacity(0.15))),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: widget.statusTypes.map((status) {
          final isActive = status == _activeTab;
          final c = widget.statusColors[status] ?? Colors.grey;
          return GestureDetector(
            onTap: () => _switchTab(status),
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                AnimatedContainer(duration: const Duration(milliseconds: 200), width: isActive ? (isTV ? 20 : 16) : (isTV ? 16 : 12), height: isActive ? (isTV ? 20 : 16) : (isTV ? 16 : 12), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4), boxShadow: isActive ? [BoxShadow(color: c.withOpacity(0.4), blurRadius: 6)] : [])),
                const SizedBox(width: 5),
                Text(status, style: TextStyle(fontSize: isTV ? 13 : 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? c : Colors.grey.shade600)),
              ]),
            ),
          );
        }).toList()),
      ),
    ]);
  }
}