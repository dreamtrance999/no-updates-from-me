import "package:flutter/material.dart";
import "package:no_updates_from_me/ui_models/game_channel_ui_model.dart";
import "package:provider/provider.dart";

import "../ui_models/chat_item_ui_model.dart";
import "game_screen_view_model.dart";

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _drawerOpen = false;

  void _toggleDrawer() => setState(() => _drawerOpen = !_drawerOpen);

  void _closeDrawer() => setState(() => _drawerOpen = false);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<GameScreenViewModel>();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1) MAIN CONTENT (full width)
            _MainChat(
              day: vm.day,
              weekday: vm.weekday,
              clockLabel: vm.clockLabel,
              items: vm.chatItems,
              onMenu: _toggleDrawer,
              onPickDecision: (decisionId, optionId) {
                vm.onDecisionOptionSelected(
                    decisionId: decisionId, optionId: optionId);
              },
            ),

            // 2) SCRIM (tap to close)
            if (_drawerOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: _closeDrawer,
                  child: Container(color: Colors.black.withOpacity(0.35)),
                ),
              ),

            // 3) DRAWER (slides in)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              top: 0,
              bottom: 0,
              left: _drawerOpen ? 0 : -320,
              // slide from left
              width: 320,
              child: _DrawerPanel(
                clockLabel: vm.clockLabel,
                morale: vm.morale,
                stress: vm.stress,
                channels: vm.channels,
                chats: vm.chats,
                onChannelTap: (id) async {
                  await vm.onChannelSelected(id);
                  _closeDrawer();
                },
                onClose: _closeDrawer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainChat extends StatelessWidget {
  final int day;
  final String weekday;
  final String clockLabel;
  final List<ChatItemUiModel> items;
  final VoidCallback onMenu;
  final void Function(String decisionId, String optionId) onPickDecision;

  const _MainChat({
    required this.day,
    required this.weekday,
    required this.clockLabel,
    required this.items,
    required this.onMenu,
    required this.onPickDecision,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: onMenu,
                icon: const Icon(Icons.menu, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                clockLabel,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              const Spacer(),
              Text(
                "$weekday, Day $day",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // chat feed
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final item = items[i];
              return switch (item) {
                ChatMessageUiModel m => _MessageBubble(m: m),
                ChatDecisionUiModel d =>
                  _DecisionBlock(d: d, onPick: onPickDecision),
                _ => const SizedBox.shrink(),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _DrawerPanel extends StatelessWidget {
  final String clockLabel;
  final int morale;
  final int stress;
  final List<GameChannelUiModel> channels;
  final List<GameChannelUiModel> chats;
  final Future<void> Function(String channelId) onChannelTap;
  final VoidCallback onClose;

  const _DrawerPanel({
    required this.clockLabel,
    required this.morale,
    required this.stress,
    required this.channels,
    required this.chats,
    required this.onChannelTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1A1A1A),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  clockLabel,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text("Morale: $morale",
                style: const TextStyle(color: Colors.white54)),
            Text("Stress: $stress",
                style: const TextStyle(color: Colors.white54)),
            Expanded(
              child: ListView(
                children: [
                  _DrawerSection(
                    title: "CHANNELS",
                    items: channels,
                    onTap: onChannelTap,
                  ),
                  const SizedBox(height: 16),
                  _DrawerSection(
                    title: "CHATS",
                    items: chats,
                    onTap: onChannelTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DrawerSection extends StatelessWidget {
  final String title;
  final List<GameChannelUiModel> items;
  final Future<void> Function(String channelId) onTap;

  const _DrawerSection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 8),
        for (final c in items)
          ListTile(
            dense: true,
            title: Text(
              c.title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: c.isSelected ? Colors.white : Colors.white70,
                  ),
            ),
            trailing: c.unreadCount > 0
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "${c.unreadCount}",
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white),
                    ),
                  )
                : null,
            onTap: () => onTap(c.id),
          ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageUiModel m;

  const _MessageBubble({required this.m});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2A2A2A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (m.avatarAssetPath != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: CircleAvatar(
                  radius: 16, backgroundImage: AssetImage(m.avatarAssetPath!)),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        m.name,
                        style: const TextStyle(color: Colors.white70),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(m.timeLabel,
                        style: const TextStyle(color: Colors.white38)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  m.message,
                  style: const TextStyle(color: Colors.white),
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecisionBlock extends StatelessWidget {
  final ChatDecisionUiModel d;
  final void Function(String decisionId, String optionId) onPick;

  const _DecisionBlock({required this.d, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF181818),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF3A3A3A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(d.prompt,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          for (final o in d.options)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: d.isResolved ? null : () => onPick(d.id, o.id),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${o.label} (+${_jumpLabel(o.timeJumpMinutes)})",
                          style: const TextStyle(color: Colors.white),
                          softWrap: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(o.hint,
                          style: const TextStyle(color: Colors.white60)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String _jumpLabel(int minutes) {
    if (minutes < 60) return "${minutes}m";
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return m == 0 ? "${h}h" : "${h}h ${m}m";
  }
}
