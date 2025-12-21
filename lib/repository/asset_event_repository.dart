import 'dart:convert';

import 'package:flutter/services.dart';

import '../engine/event.dart';
import 'event_repository.dart';

class AssetEventRepository implements EventRepository {
  final Map<String, List<Event>> _eventsByChannel = {};
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    final assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final eventAssets = assetManifest
        .listAssets()
        .where((s) => s.startsWith('assets/events/'))
        .toList();

    for (final assetPath in eventAssets) {
      final channelName = assetPath
          .replaceFirst('assets/events/', '')
          .replaceFirst('.json', '');
      await _loadChannel(channelName);
    }

    _isInitialized = true;
  }

  Future<void> _loadChannel(String channel) async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/events/$channel.json');
      final jsonList = json.decode(jsonString) as List;
      final events = jsonList.map((j) => Event.fromJson(j)).toList();
      _eventsByChannel[channel] = events;
    } catch (e) {
      // Log the error, but don't crash.
      // ignore: avoid_print
      print('Error loading events for channel $channel: $e');
      _eventsByChannel[channel] = [];
    }
  }

  @override
  List<String> get channels => _eventsByChannel.keys.toList();

  @override
  List<Event> getByChannel(String channel) {
    return _eventsByChannel[channel] ?? [];
  }
}
