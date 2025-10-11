import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:trentify/screens/home/product_detail.dart';

class ReviewTileWidget extends StatelessWidget {
  final ReviewData r;
  const ReviewTileWidget(this.r);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundImage: AssetImage('assets/images/avatar/01.png'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.author,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(r.ago, style: text.bodySmall),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final filled = i < r.stars.round();
              return Icon(filled ? Icons.star : Icons.star_border, size: 16);
            }),
          ),
          const SizedBox(height: 6),
          Text('Variant : ${r.variant}', style: text.bodySmall),
          const SizedBox(height: 8),
          Text(r.text),
          if (r.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: r.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    r.photos[i],
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
