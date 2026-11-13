import 'package:flutter/material.dart';

import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/extensions/context_extensions.dart';
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
    if (widget.initialMode == AiScreenMode.chat &&
        widget.initialPrompt != null &&
        widget.initialPrompt!.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialPrompt!);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SkaviaAiScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialMode != widget.initialMode) {
      _currentMode = widget.initialMode;
    }
  }

  List<String> get _resolvedRequiredSkills {
    final fromAnalysis = widget.analysisData?['skills'];
    if (fromAnalysis is List && fromAnalysis.isNotEmpty) {
      return fromAnalysis.map((e) => e.toString()).toList();
    }
    return _requiredSkills;
  }

  List<Map<String, String>> get _resolvedRecommendedTeam {
    final fromTeam = widget.analysisData?['recommended_team'];
    if (fromTeam is List && fromTeam.isNotEmpty) {
      final result = <Map<String, String>>[];
      for (var i = 0; i < fromTeam.length; i++) {
        final item = fromTeam[i];
        if (item is Map) {
          result.add({
            'role': item['role']?.toString() ?? 'Verified Specialist',
            'index': item['index']?.toString() ?? '${i + 1}',
          });
        } else {
          result.add({'role': item.toString(), 'index': '${i + 1}'});
        }
      }
      if (result.isNotEmpty) return result;
    }

    final skills = widget.analysisData?['skills'];
    if (skills is List && skills.isNotEmpty) {
      final result = <Map<String, String>>[];
      for (var i = 0; i < skills.length && i < 4; i++) {
        result.add({
          'role': '${skills[i]} Specialist',
          'index': '${i + 1}',
        });
      }
      if (result.length < 3) {
        result.add({
          'role': 'Site Lead & QA Verifier',
          'index': '${result.length + 1}',
        });
      }
      return result;
    }

    return _recommendedTeam;
  }

  String get _resolvedSummary {
    final summary = widget.analysisData?['technical_summary']?.toString().trim();
    if (summary != null && summary.isNotEmpty) return summary;
    final prompt = widget.initialPrompt?.trim();
    if (prompt != null && prompt.isNotEmpty) return prompt;
    return 'Mobile app for e-commerce with payment integration and admin panel.';
  }

  String get _resolvedProjectTitle {
    final title = widget.analysisData?['suggested_title']?.toString().trim();
    if (title != null && title.isNotEmpty) return title;
    final categoryName = widget.analysisData?['category_name']?.toString().trim();
    if (categoryName != null && categoryName.isNotEmpty) {
      return '$categoryName Project';
    }
    return 'Mobile App for E-Commerce';
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
          requiredSkills: _resolvedRequiredSkills,
          recommendedTeam: _resolvedRecommendedTeam,
          projectSummary: _resolvedSummary,
          projectTitle: _resolvedProjectTitle,
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

  Widget _buildModeTogglePill(BuildContext context, {bool fullWidth = false}) {
    final colorScheme = context.colorScheme;
    final tokens = context.skavia;
    final isChat = _currentMode == AiScreenMode.chat;

    Widget buildOption({
      required String label,
      required bool active,
      required VoidCallback onTap,
    }) {
      final pill = GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: fullWidth ? 12 : 8,
            vertical: fullWidth ? 7 : 4,
          ),
          alignment: fullWidth ? Alignment.center : null,
          decoration: BoxDecoration(
            color: active ? tokens.brandAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: active ? tokens.onBrandAccent : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
      return fullWidth ? Expanded(child: pill) : pill;
    }

    return Container(
      margin: fullWidth
          ? const EdgeInsets.fromLTRB(16, 4, 16, 8)
          : const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tokens.subtleBorder),
      ),
      child: Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          buildOption(
            label: 'Chat',
            active: isChat,
            onTap: () => setState(() => _currentMode = AiScreenMode.chat),
          ),
          buildOption(
            label: 'Match',
            active: !isChat,
            onTap: () => setState(() => _currentMode = AiScreenMode.analyzing),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final compactModeBar = width < 360 || textScale > 1.3;

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
        actions: compactModeBar ? null : [_buildModeTogglePill(context)],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (compactModeBar) _buildModeTogglePill(context, fullWidth: true),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildCurrentView(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
