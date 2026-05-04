import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

// Providers
import 'core/result_store.dart';
import 'package:knowme/astrology/providers/astrology_provider.dart';
import 'package:knowme/presentation/providers/personality_provider.dart';

// Pages
import 'package:knowme/presentation/pages/auth/login_page.dart';
import 'package:knowme/presentation/pages/home/home_page.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.web);

  runApp(
    MultiProvider(
      providers: [
        Provider(create: (_) => ResultStore()),
        ChangeNotifierProvider(create: (_) => AstrologyProvider()),
        ChangeNotifierProvider(create: (_) => PersonalityProvider()),
      ],
      child: const KnowMeApp(),
    ),
  );
}

class KnowMeApp extends StatelessWidget {
  const KnowMeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KnowMe',

      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('th')],

      home: const LoginPage(),
    );
  }
}
