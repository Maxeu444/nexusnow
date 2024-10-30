import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/esport_notifier.dart';

class EditDialog extends ConsumerWidget {
  final String title;
  final String id;
  final String type;

  EditDialog({
    required this.title,
    required this.id,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController _controller = TextEditingController();

    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(hintText: "Entrez le nouveau nom"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              final notifier = ref.read(esportNotifierProvider.notifier);
              notifier.updateFavorite(id, type);
              Navigator.of(context).pop();
            }
          },
          child: Text("Modifier"),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("Annuler"),
        ),
      ],
    );
  }
}
