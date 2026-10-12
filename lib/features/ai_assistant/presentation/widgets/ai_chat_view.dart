import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/constants/app_assets.dart';

/// Interactive Copilot Chat View (with Groq 70B & Quick Suggestions)
class AiChatView extends StatelessWidget {
  final List<Map<String, dynamic>> quickSuggestions;
  final List<Map<String, String>> messages;
  final bool isGenerating;
  final ScrollController scrollController;
  final TextEditingController textController;
  final ValueChanged<String> onSendMessage;

  const AiChatView({
    super.key,
    required this.quickSuggestions,
    required this.messages,
    required this.isGenerating,
    required this.scrollController,
    required this.textController,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('chat_view'),
      children: [
        // Quick suggestions bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickSuggestions.map((suggestion) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    avatar: Icon(
                      suggestion['icon'] as IconData,
                      size: 14,
                      color: AppColors.primaryRoyal,
                    ),
                    label: Text(
                      suggestion['label'] as String,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onPressed: () =>
                        onSendMessage(suggestion['label'] as String),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // Messages list
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              final isUser = msg['role'] == 'user';
              final content = msg['content'] ?? '';

              return Align(
                alignment: isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.82,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF2563EB)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              AppAssets.emblem,
                              width: 14,
                              height: 14,
                              errorBuilder: (_, error, stack) => const Icon(
                                Icons.auto_awesome,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'SKAVIA AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        content,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                          color: isUser ? Colors.white : AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Generating indicator
        if (isGenerating)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            alignment: Alignment.centerLeft,
            child: const Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'SKAVIA AI is analyzing...',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),

        // Chat Input bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: textController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Ask SKAVIA AI anything...',
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: AppColors.textMuted,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onSubmitted: onSendMessage,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => onSendMessage(textController.text),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
