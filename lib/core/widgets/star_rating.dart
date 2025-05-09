import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StarRating extends StatelessWidget {
  final double rating; // 0-10 (atau 0-5 jika ingin)
  final double size;
  final Color color;
  final int maxStars;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 16,
    this.color = const Color(0xFFEC2626),
    this.maxStars = 5,
  });

  @override
  Widget build(BuildContext context) {
    final double starRating = (rating / 2).clamp(0, maxStars.toDouble());
    final int fullStars = starRating.floor();
    final bool hasHalfStar = (starRating - fullStars) >= 0.5;
    final List<Widget> stars = [];
    for (int i = 0; i < maxStars; i++) {
      if (i < fullStars) {
        stars.add(Padding(
          padding: const EdgeInsets.only(right: 2),
          child: SvgPicture.asset(
            'assets/icons/star.svg',
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size,
          ),
        ));
      } else if (i == fullStars && hasHalfStar) {
        stars.add(Padding(
          padding: const EdgeInsets.only(right: 2),
          child: SvgPicture.asset(
            'assets/icons/halfstar.svg',
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: size,
            height: size,
          ),
        ));
      }
      // Tidak perlu bintang kosong
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
} 