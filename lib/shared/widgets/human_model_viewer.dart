import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../core/constants/app_colors.dart';

/// Visor de modelo 3D con fallback animado cuando WebGL no está disponible
/// (p.ej. emulador x86 sin soporte GLES).
class HumanModelViewer extends StatefulWidget {
  final String src;
  final String alt;
  final bool autoRotate;
  final bool cameraControls;
  final bool autoPlay;
  final String? cameraOrbit;
  final String? fieldOfView;
  final String? orientation;
  final String? scale;
  final Color? highlightColor;
  final String? badgeLabel;

  const HumanModelViewer({
    super.key,
    required this.src,
    required this.alt,
    this.autoRotate = false,
    this.cameraControls = true,
    this.autoPlay = true,
    this.cameraOrbit,
    this.fieldOfView,
    this.orientation,
    this.scale,
    this.highlightColor,
    this.badgeLabel,
  });

  @override
  State<HumanModelViewer> createState() => _HumanModelViewerState();
}

class _HumanModelViewerState extends State<HumanModelViewer>
    with SingleTickerProviderStateMixin {
  // En web, model_viewer_plus administra su propio estado de carga. Los
  // JavascriptChannel solo notifican de forma fiable en WebView movil.
  bool _showFallback = !kIsWeb;
  bool _modelFailed = false;
  Timer? _loadTimer;

  late final AnimationController _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    // Si en 30 s no llegó 'load', marcamos como fallido y retiramos el WebView.
    _loadTimer = Timer(const Duration(seconds: 30), () {
      if (mounted && _showFallback) {
        setState(() => _modelFailed = true);
      }
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onModelStatus(JavaScriptMessage message) {
    if (!mounted) return;
    debugPrint('HumanModelViewer: ${message.message}');
    if (message.message == 'load') {
      _loadTimer?.cancel();
      setState(() => _showFallback = false);
    } else if (message.message.startsWith('error')) {
      _loadTimer?.cancel();
      setState(() => _modelFailed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final glow = widget.highlightColor ?? AppColors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              glow.withValues(alpha: 0.14),
              Theme.of(context).cardColor,
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Fallback silhouette ──────────────────────────────────────
            if (_showFallback || _modelFailed)
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => CustomPaint(
                  painter: _SilhouettePainter(
                    color: base.withValues(alpha: 0.22),
                    glow: glow.withValues(
                      alpha: 0.12 +
                          0.10 * Curves.easeInOut.transform(_pulseCtrl.value),
                    ),
                    isDark: isDark,
                  ),
                ),
              ),

            // ── Estado de carga ──────────────────────────────────────────
            if (_showFallback && !_modelFailed)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: _StatusBadge(
                    label: 'Cargando modelo 3D…',
                    color: glow,
                  ),
                ),
              ),

            // ── Estado de error / fallback definitivo ────────────────────
            if (_modelFailed)
              Positioned(
                bottom: 14,
                left: 0,
                right: 0,
                child: Center(
                  child: _StatusBadge(
                    label: 'Vista previa',
                    color: base.withValues(alpha: 0.5),
                    icon: Icons.view_in_ar_rounded,
                  ),
                ),
              ),

            // ── ModelViewer (se retira cuando falla) ─────────────────────
            if (!_modelFailed)
              ModelViewer(
                src: widget.src,
                alt: widget.alt,
                backgroundColor: Colors.transparent,
                loading: Loading.eager,
                reveal: Reveal.auto,
                cameraControls: widget.cameraControls,
                autoRotate: widget.autoRotate,
                autoPlay: widget.autoPlay,
                disableTap: true,
                interactionPrompt: InteractionPrompt.none,
                cameraOrbit: widget.cameraOrbit,
                fieldOfView: widget.fieldOfView,
                orientation: widget.orientation,
                scale: widget.scale,
                debugLogging: kDebugMode,
                onWebViewCreated: _configureWebView,
                javascriptChannels: {
                  JavascriptChannel(
                    'ModelStatus',
                    onMessageReceived: _onModelStatus,
                  ),
                },
                relatedJs: r'''
                  const mv = document.querySelector('model-viewer');
                  if (mv) {
                    mv.addEventListener('load', () => ModelStatus.postMessage('load'));
                    mv.addEventListener('error', e => ModelStatus.postMessage('error:' + (e.detail?.type ?? 'unknown')));
                    requestAnimationFrame(() => { if (mv.loaded) ModelStatus.postMessage('load'); });
                  }
                ''',
              ),

            // ── Badge de zona ────────────────────────────────────────────
            if (widget.badgeLabel != null)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surface
                        .withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: glow.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    widget.badgeLabel!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: glow,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _configureWebView(WebViewController controller) {
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
  }
}

// ─── Status badge ────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _StatusBadge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Silhouette fallback painter ─────────────────────────────────────────────

class _SilhouettePainter extends CustomPainter {
  final Color color;
  final Color glow;
  final bool isDark;

  const _SilhouettePainter({
    required this.color,
    required this.glow,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;

    final glowP = Paint()
      ..color = glow
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    final fillP = Paint()..color = color;

    // Glow aura behind torso
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, h * 0.52), width: w * 0.52, height: h * 0.68),
      glowP,
    );

    final headR = w * 0.13;
    final headCY = headR + h * 0.010;

    // Head
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(cx, headCY), width: headR * 2, height: headR * 2.1),
      fillP,
    );

    // Neck
    _rrect(
        canvas,
        Rect.fromCenter(
            center: Offset(cx, headCY + headR * 0.9 + h * 0.025),
            width: w * 0.085,
            height: h * 0.048),
        fillP);

    final shoulderY = headCY + headR * 0.9 + h * 0.07;
    final shoulderLX = cx - w * 0.20;
    final shoulderRX = cx + w * 0.20;
    final hipY = shoulderY + h * 0.285;
    final hipLX = cx - w * 0.148;
    final hipRX = cx + w * 0.148;

    // Torso
    final torso = Path()
      ..moveTo(shoulderLX, shoulderY)
      ..lineTo(shoulderRX, shoulderY)
      ..lineTo(cx + w * 0.148, hipY)
      ..quadraticBezierTo(cx, hipY + h * 0.028, cx - w * 0.148, hipY)
      ..close();
    canvas.drawPath(torso, fillP);

    // Arms
    _limb(canvas, Offset(shoulderLX, shoulderY),
        Offset(shoulderLX - w * 0.08, shoulderY + h * 0.155), w * 0.085, fillP);
    _limb(canvas, Offset(shoulderLX - w * 0.08, shoulderY + h * 0.155),
        Offset(shoulderLX - w * 0.06, shoulderY + h * 0.295), w * 0.072, fillP);
    _limb(canvas, Offset(shoulderRX, shoulderY),
        Offset(shoulderRX + w * 0.08, shoulderY + h * 0.155), w * 0.085, fillP);
    _limb(canvas, Offset(shoulderRX + w * 0.08, shoulderY + h * 0.155),
        Offset(shoulderRX + w * 0.06, shoulderY + h * 0.295), w * 0.072, fillP);

    // Legs
    final thighLen = h * 0.195;
    final shinLen = h * 0.175;
    _limb(canvas, Offset(hipLX, hipY), Offset(hipLX, hipY + thighLen),
        w * 0.105, fillP);
    _limb(canvas, Offset(hipLX, hipY + thighLen),
        Offset(hipLX, hipY + thighLen + shinLen), w * 0.090, fillP);
    _limb(canvas, Offset(hipRX, hipY), Offset(hipRX, hipY + thighLen),
        w * 0.105, fillP);
    _limb(canvas, Offset(hipRX, hipY + thighLen),
        Offset(hipRX, hipY + thighLen + shinLen), w * 0.090, fillP);

    // Feet
    _rrect(
        canvas,
        Rect.fromCenter(
            center:
                Offset(hipLX - w * 0.02, hipY + thighLen + shinLen + h * 0.018),
            width: w * 0.148,
            height: h * 0.030),
        fillP,
        r: 8);
    _rrect(
        canvas,
        Rect.fromCenter(
            center:
                Offset(hipRX + w * 0.02, hipY + thighLen + shinLen + h * 0.018),
            width: w * 0.148,
            height: h * 0.030),
        fillP,
        r: 8);

    // Eyes
    final eyeP = Paint()
      ..color = (isDark ? Colors.black : Colors.white).withValues(alpha: 0.55);
    canvas.drawCircle(
        Offset(cx - headR * 0.34, headCY - headR * 0.06), headR * 0.14, eyeP);
    canvas.drawCircle(
        Offset(cx + headR * 0.34, headCY - headR * 0.06), headR * 0.14, eyeP);
  }

  void _rrect(Canvas canvas, Rect rect, Paint paint, {double r = 5}) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)), paint);
  }

  void _limb(Canvas canvas, Offset from, Offset to, double width, Paint paint) {
    final dir = to - from;
    final len = dir.distance;
    if (len < 1) return;
    final angle = atan2(dir.dx, -dir.dy);
    canvas.save();
    canvas.translate(from.dx, from.dy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(-width / 2, 0, width, len), Radius.circular(width / 2)),
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) =>
      old.color != color || old.glow != glow;
}
