import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/avatar_3d_assets.dart';
import '../../../../core/constants/body_region.dart';
import '../../../../core/utils/platform_capabilities.dart';
import 'body_model_view.dart';
import 'interactive_body_model.dart';

// ─── Categorías anatómicas ────────────────────────────────────────────────────
// Agrupa las regiones corporales en secciones lógicas para facilitar
// la selección rápida y precisa por parte del usuario.

enum _BodyCategory {
  headAndNeck('Cabeza y cuello', Icons.face_retouching_natural_rounded),
  back('Espalda y columna', Icons.accessibility_new_rounded),
  torso('Pecho y abdomen', Icons.self_improvement_rounded),
  arms('Brazos y manos', Icons.sports_handball_rounded),
  hips('Caderas', Icons.accessibility_rounded),
  legs('Piernas', Icons.directions_walk_rounded);

  final String label;
  final IconData icon;
  const _BodyCategory(this.label, this.icon);
}

class _CategoryGroup {
  final _BodyCategory category;
  final List<BodyRegion> regions;
  const _CategoryGroup(this.category, this.regions);
}

const List<_CategoryGroup> _bodyGroups = [
  _CategoryGroup(_BodyCategory.headAndNeck, [
    BodyRegion.neck,
  ]),
  _CategoryGroup(_BodyCategory.back, [
    BodyRegion.upperBackLeft,
    BodyRegion.upperBackRight,
    BodyRegion.midBack,
    BodyRegion.lowerBack,
    BodyRegion.sacroiliac,
  ]),
  _CategoryGroup(_BodyCategory.torso, [
    BodyRegion.chestLeft,
    BodyRegion.chestRight,
    BodyRegion.abdomen,
  ]),
  _CategoryGroup(_BodyCategory.arms, [
    BodyRegion.shoulderLeft,
    BodyRegion.shoulderRight,
    BodyRegion.armLeft,
    BodyRegion.armRight,
    BodyRegion.forearmLeft,
    BodyRegion.forearmRight,
    BodyRegion.handLeft,
    BodyRegion.handRight,
  ]),
  _CategoryGroup(_BodyCategory.hips, [
    BodyRegion.hipLeft,
    BodyRegion.hipRight,
  ]),
  _CategoryGroup(_BodyCategory.legs, [
    BodyRegion.thighLeft,
    BodyRegion.thighRight,
    BodyRegion.kneeLeft,
    BodyRegion.kneeRight,
    BodyRegion.calfLeft,
    BodyRegion.calfRight,
    BodyRegion.ankleLeft,
    BodyRegion.ankleRight,
  ]),
];

// ─── Widget principal ────────────────────────────────────────────────────────

class BodyMapWidget extends StatefulWidget {
  final BodyRegion? selectedRegion;
  final ValueChanged<BodyRegion> onRegionTap;

  const BodyMapWidget({
    super.key,
    this.selectedRegion,
    required this.onRegionTap,
  });

  @override
  State<BodyMapWidget> createState() => _BodyMapWidgetState();
}

class _BodyMapWidgetState extends State<BodyMapWidget> {
  // ── Estado del modelo 3D (referencia visual, no interactivo) ──────────────
  // En web, model_viewer_plus no reenvia sus eventos al JavascriptChannel de
  // Flutter. El propio componente gestiona la carga y el reveal del modelo.
  bool _modelLoaded = false;
  bool _modelFailed = !supportsEmbeddedViewers;
  Timer? _loadTimer;
  BodyModelView _modelView = BodyModelView.front;
  int _modelRevision = 0;

  // ── Estado de UI del selector ─────────────────────────────────────────────
  _BodyCategory? _expandedCategory;

  @override
  void initState() {
    super.initState();
    if (_modelFailed) return;
    // Timer de seguridad: si en 45 s no llega 'load', mostramos fallback.
    _loadTimer = Timer(const Duration(seconds: 45), () {
      if (mounted && !_modelLoaded) {
        setState(() => _modelFailed = true);
      }
    });
  }

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  void _on3DModelLoad() {
    _loadTimer?.cancel();
    if (mounted && !_modelLoaded) setState(() => _modelLoaded = true);
  }

  void _on3DModelError() {
    _loadTimer?.cancel();
    if (mounted) setState(() => _modelFailed = true);
  }

