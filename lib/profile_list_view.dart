import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'database/profile.dart';

class _ExpandingListItem extends StatefulWidget {
  const _ExpandingListItem(
      {required this.onEdit,
      required this.onDelete,
      this.open = false,
      required this.onToggle,
      required this.profile});

  final void Function() onEdit;
  final void Function() onDelete;
  final void Function(bool) onToggle;
  final bool open;
  final Profile profile;

  @override
  State<StatefulWidget> createState() => _ExpandingListItemState();
}

class _ExpandingListItemState extends State<_ExpandingListItem> {
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isOpen = widget.open;
    });
  }

  bool getOpen() {
    _logger.d(
        '[${widget.profile.name}]widget.open = ${widget.open}, _isOpen = $_isOpen');
    _isOpen = widget.open && _isOpen;
    return _isOpen;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      onTap: () => {_logger.i('replace me with a function')},
      title: Text(widget.profile.name),
      trailing: getOpen() ? _openMenu() : _closedMenu(),
    ));
  }

  Widget _openMenu() {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
              onPressed: widget.onEdit, child: const Icon(Icons.edit)),
          ElevatedButton(
              onPressed: widget.onDelete, child: const Icon(Icons.delete)),
          ElevatedButton(
              onPressed: () => _pressed(),
              child: const Icon(Icons.arrow_right)),
        ],
      ),
    );
  }

  Widget _closedMenu() {
    return SizedBox(
      width: 200,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
              onPressed: () => _pressed(), child: const Icon(Icons.arrow_left)),
        ],
      ),
    );
  }

  _pressed() {
    setState(() {
      _logger.d('_open = $_isOpen');
      _isOpen = !_isOpen;
      widget.onToggle(_isOpen);
    });
  }
}

/// ProfileListView
class ProfileListView extends StatefulWidget {
  const ProfileListView({super.key, required this.items});

  final List<Profile> items;

  @override
  State<StatefulWidget> createState() => _ProfileListViewState();
}

/// State for ProfileListView
class _ProfileListViewState extends State<ProfileListView> {
  Profile? _requestOpenProfile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: _toExpandingListItems(widget.items),
    );
  }

  List<Widget> _toExpandingListItems(List<Profile> items) {
    _logger.d('Items: $items');
    List<Widget> list = items
        .map(
          (e) => _ExpandingListItem(
            profile: e,
            onEdit: () => onEdit(e),
            onDelete: () => onDelete(e),
            onToggle: (isOpen) => onOpen(isOpen, e),
            open: _requestOpenProfile == e,
          ),
        )
        .toList();
    _logger.d('List: $list');
    return list;
  }

  onEdit(Profile e) {
    _logger.d('onEdit clicked for $e');
  }

  onDelete(Profile e) {
    _logger.d('onDelete clicked for $e');
  }

  onOpen(bool isOpen, Profile e) {
    _logger.d(('onOpen called for $e'));
    setState(() {
      isOpen ? _requestOpenProfile = e : _requestOpenProfile = null;
    });
  }
}

///
/// Test code
///

class _ExpandingListTest extends StatelessWidget {
  const _ExpandingListTest();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ListView Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: _MyHomePage(),
    );
  }
}

class _MyHomePage extends StatelessWidget {
  final String title = 'ExpandingListItem test';

  // final List<String> items = ['Rick', 'Link', 'Tori'];
  final List<Profile> items = [
    Profile("1", "Rick", DateTime.now(), Gender.male),
    Profile("2", "Linh", DateTime.now(), Gender.female),
    Profile("3", "Tori", DateTime.now(), Gender.female),
    Profile("4", "Willben", DateTime.now(), Gender.male),
    Profile("5", "Vincent", DateTime.now(), Gender.male),
  ];

  _MyHomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ProfileListView(items: items),
    );
  }
}

final Logger _logger = Logger(
  printer: PrettyPrinter(methodCount: 0, noBoxingByDefault: true),
);

void main() {
  runApp(const _ExpandingListTest());
}
