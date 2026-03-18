import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'cupula_portfolio_screen.dart';

class CupulaAlanoPortfolioScreen extends StatelessWidget {
  static const String alanoUserId = 'XHMsmRONXcOp3vm7VM3326P1DSt2';

  static const List<String> adminUserIds = [
    'MSnKrBPj5uZK3JK8LsB8CeHLdb82',
    'XHMsmRONXcOp3vm7VM3326P1DSt2',
  ];

  const CupulaAlanoPortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isAdmin = adminUserIds.contains(currentUserId);

    return CupulaPortfolioScreen(
      isReadOnly: !isAdmin,
      oderId: alanoUserId,
    );
  }
}