  void _retry3D() {
    if (!mounted || !supportsEmbeddedViewers) return;
    setState(() {
      _modelFailed = false;
      _modelLoaded = false;
      _modelRevision += 1;
    });
    _loadTimer?.cancel();
    _loadTimer = Timer(const Duration(seconds: 45), () {
      if (mounted && !_modelLoaded) {
        setState(() => _modelFailed = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Modelo 3D (referencia visual) ────────────────────────────────────
        _buildInteractive3DViewer(context),
        const SizedBox(height: AppDimensions.sm),
        _buildModelViewSelector(context),
        const SizedBox(height: AppDimensions.lg),
        // ── Selector anatómico por categorías ────────────────────────────────
        _buildCategorySelector(context),
      ],
    );
  }

  // ── Visor 3D (referencia visual no interactiva para selección) ──────────────
  Widget _buildModelViewSelector(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SegmentedButton<BodyModelView>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment(
            value: BodyModelView.front,
            icon: Icon(Icons.accessibility_new_rounded),
            label: Text('Frente'),
          ),
          ButtonSegment(
            value: BodyModelView.back,
            icon: Icon(Icons.flip_rounded),
            label: Text('Espalda'),
          ),
        ],
        selected: {_modelView},
        onSelectionChanged: (selection) {
          setState(() => _modelView = selection.first);
        },
        style: const ButtonStyle(visualDensity: VisualDensity.compact),
      ),
    );
  }

  Widget _buildInteractive3DViewer(BuildContext context) {
    if (_modelFailed) return _build3DViewer(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedRegion = widget.selectedRegion;
    final background =
        isDark ? const Color(0xFF142124) : const Color(0xFFEEF6F6);

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewerHeight = (constraints.maxWidth * 1.12).clamp(370.0, 500.0);
        return Semantics(
          label: selectedRegion == null
              ? 'Mapa corporal 3D interactivo'
              : 'Mapa corporal 3D, zona seleccionada: ${selectedRegion.displayName}',
          child: SizedBox(
            height: viewerHeight,
            child: ColoredBox(
              color: background,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned.fill(
                    child: InteractiveBodyModel(
                      key: ValueKey(_modelRevision),
                      selectedRegion: selectedRegion,
                      view: _modelView,
                      isDark: isDark,
                      onReady: _on3DModelLoad,
                      onError: _on3DModelError,
                      onRegionSelected: (region) {
                        widget.onRegionTap(region);
                        setState(() => _expandedCategory = null);
                      },
                    ),
                  ),
                  if (!_modelLoaded)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: ColoredBox(
                          color: Color(0xB3EEF6F6),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _build3DViewer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = AppColors.painModule;
    final isSelected = widget.selectedRegion != null;

    return SizedBox(
      height: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Fondo degradado
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.withValues(alpha: 0.10),
                    Theme.of(context).cardColor,
                  ],
                ),
              ),
            ),

            // ── Si falló el modelo → fallback 2D silhouette ──────────────────
            if (_modelFailed)
              _buildFallbackSilhouette(context)
            else ...[
              // ── Loading indicator ──────────────────────────────────────────
              if (!_modelLoaded)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 36,
                        height: 36,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Cargando modelo 3D…',
                        style: TextStyle(
                          color: (isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF334155))
                              .withValues(alpha: 0.65),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── ModelViewer ────────────────────────────────────────────────
              ModelViewer(
                src: Avatar3DAssets.painBodyMap,
                alt: isSelected
                    ? 'Modelo 3D — zona seleccionada: ${widget.selectedRegion!.displayName}'
                    : 'Modelo corporal 3D de referencia',
                backgroundColor: Colors.transparent,
                loading: Loading.eager,
                reveal: Reveal.auto,
                cameraControls: true,
                autoRotate: !isSelected, // Rota si no hay selección
                autoRotateDelay: 0,
                rotationPerSecond: '20deg',
                autoPlay: false,
                interactionPrompt: InteractionPrompt.none,
                cameraOrbit: '0deg 80deg 120%',
                fieldOfView: '22deg',
                orientation: '0deg 0deg 90deg',
                disableTap: false,
                debugLogging: kDebugMode,
                onWebViewCreated: _configureWebView,
                javascriptChannels: {
                  JavascriptChannel(
                    'ModelStatus',
                    onMessageReceived: (m) {
                      debugPrint('BodyMap3D → ${m.message}');
                      final msg = m.message;
                      if (msg == 'load') {
                        _on3DModelLoad();
                      } else if (msg.startsWith('error')) {
                        _on3DModelError();
                      }
                    },
                  ),
                },
                relatedJs: _modelLoadJs,
              ),

              // ── Badge de zona seleccionada (overlay) ─────────────────────────
              if (isSelected && _modelLoaded)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                            color: color.withValues(alpha: 0.50), width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.my_location_rounded,
                              size: 14, color: color),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              widget.selectedRegion!.displayName,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Selector por categorías ─────────────────────────────────────────────────
  Widget _buildCategorySelector(BuildContext context) {
    final color = AppColors.painModule;
    final isSelected = widget.selectedRegion != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título del selector
        Row(
          children: [
            Icon(Icons.touch_app_rounded, size: 18, color: color),
            const SizedBox(width: 6),
            Text(
              'Selecciona la zona de dolor',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.sm),
        Text(
          'Toca el cuerpo o elige una zona de la lista',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
              ),
        ),
        const SizedBox(height: AppDimensions.md),

        // Expandir automáticamente la categoría que contiene la región seleccionada
        ...(_bodyGroups.map((group) {
          final isExpanded = _expandedCategory == group.category ||
              (widget.selectedRegion != null &&
                  group.regions.contains(widget.selectedRegion) &&
                  _expandedCategory == null);
          return _buildCategoryTile(context, group, isExpanded);
        })),

        // Confirmación visual
        if (isSelected) ...[
          const SizedBox(height: AppDimensions.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.md),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: color, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.selectedRegion!.displayName,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Just expand the category that contains the current selection
                    // so the user can pick a different zone.
                    final currentGroup =
                        _bodyGroups.cast<_CategoryGroup?>().firstWhere(
                              (g) => g!.regions.contains(widget.selectedRegion),
                              orElse: () => null,
                            );
                    setState(() {
                      _expandedCategory = currentGroup?.category;
                    });
                  },
                  child: const Text('Cambiar'),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Tile de categoría expandible ────────────────────────────────────────────
  Widget _buildCategoryTile(
      BuildContext context, _CategoryGroup group, bool isExpanded) {
    final color = AppColors.painModule;
    final hasSelection = widget.selectedRegion != null &&
        group.regions.contains(widget.selectedRegion);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _expandedCategory =
                  _expandedCategory == group.category ? null : group.category;
            });
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasSelection
                  ? color.withValues(alpha: 0.06)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: hasSelection
                    ? color.withValues(alpha: 0.30)
                    : Theme.of(context).dividerColor,
              ),
            ),
            child: Column(
              children: [
                // Cabecera de la categoría
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(group.category.icon, size: 20, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.category.label,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          if (hasSelection && !isExpanded)
                            Text(
                              widget.selectedRegion!.displayName,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          else
                            Text(
                              '${group.regions.length} zonas',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.45),
                                  ),
                            ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isExpanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.50),
                      ),
                    ),
                  ],
                ),

                // Lista de regiones (expandible)
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: group.regions.map((region) {
                        final isSel = region == widget.selectedRegion;
                        return ActionChip(
                          label: Text(region.displayName),
                          onPressed: () {
                            widget.onRegionTap(region);
                            setState(() {
                              _expandedCategory = null;
                            });
                          },
                          backgroundColor:
                              isSel ? color : color.withValues(alpha: 0.08),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                          avatar: isSel
                              ? const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 16)
                              : null,
                          side: BorderSide(
                            color:
                                isSel ? color : color.withValues(alpha: 0.20),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(99),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Fallback silhouette (si el 3D falla) ────────────────────────────────────
  Widget _buildFallbackSilhouette(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.accessibility_new_rounded,
            size: 100,
            color: AppColors.painModule.withValues(alpha: 0.30),
          ),
          const SizedBox(height: 8),
          Text(
            'Modelo 3D no disponible',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.40),
                ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _retry3D,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reintentar'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.painModule,
              side: BorderSide(
                  color: AppColors.painModule.withValues(alpha: 0.45)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers 3D ───────────────────────────────────────────────────────────
  void _configureWebView(WebViewController controller) {
    controller.setBackgroundColor(Colors.transparent);
    final platform = controller.platform;
    if (platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(kDebugMode);
      platform.setMediaPlaybackRequiresUserGesture(false);
    }
  }

  static const String _modelLoadJs = r'''
    (function() {
      function post(msg) {
        try { ModelStatus.postMessage(msg); } catch(e) {}
      }

      window.onerror = function(msg, src, line) {
        post('jserror:' + msg + ' @' + line);
        if (msg && (msg.indexOf('WebGL context') !== -1 ||
                    msg.indexOf('getFieldOfView') !== -1 ||
                    msg.indexOf('WebGL2') !== -1)) {
          post('error:webgl');
        }
      };

      var _origCE = console.error;
      console.error = function() {
        var msg = Array.prototype.join.call(arguments, ' ');
        _origCE.apply(console, arguments);
        if (msg.indexOf('Error creating WebGL context') !== -1 ||
            msg.indexOf('Failed to create a WebGL2') !== -1) {
          post('error:webgl');
        }
      };

      try {
        var canvas = document.createElement('canvas');
        var gl2 = canvas.getContext('webgl2');
        var gl1 = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
        if (!gl2 && !gl1) { post('error:no-webgl'); return; }
        if (!gl2 && gl1) { post('error:no-webgl2'); return; }
        post('webgl:ok');
      } catch(e) { post('error:webgl:' + e.message); return; }

      var mv = document.querySelector('model-viewer');
      if (!mv) { post('error:no-element'); return; }

      mv.addEventListener('load', function() { post('load'); });
      mv.addEventListener('error', function(e) {
        post('error:mv:' + (e.type || '?'));
      });

      requestAnimationFrame(function() {
        if (mv.loaded) post('load');
      });
    })();
  ''';
}
