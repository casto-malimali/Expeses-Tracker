import 'package:expenses_tracker/providers/network_provider.dart';
import 'package:expenses_tracker/providers/sync_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:expenses_tracker/providers/budget_provider.dart';
import 'package:expenses_tracker/providers/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'services/security_service.dart';
import 'screens/lock_screen.dart';
import 'screens/setup_pin_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase FIRST
  await Firebase.initializeApp();

  await Hive.initFlutter();
  await Hive.openBox('transactions');
  await Hive.openBox('budgets');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final network = context.read<NetworkProvider>();
    final tx = context.read<TransactionProvider>();
    final sync = context.read<SyncProvider>();

    network.onReconnect = () async {
      if (sync.hasPendingChanges) {
        await tx.autoRestore();
      }
    };
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => TransactionProvider()..load()),
        ChangeNotifierProvider(
          create: (_) => TransactionProvider()
            ..load()
            ..autoRestore(),
        ),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => NetworkProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: MaterialApp(
        title: 'Income & Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final security = SecurityService();

    return FutureBuilder<bool>(
      future: security.hasPin(),

      builder: (context, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snap.data == false) {
          return const SetupPinScreen();
        }

        return const LockScreen();
      },
    );
  }
}
