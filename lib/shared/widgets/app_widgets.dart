import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_theme.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: bgColor ?? color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 16),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          subtitle!,
                          style: AppTextStyles.caption.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.stat.copyWith(color: color, fontSize: 20),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: AppTextStyles.body2.copyWith(fontSize: 11),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.heading2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel!,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

class AvatarWidget extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;

  const AvatarWidget({
    super.key,
    required this.initials,
    required this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.32,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class HCMAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;

  const HCMAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBackButton = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            )
          : leading,
      title: Text(
        title,
        style: AppTextStyles.heading2.copyWith(color: Colors.white),
        overflow: TextOverflow.ellipsis,
      ),
      actions: actions,
      flexibleSpace: Stack(
        children: [
          Container(color: AppColors.primaryDark),
          BlobAccentBackdrop(color: AppColors.primary),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.primaryLighter,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                style: AppTextStyles.heading2, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.body2, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 24), action!],
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor ?? AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.body1,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill badge used for role identity (banners, employee tags).
class RoleBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const RoleBadge({super.key, required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.label.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Soft abstract circles used as a hero-header backdrop instead of a flat
/// gradient. Must be placed inside a [Stack] — it positions itself with
/// [Positioned.fill].
class BlobAccentBackdrop extends StatelessWidget {
  final Color color;
  const BlobAccentBackdrop({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(painter: _BlobPainter(color)),
      ),
    );
  }
}

/// Same backdrop as [BlobAccentBackdrop] but with a slow looping drift —
/// the "alive" motion substitute for a video background. Must be placed
/// inside a [Stack].
class AnimatedBlobAccentBackdrop extends StatefulWidget {
  final Color color;
  const AnimatedBlobAccentBackdrop({super.key, required this.color});

  @override
  State<AnimatedBlobAccentBackdrop> createState() => _AnimatedBlobAccentBackdropState();
}

class _AnimatedBlobAccentBackdropState extends State<AnimatedBlobAccentBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            final t = _ctrl.value;
            return Transform.translate(
              offset: Offset(10 * (t - 0.5), 8 * (0.5 - t)),
              child: CustomPaint(painter: _BlobPainter(widget.color)),
            );
          },
        ),
      ),
    );
  }
}

class _BlobPainter extends CustomPainter {
  final Color color;
  const _BlobPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.02),
      size.width * 0.45,
      Paint()..color = color.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset(size.width * 0.02, size.height * 0.98),
      size.width * 0.32,
      Paint()..color = color.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      Offset(size.width * 0.55, size.height * 0.55),
      size.width * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.08),
    );
  }

  @override
  bool shouldRepaint(covariant _BlobPainter oldDelegate) => oldDelegate.color != color;
}

/// Drop-in pill-indicator replacement for [TabBar], meant to sit on a
/// colored hero header (the unselected track is translucent white, the
/// selected pill is solid white with [color] label text).
class SegmentedTabBar extends StatelessWidget implements PreferredSizeWidget {
  final TabController controller;
  final List<String> labels;
  final Color color;
  final ValueChanged<int>? onTap;

  const SegmentedTabBar({
    super.key,
    required this.controller,
    required this.labels,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: controller,
        onTap: onTap,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: color,
        unselectedLabelColor: Colors.white,
        labelStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: AppTextStyles.label,
        tabs: labels.map((l) => Tab(text: l)).toList(),
      ),
    );
  }

  // Actual rendered height = TabBar's default 46 + the Container's own
  // padding (8) + bottom margin (12). Under-reporting this causes the
  // Sliver layout to reserve too little space, so the bar bleeds upward
  // into whatever sits above it in the header.
  @override
  Size get preferredSize => const Size.fromHeight(66);
}

/// Large, featured stat — the "spotlight" card in an asymmetric dashboard
/// layout, as opposed to the uniform [StatCard] grid.
class HeroStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const HeroStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.30),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              top: -10,
              child: Icon(icon, size: 90, color: Colors.white.withValues(alpha: 0.12)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 14),
                Text(value, style: AppTextStyles.stat.copyWith(color: Colors.white, fontSize: 32)),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.body1.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      subtitle!,
                      style: AppTextStyles.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FloatingNavItem {
  final IconData icon;
  final String label;
  const FloatingNavItem({required this.icon, required this.label});
}

/// Pill-shaped, inset, elevated bottom nav — replaces a plain full-width bar.
class FloatingNavBar extends StatelessWidget {
  final List<FloatingNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final item = items[i];
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(i),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(item.icon, size: 22, color: selected ? activeColor : AppColors.textLight),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.caption.copyWith(
                            color: selected ? activeColor : AppColors.textLight,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Single shimmering placeholder block, for loading states.
class ShimmerBox extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  const ShimmerBox({super.key, required this.height, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: borderRadius ?? BorderRadius.circular(14),
        ),
      ),
    );
  }
}

/// A column of [ShimmerBox] placeholders standing in for a list while it
/// loads, instead of a bare centered spinner.
class ShimmerListPlaceholder extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const ShimmerListPlaceholder({super.key, this.itemCount = 6, this.itemHeight = 72});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) => ShimmerBox(height: itemHeight),
    );
  }
}

/// One column of a "connected" stats row — several of these plus
/// [ConnectedStatDivider] in a [Row] form a single card with no gaps
/// between stats, as opposed to a grid of separate [StatCard]s.
class ConnectedStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const ConnectedStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 6),
        Text(value, style: AppTextStyles.heading2.copyWith(color: color)),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class ConnectedStatDivider extends StatelessWidget {
  const ConnectedStatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: AppColors.divider);
  }
}
