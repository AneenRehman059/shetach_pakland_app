import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pakland/core/widgets/wt_preview_screen.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';

import 'package:pakland/core/theme/colors.dart';
import 'package:pakland/core/widgets/chat_attachments_picker.dart';


class VoiceMessageInput extends StatefulWidget {
  final ValueChanged<File?> onSend; // This expects nullable
  final ValueChanged<String>? onTextSend;
  final ValueChanged<File?>? onAttach; // This expects nullable
  final Function(File file, Function(double progress)? onProgress)? onUpload;

  const VoiceMessageInput({
    super.key,
    required this.onSend,
    this.onTextSend,
    this.onAttach,
    this.onUpload,
  });

  @override
  State<VoiceMessageInput> createState() => _VoiceMessageInputState();
}

class _VoiceMessageInputState extends State<VoiceMessageInput>
    with TickerProviderStateMixin {
  final bool _recording = false;
  bool _isLocked = false;
  bool _isRecording = false;
  final _textCtrl = TextEditingController();
  Timer? _recordingTimer;
  int _recordingDuration = 0;
  late AnimationController _pulseController;
  late AnimationController _lockController;

  late final AudioRecorder _audioRecorder;
  String? _recordingPath;

  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _uploadingFileName;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _lockController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _textCtrl.addListener(() {
      setState(() {});
    });

    _initAudioRecorder();
  }

  Future<void> _initAudioRecorder() async {
    try {
      _audioRecorder = AudioRecorder();
      if (await _audioRecorder.hasPermission()) {
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: '${(await getTemporaryDirectory()).path}/temp_init.m4a',
        );
        await _audioRecorder.stop();
      }
    } catch (e) {
      print('Error initializing audio recorder: $e');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _lockController.dispose();
    _recordingTimer?.cancel();
    _textCtrl.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (!await _audioRecorder.hasPermission()) return;

      final tempDir = await getTemporaryDirectory();

      _recordingPath =
      '${tempDir.path}/voice_message_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _recordingPath!,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
      });

      _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() => _recordingDuration++);
      });

      _pulseController.repeat(reverse: true);
    } catch (e) {
      print('Start Rec Error: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      _recordingTimer?.cancel();
      _pulseController.stop();

      await _audioRecorder.stop();

      setState(() {
        _isRecording = false;
        _isLocked = false;
      });

      if (_recordingPath != null) {
        final voiceFile = File(_recordingPath!);
        if (await voiceFile.exists() && await voiceFile.length() > 0) {
          widget.onSend(voiceFile);
        }
      }

      _recordingPath = null;
    } catch (e) {
      print('Stop Rec Error: $e');
    }
  }

  Future<void> _cancelRecording() async {
    try {
      _recordingTimer?.cancel();
      _pulseController.stop();

      await _audioRecorder.stop();

      if (_recordingPath != null) {
        final f = File(_recordingPath!);
        if (await f.exists()) await f.delete();
      }

      setState(() {
        _recordingPath = null;
        _isRecording = false;
        _isLocked = false;
      });
    } catch (e) {
      print("Cancel Rec Error: $e");
    }
  }

  void _toggleLock() {
    if (!_isRecording) return;

    setState(() => _isLocked = !_isLocked);

    if (_isLocked) {
      _lockController.forward();
    } else {
      _lockController.reverse();
    }
  }

  /// ----------------------------------------------------------------------
  /// NEW: OPEN WHATSAPP ATTACHMENT PICKER SHEET
  /// ----------------------------------------------------------------------
  // In VoiceMessageInput widget, modify the _openAttachmentPicker function:

  void _openAttachmentPicker() {
    ChatFilePicker.openPickerSheet(
      context: context,
      onFilesSelected: (files) async {
        if (files.isNotEmpty) {
          // Show WhatsApp-style preview before sending
          final shouldSend = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => WhatsAppMultiFilePreview(
                files: files,
                onSend: () {
                  // Just return true - don't send files here
                  Navigator.pop(context, true);
                },
                onCancel: () {
                  // Return false to indicate cancel
                  Navigator.pop(context, false);
                },
              ),
            ),
          );

          // Only send files if user pressed send button
          if (shouldSend == true) {
            // Send each file individually
            for (var file in files) {
              // Add a small delay between sends to prevent overwhelming
              await Future.delayed(Duration(milliseconds: 100));
              widget.onAttach?.call(file);
            }
          }
        }
      },
    );
  }
  void _sendTextMessage() {
    if (_textCtrl.text.trim().isEmpty) return;

    widget.onTextSend?.call(_textCtrl.text.trim());
    _textCtrl.clear();
  }

  String _formatDuration(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _textCtrl.text.trim().isNotEmpty;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          // ---------------- UPLOADING UI ----------------
          if (_isUploading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.blue.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(Icons.upload, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Uploading ${_uploadingFileName ?? ''}...",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text("${(_uploadProgress * 100).toInt()}%"),
                ],
              ),
            ),

          // ---------------- RECORDING UI ----------------
          if (_isRecording)
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.red.withOpacity(0.1),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      return Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(
                              0.5 + _pulseController.value * 0.5),
                          shape: BoxShape.circle,
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    "Recording... ${_formatDuration(_recordingDuration)}",
                    style: TextStyle(color: Colors.red),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _cancelRecording,
                    child: Icon(Icons.close, color: Colors.red),
                  )
                ],
              ),
            ),

          // ---------------- MAIN INPUT AREA ----------------
          Row(
            children: [
              // WhatsApp style attachment button
              Container(
                margin: const EdgeInsets.only(left: 8),
                child: IconButton(
                  onPressed: _isUploading ? null : _openAttachmentPicker,
                  icon: Icon(Icons.attach_file, color: AppColors.primaryColor),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.textSecondaryColor.withOpacity(0.1),
                    shape: const CircleBorder(),
                  ),
                ),
              ),

              // ---------------- TEXT FIELD ----------------
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: TextField(
                    controller: _textCtrl,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Type your message...",
                      filled: true,
                      fillColor: AppColors.cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // ---------------- MIC OR SEND BUTTON ----------------
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: hasText
                    ? IconButton(
                  onPressed: _sendTextMessage,
                  icon: Icon(Icons.send, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: CircleBorder(),
                  ),
                )
                    : GestureDetector(
                  onLongPressStart: (_) => _startRecording(),
                  onLongPressEnd: (_) {
                    if (!_isLocked) _stopRecording();
                  },
                  onTap: _isRecording ? _toggleLock : null,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _isRecording
                          ? Colors.red
                          : AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording
                          ? (_isLocked ? Icons.lock : Icons.mic)
                          : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

