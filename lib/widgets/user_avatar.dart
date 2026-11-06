import 'package:flutter/material.dart';
import '../data/user_constants.dart';
import '../theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  final double radius;
  final bool showEditBadge;
  final VoidCallback? onEditPhoto;

  const UserAvatar({
    super.key,
    this.radius = 44,
    this.showEditBadge = false,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.all(3.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(
            child: SizedBox(
              width: radius * 2,
              height: radius * 2,
              child: _buildImageOrFallback(),
            ),
          ),
        ),
        if (showEditBadge)
          Positioned(
            right: 0,
            bottom: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEditPhoto,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImageOrFallback() {
    if (userPhotoUrl.trim().isEmpty) {
      return _buildFallback();
    }

    final isNetwork = userPhotoUrl.startsWith('http://') || userPhotoUrl.startsWith('https://');

    if (isNetwork) {
      return Image.network(
        userPhotoUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            color: Colors.white,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
      );
    }

    return Image.asset(
      userPhotoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.asset(
        'assets/images/WhatsApp Image 2024-07-26 at 21.38.35_94220951.jpg',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text(
          userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
          style: TextStyle(
            fontSize: radius * 0.85,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }
}
