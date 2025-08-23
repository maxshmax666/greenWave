import 'package:flutter/material.dart';

 
import '../../screens/lights_screen.dart';
import '../../screens/map_screen.dart';
import '../../screens/cycles_screen.dart';
import '../../screens/speed_advisor.dart';
import '../../screens/settings_screen.dart';
import '../auth/register_page.dart';

/// Home page shown after a successful authentication.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const MapScreen(),
      const LightsScreen(),
      const CyclesScreen(),
      const SpeedAdvisorScreen(),
      const SettingsScreen(),
    ];
    const titles = ['Карта', 'Светофоры', 'Циклы', 'Советчик', 'Настройки'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_index]),
        actions: [
          IconButton(
            onPressed: () => RegisterPage.signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (v) => setState(() => _index = v),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurfaceVariant,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Карта'),
          BottomNavigationBarItem(icon: Icon(Icons.traffic), label: 'Светофоры'),
          BottomNavigationBarItem(icon: Icon(Icons.timelapse), label: 'Циклы'),
          BottomNavigationBarItem(icon: Icon(Icons.speed), label: 'Советчик'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}
 
