import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:provider/provider.dart';

import 'firebase_options.dart';

import 'presentation/pages/auth/auth_gate.dart';

import 'presentation/providers/auth_provider.dart';

import 'presentation/providers/profile_provider.dart';

import 'presentation/providers/astrology_provider.dart';

import 'presentation/providers/locale_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        ChangeNotifierProvider(create: (_) => AstrologyProvider()),

        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],

      child: const KnowMeApp(),
    ),
  );
}

class KnowMeApp extends StatelessWidget {
  const KnowMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,

          locale: localeProvider.locale,

          supportedLocales: const [Locale('en'), Locale('th')],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,

            GlobalWidgetsLocalizations.delegate,

            GlobalCupertinoLocalizations.delegate,
          ],

          home: const AuthGate(),
        );
      },
    );
  }
}
