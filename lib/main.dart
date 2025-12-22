import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:no_updates_from_me/screen/game_screen_view_model.dart';
import 'package:no_updates_from_me/screen/main_menu_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  final vm = GameScreenViewModel();
  await vm.init();

  runApp(MyApp(vm: vm));
}

class MyApp extends StatelessWidget {
  final GameScreenViewModel vm;

  const MyApp({super.key, required this.vm});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameScreenViewModel>.value(value: vm),
      ],
      child: ScreenUtilInit(
        designSize: const Size(490, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'PixelifySans',
              scaffoldBackgroundColor: const Color(0xFF141414),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(
                  color: Color(0xFFEAEAEA),
                ),
              ),
            ),
            // REMOVED localizationsDelegates and supportedLocales
            home: child,
          );
        },
        child: const MainMenuScreen(),
      ),
    );
  }
}
