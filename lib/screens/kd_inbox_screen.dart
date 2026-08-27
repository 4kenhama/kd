import 'package:flutter/material.dart';
import '../utils/kd_localization.dart';

/// KD Inbox Screen (Messages & Conversations)
/// View and manage messaging threads with other users

class KDInboxScreen extends StatefulWidget {
  final String currentLanguage;
  final String? threadTitle;
  final String? prefilledMessage;

  const KDInboxScreen({
    Key? key,
    required this.currentLanguage,
    this.threadTitle,
    this.prefilledMessage,
  }) : super(key: key);

  @override
  State<KDInboxScreen> createState() => _KDInboxScreenState();
}

class _KDInboxScreenState extends State<KDInboxScreen> {
  late String _currentLanguage;
  late final TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.currentLanguage;
    _messageController = TextEditingController(
      text: widget.prefilledMessage ?? '',
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.threadTitle ??
              AppStrings.get('inbox_title', language: _currentLanguage),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_rounded, color: Colors.grey),
                      const SizedBox(height: 12),
                      Text(
                        AppStrings.get(
                          'inbox_empty',
                          language: _currentLanguage,
                        ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _messageController,
                minLines: 3,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    AppStrings.get(
                      'detail_interest_button',
                      language: _currentLanguage,
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
