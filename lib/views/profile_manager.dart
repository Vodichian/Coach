import 'package:coach/database/local_database.dart';
import 'package:coach/database/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

var _logger = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

class ProfileManager extends StatefulWidget {
  const ProfileManager({super.key});

  @override
  State<ProfileManager> createState() => _ProfileManagerState();
}

class _ProfileManagerState extends State<ProfileManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profiles')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          GoRouter.of(context).push('/profiles/create_profile');
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
          child: SizedBox(
        width: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 100,
            ),
            Text(
              'Select a profile:',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ListView(
              shrinkWrap: true,
              children: _profileList(),
            ),
          ],
        ),
      )),
    );
  }

  List<Widget> _profileList() {
    LocalDatabase database = context.read();
    return database.profiles().map((e) => _toText(e)).toList();
  }

  Widget _toText(Profile profile) {
    Widget widget = Card(
        child: ListTile(
      title: Text(profile.name),
      onTap: () => _makeCurrent(profile),
      leading: const Icon(Icons.account_circle),
    ));
    return widget;
  }

  _makeCurrent(Profile profile) {
    LocalDatabase database = context.read();
    _logger.d('Setting profile "${profile.name} to current');
    database.makeProfileCurrent(profile);
  }
}
