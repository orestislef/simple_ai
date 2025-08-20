import 'package:flutter/material.dart';
import '../services/prompt_service.dart';

class PromptManagementDialog extends StatefulWidget {
  final Function(String) onPromptSelected;

  const PromptManagementDialog({
    super.key,
    required this.onPromptSelected,
  });

  @override
  State<PromptManagementDialog> createState() => _PromptManagementDialogState();
}

class _PromptManagementDialogState extends State<PromptManagementDialog> {
  final PromptService _promptService = PromptService();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.bookmark),
          SizedBox(width: 8),
          Text('Manage Prompts'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddPromptDialog,
                icon: const Icon(Icons.add),
                label: const Text('Add New Prompt'),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListenableBuilder(
                listenable: _promptService,
                builder: (context, child) {
                  final prompts = _promptService.savedPrompts;

                  if (prompts.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bookmark_border,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No saved prompts'),
                          Text(
                            'Add some prompts to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: prompts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final prompt = prompts[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.text_snippet,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        title: Text(
                          prompt,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () {
                                widget.onPromptSelected(prompt);
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.send),
                              tooltip: 'Use this prompt',
                            ),
                            IconButton(
                              onPressed: () => _deletePrompt(index),
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Delete prompt',
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  void _showAddPromptDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Prompt'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Enter your prompt',
            hintText: 'Type your prompt here...',
          ),
          maxLines: 3,
          minLines: 1,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final prompt = controller.text.trim();
              if (prompt.isNotEmpty) {
                _promptService.addPrompt(prompt);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _deletePrompt(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prompt'),
        content: const Text('Are you sure you want to delete this prompt?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _promptService.removePromptAt(index);
              Navigator.of(context).pop();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  static Future<void> show(
    BuildContext context,
    Function(String) onPromptSelected,
  ) {
    return showDialog(
      context: context,
      builder: (context) => PromptManagementDialog(
        onPromptSelected: onPromptSelected,
      ),
    );
  }
}
