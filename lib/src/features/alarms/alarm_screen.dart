
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import '../../services/music_service.dart';

// Top level function for Alarm Manager (Android)
@pragma('vm:entry-point')
void alarmCallback(int id) {
  // Since this runs in an isolate, we cannot easily access the UI or plugins initialized in main isolate
  // without re-initializing.
  // However, local_notifications plugin supports background execution if set up correctly.
  // Ideally, we send a notification that the user can tap to open the music.

  // NOTE: In a real production app, we would re-initialize the notification plugin here
  // and show the notification.
  print('Alarm fired in background: $id');
}

class AlarmScreen extends ConsumerStatefulWidget {
  const AlarmScreen({super.key});

  @override
  ConsumerState<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends ConsumerState<AlarmScreen> {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final List<Map<String, dynamic>> _alarms = []; // In-memory

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        if (response.payload != null) {
          launchUrl(Uri.parse(response.payload!));
        }
      },
    );

    if (Platform.isAndroid) {
       await AndroidAlarmManager.initialize();
    }
  }

  Future<void> _addAlarm() async {
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) return;

    // Select Music Mock
    final musicService = ref.read(musicServiceProvider);
    final songs = await musicService.searchMusic('Morning');

    if (!mounted) return;

    final selectedSong = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Wake Up Music'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: Icon(song['type'] == 'Spotify' ? Icons.music_note : Icons.video_library),
                title: Text(song['title']!),
                subtitle: Text(song['type']!),
                onTap: () => Navigator.pop(context, song),
              );
            },
          ),
        ),
      ),
    );

    if (selectedSong == null) return;

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final id = scheduledDate.hashCode;

    // Logic:
    // Android: Use AlarmManager to wake up device + Notification
    // iOS: Use LocalNotification (Reminder)

    if (Platform.isAndroid) {
        try {
            await AndroidAlarmManager.oneShotAt(
                scheduledDate,
                id,
                alarmCallback,
                exact: true,
                wakeup: true,
                allowWhileIdle: true,
            );
        } catch (e) {
            debugPrint('Android Alarm Error: $e');
        }
    }

    // Schedule Notification for both (as fallback for Android UI, and primary for iOS)
    try {
        await _notificationsPlugin.zonedSchedule(
            id,
            'Wake Up!',
            'Tap to play ${selectedSong['title']}',
            tz.TZDateTime.from(scheduledDate, tz.local),
            NotificationDetails(
                android: AndroidNotificationDetails(
                    'alarm_channel',
                    'Alarms',
                    importance: Importance.max,
                    priority: Priority.high,
                    fullScreenIntent: true, // Attempt to show over lockscreen
                    sound: RawResourceAndroidNotificationSound('alarm_sound'), // mock
                ),
                iOS: const DarwinNotificationDetails(
                    presentSound: true,
                    presentAlert: true,
                    presentBanner: true,
                ),
            ),
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            payload: selectedSong['uri'],
        );
    } catch (e) {
        debugPrint('Notification Schedule Error: $e');
    }

    setState(() {
      _alarms.add({
        'time': time,
        'song': selectedSong,
        'active': true,
        'id': id,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _alarms.isEmpty
        ? const Center(child: Text('No alarms set'))
        : ListView.builder(
        itemCount: _alarms.length,
        itemBuilder: (context, index) {
          final alarm = _alarms[index];
          final time = alarm['time'] as TimeOfDay;
          final song = alarm['song'] as Map<String, String>;

          return ListTile(
            title: Text(time.format(context), style: const TextStyle(fontSize: 24)),
            subtitle: Text('Wake up to: ${song['title']}'),
            trailing: Switch(
              value: alarm['active'],
              onChanged: (val) {
                // In real app, cancel alarm/notification here
                setState(() {
                  alarm['active'] = val;
                });
              },
            ),
            onTap: () async {
                if (await canLaunchUrl(Uri.parse(song['uri']!))) {
                    await launchUrl(Uri.parse(song['uri']!));
                }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAlarm,
        child: const Icon(Icons.alarm_add),
      ),
    );
  }
}
