import 'package:calc_yhp/graph.dart';
import 'package:flutter/material.dart';

import 'package:calc_yhp/sky.dart';

import 'package:calc_yhp/calc.dart';
import 'package:calc_yhp/line.dart';
import 'package:vector_math/vector_math.dart' as vec;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Calculus BC YHP Project'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Offset _offset = Offset.zero;
  Offset _initialFocalPoint = Offset.zero;
  Offset _sessionOffset = Offset.zero;

  double _scale = 1.0;
  double _initialScale = 1.0;

  double xPos = 2.0;
  double yPos = 2.0;
  double zPos = 2.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onScaleStart: (details) {
                _initialFocalPoint = details.focalPoint;
                _initialScale = _scale;
              },
              onScaleUpdate: (details) {
                setState(() {
                  _sessionOffset = details.focalPoint - _initialFocalPoint;
                  _scale = _initialScale * details.scale;
                });
              },
              onScaleEnd: (details) {
                setState(() {
                  _offset += _sessionOffset;
                  _sessionOffset = Offset.zero;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: Graph.points(
                    lines: [
                      Line(vec.Vector3(0, 0, 0), vec.Vector3(10, 0, 0),
                          Colors.red),
                      Line(vec.Vector3(0, 0, 0), vec.Vector3(0, 10, 0),
                          Colors.green),
                      Line(vec.Vector3(0, 0, 0), vec.Vector3(0, 0, 10),
                          Colors.blue),
                      Line(vec.Vector3(0, 0, 0), vec.Vector3(-10, 0, 0),
                          Colors.red),
                      Line(vec.Vector3(0, 0, 0), vec.Vector3(0, -10, 0),
                          Colors.green),
                      Line(vec.Vector3(0, 0, 0), vec.Vector3(0, 0, -10),
                          Colors.blue),
                      Line(vec.Vector3(0, 0, 0), vec.Vector3(xPos, yPos, zPos),
                          Colors.black),
                      Line(vec.Vector3(xPos, 0, 0), vec.Vector3(xPos, 0, zPos),
                          Colors.orangeAccent),
                      Line(
                          vec.Vector3(xPos, 0, zPos),
                          vec.Vector3(xPos, yPos, zPos),
                          Colors.lightGreenAccent),
                      Line(vec.Vector3(0, 0, zPos), vec.Vector3(xPos, 0, zPos),
                          Colors.cyanAccent),
                    ],
                    rotation: vec.Vector3(
                      (_offset + _sessionOffset).dy * -0.01,
                      (_offset + _sessionOffset).dx * 0.01,
                      0,
                    ),
                    translation: vec.Vector3.zero(),
                    distance: _scale * 5.0,
                  ),
                ),
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'X Pos',
              ),
              onChanged: (value) {
                setState(() {
                  xPos = double.parse(value);
                });
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Y Pos',
              ),
              onChanged: (value) {
                setState(() {
                  yPos = double.parse(value);
                });
              },
            ),
            TextField(
              keyboardType: TextInputType.number,
              obscureText: false,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Z Pos',
              ),
              onChanged: (value) {
                setState(() {
                  zPos = double.parse(value);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
