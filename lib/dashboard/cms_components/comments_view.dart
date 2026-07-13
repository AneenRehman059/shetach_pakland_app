import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../colors.dart';
import '../../constants/api_constant.dart';
import '../../controllers/tickets_controller.dart';
import '../../customs/widgets/voice_message_input.dart';
import '../../function/screen_helper.dart';
import '../../models/comments_model.dart';
import '../../models/ticket_models.dart';

class _PendingUpload {
  _PendingUpload({required this.id, required this.file, this.text = '', required this.commentType, this.progress = 0.0});
  final String id;
  final File file;
  final String text;
  final String commentType;
  double progress;
}

class CommentsView extends StatefulWidget {
  final TicketModel ticket;
  final TicketController controller;
  const CommentsView({super.key, required this.ticket, required this.controller});
  @override
  State<CommentsView> createState() => _CommentsViewState();
}

class _CommentsViewState extends State<CommentsView> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<_PendingUpload> _pending = [];
  final Dio _dio = Dio();

  @override
  void initState() { super.initState(); _loadComments(); }

  @override
  void dispose() {
    _textController.dispose(); _scrollController.dispose(); _dio.close();
    super.dispose();
  }

  Future<void> _loadComments() async {
    await widget.controller.loadComments(widget.ticket.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  String _normalizeId(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    return v.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Widget _buildCommentBubble(CommentsModel comment, bool isCurrentUser, bool isTV) {
    final bubbleColor = isCurrentUser ? Colors.blue[100] : Colors.grey[200];
    final maxWidth = isTV ? 500.0 : double.infinity;

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isCurrentUser ? (isTV ? 100 : 50) : 8,
          right: isCurrentUser ? 8 : (isTV ? 100 : 50),
          bottom: 8,
        ),
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isTV ? 16 : 12),
              decoration: BoxDecoration(color: bubbleColor, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(comment.username ?? 'User ${comment.userId}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTV ? 14 : 12)),
                SizedBox(height: isTV ? 6 : 4),
                if (comment.commentType.toLowerCase() == 'text')
                  Text(comment.text, style: TextStyle(fontSize: isTV ? 16 : 14)),
                if (comment.mediaPath != null) ...[
                  SizedBox(height: isTV ? 10 : 8),
                  _buildMediaAttachment(comment, isTV),
                ],
              ]),
            ),
            Padding(
              padding: EdgeInsets.only(left: isCurrentUser ? 0 : 8, right: isCurrentUser ? 8 : 0, top: 4),
              child: Text(_formatWhatsAppTime(comment.createdAt), style: TextStyle(color: Colors.grey[600], fontSize: isTV ? 13 : 11)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaAttachment(CommentsModel comment, bool isTV) {
    if (comment.mediaPath == null || comment.mediaPath!.isEmpty) return const SizedBox.shrink();
    final imageUrl = ApiConstants.buildImageUrl(comment.mediaPath!);
    final isVoice = comment.commentType.toLowerCase() == 'voice';
    final fileName = comment.mediaPath!.split('/').last;
    final fileExtension = fileName.toLowerCase().split('.').last;

    if (isVoice) return _VoicePlayerBubble(url: imageUrl, isTV: isTV);

    final isImage = comment.mediaPath!.toLowerCase().contains(RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)$'));
    final isVideo = comment.mediaPath!.toLowerCase().contains(RegExp(r'\.(mp4|mov|avi|mkv|flv|wmv|webm|3gp)$'));
    final isAudio = comment.mediaPath!.toLowerCase().contains(RegExp(r'\.(mp3|m4a|aac|wav|ogg|flac)$'));
    final isDocument = comment.mediaPath!.toLowerCase().contains(RegExp(r'\.(pdf|doc|docx|txt|rtf|xls|xlsx|ppt|pptx|csv)$'));

    final imgW = isTV ? 300.0 : 200.0;
    final imgH = isTV ? 200.0 : 150.0;

    Future<void> downloadAndOpen() async {
      try {
        showDialog(context: context, barrierDismissible: false, builder: (c) => const Center(child: CircularProgressIndicator()));
        final dir = await getTemporaryDirectory();
        final localPath = '${dir.path}/$fileName';
        await _dio.download(imageUrl, localPath);
        if (mounted) Navigator.of(context).pop();
        final result = await OpenFilex.open(localPath);
        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot open: ${result.message}'), backgroundColor: Colors.red));
        }
      } catch (e) {
        if (mounted && Navigator.of(context).canPop()) Navigator.of(context).pop();
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }

    if (isImage) {
      return GestureDetector(
        onTap: downloadAndOpen,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(imageUrl, width: imgW, height: imgH, fit: BoxFit.cover,
            loadingBuilder: (c, child, p) => p == null ? child : Container(width: imgW, height: imgH, color: Colors.grey[300], child: Center(child: CircularProgressIndicator(value: p.expectedTotalBytes != null ? p.cumulativeBytesLoaded / p.expectedTotalBytes! : null))),
            errorBuilder: (c, e, s) => _buildImageFallback(imgW, imgH),
          )),
          const SizedBox(height: 4),
          Text('Tap to open', style: TextStyle(fontSize: isTV ? 12 : 10, color: Colors.blue, fontStyle: FontStyle.italic)),
        ]),
      );
    } else if (isDocument) {
      IconData documentIcon; Color iconColor;
      switch (fileExtension) {
        case 'pdf': documentIcon = Icons.picture_as_pdf; iconColor = Colors.red; break;
        case 'doc': case 'docx': documentIcon = Icons.description; iconColor = Colors.blue; break;
        case 'xls': case 'xlsx': case 'csv': documentIcon = Icons.table_chart; iconColor = Colors.green; break;
        default: documentIcon = Icons.insert_drive_file; iconColor = Colors.grey;
      }
      return GestureDetector(
        onTap: downloadAndOpen,
        child: Container(
          padding: EdgeInsets.all(isTV ? 16 : 12),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[300]!)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: isTV ? 50 : 40, height: isTV ? 50 : 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(documentIcon, color: iconColor, size: isTV ? 30 : 24)),
            SizedBox(width: isTV ? 16 : 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fileName, style: TextStyle(fontSize: isTV ? 16 : 14, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, maxLines: 2),
              const SizedBox(height: 4),
              Text('Tap to open', style: TextStyle(fontSize: isTV ? 13 : 11, color: Colors.blue, fontStyle: FontStyle.italic)),
            ])),
            Icon(Icons.open_in_new, size: isTV ? 22 : 18, color: Colors.blue),
          ]),
        ),
      );
    } else {
      return GestureDetector(
        onTap: downloadAndOpen,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(6)), child: Icon(Icons.insert_drive_file, size: 16, color: Colors.grey[600])),
            const SizedBox(width: 8),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(fileName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis),
              Text('Tap to open', style: TextStyle(fontSize: 10, color: Colors.blue, fontStyle: FontStyle.italic)),
            ])),
          ]),
        ),
      );
    }
  }

  Widget _buildImageFallback(double w, double h) => Container(
    width: w, height: h,
    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
    child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.image_not_supported), SizedBox(height: 4), Text('Image not available', style: TextStyle(fontSize: 10, color: Colors.grey))]),
  );

  Widget _buildDescriptionComment(bool isTV) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 8, right: isTV ? 100 : 50, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: EdgeInsets.all(isTV ? 16 : 12),
            decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Ticket Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTV ? 14 : 12)),
              SizedBox(height: isTV ? 6 : 4),
              Text(widget.ticket.description, style: TextStyle(fontSize: isTV ? 16 : 14)),
            ]),
          ),
          const Padding(padding: EdgeInsets.only(left: 8, top: 4), child: Text('Ticket Description', style: TextStyle(color: Colors.grey, fontSize: 11))),
        ]),
      ),
    );
  }

  String _formatWhatsAppTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    final timeString = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    if (messageDate == today) return timeString;
    else if (messageDate == yesterday) return 'Yesterday at $timeString';
    else return '${dateTime.day}/${dateTime.month}/${dateTime.year} at $timeString';
  }

  Future<void> _sendFile(File file, String commentType, String text) async {
    final pending = _PendingUpload(id: DateTime.now().microsecondsSinceEpoch.toString(), file: file, text: text, commentType: commentType, progress: 0.0);
    setState(() => _pending.add(pending));
    _scrollToBottom();
    try {
      final success = await widget.controller.addCommentWithFile(ticketId: widget.ticket.id, file: file, commentType: pending.commentType, purposeName: 'CommentAttachment', commentId: DateTime.now().millisecondsSinceEpoch.toInt(), onUploadProgress: (sent, total) { if (total > 0 && mounted) setState(() => pending.progress = sent / total); });
      if (mounted) setState(() => _pending.removeWhere((p) => p.id == pending.id));
      if (success) await _loadComments();
      else if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send ${commentType == 'voice' ? 'voice message' : 'attachment'}'), backgroundColor: Colors.red));
    } catch (e) {
      if (mounted) { setState(() => _pending.removeWhere((p) => p.id == pending.id)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red)); }
    }
  }

  Future<void> _handleVoiceMessage(File? file) async => await _sendFile(file!, 'voice', 'Voice message');
  Future<void> _handleAttachment(File? file) async => await _sendFile(file!, 'comments', 'File attachment');
  Future<void> _handleMultipleFiles(List<File> files) async {
    for (var file in files) { await Future.delayed(const Duration(milliseconds: 100)); await _handleAttachment(file); }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTV = ScreenHelper.isTV(context);

    return FutureBuilder<String?>(
      future: _storage.read(key: "user_id"),
      builder: (context, snapshot) {
        final userId = snapshot.data ?? '';
        return Column(children: [
          Expanded(
            child: Obx(() {
              if (widget.controller.commentsLoading.value) return Center(child: SpinKitWave(color: AppColors.primaryColor, size: 24.0));
              return RefreshIndicator(
                onRefresh: _loadComments,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(isTV ? 24 : 16),
                  itemCount: 1 + widget.controller.comments.length + _pending.length,
                  itemBuilder: (context, index) {
                    if (index == 0) return _buildDescriptionComment(isTV);
                    final commentsCount = widget.controller.comments.length;
                    if (index <= commentsCount) {
                      final comment = widget.controller.comments[index - 1];
                      final isCurrentUser = _normalizeId(comment.userId) == _normalizeId(userId);
                      return _buildCommentBubble(comment, isCurrentUser, isTV);
                    }
                    final pending = _pending[index - 1 - commentsCount];
                    return _buildPendingBubble(pending, isTV);
                  },
                ),
              );
            }),
          ),
          VoiceMessageInput(
            onSend: _handleVoiceMessage,
            onAttach: _handleAttachment,
            onTextSend: (text) async {
              if (text.trim().isNotEmpty) {
                final success = await widget.controller.addComment(ticketId: widget.ticket.id, text: text.trim(), commentType: 'text');
                if (success && mounted) { _textController.clear(); await _loadComments(); }
              }
            },
          ),
        ]);
      },
    );
  }

  Widget _buildPendingBubble(_PendingUpload pending, bool isTV) {
    final isVoice = pending.commentType == 'voice';
    final filename = pending.file.path.split('/').last;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: EdgeInsets.only(left: isTV ? 100 : 50, right: 8, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Container(
            padding: EdgeInsets.all(isTV ? 16 : 12),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('You', style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTV ? 14 : 12)),
              SizedBox(height: isTV ? 10 : 8),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(isVoice ? Icons.mic : Icons.attach_file, size: isTV ? 22 : 18),
                if (!isVoice) ...[const SizedBox(width: 8), SizedBox(width: 140, child: Text(filename, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: isTV ? 14 : 12)))],
              ]),
              const SizedBox(height: 8),
              SizedBox(width: isTV ? 300 : 200, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                LinearProgressIndicator(value: pending.progress.clamp(0.0, 1.0)),
                const SizedBox(height: 4),
                Text('Uploading ${(pending.progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: isTV ? 13 : 11, color: Colors.grey)),
              ])),
            ]),
          ),
          const Padding(padding: EdgeInsets.only(top: 4), child: Text('sending…', style: TextStyle(color: Colors.grey, fontSize: 11))),
        ]),
      ),
    );
  }
}

