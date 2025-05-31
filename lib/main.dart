import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/portfolio_screen.dart';

// Global navigator key for scrolling ggg
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(const MyPortfolioApp());
}

class MyPortfolioApp extends StatelessWidget {
  const MyPortfolioApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Portfolio',
      theme: AppTheme.lightTheme,
      home: const PortfolioScreen(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
    );
  }
}
// import 'package:flutter/material.dart';
// import 'core/theme/app_theme.dart';
// import 'presentation/screens/portfolio_screen.dart';

// void main() {
//   runApp(const MyPortfolioApp());
// }

// class MyPortfolioApp extends StatelessWidget {
//   const MyPortfolioApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Saad Portfolio',
//       theme: AppTheme.lightTheme,
//       home: const PortfolioScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
