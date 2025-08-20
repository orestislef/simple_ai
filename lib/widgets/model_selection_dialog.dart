import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class ModelSelectionDialog extends StatelessWidget {
  final List<OpenAIModelModel> models;

  const ModelSelectionDialog({
    super.key,
    required this.models,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.memory),
          SizedBox(width: 8),
          Text('Choose AI Model'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 300,
        child: models.isEmpty 
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No models available'),
                    Text(
                      'Please check your server connection',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.separated(
                itemCount: models.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final model = models[index];
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(
                      model.id,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Owned by ${model.ownedBy}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pop(model),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  static Future<OpenAIModelModel?> show(
    BuildContext context,
    List<OpenAIModelModel> models,
  ) {
    return showDialog<OpenAIModelModel>(
      context: context,
      builder: (context) => ModelSelectionDialog(models: models),
    );
  }
}