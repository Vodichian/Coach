import 'package:coach/views/profile_manager.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

void main() => runApp(const ProfileEditor());

class ProfileEditor extends StatelessWidget {
  const ProfileEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create a new profile'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // TODO: 10/26/2023 Add a confirmation step
              GoRouter.of(context).pop();
            },
          ),
        ),
        body: const ProfileEditorState(),
      ),
    );
  }
}

class ProfileEditorState extends StatefulWidget {
  const ProfileEditorState({super.key});

  @override
  State<ProfileEditorState> createState() => _ProfileEditorStateState();
}

class _ProfileEditorStateState extends State<ProfileEditorState> {
  var logger = Logger(
    printer: PrettyPrinter(methodCount: 0),
  );

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dateController = TextEditingController();
  final format = DateFormat("MMMM yyyy");

  @override
  Widget build(BuildContext context) {
    return Center(
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
                  }
                  return null;
                },
                controller: nameController,
              ),

              /// DoB field
              TextFormField(
                decoration: const InputDecoration(
                  hintText:
                      'Month and year of birth, for example: "January 1970"',
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
                child: ElevatedButton(
                  onPressed: () {
                    // Validate will return true if the form is valid, or false if
                    // the form is invalid.
                    if (_formKey.currentState!.validate()) {
                      // Process data.
                      logger.d('Name: ${nameController.text}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileManager()),
                      );
                    }
                  },
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// class BasicDateField extends StatelessWidget {
//   final format = DateFormat("yyyy-MM-dd");
//
//   BasicDateField({super.key});
//   @override
//   Widget build(BuildContext context) {
//     return Column(children: <Widget>[
//       Text('Basic date field (${format.pattern})'),
//       DateTimeField(
//         format: format,
//         validator: (DateTime? value) {
//           if (value == null || value.isAfter(DateTime.now())) {
//             return 'A valid date is required';
//           }
//           return null;
//         },
//         onShowPicker: (context, currentValue) {
//           return showDatePicker(
//               context: context,
//               firstDate: DateTime(1900),
//               initialDate: currentValue ?? DateTime.now(),
//               lastDate: DateTime(2100));
//         },
//         controller: dateController,
//       ),
//     ]);
//   }
// }
