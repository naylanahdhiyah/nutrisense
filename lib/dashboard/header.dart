import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:nutrisense/pages/profil.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    // String formattedDate = DateFormat('EEEE, d MMMM y', 'id_ID').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            },
            child: const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/icons/profile.png'),
            ),
          ),
        ],
      ),
    );
  }
}