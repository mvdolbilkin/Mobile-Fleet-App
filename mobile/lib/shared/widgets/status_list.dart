import 'package:flutter/material.dart';

class StatusList extends StatelessWidget {
  final List<({Color color, String text, VoidCallback? onTap})> items;

  const StatusList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.length > 3) {
      return Wrap(
        spacing: 12,
        runSpacing: 8,
        children: items.map((item) => _StatusRow(item: item)).toList(),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: _StatusRow(item: item),
            ),
          )
          .toList(),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final ({Color color, String text, VoidCallback? onTap}) item;

  const _StatusRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          item.text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'Yandex Sans Text',
          ),
        ),
      ],
    );

    if (item.onTap != null) {
      return InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: content,
        ),
      );
    }

    return content;
  }
}
