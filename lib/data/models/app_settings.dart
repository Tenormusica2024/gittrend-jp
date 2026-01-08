import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool notificationEnabled;

  @HiveField(1)
  int notificationHour;

  @HiveField(2)
  int notificationMinute;

  @HiveField(3)
  String? defaultLanguageFilter;

  @HiveField(4)
  int minimumStars;

  @HiveField(5)
  bool japaneseOnlyNotification;

  AppSettings({
    this.notificationEnabled = true,
    this.notificationHour = 8,
    this.notificationMinute = 0,
    this.defaultLanguageFilter,
    this.minimumStars = 100,
    this.japaneseOnlyNotification = false,
  });
}
