import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banking System', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.teal[700],
        actions: [
          IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () => Get.toNamed('/transactions'),
          tooltip: 'View Transaction History',
        ),],
      ),
      body: Center(
        child: 
        SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance, size: 100, color: Colors.teal),
              const SizedBox(height: 30),
              const Text(
                'Welcome to Advanced Banking System',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 10),
              const Text(
                'An integrated system for managing accounts, transactions, and reports',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: 300,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/accounts'),
                        icon: const Icon(Icons.account_balance_wallet, color: Colors.white),
                        label: const Text('Manage Accounts', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/accounts/onboard'),
                        icon: const Icon(Icons.person_add, color: Colors.white),
                        label: const Text('Add New Customer', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/reports'),
                        icon: const Icon(Icons.assessment, color: Colors.white),
                        label: const Text('Reports & Analytics', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),

                      const SizedBox(height: 15),
                      ElevatedButton.icon(
                        onPressed: () => Get.toNamed('/support'),
                        icon: const Icon(Icons.support_agent, color: Colors.white),
                        label: const Text('Support Tickets', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                  
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}