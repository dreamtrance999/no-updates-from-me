import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isDrawerOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
      if (_isDrawerOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final drawerWidth = 156.w; // 40% of 390

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final slide = drawerWidth * _animationController.value;
          return Stack(
            children: [
              // Drawer
              Positioned(
                left: -drawerWidth + slide,
                top: 0,
                bottom: 0,
                width: drawerWidth,
                child: _buildDrawer(context),
              ),
              // Chat Panel
              Positioned(
                left: slide,
                right: -slide,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: _isDrawerOpen ? _toggleDrawer : null,
                  child: AbsorbPointer(
                    absorbing: _isDrawerOpen,
                    child: _buildChatPanel(context, l10n),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Container(
      color: const Color(0xFF3A3A3A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'CHANNELS',
              style: TextStyle(
                color: const Color(0xFFE0D8C0),
                fontSize: 18.sp,
                fontFamily: 'PressStart2P',
              ),
            ),
          ),
          const Divider(color: Color(0xFFE0D8C0), height: 1),
          _buildDrawerItem(context, '# general', false, () {}),
          _buildDrawerItem(context, '# development', true, () {}),
          _buildDrawerItem(context, '# incidents', false, () {}),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return Material(
      color: isSelected ? const Color(0xFFE0D8C0) : Colors.transparent,
      child: InkWell(
        onTap: () {
          _toggleDrawer();
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFE0D8C0),
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatPanel(BuildContext context, AppLocalizations l10n) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF3A3A3A)),
          onPressed: _toggleDrawer,
        ),
        actions: const [
          Icon(Icons.more_vert, color: Color(0xFF3A3A3A)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildMessage(
                  context,
                  'assets/images/emily.png',
                  'Emily',
                  'Need your help with the API...',
                  '1min',
                ),
                _buildMessage(
                  context,
                  'assets/images/noah.png',
                  'Noah',
                  'Update on the migration?',
                  '3min',
                ),
                _buildMessage(
                  context,
                  'assets/images/jacob.png',
                  'Jacob',
                  'I\'m on it.',
                  '4min',
                ),
              ],
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessage(
    BuildContext context,
    String imagePath,
    String name,
    String message,
    String time,
  ) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for the avatar
          Container(
            width: 50.w,
            height: 50.h,
            color: Colors.grey[400],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(name,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(time, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF3A3A3A))),
      ),
      child: Row(
        children: [
          const Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          const Icon(Icons.send, color: Color(0xFF3A3A3A)),
        ],
      ),
    );
  }
}
