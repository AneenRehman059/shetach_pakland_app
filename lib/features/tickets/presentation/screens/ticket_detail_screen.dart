import 'package:pakland/core/widgets/loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:just_audio/just_audio.dart';
import 'package:pakland/features/feedback/presentation/screens/cms_feedback_screen.dart';
import 'package:pakland/features/cms/presentation/widgets/timeline_view.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:photo_view/photo_view.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:mime/mime.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/constants/api_constant.dart';
import 'package:pakland/features/tickets/presentation/controllers/tickets_controller.dart';
import 'package:pakland/core/widgets/app_bar2.dart';
import 'package:pakland/features/tickets/data/models/ticket_models.dart';
import 'package:pakland/features/feedback/presentation/widgets/comments_view.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';


class TicketDetailView extends StatefulWidget {
  final TicketModel ticket;

  const TicketDetailView({super.key, required this.ticket});

  @override
  State<TicketDetailView> createState() => _TicketDetailViewState();
}

class _TicketDetailViewState extends State<TicketDetailView> {

  final _storage = const FlutterSecureStorage();
  String _userType = '';

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final userType = await _storage.read(key: "user_type") ?? '';
    if (mounted) {
      setState(() => _userType = userType);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _buildTicketDetail();
  }

  Widget _buildTicketDetail() {
    return DefaultTabController(
      length: 3,
      child: WillPopScope(

        onWillPop: () async {
          final route = _userType.toLowerCase() == 'admin'
              ? '/mainDashboard'
              : _userType.toLowerCase() == 'customer'
              ? '/adminDashboard'
              : '/clintDashboard';
          Get.offAllNamed(route);
          return false;
        },
        child: Scaffold(
          appBar: CustomAppBar(
            custom_RouteName: _userType.toLowerCase() == 'admin'
                ? '/mainDashboard'
                : _userType.toLowerCase() == 'customer'
                ? '/adminDashboard'
                : '/clintDashboard',
            title: 'Ticket Details',
            buttombar: true,
          ),
          body: TabBarView(
            children: [_buildDetails(), _buildTimeline(), _buildComments()],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    final FlutterSecureStorage storage = const FlutterSecureStorage();
    TicketController ticketController = Get.put(TicketController());
    return FutureBuilder<Map<String, String?>>(
      future: Future.wait([
        storage.read(key: "user_name"),
        storage.read(key: "user_type"),
      ]).then((values) => {
        'userName': values[0],
        'userType': values[1],
      }),
      builder: (context, snapshot) {
        final userType = snapshot.data?['userType'] ?? 'Client';


        final isSOSTicket = widget.ticket.title.toLowerCase().contains('sos') ||
            widget.ticket.description.toLowerCase().contains('emergency');

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSOSTicket) ...[
                Card(
                  color: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Colors.red, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emergency, color: Colors.red, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              '🚨 SOS EMERGENCY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This is an emergency ticket requiring immediate attention.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text('TICKET DETAILS', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textSecondaryColor.withOpacity(0.6),
                          ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _kv('Name', (widget.ticket.userName != null && widget.ticket.userName!.isNotEmpty)
                          ? widget.ticket.userName!
                          : 'N/A'),
                      _kv('Ticket Id', widget.ticket.id.toString().padLeft(5, '0')),
                      _kv('Status', widget.ticket.status.toString().padLeft(5, '')),
                      _kv('Date & Time', _formatDate(widget.ticket.createdAt)),
                      _kv('Description', widget.ticket.description.toString()),
                      const SizedBox(height: 12),
                      if (!widget.ticket.id.toString().toUpperCase().contains('SOS')) ...[
                        const SizedBox(height: 12),
                        Text(
                          "Attachments",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (context) {
                            final path = widget.ticket.attachmentPath ?? [];
                            debugPrint('📎 Building attachments row for ticket ${widget.ticket.id} -> "$path"');
                            if (path.isEmpty) {
                              return const _EmptyAttachmentPlaceholder();
                            }
                            return SizedBox(
                              width: double.infinity,
                              child: _AttachmentsPreDownload(
                                rawAttachmentPath: path.toList(),
                                onOpen: (url, mime) => _handleOpenFile(context, url, mime),
                              ),
                            );
                          },
                        ),
                      ],

                    ],
                  ),
                ),
              ),

              if (isSOSTicket && widget.ticket.latitude != null && widget.ticket.longitude != null) ...[
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Text("Attachment",style: TextStyle(color: Colors.black54,fontSize: 17,fontWeight: FontWeight.bold),),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.ticket.latitude!, widget.ticket.longitude!),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('sos_location'),
                                position: LatLng(widget.ticket.latitude!, widget.ticket.longitude!),
                                infoWindow: const InfoWindow(title: '🚨Emergency Location'),
                              ),
                            },
                            zoomControlsEnabled: false,
                            scrollGesturesEnabled: false,
                            tiltGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                            liteModeEnabled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                SizedBox(height: 30,)
              ],

              if(userType == "Client" && widget.ticket.status.toLowerCase() == 'done') Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [

                      userType == "Client" && widget.ticket.status.toLowerCase() == 'done' ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (widget.ticket.status.toLowerCase() != 'closed') ...[
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Get.to(
                                          () => FeedbackScreen(
                                        ticket: widget.ticket,
                                        controller: Get.put(TicketController()),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.feedback),
                                  label: const Text('Feedback'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.successColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.successColor),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle, color: AppColors.successColor, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ticket is already closed',
                                        style: TextStyle(
                                          color: AppColors.successColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ) : const SizedBox.shrink(),

                    ],
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeline() {
    final controller = Get.put(TicketController());
    return TimelineView(ticketId: widget.ticket.id, controller: controller);
  }

  Widget _buildComments() {
    final controller = Get.put(TicketController());
    return CommentsView(ticket: widget.ticket, controller: controller);
  }

  Widget _kv(String k, String v) {
    return Table(
      columnWidths: const {
        0: FixedColumnWidth(120),
        1: FixedColumnWidth(16),
        2: FlexColumnWidth(),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade300,
                width: 1.0,
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                k,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            SizedBox(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                v,
                style: TextStyle(
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final m = d.minute.toString().padLeft(2, '0');
    final am = d.hour >= 12 ? 'pm' : 'am';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year.toString().padLeft(2, '0')} '
        '${h.toString().padLeft(2, '0')}:$m $am';
  }

  Future<void> _handleOpenFile(BuildContext context, String url, String mimeType) async {
    if (mimeType.startsWith('audio/')) {
      final file = await _cacheFile(url);
      if (!Navigator.of(context).mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _AudioPlayerPage(filePath: file.path)),
      );
      return;
    }
    if (mimeType.startsWith('video/')) {
      final file = await _cacheFile(url);
      if (!Navigator.of(context).mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => _VideoPlayerPage(filePath: file.path)),
      );
      return;
    }
    final file = await _cacheFile(url);
    if (!Navigator.of(context).mounted) return;
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open file: ${result.message}')),
      );
    }
  }

  Future<File> _cacheFile(String url) async {
    final baseDir = await getTemporaryDirectory();
    final cacheDir = Directory('${baseDir.path}/attachments_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    final baseName = url.split('?').first.split('/').last;
    final hasExt = baseName.contains('.');
    final sanitized = baseName.isEmpty ? 'file' : baseName;
    final outPath = '${cacheDir.path}/${sanitized}_${url.hashCode}${hasExt ? '' : '.bin'}';
    final outFile = File(outPath);
    if (!await outFile.exists()) {
      final dio = Dio();
      await dio.download(url, outPath, options: Options(responseType: ResponseType.bytes));
    }
    return outFile;
  }

  Widget buildFilePreview(BuildContext context, String filePath) {
    final url = ApiConstants.buildImageUrl(filePath);
    final mimeType = lookupMimeType(url) ?? '';
    final fileName = filePath.split('/').last;

    if (mimeType.startsWith('image/')) {
      return GestureDetector(
        onTap: () => _showImageViewer(context, url),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            url,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                width: 200,
                height: 200,
                alignment: Alignment.center,
                child: const AppLoader(),
              );
            },
            errorBuilder: (context, error, stackTrace) => Container(
              width: 200,
              height: 200,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image),
            ),
          ),
        ),
      );
    } else {
      IconData icon;
      Color color;

      if (mimeType.startsWith('video/')) {
        icon = Icons.videocam;
        color = Colors.redAccent;
      } else if (mimeType.startsWith('audio/')) {
        icon = Icons.audiotrack;
        color = Colors.blueAccent;
      } else {
        icon = Icons.insert_drive_file;
        color = Colors.green;
      }

      return InkWell(
        onTap: () => _handleOpenFile(context, url, mimeType),
        child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[100],
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fileName,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showImageViewer(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(16),
        child: PhotoView(
          imageProvider: NetworkImage(url),
          heroAttributes: PhotoViewHeroAttributes(tag: url),
          loadingBuilder: (_, __) => const Center(child: AppLoader()),
        ),
      ),
    );
  }
}

