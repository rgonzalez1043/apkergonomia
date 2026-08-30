enum BodyRegion {
  neck,
  shoulderLeft,
  shoulderRight,
  upperBackLeft,
  upperBackRight,
  midBack,
  lowerBack,
  sacroiliac,
  chestLeft,
  chestRight,
  abdomen,
  armLeft,
  armRight,
  forearmLeft,
  forearmRight,
  handLeft,
  handRight,
  hipLeft,
  hipRight,
  thighLeft,
  thighRight,
  kneeLeft,
  kneeRight,
  calfLeft,
  calfRight,
  ankleLeft,
  ankleRight;

  String get displayName {
    switch (this) {
      case BodyRegion.neck:
        return 'Cuello';
      case BodyRegion.shoulderLeft:
        return 'Hombro izquierdo';
      case BodyRegion.shoulderRight:
        return 'Hombro derecho';
      case BodyRegion.upperBackLeft:
        return 'Espalda superior izq.';
      case BodyRegion.upperBackRight:
        return 'Espalda superior der.';
      case BodyRegion.midBack:
        return 'Espalda media';
      case BodyRegion.lowerBack:
        return 'Espalda baja';
      case BodyRegion.sacroiliac:
        return 'Sacroilíaca';
      case BodyRegion.chestLeft:
        return 'Pecho izquierdo';
      case BodyRegion.chestRight:
        return 'Pecho derecho';
      case BodyRegion.abdomen:
        return 'Abdomen';
      case BodyRegion.armLeft:
        return 'Brazo izquierdo';
      case BodyRegion.armRight:
        return 'Brazo derecho';
      case BodyRegion.forearmLeft:
        return 'Antebrazo izquierdo';
      case BodyRegion.forearmRight:
        return 'Antebrazo derecho';
      case BodyRegion.handLeft:
        return 'Mano izquierda';
      case BodyRegion.handRight:
        return 'Mano derecha';
      case BodyRegion.hipLeft:
        return 'Cadera izquierda';
      case BodyRegion.hipRight:
        return 'Cadera derecha';
      case BodyRegion.thighLeft:
        return 'Muslo izquierdo';
      case BodyRegion.thighRight:
        return 'Muslo derecho';
      case BodyRegion.kneeLeft:
        return 'Rodilla izquierda';
      case BodyRegion.kneeRight:
        return 'Rodilla derecha';
      case BodyRegion.calfLeft:
        return 'Pantorrilla izquierda';
      case BodyRegion.calfRight:
        return 'Pantorrilla derecha';
      case BodyRegion.ankleLeft:
        return 'Tobillo izquierdo';
      case BodyRegion.ankleRight:
        return 'Tobillo derecho';
    }
  }
}
