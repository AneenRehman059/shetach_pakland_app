import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String? image;
  final String title;
  final IconData icon;
  final int count;
  final int totalCount;
  final Color color;
  final VoidCallback? onTap;

  const StatusCard({
    Key? key,
    this.image,
    required this.title,
    required this.icon,
    required this.count,
    required this.totalCount,
    required this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final baseSize = isPortrait ? screenSize.height : screenSize.width;

    // Responsive calculations
    final cardHeight = baseSize * 0.11;
    final horizontalPadding = baseSize * 0.02;
    final verticalPadding = baseSize * 0.015;
    final spacing = baseSize * 0.012;
    final borderRadius = baseSize * 0.02;
    final titleFontSize = baseSize * 0.018;
    final iconContainerSize = baseSize * 0.03;
    final arrowIconSize = baseSize * 0.028;
    final statusIconSize = baseSize * 0.02;

    final card = Container(
      height: cardHeight,
      decoration: BoxDecoration(
        image: image != null
            ? DecorationImage(
          image: AssetImage(image!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.white.withOpacity(0.3),
            BlendMode.darken,
          ),
        )
            : null,
        borderRadius: BorderRadius.circular(borderRadius),
        color: image != null ? null : color.withOpacity(0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Title + Graph
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: titleFontSize,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: spacing),
                GraphStatus(
                  count: count,
                  totalCount: totalCount,
                  color: color,
                  size: iconContainerSize * 1.2,
                ),
              ],
            ),
          ),

          // Icon + Arrow
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: iconContainerSize * 1.1,
                    height: iconContainerSize * 1.1,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Icon(
                    Icons.arrow_circle_right_rounded,
                    size: arrowIconSize * 0.9,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ],
              ),
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: statusIconSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: card,
    );
  }
}

class GraphStatus extends StatelessWidget {
  final int count;
  final int totalCount;
  final Color color;
  final double size;

  const GraphStatus({
    Key? key,
    required this.count,
    required this.totalCount,
    required this.color,
    this.size = 40,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = screenSize.height > screenSize.width;
    final baseSize = isPortrait ? screenSize.height : screenSize.width;

    double progress = (totalCount == 0) ? 0 : count / totalCount.toDouble();
    progress = progress.clamp(0.0, 1.0);

    final fontSize = size * 0.35;
    final strokeWidth = size * 0.075;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.1),
            ),
          ),

          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.9),
              ),
            ),
          ),

          // Inner colored circle
          Center(
            child: Container(
              width: size * 0.7,
              height: size * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Count text
          Center(
            child: Text(
              '$count',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}