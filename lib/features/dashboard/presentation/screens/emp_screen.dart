import 'package:flutter/material.dart';
import 'package:pakland/core/widgets/app_header_bar.dart';

class EmpScreen extends StatefulWidget {
  const EmpScreen({super.key});

  @override
  State<EmpScreen> createState() => _EmpScreenState();
}

class _EmpScreenState extends State<EmpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeaderBar(title: Text('Screen'),),
      body: Center(
        child: Text('Screen'),
      ),
    );
  }
}