void _openImageViewer(BuildContext context, String url) {
  showDialog(
    context: context,
    builder: (_) => Dialog(
      backgroundColor: Colors.black,
      insetPadding: const EdgeInsets.all(16),
      child: PhotoView(
        imageProvider: NetworkImage(url),
        heroAttributes: PhotoViewHeroAttributes(tag: url),
        loadingBuilder: (_, __) => const Center(child: AppLoader()),
      ),
    ),
  );
}

class _AttachmentsPreDownload extends StatefulWidget {
  final List<String> rawAttachmentPath;
  final Future<void> Function(String url, String mimeType) onOpen;

  const _AttachmentsPreDownload({
    required this.rawAttachmentPath,
    required this.onOpen,
  });

  @override
  State<_AttachmentsPreDownload> createState() => _AttachmentsPreDownloadState();
}

class _AttachmentsPreDownloadState extends State<_AttachmentsPreDownload> {
  late final List<String> _urls;
  final Map<String, double> _progress = {};
  final Map<String, File?> _cached = {};
  bool _started = false;

  @override
  void initState() {
    super.initState();

    final raw = widget.rawAttachmentPath;
    _urls = raw
        .where((e) => e.trim().isNotEmpty)
        .map((e) => ApiConstants.buildImageUrl(e.trim()))
        .toList();

    try {
      debugPrint('📎 Parsed ${_urls.length} attachment(s) from ticket.');
      for (final url in _urls) {
        debugPrint('📎 Attachment URL: $url');
      }
    } catch (_) {}

    _kickoff();
  }

