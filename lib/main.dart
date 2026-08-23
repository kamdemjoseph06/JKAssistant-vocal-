import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'service_locator.dart';
import 'presentation/blocs/voice_bloc.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent,statusBarIconBrightness: Brightness.light));
  await setupDependencies();
  runApp(const VocalAssistantApp());
}

class VocalAssistantApp extends StatelessWidget {
  const VocalAssistantApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Vocal Assist',debugShowCheckedModeBanner: false,theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4ECDC4),brightness: Brightness.dark),useMaterial3: true),home: const PermissionGate());
  }
}

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key});
  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _permissionsGranted = false;
  bool _checking = true;
  @override
  void initState() { super.initState(); _checkPermissions(); }
  Future<void> _checkPermissions() async {
    final statuses = await [Permission.microphone,Permission.phone,Permission.contacts].request();
    var contactsGranted = statuses[Permission.contacts] == PermissionStatus.granted;
    if (contactsGranted) contactsGranted = await FlutterContacts.requestPermission(readonly: true);
    final allGranted = statuses.entries.where((entry) => entry.key != Permission.contacts).every((entry) => entry.value == PermissionStatus.granted) && contactsGranted;
    setState(() { _permissionsGranted = allGranted; _checking = false; });
  }
  @override
  Widget build(BuildContext context) {
    if (_checking) return const Scaffold(backgroundColor: Color(0xFF0A0E1A),body: Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4))));
    if (!_permissionsGranted) return _PermissionDeniedScreen(onRetry: _checkPermissions);
    return BlocProvider(create: (_) => getIt<VoiceBloc>()..add(VoiceInitialized()),child: const HomeScreen());
  }
}

class _PermissionDeniedScreen extends StatelessWidget {
  final VoidCallback onRetry;
  const _PermissionDeniedScreen({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: const Color(0xFF0A0E1A),body: Center(child: Padding(padding: const EdgeInsets.all(32),child: Column(mainAxisAlignment: MainAxisAlignment.center,children: [const Icon(Icons.mic_off,color: Color(0xFFFF6B6B),size: 64),const SizedBox(height: 24),const Text('Permissions requises',style: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.bold)),const SizedBox(height: 12),const Text('L\'application a besoin de :\n• Microphone (écoute vocale)\n• Téléphone (passer des appels)\n• Contacts (accès au répertoire)',style: TextStyle(color: Color(0xFF6B7280),height: 1.6),textAlign: TextAlign.center),const SizedBox(height: 32),ElevatedButton(onPressed: onRetry,style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4ECDC4),foregroundColor: const Color(0xFF0A0E1A),padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 14),shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),child: const Text('Autoriser les permissions',style: TextStyle(fontWeight: FontWeight.bold))),const SizedBox(height: 12),TextButton(onPressed: openAppSettings,child: const Text('Ouvrir les paramètres',style: TextStyle(color: Color(0xFF4ECDC4))))]))));
  }
}
