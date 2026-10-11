import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_colors.dart';
import 'features/navigation/main_navigation_scaffold.dart';
import 'features/transactions/presentation/blocs/transaction_bloc.dart';
import 'features/transactions/presentation/blocs/transaction_event.dart';
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  // Set immersive dark status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.bgDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await initDependencies();

  runApp(const MoneyRecordApp());
}

class MoneyRecordApp extends StatelessWidget {
  const MoneyRecordApp({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month, 1);

    return BlocProvider(
      create: (context) =>
          sl<TransactionBloc>()..add(LoadTransactionsEvent(currentMonth)),
      child: MaterialApp(
        title: 'MoneyRecord',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.bgDark,
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primaryAccent,
            surface: AppColors.cardDark,
            error: AppColors.expense,
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardDark,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: AppColors.cardBorderDark),
            ),
          ),
        ),
        home: const MainNavigationScaffold(),
      ),
    );
  }
}
