import 'package:flutter/material.dart';
import 'package:no_updates_from_me/engine/status_meter/action.dart';
import 'package:no_updates_from_me/engine/status_meter/event_definition.dart';
import 'package:no_updates_from_me/engine/status_meter/status_meter_engine.dart';
import 'package:no_updates_from_me/engine/status_meter/status_meter_game_state.dart';

class StatusMeterScreen extends StatefulWidget {
  final StatusMeterEngine engine;
  final StatusMeterGameState initialState;

  const StatusMeterScreen({
    super.key,
    required this.engine,
    required this.initialState,
  });

  @override
  State<StatusMeterScreen> createState() => _StatusMeterScreenState();
}

class _StatusMeterScreenState extends State<StatusMeterScreen> {
  late StatusMeterGameState _gameState;
  late EventDefinition _currentEvent;

  @override
  void initState() {
    super.initState();
    _gameState = widget.initialState;
    _selectNextEvent();
  }

  void _selectNextEvent() {
    _currentEvent = widget.engine.selectNextEvent(_gameState);
  }

  void _handleAction(StatusMeterAction action) {
    setState(() {
      _gameState =
          widget.engine.handleAction(_gameState, _currentEvent.id, action);
      if (!_gameState.isRunFinished) {
        _selectNextEvent();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Status & Meter Mode'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _gameState.isRunFinished ? _buildEndScreen() : _buildGameScreen(),
      ),
    );
  }

  Widget _buildGameScreen() {
    return Column(
      children: [
        _buildTopBar(),
        const SizedBox(height: 24),
        _buildMeters(),
        const SizedBox(height: 32),
        _buildAlert(),
        const SizedBox(height: 32),
        _buildActionButtons(),
        const SizedBox(height: 24),
        const Divider(),
        Expanded(child: _buildHistoryLog()),
      ],
    );
  }

  Widget _buildEndScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Run Over', style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 24),
          Text(
            _gameState.endingSummary ?? 'The run has ended.',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildMeters(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Main Menu'),
          )
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Turn: ${_gameState.turnIndex + 1}'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LinearProgressIndicator(
              value: _gameState.minutesElapsed / 60,
              minHeight: 8,
            ),
          ),
        ),
        Text('Time: ${_gameState.minutesElapsed}/60 min'),
      ],
    );
  }

  Widget _buildMeters() {
    return Column(
      children: [
        _MeterBar(label: 'Stress', value: _gameState.stress),
        _MeterBar(
            label: 'Institutional Trust', value: _gameState.institutionalTrust),
        _MeterBar(label: 'Team Cohesion', value: _gameState.teamCohesion),
        _MeterBar(label: 'Personal Risk', value: _gameState.personalRisk),
      ],
    );
  }

  Widget _buildAlert() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _currentEvent.text,
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: StatusMeterAction.values.map((action) {
        return ElevatedButton(
          onPressed: () => _handleAction(action),
          child: Text(action.label),
        );
      }).toList(),
    );
  }

  Widget _buildHistoryLog() {
    return ListView.builder(
      reverse: true,
      itemCount: _gameState.history.length,
      itemBuilder: (context, index) {
        final entry = _gameState.history.reversed.toList()[index];
        return Text(
            'T${entry.turnIndex}: ${entry.eventText} -> ${entry.action}');
      },
    );
  }
}

class _MeterBar extends StatelessWidget {
  final String label;
  final int value;

  const _MeterBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: LinearProgressIndicator(
              value: value / 100,
              minHeight: 12,
            ),
          ),
          SizedBox(width: 40, child: Text('$value', textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
