import 'package:flutter/foundation.dart';

class Avatar3DAssets {
  Avatar3DAssets._();

  /// Flutter Web publica los recursos declarados bajo `/assets/assets/`.
  /// `model_viewer_plus` carga el GLB directamente por URL y no mediante el
  /// AssetBundle, por lo que necesita la ruta web completa.
  static String get localCoach => kIsWeb
      ? 'assets/assets/models/male_anatomy_figure.glb'
      : 'assets/models/male_anatomy_figure.glb';

  /// URL remota de respaldo (solo si el GLB local no carga en el dispositivo).
  static const String remoteCoach =
      'https://api.readyplayer.me/v1/avatars/6185a4acfb622cf1cdc49348.glb?meshLod=2';

  static String get defaultCoach => localCoach;

  /// Mapa corporal de dolor → usa el muñeco 3D local.
  static String get painBodyMap => localCoach;

  /// Coach de ejercicios → mismo muñeco 3D local.
  static String get exerciseCoach => localCoach;
}
