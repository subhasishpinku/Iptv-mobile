import 'package:flutter/material.dart';
import 'package:iptvmobile/CategoriesScreen/CategoriesScreen.dart';
import 'package:iptvmobile/ForgotPassword/ForgotPassword.dart';
import 'package:iptvmobile/GetStartScreen/GetStartScreen.dart';
import 'package:iptvmobile/HomeScreen/HomeScreen.dart';
import 'package:iptvmobile/HomeScreen/MovieDetailsScreen/movie_Details_Screen.dart';
import 'package:iptvmobile/LiveTvScreen/LiveTvScreen.dart';
import 'package:iptvmobile/LoginScreen/LoginScreen.dart';
import 'package:iptvmobile/MovieScreen/MovieScreen.dart';
import 'package:iptvmobile/MusicScreen/MusicPlayerScreen.dart';
import 'package:iptvmobile/MusicScreen/MusicScreen.dart';
import 'package:iptvmobile/OtpScreen.dart/OtpScreen.dart';
import 'package:iptvmobile/PlanScreen/PlanScreen.dart';
import 'package:iptvmobile/SingnupScreen/SingnupScreen.dart';
import 'package:iptvmobile/SplashScreen/SplashScreen.dart';
import 'package:iptvmobile/dashboard.dart';
import 'package:iptvmobile/routes/routes_names.dart';

class Routes {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case (RouteNames.splashScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const Splashscreen(),
        );
      case (RouteNames.getStartScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const Getstartscreen(),
        );
      case (RouteNames.loginScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const Loginscreen(),
        );
      case (RouteNames.forgotPassword):
        return MaterialPageRoute(
          builder: (BuildContext context) => const ForgotPassword(),
        );
      case (RouteNames.otpScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const OtpScreen(),
          settings: settings, // ✅ settings pass করুন
        );
      case (RouteNames.dashBoardScreenn):
        return MaterialPageRoute(
          builder: (BuildContext context) => const Dashboard(),
        );
      case (RouteNames.singnupScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const SignUpScreen(),
        );
      case (RouteNames.homeScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const Homescreen(),
        );
      case (RouteNames.categoriesScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const Categoriesscreen(),
        );
      case (RouteNames.movieScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const MovieScreen(),
        );
      case (RouteNames.liveTvScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const LiveTvScreen(),
        );
      case (RouteNames.planScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const PlanScreen(),
        );
      case (RouteNames.musicScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const MusicScreen(),
        );
      case (RouteNames.musicPlayerScreen):
        return MaterialPageRoute(
          builder: (BuildContext context) => const Musicplayerscreen(),
        );
      // case (RouteNames.movieDetailsScreen):
      //   return MaterialPageRoute(
      //     builder: (BuildContext context) => const MovieDetailsScreen(movie: movie),
      //   );

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("No route is configured")),
          ),
        );
    }
  }
}
