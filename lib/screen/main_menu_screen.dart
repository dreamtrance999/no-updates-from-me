import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_updates_from_me/engine/status_meter/event_definition.dart';
import 'package:no_updates_from_me/engine/status_meter/status_meter_engine.dart';
import 'package:no_updates_from_me/engine/status_meter/status_meter_game_state.dart';
import 'package:no_updates_from_me/screen/game_screen.dart';
import 'package:no_updates_from_me/screen/status_meter_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  Future<List<EventDefinition>> _loadEventDefinitions() async {
    final jsonString =
        await rootBundle.loadString('assets/events/status_meter.json');
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => EventDefinition.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No Updates From Me',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GameScreen()),
                );
              },
              child: const Text('Start Narrative Mode'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                final events = await _loadEventDefinitions();
                final engine = StatusMeterEngine(eventDefinitions: events);
                final initialState = StatusMeterGameState.initial(
                  seed: Random().nextInt(0x7FFFFFFF),
                );

                if (context.mounted) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StatusMeterScreen(
                        engine: engine,
                        initialState: initialState,
                      ),
                    ),
                  );
                }
              },
              child: const Text('Start Status & Meter Mode'),
            ),
          ],
        ),
      ),
    );
  }
}
