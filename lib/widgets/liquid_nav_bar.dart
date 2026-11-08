import 'package:flutter/material.dart';

import '../theme.dart';

class NavItemData {
  final IconData icon;
  final String label;
  final List<Color> colors;
  const NavItemData(this.icon, this.label, this.colors);
}

/// Bottom bar dengan animasi "liquid": tonjolan cair mengikuti tab aktif,
/// melebar saat bergerak (stretch) lalu memantul kembali, dengan bola 3D di dalamnya.
class LiquidNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  final List<NavItemData> items;

  const LiquidNavBar({
    super.key,
    required this.index,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: LayoutBuilder(
        builder: (context, box) {
          final w = box.maxWidth;
          final n = items.length;
          final itemW = w / n;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(end: index.toDouble()),
            duration: const Duration(milliseconds: 750),
            curve: Curves.easeOutBack,
            builder: (context, pos, _) {
              final stretch = (pos - index).abs().clamp(0.0, 3.0);
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _BarPainter(pos: pos, n: n, stretch: stretch),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 34,
                    bottom: 6,
                    child: Row(
                      children: [
                        for (int i = 0; i < n; i++)
                          Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(i),
                              child: _NavButton(
                                data: items[i],
                                selected: i == index,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // bola 3D yang meluncur mengikuti tonjolan cair
                  Positioned(
                    left: (pos + .5) * itemW - 27,
                    top: 1,
                    width: 54,
                    height: 54,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: items[index].colors,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: items[index].colors.last.withValues(alpha: .6),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: .35),
                              blurRadius: 4,
                              offset: const Offset(-2, -2),
                              spreadRadius: -3,
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, anim) => ScaleTransition(
                            scale: anim,
                            child: RotationTransition(
                              turns: Tween<double>(begin: -.1, end: 0).animate(anim),
                              child: child,
                            ),
                          ),
                          child: Icon(
                            items[index].icon,
                            key: ValueKey(index),
                            color: Colors.white,
                            size: 26,
                            shadows: const [
                              Shadow(
                                  color: Colors.black38,
                                  blurRadius: 5,
                                  offset: Offset(1.5, 3)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavItemData data;
  final bool selected;
  const _NavButton({required this.data, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: selected ? 0 : 1,
          child: ShaderMask(
            shaderCallback: (r) => LinearGradient(colors: data.colors).createShader(r),
            child: Icon(data.icon, size: 26, color: Colors.white),
          ),
        ),
        const SizedBox(height: 3),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
            color: selected ? Colors.white : Colors.white54,
          ),
          child: Text(data.label),
        ),
      ],
    );
  }
}

class _BarPainter extends CustomPainter {
  final double pos;
  final int n;
  final double stretch;
  _BarPainter({required this.pos, required this.n, required this.stretch});

  @override
  void paint(Canvas canvas, Size size) {
    const topY = 32.0;
    final w = size.width;
    final h = size.height;
    final itemW = w / n;

    final bw = itemW * .5 + stretch.clamp(0.0, 1.5) * itemW * .28;
    final cx = ((pos + .5) * itemW).clamp(bw * .6, w - bw * .6).toDouble();

    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTRB(0, topY, w, h - 6),
        const Radius.circular(30),
      ));

    final bump = Path()
      ..moveTo(cx - bw, topY + 1)
      ..cubicTo(cx - bw * .45, topY + 1, cx - bw * .55, 4, cx, 4)
      ..cubicTo(cx + bw * .55, 4, cx + bw * .45, topY + 1, cx + bw, topY + 1)
      ..close();

    final shape = Path.combine(PathOperation.union, body, bump);

    canvas.drawShadow(shape, Colors.black, 14, false);
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF26264A), Color(0xFF14142A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(shape, paint);
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.white.withValues(alpha: .09),
    );
    // kilau tipis di tepi atas
    canvas.drawPath(
      shape,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = LinearGradient(
          colors: [
            JP.purple.withValues(alpha: 0),
            JP.pink.withValues(alpha: .35),
            JP.purple.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, w, 40)),
    );
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.pos != pos || old.stretch != stretch || old.n != n;
}