  Future<void> _kickoff() async {
    if (_started) return;
    _started = true;
    for (final url in _urls) {
      _progress[url] = 0.0;
      setState(() {});
      try {
        final file = await _cacheFileWithProgress(url, (pct) {
          _progress[url] = pct;
          if (mounted) setState(() {});
        });
        _cached[url] = file;
      } catch (_) {
        _cached[url] = null;
      }
      if (mounted) setState(() {});
    }
  }

  Future<File> _cacheFileWithProgress(
      String url, void Function(double pct) onProgress) async {
    final baseDir = await getTemporaryDirectory();
    final cacheDir = Directory('${baseDir.path}/attachments_cache');
    if (!await cacheDir.exists()) await cacheDir.create(recursive: true);

    final baseName = url.split('?').first.split('/').last;
    final hasExt = baseName.contains('.');
    final sanitized = baseName.isEmpty ? 'file' : baseName;
    final outPath =
        '${cacheDir.path}/${sanitized}_${url.hashCode}${hasExt ? '' : '.bin'}';
    final outFile = File(outPath);

    if (await outFile.exists()) {
      onProgress(1.0);
      return outFile;
    }

    final dio = Dio();
    await dio.download(
      url,
      outPath,
      options: Options(responseType: ResponseType.bytes),
      onReceiveProgress: (received, total) {
        if (total > 0) onProgress(received / total);
      },
    );
    onProgress(1.0);
    return outFile;
  }

