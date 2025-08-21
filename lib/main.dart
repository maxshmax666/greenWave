import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/map_screen.dart';
import 'screens/cycle_recorder.dart';
import 'screens/speed_advisor.dart';

const supabaseUrl = 'https://asoyjqtqtomxcdmsgehx.supabase.co';
const supabaseAnonKey = '...твой ключ...';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MyApp());
}

final supa = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenWave',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});
  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    supa.auth.onAuthStateChange.listen((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return supa.auth.currentSession == null
        ? const LoginPage()
        : const HomeTabs();
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final pages = [
      const MapScreen(),
      const TodosPage(),
      const CycleRecorderScreen(),
      const SpeedAdvisorScreen(),
    ];
    return Scaffold(
      body: pages[_i],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _i,
        onTap: (v) => setState(() => _i = v),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist), label: 'Todos'),
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.speed), label: 'Advisor'),
        ],
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool isLogin = true;
  bool busy = false;

  Future<void> _submit() async {
    setState(() => busy = true);
    try {
      if (isLogin) {
        await supa.auth.signInWithPassword(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      } else {
        await supa.auth.signUp(
          email: emailCtrl.text.trim(),
          password: passCtrl.text.trim(),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Sign in' : 'Sign up')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: passCtrl,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: busy ? null : _submit,
            child: Text(isLogin ? 'Sign in' : 'Create account'),
          ),
          TextButton(
            onPressed: () => setState(() => isLogin = !isLogin),
            child: Text(isLogin ? 'Create account' : 'I have an account'),
          ),
        ]),
      ),
    );
  }
}

class TodosPage extends StatefulWidget {
  const TodosPage({super.key});
  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  final _controller = TextEditingController();
  List<Map<String, dynamic>> _todos = [];
  RealtimeChannel? _ch;

  @override
  void initState() {
    super.initState();
    _load();
    _ch = supa
        .channel('public:todos')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'todos',
          callback: (_) => _load(),
        )
        .subscribe();
  }

  Future<void> _load() async {
    final u = supa.auth.currentUser;
    if (u == null) return;
    final res = await supa
        .from('todos')
        .select('*')
        .eq('user_id', u.id)
        .order('inserted_at', ascending: false);
    setState(() => _todos = List<Map<String, dynamic>>.from(res));
  }

  Future<void> _add() async {
    final t = _controller.text.trim();
    if (t.isEmpty) return;
    final u = supa.auth.currentUser;
    if (u == null) return;
    await supa.from('todos').insert({
      'task': t,
      'status': 'Not Started',
      'user_id': u.id,
      'inserted_at': DateTime.now().toIso8601String()
    });
    _controller.clear();
  }

  Future<void> _toggle(int id, String status) async {
    final next =
        status.toLowerCase() == 'complete' ? 'Not Started' : 'Complete';
    await supa.from('todos').update({'status': next}).eq('id', id);
  }

  Future<void> _del(int id) async {
    await supa.from('todos').delete().eq('id', id);
  }

  Future<void> _logout() async => supa.auth.signOut();

  @override
  void dispose() {
    _controller.dispose();
    if (_ch != null) supa.removeChannel(_ch!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My todos'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'New todo'),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _add, child: const Text('Add')),
          ]),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (c, i) {
                final t = _todos[i];
                return ListTile(
                  title: Text(t['task'] ?? ''),
                  subtitle: Text('status: ${t['status']}'),
                  onTap: () => _toggle(t['id'] as int, t['status'] as String),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _del(t['id'] as int),
                  ),
                );
              },
            ),
          ),
        ),
      ]),
    );
  }
}