class _VoicePlayerBubble extends StatefulWidget {
  const _VoicePlayerBubble({required this.url, this.label, this.isTV = false});
  final String url;
  final String? label;
  final bool isTV;
  @override
  State<_VoicePlayerBubble> createState() => _VoicePlayerBubbleState();
}

class _VoicePlayerBubbleState extends State<_VoicePlayerBubble> {
  final AudioPlayer _player = AudioPlayer();
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _loading = true;
  String? _localPath;

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      final dir = await getTemporaryDirectory();
      final ext = _guessExtFromUrl(widget.url);
      _localPath = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}$ext';
      final dio = Dio();
      await dio.download(widget.url, _localPath!);
      await _player.setFilePath(_localPath!);
      _duration = _player.duration ?? Duration.zero;
      _player.positionStream.listen((pos) { if (mounted) setState(() => _position = pos); });
      _player.playerStateStream.listen((state) async {
        if (state.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero); await _player.pause();
          if (mounted) setState(() => _position = Duration.zero);
        }
      });
    } catch (e) { debugPrint("Audio init failed: $e"); }
    finally { if (mounted) setState(() => _loading = false); }
  }

  String _guessExtFromUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.mp3')) return '.mp3';
    if (lower.endsWith('.m4a')) return '.m4a';
    if (lower.endsWith('.aac')) return '.aac';
    if (lower.endsWith('.wav')) return '.wav';
    return '.mp3';
  }

  @override
  void dispose() {
    _player.dispose();
    if (_localPath != null) File(_localPath!).delete().catchError((_) {});
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final playing = _player.playing;
    final totalMs = _duration.inMilliseconds == 0 ? 1 : _duration.inMilliseconds;
    final posMs = _position.inMilliseconds.clamp(0, totalMs);
    // TV pe wider slider
    final sliderWidth = widget.isTV
        ? MediaQuery.of(context).size.width * 0.25
        : MediaQuery.of(context).size.width * 0.4;

    return Row(mainAxisSize: MainAxisSize.min, children: [
      IconButton(
        icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_fill, size: widget.isTV ? 36 : 24),
        onPressed: _loading ? null : () async {
          if (playing) await _player.pause(); else await _player.play();
          if (mounted) setState(() {});
        },
      ),
      SizedBox(
        width: sliderWidth,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Slider(value: _loading ? 0 : posMs.toDouble(), max: totalMs.toDouble(), onChanged: _loading ? null : (v) async {
            final target = Duration(milliseconds: v.floor());
            await _player.seek(target);
            if (!playing && mounted) setState(() => _position = target);
          }),
          Row(mainAxisSize: MainAxisSize.max, children: [
            Text(_fmt(_position), style: TextStyle(fontSize: widget.isTV ? 13 : 11, color: Colors.grey)),
            const Spacer(),
            Text(_fmt(_duration), style: TextStyle(fontSize: widget.isTV ? 13 : 11, color: Colors.grey)),
          ]),
        ]),
      ),
    ]);
  }
}