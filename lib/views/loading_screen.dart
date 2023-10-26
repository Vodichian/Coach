import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../database/local_database.dart';

/// An initial loading screen to give the database time to synchronize with the
/// filesystem before being accessed.
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    _loadDatabase();
    Timer(const Duration(seconds: 3), () {
      GoRouter.of(context).go('/weightchart');
    });
  }

  void _loadDatabase() async {
    LocalDatabase database = context.read();
    Directory directory = await getApplicationDocumentsDirectory();
    database.load(directory);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