  @override
  Widget build(BuildContext context) {
    if (_urls.isEmpty) {
      return const _EmptyAttachmentPlaceholder();
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final url = _urls[index];
          final urlMime = lookupMimeType(url) ?? '';
          final pct = _progress[url] ?? 0.0;
          final cached = _cached[url];

          Widget child;

          if (pct < 1.0 || cached == null) {
            child = _DownloadTile(url: url, mime: urlMime, progress: pct);
          } else {
            final effectiveMime = lookupMimeType(cached.path) ?? urlMime;

            if (effectiveMime.startsWith('image/')) {
              child = GestureDetector(
                onTap: () => _openImageViewer(context, url),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    cached,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            } else if (effectiveMime.startsWith('video/')) {
              child = _VideoPreviewTile(
                file: cached,
                onTap: () => widget.onOpen(url, effectiveMime),
              );
            } else {
              IconData icon;
              Color color;
              if (effectiveMime.startsWith('audio/')) {
                icon = Icons.audiotrack;
                color = Colors.blueAccent;
              } else {
                icon = Icons.insert_drive_file;
                color = Colors.green;
              }

              child = InkWell(
                onTap: () => widget.onOpen(url, effectiveMime),
                child: Container(
                  width: 200,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[100],
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(icon, size: 40, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          url.split('?').first.split('/').last,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          }

          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: child,
          );
        },
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  final String url;
  final String mime;
  final double progress;

  const _DownloadTile({
    required this.url,
    required this.mime,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    if (mime.startsWith('video/')) {
      icon = Icons.videocam;
      color = Colors.redAccent;
    } else if (mime.startsWith('audio/')) {
      icon = Icons.audiotrack;
      color = Colors.blueAccent;
    } else if (mime.startsWith('image/')) {
      icon = Icons.image;
      color = Colors.orangeAccent;
    } else {
      icon = Icons.insert_drive_file;
      color = Colors.green;
    }

    return Container(
      width: 200,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[100],
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 28, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  url.split('?').first.split('/').last,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: progress.clamp(0, 1)),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${(progress * 100).toStringAsFixed(0)}%'),
          )
        ],
      ),
    );
  }
}

class _EmptyAttachmentPlaceholder extends StatelessWidget {
  const _EmptyAttachmentPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.attach_file, color: Colors.grey),
          SizedBox(width: 8),
          Text('No attachments available', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _VideoPreviewTile extends StatefulWidget {
  final File file;
  final VoidCallback onTap;

  const _VideoPreviewTile({required this.file, required this.onTap});

  @override
  State<_VideoPreviewTile> createState() => _VideoPreviewTileState();
}

class _VideoPreviewTileState extends State<_VideoPreviewTile> {
  VideoPlayerController? _controller;
  bool _init = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() { _init = true; });
      }).catchError((_) {
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: 200,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.black,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_init && _controller != null)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              )
            else
              const Center(child: Icon(Icons.videocam, color: Colors.white70, size: 48)),
            Container(
              color: Colors.black26,
            ),
            const Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
          ],
        ),
      ),
    );
  }
}
class _AudioPlayerPage extends StatefulWidget {
  final String filePath;
  const _AudioPlayerPage({required this.filePath});

  @override
  State<_AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<_AudioPlayerPage> {
  final _player = AudioPlayer();
  bool _ready = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await _player.setFilePath(widget.filePath);
      await _player.play();
      setState(() { _ready = true; _playing = true; });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to load audio')),
      );
      Navigator.of(context).maybePop();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeaderBar(title: const Text('Audio Player')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 48),
                  onPressed: _ready ? () async {
                    if (_playing) {
                      await _player.pause();
                    } else {
                      await _player.play();
                    }
                    setState(() { _playing = !_playing; });
                  } : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StreamBuilder<Duration?> (
                    stream: _player.durationStream,
                    builder: (context, snapDur) {
                      final total = snapDur.data ?? Duration.zero;
                      return StreamBuilder<Duration>(
                        stream: _player.positionStream,
                        builder: (context, snapPos) {
                          final pos = snapPos.data ?? Duration.zero;
                          final pct = total.inMilliseconds == 0 ? 0.0 : pos.inMilliseconds / total.inMilliseconds;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              LinearProgressIndicator(value: pct.clamp(0, 1)),
                              const SizedBox(height: 6),
                              Text('${_formatTime(pos)} / ${_formatTime(total)}'),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final h = d.inHours;
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _VideoPlayerPage extends StatefulWidget {
  final String filePath;
  const _VideoPlayerPage({required this.filePath});

  @override
  State<_VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<_VideoPlayerPage> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(File(widget.filePath))
      ..initialize().then((_) {
        if (!mounted) return;
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: false,
          allowMuting: true,
          allowPlaybackSpeedChanging: true,
          hideControlsTimer: const Duration(seconds: 3),
        );
        setState(() { _initialized = true; });
      }).catchError((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to load video')),
        );
        Navigator.of(context).pop();
      });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeaderBar(title: const Text('Video Player')),
      body: Center(
        child: _initialized && _chewieController != null
            ? Chewie(controller: _chewieController!)
            : const AppLoader(),
      ),
    );
  }
}
