import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:pakland/core/theme/colors.dart';

const Color kDocPageBg = Color(0xFFF4F7FA);

class DocFileType {
  final String label;
  final IconData icon;
  final Color color;

  const DocFileType._(this.label, this.icon, this.color);

  static const DocFileType pdf =
      DocFileType._('PDF', Icons.picture_as_pdf_rounded, Color(0xFFD64545));
  static const DocFileType doc =
      DocFileType._('DOC', Icons.description_rounded, Color(0xFF2F7DD1));

  static DocFileType fromUrl(String url) =>
      url.toLowerCase().endsWith('.pdf') ? pdf : doc;
}

class DocListHeader extends StatelessWidget {
  final int count;
  final String singular;
  final String plural;

  const DocListHeader({
    super.key,
    required this.count,
    required this.singular,
    required this.plural,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.appColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count ${count == 1 ? singular : plural}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2B3A42),
            ),
          ),
          const Spacer(),
          Text(
            'Tap to view',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class DocumentListTile extends StatelessWidget {
  final String title;
  final DocFileType type;
  final bool isDownloading;
  final bool isDownloaded;
  final VoidCallback onOpen;
  final VoidCallback onDownload;
  final String downloadTooltip;

  const DocumentListTile({
    super.key,
    required this.title,
    required this.type,
    required this.isDownloading,
    required this.isDownloaded,
    required this.onOpen,
    required this.onDownload,
    this.downloadTooltip = 'Download',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6ECF2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: type.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(type.icon, color: type.color, size: 25),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: Color(0xFF2B3A42),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: type.color.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              type.label,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: type.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.visibility_outlined,
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 3),
                          Text(
                            'View',
                            style: TextStyle(
                                fontSize: 11.5, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                _DownloadButton(
                  isDownloading: isDownloading,
                  isDownloaded: isDownloaded,
                  tooltip: downloadTooltip,
                  onPressed: onDownload,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  final bool isDownloading;
  final bool isDownloaded;
  final String tooltip;
  final VoidCallback onPressed;

  const _DownloadButton({
    required this.isDownloading,
    required this.isDownloaded,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        isDownloaded ? const Color(0xFF2E9E5B) : AppColors.appColor;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: color.withOpacity(0.10),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: isDownloading ? null : onPressed,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(
              child: isDownloading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: AppLoader(),
                    )
                  : Icon(
                      isDownloaded
                          ? Icons.check_circle_rounded
                          : Icons.download_rounded,
                      color: color,
                      size: 22,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class DocLoadingState extends StatelessWidget {
  final String? label;
  const DocLoadingState({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoader(size: 88),
          if (label != null) ...[
            const SizedBox(height: 10),
            Text(
              label!,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.appColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DocEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const DocEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: AppColors.appColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.appColor),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF2B3A42),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
