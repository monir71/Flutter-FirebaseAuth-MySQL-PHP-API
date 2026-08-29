import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/owner_service.dart';
import '../auth/login_screen.dart';
import 'financial_partner_management_screen.dart';
import 'fund_management_screen.dart';
import 'garden_management_screen.dart';
import 'owner_management_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();

              if (!context.mounted) return;

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const GardenManagementScreen(),
                  ),
                );
              },
              child: const Text(
                'Garden Management',
              ),
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OwnerManagementScreen(),
                  ),
                );
              },
              child: const Text('Owner Management'),
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () async {
                try {
                  final owners = await OwnerService.getOwners();

                  print('==============================');
                  print('Owner List');
                  print('==============================');

                  for (final owner in owners) {
                    print('Owner ID: ${owner.ownerId}');
                    print('Owner Name: ${owner.ownerName}');

                    print('Gardens:');

                    for (final garden in owner.gardens) {
                      print(
                        '  Garden ID: ${garden.gardenId}',
                      );

                      print(
                        '  Garden Name: ${garden.gardenName}',
                      );
                    }

                    print('------------------------------');
                  }
                } catch (e) {
                  print('Owner Error: $e');
                }
              },
              child: const Text('Get Owners'),
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () async {
                try {
                  final owner = await OwnerService.addOwner(
                    ownerName: 'Sohanur Rahman',
                    gardenIds: [1],
                  );

                  print('==============================');
                  print('Owner Added Successfully');
                  print('==============================');
                  print('Owner ID: ${owner.ownerId}');
                  print('Owner Name: ${owner.ownerName}');

                  for (final garden in owner.gardens) {
                    print('Garden ID: ${garden.gardenId}');
                    print('Garden Name: ${garden.gardenName}');
                  }

                  print('------------------------------');
                } catch (e) {
                  print('Owner Add Error: $e');
                }
              },
              child: const Text('Test Add Owner'),
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const FinancialPartnerManagementScreen(),
                  ),
                );
              },
              child: const Text(
                'Financial Partner Management',
              ),
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const FundManagementScreen(),
                  ),
                );
              },
              child: const Text(
                'Fund Management',
              ),
            ),
          ],
        ),
      ),
    );
  }
}