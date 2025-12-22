import 'package:bankingplatform/presentation/controller/approval_controller.dart';
import 'package:bankingplatform/presentation/controller/report_controller.dart';
import 'package:bankingplatform/presentation/controller/support_controller.dart';
import 'package:bankingplatform/presentation/controller/transaction_controller.dart';
import 'package:bankingplatform/presentation/pages/account_hierarchy_page.dart';
import 'package:bankingplatform/presentation/pages/account_management_page.dart';
import 'package:bankingplatform/presentation/pages/approvals_page.dart';
import 'package:bankingplatform/presentation/pages/home_page.dart';
import 'package:bankingplatform/presentation/pages/onboard_customer_page.dart';
import 'package:bankingplatform/presentation/pages/reports_page.dart';
import 'package:bankingplatform/presentation/pages/support_tickets_page.dart';
import 'package:bankingplatform/presentation/pages/transaction_history_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'data/repositories/report_repository_impl.dart';
import 'package:bankingplatform/presentation/controller/enhanced_account_controller.dart';
import 'domain/repositories/repository_builder.dart';

void main() async {
  await GetStorage.init();
  runApp(BankingApp());
}

class BankingApp extends StatelessWidget {
  BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final accountRepository = RepositoryBuilder.buildAccountRepository();
    final reportRepository = ReportRepositoryImpl();
    final supportRepository = RepositoryBuilder.buildSupportRepository();


    return GetMaterialApp(
      title: 'Banking System',
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
            Get.put(EnhancedAccountController(repository: accountRepository));
            Get.put(ApprovalController(repository: accountRepository));
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
            Get.put(ReportController(repository: reportRepository));
          }),
        ),
        GetPage(
          name: '/transactions',
          page: () => TransactionsPage(),
          binding: BindingsBuilder(() {
            Get.put(TransactionController(repository: accountRepository));
          }),
        ),
        GetPage(
          name: '/approvals',
          page: () => ApprovalsPage(),
          binding: BindingsBuilder(() {
            Get.put(ApprovalController(repository: accountRepository));
          }),
        ),

        GetPage(
          name: '/support',
          page: () => SupportTicketsPage(),
          binding: BindingsBuilder(() {
            Get.put(SupportController(repository: supportRepository));
          }),
        ),
        GetPage(
          name: '/accounts/hierarchy',
          page: () => AccountHierarchyPage(),
        ),

      ],
      debugShowCheckedModeBanner: false,
    );
  }
}