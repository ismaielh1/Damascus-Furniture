import 'package:flutter/material.dart';

class AgreementActionsPanel extends StatelessWidget {
  final bool isUpdating;
  final VoidCallback onMarkAsCompleted;
  final VoidCallback onPostpone;
  final VoidCallback onCancel;

  const AgreementActionsPanel({
    super.key,
    required this.isUpdating,
    required this.onMarkAsCompleted,
    required this.onPostpone,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الإجراءات', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        if (isUpdating)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                onPressed: onMarkAsCompleted,
                icon: Icons.check_circle_outline,
                label: 'تم التسليم',
                color: Colors.green,
              ),
              _buildActionButton(
                onPressed: onPostpone,
                icon: Icons.edit_calendar_outlined,
                label: 'تأجيل',
                color: Colors.orange,
              ),
              _buildActionButton(
                onPressed: onCancel,
                icon: Icons.cancel_outlined,
                label: 'إلغاء',
                color: Colors.red,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}
