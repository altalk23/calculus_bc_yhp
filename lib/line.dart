import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';
import 'package:calc_yhp/calc.dart';
import 'dart:math' as math;

class LineOffset {
  final Offset item1;
  final Offset item2;
  final double item3;
  final Color color;
  LineOffset(this.item1, this.item2, this.item3, this.color);
}

class Line {
  final Vector3 point1;
  final Vector3 point2;
  final Color color;
  final double scale = 4;

  Line(this.point1, this.point2, this.color);

  LineOffset? toOffset(
      Vector3 rotation, Vector3 translation, double distance, Size size) {
    Vector3 difference = point2 - point1;
    // assumes point1 is visible
    final Rect rect = Offset.zero & size;
    Vector3? project1 =
        Calculations.project(point1, rotation, translation, distance);

    if (project1 == null) {
      return null;
    }

    Offset offset1 = Offset(
        Calculations.map(project1.x, -scale, scale, 0, size.width),
        Calculations.map(project1.y, -scale, scale, size.height, 0));

    Vector3? project2 = Vector3.zero();
    Offset offset2 = Offset.zero;

    double multiplier = 0.5;

    for (num i = math.pow(2, -2); i > math.pow(2, -20); i /= 2) {
      project2 = Calculations.project(
          point1 + difference * multiplier, rotation, translation, distance);
      if (project2 != null) {
        offset2 = Offset(
            Calculations.map(project2.x, -scale, scale, 0, size.width),
            Calculations.map(project2.y, -scale, scale, size.height, 0));
        if (rect.contains(offset2)) {
          multiplier += i;
        } else {
          multiplier -= i;
        }
      } else {
        multiplier -= i;
      }
    }
    if (project2 == null) {
      return null;
    }

    return LineOffset(offset1, offset2, (project1.z + project2.z) / 2, color);
  }

  LineOffset? toOffset2(
      Vector3 rotation, Vector3 translation, double distance, Size size) {
    Vector3 difference = point2 - point1;
    final Rect rect = Offset.zero & size;

    Vector3? project1 =
        Calculations.project(point1, rotation, translation, distance);
    Offset offset1 = Offset.zero;
    if (project1 != null) {
      offset1 = Offset(
          Calculations.map(project1.x, -scale, scale, 0, size.width),
          Calculations.map(project1.y, -scale, scale, size.height, 0));
    }

    Vector3? project2 =
        Calculations.project(point2, rotation, translation, distance);

    Offset offset2 = Offset.zero;
    if (project2 != null) {
      offset2 = Offset(
          Calculations.map(project2.x, -scale, scale, 0, size.width),
          Calculations.map(project2.y, -scale, scale, size.height, 0));
    }

    Vector3? projectCutoff = Vector3.zero();
    Offset offsetCutoff = Offset.zero;

    double multiplier = 0.5;

    for (num i = math.pow(2, -2); i > math.pow(2, -20); i /= 2) {
      projectCutoff = Calculations.project(
          point1 + difference * multiplier, rotation, translation, distance);
      if (projectCutoff != null) {
        offsetCutoff = Offset(
            Calculations.map(projectCutoff.x, -scale, scale, 0, size.width),
            Calculations.map(projectCutoff.y, -scale, scale, size.height, 0));
        if (rect.contains(offsetCutoff)) {
          multiplier += i;
        } else {
          multiplier -= i;
        }
      } else {
        multiplier -= i;
      }
    }
    if (projectCutoff == null) {
      return null;
    }
    if (project1 != null && rect.contains(offset1)) {
      return LineOffset(
          offset1, offsetCutoff, (project1.z + projectCutoff.z) / 2, color);
    } else if (project2 != null && rect.contains(offset2)) {
      return LineOffset(
          offsetCutoff, offset2, (projectCutoff.z + project2.z) / 2, color);
    } else {
      return null;
    }
  }

  // factory Line.points(Vector3 point1, Vector3 point2, Vector3 rotation, Vector3 translation, double distance, Size size, Color color) {
  //   Offset start = Offset(
  //       Calculations.map(point1.x, -2, 2, 0, size.width),
  //       Calculations.map(point1.y, -2, 2, size.height, 0));

  //   Offset end = Offset(
  //       Calculations.map(point2.x, -2, 2, 0, size.width),
  //       Calculations.map(point2.y, -2, 2, size.height, 0));

  //   double z = (point1.z + point2.z) / 2;

  //   return Line(start, end, z, color);
  // }

}
