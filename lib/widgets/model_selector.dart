import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class ModelSelector extends StatefulWidget {
  final OpenAIModelModel? selectedModel;
  final List<OpenAIModelModel> availableModels;
  final Function(OpenAIModelModel) onModelSelected;
  final VoidCallback onRefreshModels;
  final bool isLoading;

  const ModelSelector({
    super.key,
    required this.selectedModel,
    required this.availableModels,
    required this.onModelSelected,
    required this.onRefreshModels,
    this.isLoading = false,
  });

  @override
  State<ModelSelector> createState() => _ModelSelectorState();
}

class _ModelSelectorState extends State<ModelSelector> {
  @override
  Widget build(BuildContext context) {
    if (widget.availableModels.isEmpty) {
      return IconButton(
        onPressed: widget.onRefreshModels,
        icon: widget.isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.refresh),
        tooltip: 'Load models',
      );
    }

    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: PopupMenuThemeData(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey[850] 
              : Colors.white,
          textStyle: TextStyle(
            color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black87,
          ),
        ),
      ),
      child: PopupMenuButton<OpenAIModelModel>(
        onSelected: widget.onModelSelected,
        tooltip: 'Select AI Model',
        itemBuilder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return widget.availableModels.map((model) {
            final isSelected = widget.selectedModel?.id == model.id;
            return PopupMenuItem<OpenAIModelModel>(
              value: model,
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                    size: 18,
                    color: isSelected 
                        ? Theme.of(context).primaryColor 
                        : (isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          model.id,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (model.ownedBy.isNotEmpty)
                          Text(
                            model.ownedBy,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList();
        },
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                widget.selectedModel?.id ?? 'Select Model',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 18,
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
        ),
      ),
    );
  }
}