import 'package:flutter/material.dart';

class DisclaimerBanner extends StatelessWidget {
  final VoidCallback onClose;
  const DisclaimerBanner({super.key, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Low-level search API, results may not be completely accurate.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            )
          ],
        ),
      ),
    );
  }
}
