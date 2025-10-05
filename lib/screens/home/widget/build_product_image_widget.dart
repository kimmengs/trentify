import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';

Widget BuildProductImageWidget(String pathOrUrl) {
  final isNetwork = pathOrUrl.startsWith('http');
  if (isNetwork) {
    return CachedNetworkImage(
      imageUrl: pathOrUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      placeholder: (_, __) => const _ImagePlaceholder(),
      errorWidget: (_, __, ___) => const _ImagePlaceholder(),
    );
  } else {
    // Asset
    return Image.asset(
      pathOrUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F4),
      alignment: Alignment.center,
      child: const Icon(
        CupertinoIcons.photo,
        size: 38,
        color: CupertinoColors.systemGrey3,
      ),
    );
  }
}
