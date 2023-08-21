import 'package:conejoz/src/constants/conejoz_logos.dart';
import 'package:conejoz/src/features/feed/screens/feed_screen.dart';
import 'package:conejoz/src/features/journal/screens/journal_screen.dart';
import 'package:conejoz/src/features/profile/screens/profile_screen.dart';
import 'package:conejoz/src/features/settings/screens/settings_screen.dart';
import 'package:conejoz/src/repository/user_repository/user_repository.dart';
import 'package:flutter/material.dart';

// * Main navigation board for the app.
// * By default the user will see the feed screen.

class ConejozDashboard extends StatefulWidget {
  const ConejozDashboard({super.key});

  @override
  State<ConejozDashboard> createState() => _ConejozDashboardState();
}

class _ConejozDashboardState extends State<ConejozDashboard> {
  final _userRepo = UserRepository.instance;
  String? _username;
  @override
  void initState() {
    super.initState();
    // Trigger the function to get the username once the screen is opened
    _getUsername();
  }

  // Function to retrieve the username from the UserRepository
  void _getUsername() async {
    final username = await _userRepo.getRabbitNameByUserId();
    setState(() {
      _username = username;
    });
  }

  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(
          ConejozLogos.conejozBlackFill,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            Text("Welcome.",
                style: TextStyle(color: Theme.of(context).colorScheme.surface)),
            SizedBox(width: 5),
            Text(
              _username ?? " ",
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            )
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          FeedScreen(),
          JournalScreen(),
          ProfileScreen(), // TODO: RABBIT ICON FOR THIS SCREEN
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                ConejozLogos.conejozBlackFill,
                color: _currentIndex == 0
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.circle_outlined,
                color: _currentIndex == 1
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 1;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.cloud,
                color: _currentIndex == 2
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
