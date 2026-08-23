import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/food/cancelled_screen.dart';
import 'screens/food/fact_screen.dart';
import 'screens/food/failed_screen.dart';
import 'screens/food/food_loading.dart';
import 'screens/food/logged_screen.dart';
import 'screens/food/mode_screen.dart';
import 'screens/food/review_screen.dart';
import 'screens/food/speak_screen.dart';
import 'screens/food/type_screen.dart';
import 'screens/home_screen.dart';
import 'screens/loading_screens.dart';
import 'screens/otp_screen.dart';
import 'screens/phone_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/food_log_state.dart';
import 'state/onboarding_state.dart';
import 'theme.dart';

void main() {
  runApp(const ChompyApp());
}

class ChompyApp extends StatelessWidget {
  const ChompyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OnboardingState()),
        // Food logging shares the onboarding session's access token.
        ChangeNotifierProxyProvider<OnboardingState, FoodLogState>(
          create: (_) => FoodLogState(),
          update: (_, onboarding, food) =>
              (food ?? FoodLogState())..updateToken(onboarding.accessToken),
        ),
      ],
      child: MaterialApp(
        title: 'Chompy',
        debugShowCheckedModeBanner: false,
        theme: chompyTheme(),
        home: const _Root(),
      ),
    );
  }
}

/// One screen at a time. Onboarding owns the flow until it reaches `home`; from
/// there, the food-logging state machine takes over (or Home shows when idle).
class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final onboarding = context.select<OnboardingState, Screen>((s) => s.screen);
    final foodScreen = context.select<FoodLogState, FoodScreen>((s) => s.screen);

    Object key;
    Widget child;

    if (onboarding != Screen.home) {
      key = onboarding;
      child = switch (onboarding) {
        Screen.welcome => const WelcomeScreen(),
        Screen.phone => const PhoneScreen(),
        Screen.sending => const SendingScreen(),
        Screen.otp => const OtpScreen(),
        Screen.verifying => const VerifyingScreen(),
        Screen.profile => const ProfileScreen(),
        Screen.home => const SizedBox.shrink(),
      };
    } else if (foodScreen == FoodScreen.none) {
      key = 'home';
      child = const HomeScreen();
    } else {
      key = foodScreen;
      child = switch (foodScreen) {
        FoodScreen.mode => const ModeScreen(),
        FoodScreen.cancelled => const CancelledScreen(),
        FoodScreen.text => const TypeScreen(),
        FoodScreen.speak => const SpeakScreen(),
        FoodScreen.detecting => const DetectingScreen(),
        FoodScreen.review => const ReviewScreen(),
        FoodScreen.saving => const SavingScreen(),
        FoodScreen.fact => const FactScreen(),
        FoodScreen.saved => const LoggedScreen(),
        FoodScreen.failed => const FailedScreen(),
        FoodScreen.none => const HomeScreen(),
      };
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(key: ValueKey<Object>(key), child: child),
      ),
    );
  }
}
