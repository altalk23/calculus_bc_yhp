import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vec;
import 'package:tuple/tuple.dart';
import 'package:calc_yhp/line.dart';

typedef Vector3Tuple = Tuple2<vec.Vector3, vec.Vector3>;

class Graph extends CustomPainter {
  List<Line> lines;
  vec.Vector3 rotation;
  vec.Vector3 translation;
  double distance;
  Graph(this.lines, this.rotation, this.translation, this.distance);

  factory Graph.points({
    List<Line> lines = const [],
    vec.Vector3? rotation,
    vec.Vector3? translation,
    double distance = 1.0,
  }) {
    return Graph(lines, rotation ?? vec.Vector3.zero(),
        translation ?? vec.Vector3.zero(), distance);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    List<LineOffset> screenLines = [];
    for (Line line in lines) {
      LineOffset? offset =
          line.toOffset2(rotation, translation, distance, size);
      if (offset != null) {
        screenLines.add(offset);
      }
    }
    screenLines
        .sort((LineOffset a, LineOffset b) => a.item3.compareTo(b.item3));

    for (LineOffset line in screenLines) {
      // double sigmoid(double x) => 1 / (1 + math.exp(-x));
      // Color pointColor = Color.fromRGBO(0, 0, 0, 1.0 * (2 * sigmoid(-line.item3 / 3) - 1));
      canvas.drawLine(line.item1, line.item2,
          (Paint()..color = line.color)..strokeWidth = 2);

      // canvas.drawCircle(pointOffset, 4.0, Paint()..color = pointColor);
    }
  }

  @override
  bool shouldRepaint(Graph oldDelegate) => true;
}
