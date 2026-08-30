import 'package:equatable/equatable.dart';

import '../../core/constants/body_region.dart';

enum OccupationType { administrativo, conductor, manual, teletrabajo, otro }

enum SittingHours { lessThan2h, from2to4h, from4to6h, moreThan6h }

enum ActivityLevel { sedentario, leve, moderado, intenso }

enum AppGoal { postura, estres, energia, dolor, fitness }

enum SubscriptionTier { free, premium }

enum AvatarEmotion { happy, neutral, focused, proud, concerned }

enum ShoeStyle { sneakers, formal, boots, sandals }

enum PantsStyle { jeans, formal, shorts, tracksuit }

enum TopStyle { tshirt, shirt, hoodie, suit }

enum HairStyle { short, medium, long, curly, bald }

enum EyeColor { brown, blue, green, hazel, black }

enum SkinTone { light, mediumLight, medium, mediumDark, dark }

enum GlassesStyle { none, round, rectangular, oval }

enum HatStyle { none, cap, beanie, formal }

enum BeardStyle { none, stubble, short, full }

class AvatarConfig extends Equatable {
  final ShoeStyle shoes;
  final PantsStyle pants;
  final TopStyle top;
  final String shoeColor;
  final String pantsColor;
  final String topColor;
  final GlassesStyle glasses;
  final HatStyle hat;
  final HairStyle hair;
  final String hairColor;
  final EyeColor eyeColor;
  final SkinTone skinTone;
  final BeardStyle beard;
  final AvatarEmotion currentEmotion;

  const AvatarConfig({
    this.shoes = ShoeStyle.sneakers,
    this.pants = PantsStyle.jeans,
    this.top = TopStyle.tshirt,
    this.shoeColor = '#FFFFFF',
    this.pantsColor = '#2563EB',
    this.topColor = '#2DD4BF',
    this.glasses = GlassesStyle.none,
    this.hat = HatStyle.none,
    this.hair = HairStyle.short,
    this.hairColor = '#1A1A1A',
    this.eyeColor = EyeColor.brown,
    this.skinTone = SkinTone.medium,
    this.beard = BeardStyle.none,
    this.currentEmotion = AvatarEmotion.neutral,
  });

  AvatarConfig copyWith({
    ShoeStyle? shoes,
    PantsStyle? pants,
    TopStyle? top,
    String? shoeColor,
    String? pantsColor,
    String? topColor,
    GlassesStyle? glasses,
    HatStyle? hat,
    HairStyle? hair,
    String? hairColor,
    EyeColor? eyeColor,
    SkinTone? skinTone,
    BeardStyle? beard,
    AvatarEmotion? currentEmotion,
  }) {
    return AvatarConfig(
      shoes: shoes ?? this.shoes,
      pants: pants ?? this.pants,
      top: top ?? this.top,
      shoeColor: shoeColor ?? this.shoeColor,
      pantsColor: pantsColor ?? this.pantsColor,
      topColor: topColor ?? this.topColor,
      glasses: glasses ?? this.glasses,
      hat: hat ?? this.hat,
      hair: hair ?? this.hair,
      hairColor: hairColor ?? this.hairColor,
      eyeColor: eyeColor ?? this.eyeColor,
      skinTone: skinTone ?? this.skinTone,
      beard: beard ?? this.beard,
      currentEmotion: currentEmotion ?? this.currentEmotion,
    );
  }

  Map<String, dynamic> toJson() => {
        'shoes': shoes.name,
        'pants': pants.name,
        'top': top.name,
        'shoeColor': shoeColor,
        'pantsColor': pantsColor,
        'topColor': topColor,
        'glasses': glasses.name,
        'hat': hat.name,
        'hair': hair.name,
        'hairColor': hairColor,
        'eyeColor': eyeColor.name,
        'skinTone': skinTone.name,
        'beard': beard.name,
        'currentEmotion': currentEmotion.name,
      };

  factory AvatarConfig.fromJson(Map<String, dynamic> json) => AvatarConfig(
        shoes: ShoeStyle.values.byName(json['shoes'] as String? ?? 'sneakers'),
        pants: PantsStyle.values.byName(json['pants'] as String? ?? 'jeans'),
        top: TopStyle.values.byName(json['top'] as String? ?? 'tshirt'),
        shoeColor: json['shoeColor'] as String? ?? '#FFFFFF',
        pantsColor: json['pantsColor'] as String? ?? '#2563EB',
        topColor: json['topColor'] as String? ?? '#2DD4BF',
        glasses:
            GlassesStyle.values.byName(json['glasses'] as String? ?? 'none'),
        hat: HatStyle.values.byName(json['hat'] as String? ?? 'none'),
        hair: HairStyle.values.byName(json['hair'] as String? ?? 'short'),
        hairColor: json['hairColor'] as String? ?? '#1A1A1A',
        eyeColor:
            EyeColor.values.byName(json['eyeColor'] as String? ?? 'brown'),
        skinTone:
            SkinTone.values.byName(json['skinTone'] as String? ?? 'medium'),
        beard: BeardStyle.values.byName(json['beard'] as String? ?? 'none'),
        currentEmotion: AvatarEmotion.values
            .byName(json['currentEmotion'] as String? ?? 'neutral'),
      );

