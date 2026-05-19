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
import '../../models/comments_model.dart';
import '../../models/ticket_models.dart';



class _PendingUpload {
  _PendingUpload({
    required this.id,
    required this.file,
    this.text = '',
    required this.commentType,
    this.progress = 0.0,
  });
  final String id;
  final File file;
  final String text;
  final String commentType;
  double progress;
}

class CommentsView extends StatefulWidget {
  final TicketModel ticket;
  final TicketController controller;

  const CommentsView({
    super.key,
    required this.ticket,
    required this.controller,
  });

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
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _dio.close();
    super.dispose();
  }

  Future<void> _loadComments() async {
    await widget.controller.loadComments(widget.ticket.id);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _normalizeId(String? value) {
    final v = (value ?? '').trim().toLowerCase();
    return v.replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  Widget _buildCommentBubble(CommentsModel comment, bool isCurrentUser) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: isCurrentUser ? 50 : 8,
          right: isCurrentUser ? 8 : 50,
          bottom: 8,
        ),
        child: Column(
          crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.blue[100] : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.username ?? 'User ${comment.userId}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (comment.commentType.toLowerCase() == 'text') ...[

                    Text(
                      comment.text,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  if (comment.mediaPath != null) ...[
                    const SizedBox(height: 8),
                    _buildMediaAttachment(comment),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: isCurrentUser ? 0 : 8,
                right: isCurrentUser ? 8 : 0,
                top: 4,
              ),
              child: Text(
                _formatWhatsAppTime(comment.createdAt),
                style: TextStyle(color: Colors.grey[600], fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaAttachment(CommentsModel comment) {
    if (comment.mediaPath == null || comment.mediaPath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final imageUrl = ApiConstants.buildImageUrl(comment.mediaPath!);
    final isVoice = comment.commentType.toLowerCase() == 'voice';
    final fileName = comment.mediaPath!.split('/').last;
    final fileExtension = fileName.toLowerCase().split('.').last;

    if (isVoice) {
      return _VoicePlayerBubble(
        url: imageUrl,
      );
    }

    final isImage = comment.mediaPath!.toLowerCase().contains(
      RegExp(r'\.(jpg|jpeg|png|gif|webp|bmp)$'),
    );

    final isVideo = comment.mediaPath!.toLowerCase().contains(
      RegExp(r'\.(mp4|mov|avi|mkv|flv|wmv|webm|3gp)$'),
    );

    final isAudio = comment.mediaPath!.toLowerCase().contains(
      RegExp(r'\.(mp3|m4a|aac|wav|ogg|flac)$'),
    );

    final isDocument = comment.mediaPath!.toLowerCase().contains(
      RegExp(r'\.(pdf|doc|docx|txt|rtf|xls|xlsx|ppt|pptx|csv)$'),
    );

    Future<void> _downloadAndOpenFile() async {
      try {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );

        final dir = await getTemporaryDirectory();
        final localPath = '${dir.path}/$fileName';

        await _dio.download(
          imageUrl,
          localPath,
          onReceiveProgress: (received, total) {
            if (total != -1) {}
          },
        );

        if (mounted) Navigator.of(context).pop();

        final result = await OpenFilex.open(localPath);

        if (result.type != ResultType.done && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Cannot open file: ${result.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    Future<String?> _generateVideoThumbnail(String videoUrl) async {
      try {
        final tempDir = await getTemporaryDirectory();
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: videoUrl,
          thumbnailPath: tempDir.path,
          imageFormat: ImageFormat.JPEG,
          maxHeight: 150,
          quality: 50,
        );
        return thumbnailPath;
      } catch (e) {
        print('Error generating thumbnail: $e');
        return null;
      }
    }

    if (isImage) {
      return GestureDetector(
        onTap: () => _downloadAndOpenFile(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 200,
                height: 150,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 200,
                    height: 150,
                    color: Colors.grey[300],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildImageFallback();
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap to open',
              style: TextStyle(
                fontSize: 10,
                color: Colors.blue,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    } else if (isVideo) {
      return GestureDetector(
        onTap: () => _downloadAndOpenFile(),
        child: Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Stack(
            children: [
              FutureBuilder<String?>(
                future: _generateVideoThumbnail(imageUrl),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[400],
                      ),
                    );
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(snapshot.data!),
                        width: 200,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildVideoFallback();
                        },
                      ),
                    );
                  }

                  return _buildVideoFallback();
                },
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),

              Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.videocam,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'VIDEO',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[300],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Tap to play',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isAudio) {
      return GestureDetector(
        onTap: () => _downloadAndOpenFile(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.audiotrack,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Audio file',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.open_in_new,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tap to open',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else if (isDocument) {
      IconData documentIcon;
      Color iconColor;

      switch (fileExtension) {
        case 'pdf':
          documentIcon = Icons.picture_as_pdf;
          iconColor = Colors.red;
          break;
        case 'doc':
        case 'docx':
          documentIcon = Icons.description;
          iconColor = Colors.blue;
          break;
        case 'xls':
        case 'xlsx':
        case 'csv':
          documentIcon = Icons.table_chart;
          iconColor = Colors.green;
          break;
        case 'ppt':
        case 'pptx':
          documentIcon = Icons.slideshow;
          iconColor = Colors.orange;
          break;
        case 'txt':
          documentIcon = Icons.text_fields;
          iconColor = Colors.grey;
          break;
        default:
          documentIcon = Icons.insert_drive_file;
          iconColor = Colors.grey;
      }

      return GestureDetector(
        onTap: () => _downloadAndOpenFile(),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  documentIcon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            fileExtension.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              color: iconColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap to open with app',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new,
                size: 18,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => _downloadAndOpenFile(),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.insert_drive_file,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Tap to download and open',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildImageFallback() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported),
          SizedBox(height: 4),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoFallback() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam,
            size: 40,
            color: Colors.grey[600],
          ),
          const SizedBox(height: 8),
          Text(
            'Video',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionComment() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 8, right: 50, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ticket Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.ticket.description,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8, top: 4),
              child: Text(
                'Ticket Description',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatWhatsAppTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeString =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      return timeString;
    } else if (messageDate == yesterday) {
      return 'Yesterday at $timeString';
    } else {
      final dateString = '${dateTime.day}/${dateTime.month}/${dateTime.year}';
      return '$dateString at $timeString';
    }
  }

  Future<void> _sendFile(File file, String commentType, String text) async {
    final pending = _PendingUpload(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      file: file,
      text: text,
      commentType: commentType,
      progress: 0.0,
    );

    setState(() {
      _pending.add(pending);
    });
    _scrollToBottom();

    try {
      final success = await widget.controller.addCommentWithFile(
        ticketId: widget.ticket.id,
        file: file,
        commentType: pending.commentType,
        purposeName: 'CommentAttachment',
        commentId: (DateTime.now().millisecondsSinceEpoch).toInt(),
        onUploadProgress: (sent, total) {
          if (total > 0 && mounted) {
            setState(() {
              pending.progress = sent / total;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _pending.removeWhere((p) => p.id == pending.id);
        });
      }

      if (success) {
        await _loadComments();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send ${commentType == 'voice' ? 'voice message' : 'attachment'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pending.removeWhere((p) => p.id == pending.id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleVoiceMessage(File? file) async {
    await _sendFile(file!, 'voice', 'Voice message');
  }

  Future<void> _handleAttachment(File? file) async {
    await _sendFile(file!, 'comments', 'File attachment');
  }

  Future<void> _handleMultipleFiles(List<File> files) async {
    if (files.isEmpty) return;

    for (var file in files) {
      await Future.delayed(const Duration(milliseconds: 100));
      await _handleAttachment(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _storage.read(key: "user_id"),
      builder: (context, snapshot) {
        final userId = snapshot.data ?? '';
        return Column(
          children: [
            Expanded(
              child: Obx(() {
                if (widget.controller.commentsLoading.value) {
                  return Center(
                    child: SpinKitWave(
                      color: AppColors.primaryColor,
                      size: 24.0,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _loadComments,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                    1 + widget.controller.comments.length + _pending.length,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildDescriptionComment();
                      }
                      final commentsCount = widget.controller.comments.length;
                      if (index <= commentsCount) {
                        final comment = widget.controller.comments[index - 1];
                        final currentUser = userId;
                        final isCurrentUser = _normalizeId(comment.userId) ==
                            _normalizeId(currentUser);
                        return _buildCommentBubble(comment, isCurrentUser);
                      }
                      final pendingIndex = index - 1 - commentsCount;
                      final pending = _pending[pendingIndex];
                      return _buildPendingBubble(pending);
                    },
                  ),
                );
              }),
            ),
            VoiceMessageInput(
              onSend: _handleVoiceMessage, // Now this matches
              onAttach: _handleAttachment, // Now this matches
              onTextSend: (text) async {
                if (text.trim().isNotEmpty) {
                  final success = await widget.controller.addComment(
                    ticketId: widget.ticket.id,
                    text: text.trim(),
                    commentType: 'text',
                  );
                  if (success && mounted) {
                    _textController.clear();
                    await _loadComments();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}

extension _PendingUI on _CommentsViewState {
  Widget _buildPendingBubble(_PendingUpload pending) {
    final isVoice = pending.commentType == 'voice';
    final filename = pending.file.path.split('/').last;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 50, right: 8, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'You',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isVoice ? Icons.mic : Icons.attach_file, size: 18),
                      if (!isVoice) ...[
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 140,
                          child: Text(
                            filename,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: pending.progress.clamp(0.0, 1.0),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Uploading ${(pending.progress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'sending…',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoicePlayerBubble extends StatefulWidget {
  const _VoicePlayerBubble({required this.url, this.label});
  final String url;
  final String? label;

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
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());

      final dir = await getTemporaryDirectory();
      final ext = _guessExtFromUrl(widget.url);
      _localPath =
      '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}$ext';

      final dio = Dio();
      await dio.download(widget.url, _localPath!);

      await _player.setFilePath(_localPath!);
      _duration = _player.duration ?? Duration.zero;

      _player.positionStream.listen((pos) {
        if (mounted) setState(() => _position = pos);
      });

      _player.playerStateStream.listen((state) async {
        if (state.processingState == ProcessingState.completed) {
          await _player.seek(Duration.zero);
          await _player.pause();
          if (mounted) setState(() => _position = Duration.zero);
        }
      });
    } catch (e) {
      debugPrint("Audio init failed: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
    if (_localPath != null) {
      File(_localPath!).delete().catchError((_) {});
    }
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
          ),
          onPressed: _loading
              ? null
              : () async {
            if (playing) {
              await _player.pause();
            } else {
              await _player.play();
            }
            if (mounted) setState(() {});
          },
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: _loading ? 0 : posMs.toDouble(),
                max: totalMs.toDouble(),
                onChanged: _loading
                    ? null
                    : (v) async {
                  final target = Duration(milliseconds: v.floor());
                  await _player.seek(target);
                  if (!playing) {
                    if (mounted) setState(() => _position = target);
                  }
                },
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    _fmt(_position),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  const Spacer(),
                  Text(
                    _fmt(_duration),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}