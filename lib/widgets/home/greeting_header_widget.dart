
import 'package:flutter/material.dart';
import 'package:gym_tracker/screens/user_profile_screen.dart';

class GreetingHeaderWidget extends StatelessWidget {
  final String userName;

  const GreetingHeaderWidget({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final inicial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    final now = DateTime.now();
    final formattedDate = "${now.day}/${now.month}/${now.year}";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserProfileScreen()),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $userName',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
            
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white12,
              child: Text(
                inicial,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