  @override
  List<Object?> get props => [
        shoes,
        pants,
        top,
        shoeColor,
        pantsColor,
        topColor,
        glasses,
        hat,
        hair,
        hairColor,
        eyeColor,
        skinTone,
        beard,
        currentEmotion,
      ];
}

class UserProfile extends Equatable {
  final String uid;
  final String displayName;
  final String? email;
  final OccupationType occupation;
  final SittingHours sittingHours;
  final List<BodyRegion> painAreas;
  final ActivityLevel activityLevel;
  final List<AppGoal> goals;
  final AvatarConfig avatarConfig;
  final SubscriptionTier tier;
  final DateTime createdAt;
  final int totalXP;
  final int currentLevel;

  const UserProfile({
    required this.uid,
    required this.displayName,
    this.email,
    this.occupation = OccupationType.teletrabajo,
    this.sittingHours = SittingHours.from4to6h,
    this.painAreas = const [],
    this.activityLevel = ActivityLevel.sedentario,
    this.goals = const [],
    this.avatarConfig = const AvatarConfig(),
    this.tier = SubscriptionTier.free,
    required this.createdAt,
    this.totalXP = 0,
    this.currentLevel = 1,
  });

  bool get isPremium => tier == SubscriptionTier.premium;

  UserProfile copyWith({
    String? displayName,
    String? email,
    OccupationType? occupation,
    SittingHours? sittingHours,
    List<BodyRegion>? painAreas,
    ActivityLevel? activityLevel,
    List<AppGoal>? goals,
    AvatarConfig? avatarConfig,
    SubscriptionTier? tier,
    int? totalXP,
    int? currentLevel,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      sittingHours: sittingHours ?? this.sittingHours,
      painAreas: painAreas ?? this.painAreas,
      activityLevel: activityLevel ?? this.activityLevel,
      goals: goals ?? this.goals,
      avatarConfig: avatarConfig ?? this.avatarConfig,
      tier: tier ?? this.tier,
      createdAt: createdAt,
      totalXP: totalXP ?? this.totalXP,
      currentLevel: currentLevel ?? this.currentLevel,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'displayName': displayName,
        'email': email,
        'occupation': occupation.name,
        'sittingHours': sittingHours.name,
        'painAreas': painAreas.map((r) => r.name).toList(),
        'activityLevel': activityLevel.name,
        'goals': goals.map((g) => g.name).toList(),
        'avatarConfig': avatarConfig.toJson(),
        'tier': tier.name,
        'createdAt': createdAt.toIso8601String(),
        'totalXP': totalXP,
        'currentLevel': currentLevel,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        uid: json['uid'] as String,
        displayName: json['displayName'] as String,
        email: json['email'] as String?,
        occupation: OccupationType.values
            .byName(json['occupation'] as String? ?? 'teletrabajo'),
        sittingHours: SittingHours.values
            .byName(json['sittingHours'] as String? ?? 'from4to6h'),
        painAreas: (json['painAreas'] as List<dynamic>? ?? [])
            .map((r) => BodyRegion.values.byName(r as String))
            .toList(),
        activityLevel: ActivityLevel.values
            .byName(json['activityLevel'] as String? ?? 'sedentario'),
        goals: (json['goals'] as List<dynamic>? ?? [])
            .map((g) => AppGoal.values.byName(g as String))
            .toList(),
        avatarConfig: AvatarConfig.fromJson(
            json['avatarConfig'] as Map<String, dynamic>? ?? {}),
        tier: SubscriptionTier.values.byName(json['tier'] as String? ?? 'free'),
        createdAt: DateTime.parse(json['createdAt'] as String),
        totalXP: json['totalXP'] as int? ?? 0,
        currentLevel: json['currentLevel'] as int? ?? 1,
      );

  @override
  List<Object?> get props => [
        uid,
        displayName,
        email,
        occupation,
        sittingHours,
        painAreas,
        activityLevel,
        goals,
        avatarConfig,
        tier,
        createdAt,
        totalXP,
        currentLevel
      ];
}
