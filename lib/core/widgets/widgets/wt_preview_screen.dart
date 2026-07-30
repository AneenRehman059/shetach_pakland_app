import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path/path.dart' as path;

class WhatsAppMultiFilePreview extends StatefulWidget {
  final List<File> files;
  final VoidCallback onSend;
  final VoidCallback onCancel;

  const WhatsAppMultiFilePreview({
    Key? key,
    required this.files,
    required this.onSend,
    required this.onCancel,
  }) : super(key: key);

  @override
  State<WhatsAppMultiFilePreview> createState() => _WhatsAppMultiFilePreviewState();
}

class _WhatsAppMultiFilePreviewState extends State<WhatsAppMultiFilePreview> {
  late PageController _pageController;
  late List<VideoPlayerController?> _videoControllers;
  late List<PdfController?> _pdfControllers;
  late List<bool> _videoInitialized;
  late List<bool> _pdfInitialized;
  int _currentIndex = 0;
  bool _isSending = false; // Add flag to prevent double tap

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeControllers();
  }

  void _initializeControllers() {
    _videoControllers = List.generate(widget.files.length, (_) => null);
    _pdfControllers = List.generate(widget.files.length, (_) => null);
    _videoInitialized = List.generate(widget.files.length, (_) => false);
    _pdfInitialized = List.generate(widget.files.length, (_) => false);

    // Initialize first file immediately
    if (widget.files.isNotEmpty) {
      _initializeFilePreview(0);
    }
  }

  Future<void> _initializeFilePreview(int index) async {
    if (index < 0 || index >= widget.files.length) return;

    final file = widget.files[index];
    final filePath = file.path;
    final extension = path.extension(filePath).toLowerCase();

    if (_isVideoFile(extension) && !_videoInitialized[index]) {
      try {
        _videoControllers[index] = VideoPlayerController.file(file);
        await _videoControllers[index]!.initialize();
        setState(() => _videoInitialized[index] = true);
      } catch (e) {
        print('Error initializing video: $e');
      }
    } else if (extension == '.pdf' && !_pdfInitialized[index]) {
      try {
        _pdfControllers[index] = PdfController(
          document: PdfDocument.openFile(file.path),
        );
        setState(() => _pdfInitialized[index] = true);
      } catch (e) {
        print('Error initializing PDF: $e');
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers) {
      controller?.dispose();
    }
    for (var controller in _pdfControllers) {
      controller?.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);

    // Initialize preview for current and adjacent pages
    _initializeFilePreview(index);
    if (index > 0) _initializeFilePreview(index - 1);
    if (index < widget.files.length - 1) _initializeFilePreview(index + 1);

    // Pause videos when not on their page
    for (int i = 0; i < _videoControllers.length; i++) {
      if (i != index && _videoInitialized[i] && _videoControllers[i]!.value.isPlaying) {
        _videoControllers[i]!.pause();
      }
    }
  }

  bool _isVideoFile(String extension) {
    return ['.mp4', '.mov', '.avi', '.mkv', '.flv', '.wmv'].contains(extension);
  }

  bool _isImageFile(String extension) {
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  bool _isAudioFile(String extension) {
    return ['.mp3', '.m4a', '.aac', '.wav', '.ogg'].contains(extension);
  }

  Widget _buildFilePreview(File file, int index) {
    final filePath = file.path;
    final fileName = path.basename(filePath);
    final extension = path.extension(filePath).toLowerCase();
    final fileSize = file.lengthSync();

    if (_isImageFile(extension)) {
      return Stack(
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: Image.file(
                file,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackPreview(fileName, extension, fileSize);
                },
              ),
            ),
          ),
          _buildFileInfoOverlay(fileName, extension, fileSize),
        ],
      );
    } else if (_isVideoFile(extension) && _videoInitialized[index]) {
      final controller = _videoControllers[index]!;
      return Stack(
        children: [
          Container(
            color: Colors.black,
            child: Center(
              child: AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
            ),
          ),
          if (!controller.value.isPlaying)
            Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (controller.value.isPlaying) {
                    controller.pause();
                  } else {
                    controller.play();
                  }
                });
              },
            ),
          ),
          _buildFileInfoOverlay(
            fileName,
            extension,
            fileSize,
            duration: controller.value.duration,
          ),
        ],
      );
    } else if (extension == '.pdf' && _pdfInitialized[index]) {
      return Stack(
        children: [
          Container(
            color: Colors.black,
            child: PdfView(controller: _pdfControllers[index]!),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildFileInfoContainer(fileName, extension, fileSize),
          ),
        ],
      );
    } else if (_isAudioFile(extension)) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.audiotrack,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                fileName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatFileSize(fileSize),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return _buildFallbackPreview(fileName, extension, fileSize);
    }
  }

  Widget _buildFileInfoOverlay(String fileName, String extension, int fileSize, {Duration? duration}) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(extension),
                color: Colors.white,
                size: 20,
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
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    duration != null
                        ? '${_formatDuration(duration)} • ${_formatFileSize(fileSize)}'
                        : _formatFileSize(fileSize),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
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

  Widget _buildFileInfoContainer(String fileName, String extension, int fileSize) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.picture_as_pdf,
              color: Colors.white,
              size: 20,
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
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(fileSize),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPreview(String fileName, String extension, int fileSize) {
    return Container(
      color: Colors.grey[900],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getFileIcon(extension),
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              fileName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${extension.toUpperCase().replaceAll('.', '')} • ${_formatFileSize(fileSize)}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String extension) {
    if (_isImageFile(extension)) return Icons.image;
    if (_isVideoFile(extension)) return Icons.videocam;
    if (extension == '.pdf') return Icons.picture_as_pdf;
    if (_isAudioFile(extension)) return Icons.audiotrack;
    if (extension == '.doc' || extension == '.docx') return Icons.description;
    if (extension == '.xls' || extension == '.xlsx') return Icons.table_chart;
    if (extension == '.txt') return Icons.text_fields;
    return Icons.insert_drive_file;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Custom Page Indicator Widget
  Widget _buildCustomPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.files.length, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentIndex == index ? Colors.green : Colors.white54,
          ),
        );
      }),
    );
  }

  // Handle send button press
  void _handleSend() {
    if (_isSending) return; // Prevent double tap

    setState(() {
      _isSending = true;
    });

    // Call the onSend callback
    widget.onSend();

    // Note: The parent widget should handle closing the preview
    // by checking the boolean return value
  }

  // Handle cancel button press
  void _handleCancel() {
    if (!_isSending) {
      widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // PageView for multiple files
            PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildFilePreview(widget.files[index], index);
              },
            ),

            // WhatsApp-style header with file counter
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: _handleCancel,
                    ),
                    const Spacer(),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Preview',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (widget.files.length > 1)
                          Text(
                            '${_currentIndex + 1}/${widget.files.length}',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: _isSending
                          ? Container(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      onPressed: _isSending ? null : _handleSend,
                    ),
                  ],
                ),
              ),
            ),

            // Custom page indicator (dots) at the bottom for multiple files
            if (widget.files.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: _buildCustomPageIndicator(),
                  ),
                ),
              ),

            // Navigation arrows for large screens
            if (widget.files.length > 1 && !_isSending)
              Positioned(
                left: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: Visibility(
                  visible: _currentIndex > 0,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.black54,
                    onPressed: () {
                      _pageController.previousPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),

            if (widget.files.length > 1 && !_isSending)
              Positioned(
                right: 10,
                top: MediaQuery.of(context).size.height / 2 - 30,
                child: Visibility(
                  visible: _currentIndex < widget.files.length - 1,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.black54,
                    onPressed: () {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}