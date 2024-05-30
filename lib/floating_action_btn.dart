import 'package:floating_menu_panel/floating_menu_panel.dart';
import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class FloatingActionBtn extends StatefulWidget {
  const FloatingActionBtn({super.key});

  @override
  State<FloatingActionBtn> createState() => _FloatingActionBtnState();
}

class _FloatingActionBtnState extends State<FloatingActionBtn> {
  List<IconData>? icons = const [
    IconlyBold.camera,
    IconlyBold.game,
    IconlyBold.video,
    IconlyBold.add_user
  ];

  int _selectedIndex = 3;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Media Using Floating Btn'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Nanti content yang lain ada disini')],
          )),
          FloatingMenuPanel(
            onPressed: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            panelIcon: icons![_selectedIndex],
            backgroundColor: Colors.blueAccent,
            size: 60,
            panelShape: PanelShape.rounded,
            buttons: icons,
          )
        ],
      ),
    );
  }
}
