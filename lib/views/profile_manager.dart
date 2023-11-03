import 'package:coach/database/profile.dart';
import 'package:coach/profile_list_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';

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
            Consumer<Database>(
                builder: (context, database, child) => ProfileListView(
                      items: database.profiles(),
                      onEdit: _onEdit,
                      onDelete: _onDelete,
                      onTap: _makeCurrent,
                    ))
          ],
        ),
      )),
    );
  }

  _onEdit(Profile profile) {
    _logger.d('_onEdit called for $profile');
  }

  _onDelete(Profile profile) {
    _logger.d('_onDelete called for $profile');
    Database database = context.read();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete Confirmation'),
            content: Text('Really delete "${profile.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                  onPressed: () {
                    database.removeProfile(profile);
                    Navigator.pop(context);
                  },
                  child: const Text('Ok')),
            ],
          );
        });
  }

  _makeCurrent(Profile profile) {
    Database database = context.read();
    _logger.d('Setting profile "${profile.name} to current');
    database.makeProfileCurrent(profile);
  }
}
