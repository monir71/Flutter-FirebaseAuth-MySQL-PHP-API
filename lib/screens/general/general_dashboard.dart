import 'package:flutter/material.dart';

import '../../models/owner.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class GeneralDashboard extends StatelessWidget {
  final Owner owner;

  const GeneralDashboard({
    super.key,
    required this.owner,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garden Dashboard'),
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

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Welcome, ${owner.ownerName}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'My Gardens',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: owner.gardens.length,
                itemBuilder: (context, index) {

                  final garden = owner.gardens[index];

                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.agriculture,
                      ),

                      title: Text(
                        garden.gardenName,
                      ),

                      subtitle: Text(
                        'Garden ID: ${garden.gardenId}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}