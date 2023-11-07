import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

import '../database/database.dart';
import '../database/profile.dart';

class ProfileEditor extends StatefulWidget {
  final Profile? profile;

  const ProfileEditor({super.key, this.profile});

  get isEditMode => profile != null;

  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final format = DateFormat("MMMM yyyy");

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      nameController.text = widget.profile!.name;
      DateTime date = widget.profile!.birthday;
      dateController.text = format.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.isEditMode
            ? Text('Editing profile "${widget.profile?.name}"')
            : const Text('Create a new profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            showDialog(context: context, builder: (builderContext) {
              return AlertDialog(
                title: const Text('Confirmation'),
                content: const Text('Really abandon changes?'),
                actions: [
                  // Yes
                  TextButton(
                      onPressed: () {
                        /// close dialog
                        GoRouter.of(context).pop();
                        /// navigate back to parent route
                        GoRouter.of(context).pop();
                      },
                      child: const Text('Yes')),
                  // No
                  TextButton(
                    onPressed: () {
                      // Close the dialog
                      GoRouter.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  )
                ],
              );
            },);
          },
        ),
      ),
      body: Center(
        child: SizedBox(
          width: 400,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(
                  height: 100,
                ),
                Text('Account Details',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(
                  height: 20,
                ),

                /// Name field
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                    labelText: 'Name:',
                    filled: true,
                    icon: Icon(Icons.account_circle),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'A name for your profile is required';
                    } else if (!widget.isEditMode) {
                      /// verify name doesn't already exist
                      Database database = context.read();
                      bool found = database
                          .profiles()
                          .where((element) =>
                              element.name.toLowerCase() == value.toLowerCase())
                          .isNotEmpty;
                      if (found) {
                        return 'The name "$value" already exists';
                      }
                    }
                    return null;
                  },
                  controller: nameController,
                ),

                /// DoB field
                TextFormField(
                  decoration: const InputDecoration(
                    hintText: 'Birth date, i.e. "January 1970"',
                    icon: Icon(Icons.cake),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Date of birth is required for health calculations';
                    } else {
                      try {
                        if (format.parse(value).isAfter(DateTime.now())) {
                          return 'This date is in the future';
                        } else {
                          return null;
                        }
                      } on FormatException {
                        return 'Not a valid date';
                      }
                    }
                  },
                  controller: dateController,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  /// Submit Button
                  child: ElevatedButton(
                    onPressed: () {
                      // Validate will return true if the form is valid, or false if
                      // the form is invalid.
                      if (_formKey.currentState!.validate()) {
                        Database database = context.read();
                        DateTime date = format.parse(dateController.text);
                        Profile profile;
                        if (widget.isEditMode) {
                          profile = widget.profile!;
                        } else {
                          profile = database.makeProfile(nameController.text);
                        }
                        profile.name = nameController.text;
                        profile.birthday = date;
                        database.updateProfile(profile);
                        logger.d('Name: ${nameController.text}');
                        // TODO: 11/6/2023 Add Gender
                        GoRouter.of(context).pop();
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
