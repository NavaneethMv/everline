import 'package:everline/core/service_locator.dart';
import 'package:everline/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Add this import

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await setupServiceLocator();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      title: "Everline",
      themeMode: ThemeMode.light,
      theme: ShadThemeData(
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.nunito),
        brightness: Brightness.light,
        colorScheme: ShadColorScheme.fromName(
          'green',
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ShadThemeData(
        textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.nunito),
        brightness: Brightness.dark,
        colorScheme: ShadColorScheme.fromName(
          'green',
          brightness: Brightness.dark,
        ),
      ),
      routerConfig: appRouter,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ShadToaster(child: child ?? const SizedBox.shrink()),
        );
      },
    );
  }
}
