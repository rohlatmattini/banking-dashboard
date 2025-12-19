import 'package:bankingplatform/presentation/controller/account_controller.dart';
import 'package:bankingplatform/presentation/controller/report_controller.dart';
import 'package:bankingplatform/presentation/pages/account_management_page.dart';
import 'package:bankingplatform/presentation/pages/home_page.dart';
import 'package:bankingplatform/presentation/pages/onboard_customer_page.dart';
import 'package:bankingplatform/presentation/pages/reports_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'data/datasource/api_account_data_source.dart';
import 'data/repositories/account_repository_impl.dart';
import 'data/repositories/report_repository_impl.dart';

void main() async {
  await GetStorage.init();
  runApp(BankingApp());
}

class BankingApp extends StatelessWidget {
  BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final accountDataSource = ApiAccountDataSource();
    final accountRepository = AccountRepositoryImpl(dataSource: accountDataSource);
    final reportRepository = ReportRepositoryImpl();

    return GetMaterialApp(
      title: 'نظام البنك المتقدم',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => HomePage()),
        GetPage(
          name: '/accounts',
          page: () => AccountManagementPage(),
          binding: BindingsBuilder(() {
            Get.put(AccountController(
              repository: accountRepository,
            ));
          }),
        ),
        GetPage(
          name: '/accounts/onboard',
          page: () => OnboardCustomerPage(),
        ),

        GetPage(
          name: '/reports',
          page: () => ReportsPage(),
          binding: BindingsBuilder(() {
            Get.put(ReportController(
              repository: reportRepository,
            ));
          }),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}