import 'package:flutter/material.dart';
import 'package:opini_kopi/providers/auth_provider.dart';
import 'package:opini_kopi/providers/cart_provider.dart';
import 'package:opini_kopi/providers/notification_provider.dart';
import 'package:opini_kopi/services/ambient_light_service.dart';
import 'pages/splash/splash_page.dart';
import 'package:provider/provider.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AmbientLightMode>(
      stream: AmbientLightService.watchMode(),
      initialData: AmbientLightMode.normal,
      builder: (context, snapshot) {
        final mode = snapshot.data ?? AmbientLightMode.normal;
        final overlayColor = switch (mode) {
          AmbientLightMode.dim => Colors.black.withValues(alpha: 0.04),
          AmbientLightMode.bright => Colors.white.withValues(alpha: 0.05),
          AmbientLightMode.normal => Colors.transparent,
        };

        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => CartProvider()),
            ChangeNotifierProvider(create: (_) => NotificationProvider()),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF4A2419),
                brightness: Brightness.light,
              ),
            ),
            home: Stack(
              children: [
                const SplashPage(),
                IgnorePointer(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    color: overlayColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
