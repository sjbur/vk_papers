import 'package:flutter/material.dart';

class FinishScreen extends StatefulWidget {
  @override
  _FinishScreenState createState() => _FinishScreenState();
}

class _FinishScreenState extends State<FinishScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Финиш!"),
      ),
      body: Center(
        child: Text(
          "Ура! Всё готово!\nМожете закрыть приложение, уведомления будут приходить в указанное вами время. Удачи!",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
