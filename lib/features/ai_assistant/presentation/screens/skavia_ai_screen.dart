import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/skavia_ai_service.dart';
import '../widgets/ai_analyzing_view.dart';
import '../widgets/ai_chat_view.dart';
import '../widgets/ai_results_view.dart';

enum AiScreenMode {
  analyzing, // Screen 7: "Analyzing your requirements..."
  results, // Screen 8: "Recommended Team (3-5 members)"
  chat, // Copilot Chat UI (with Groq/Llama-3.3-70B API)
}

/// Unified SKAVIA AI Screen
/// Seamlessly supports:
/// 1. Requirement Diagnostic Mode (Screens 7 & 8)
/// 2. Interactive AI Assistant / Copilot Chat Mode (with Groq 70B & OpenRouter)
class SkaviaAiScreen extends StatefulWidget {
  final AiScreenMode initialMode;
  final String? initialPrompt;
  final Map<String, dynamic>? analysisData;

  const SkaviaAiScreen({
    super.key,
    this.initialMode = AiScreenMode.chat,
    this.initialPrompt,
    this.analysisData,
  });

  @override
  State<SkaviaAiScreen> createState() => _SkaviaAiScreenState();
}

class _SkaviaAiScreenState extends State<SkaviaAiScreen> {
  late AiScreenMode _currentMode;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'content': 'Hello! I am SKAVIA AI, your enterprise project assistant. Tell me what skills, service, or team you need, and I will find verified professionals in Dhaka for you.',
    },
  ];

  bool _isGenerating = false;

  final List<String> _analysisChecklist = [
    'Scanning verified talent database...',
    'Evaluating skill compatibility...',
    'Budget & timeline optimization...',
    'Team composition matching...',
  ];

  final List<String> _requiredSkills = [
    'Flutter',
    'Node.js',
    'UI/UX Design',
    'Payment Gateway',
    'DevOps (optional)',
  ];

  final List<Map<String, String>> _recommendedTeam = [
    {'role': 'Full Stack Developer', 'index': '1'},
    {'role': 'UI/UX Designer', 'index': '2'},
    {'role': 'QA Specialist', 'index': '3'},
  ];

  final List<Map<String, dynamic>> _quickSuggestions = [
    {'icon': Icons.ac_unit, 'label': 'AC Repair in Gulshan'},
    {'icon': Icons.flash_on, 'label': 'Emergency Electrician'},
    {'icon': Icons.code, 'label': 'Build Flutter App'},
    {'icon': Icons.plumbing, 'label': 'Fix bathroom pipe'},
  ];

  @override
  void initState() {
    super.initState();
    _currentMode = widget.initialMode;
    if (widget.initialPrompt != null &&
        widget.initialPrompt!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String userText) async {
    final trimmed = userText.trim();
    if (trimmed.isEmpty || _isGenerating) return;

    setState(() {
      _messages.add({'role': 'user', 'content': trimmed});
      _isGenerating = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final reply = await SkaviaAiService().askSkaviaAi(
        prompt: trimmed,
        conversationHistory: _messages
            .take(_messages.length - 1)
            .map(
              (m) => {
                'role': m['role'] ?? 'user',
                'content': m['content'] ?? '',
              },
            )
            .toList(),
      );

      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': reply});
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'content':
                '⚠️ Unable to reach SKAVIA AI ($e). Please verify backend credentials (GROQ_API_KEY or OPENROUTER_API_KEY) or check your internet connection.',
            'isError': 'true',
          });
          _isGenerating = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildCurrentView() {
    switch (_currentMode) {
      case AiScreenMode.analyzing:
        return AiAnalyzingView(
          checklist: _analysisChecklist,
          onResultsTap: () =>
              setState(() => _currentMode = AiScreenMode.results),
        );
      case AiScreenMode.results:
        return AiResultsView(
          requiredSkills: _requiredSkills,
          recommendedTeam: _recommendedTeam,
          onEditRequest: () =>
              setState(() => _currentMode = AiScreenMode.analyzing),
        );
      case AiScreenMode.chat:
        return AiChatView(
          quickSuggestions: _quickSuggestions,
          messages: _messages,
          isGenerating: _isGenerating,
          scrollController: _scrollController,
          textController: _textController,
          onSendMessage: _sendMessage,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Image.asset(
                AppAssets.emblem,
                width: 18,
                height: 18,
                fit: BoxFit.contain,
                errorBuilder: (_, error, stack) => const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'SKAVIA AI',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTypography.headingFont,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                  Text(
                    _currentMode == AiScreenMode.chat
                        ? 'Copilot • Online'
                        : 'Diagnostic Mode',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => setState(() => _currentMode = AiScreenMode.chat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _currentMode == AiScreenMode.chat
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Chat',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _currentMode == AiScreenMode.chat
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      setState(() => _currentMode = AiScreenMode.analyzing),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _currentMode != AiScreenMode.chat
                          ? const Color(0xFF2563EB)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Match',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _currentMode != AiScreenMode.chat
                            ? Colors.white
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentView(),
        ),
      ),
    );
  }
}
