// ignore_for_file: non_constant_identifier_names, unused_local_variable

import 'package:vector_math/vector_math.dart';

class Calculations {
  static double map(
      double value, double start1, double stop1, double start2, double stop2) {
    return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1));
  }

  /*
   * Notation
   * (x, y, z) is used for 3d points, which are also column vectors
   * [x, y, z] is used for row vectors
   * if X, Y and Z are column vectors, [X, Y, Z] is a matrix
   * for A = (x, y, z), A.x is x, A.y is y, A.z is z
   */

  static Vector3 applyRotation(Vector3 point, Vector3 rotation) {
    /**
     * Rotation is in radians
     * General 3d rotation matrix is found by
     * matrix = Rz(Rotz) * Ry(Roty) * Rx(Rotx)
     * where Rotz is the rotation around the z axis, 
     * Roty is the rotation around the y axis, 
     * and Rotx is the rotation around the x axis
     */
    final double Tx = rotation.x;
    final double Ty = rotation.y;
    final double Tz = rotation.z;
    final Matrix3 Rz = Matrix3.zero()..setRotationZ(Tz);
    final Matrix3 Ry = Matrix3.zero()..setRotationY(Ty);
    final Matrix3 Rx = Matrix3.zero()..setRotationX(Tx);
    final Matrix3 matrix = Rz * Ry * Rx;

    return point.clone()..applyMatrix3(matrix);
  }

  static Vector3 applyInverseRotation(Vector3 point, Vector3 rotation) {
    /**
     * Rotation is in radians
     * To find the inverse of a rotation matrix, we need to reverse
     * the multiplication order and take the inverse of the rotation around 
     * x y and z axis seperately
     * 
     * This gives matrix = Rx'(Rotx) * Ry'(Roty) * Rz'(Rotz)
     */
    final double Tx = rotation.x;
    final double Ty = rotation.y;
    final double Tz = rotation.z;
    final Matrix3 Rzi = Matrix3.zero()
      ..setRotationZ(Tz)
      ..invert();
    final Matrix3 Ryi = Matrix3.zero()
      ..setRotationY(Ty)
      ..invert();
    final Matrix3 Rxi = Matrix3.zero()
      ..setRotationX(Tx)
      ..invert();
    final Matrix3 matrix = Rxi * Ryi * Rzi;

    return point.clone()..applyMatrix3(matrix);
  }

  static Matrix3 createTriangleMatrix(Vector3 rotation, Vector3 translation) {
    /**
     * Rotation is in radians
     * To generate our normal camera plane, we need to create a triangle
     * and apply the necessary rotation to it
     * The triangle has the vertices (-1, 0, 0), (0, 1, 0), (1, 0, 0)
     * Then we can add the three vertices into a matrix
     * Ai = (-1, 0, 0)
     * Bi = (0, 1, 0)
     * Ci = (1, 0, 0)
     * T = [Ai * R, Bi * R, Ci * R]
     */
    final Vector3 A = Calculations.applyRotation(Vector3(-1, 0, 0), rotation);
    final Vector3 B = Calculations.applyRotation(Vector3(0, 1, 0), rotation);
    final Vector3 C = Calculations.applyRotation(Vector3(1, 0, 0), rotation);
    return Matrix3.columns(A, B, C);
  }

  static Vector4 createPlane(Vector3 rotation, Vector3 translation) {
    /**
     * Rotation is in radians
     * Here we create the plane using the triangle matrix
     * and the derivation can be found in 
     * https://keisan.casio.com/exec/system/1223596129
     * A = (By - Ay)(Cz - Az) - (Cy - Ay)(Bz - Az)
     * B = (Bz - Az)(Cx - Ax) - (Cz - Az)(Bx - Ax)
     * C = (Bx - Ax)(Cy - Ay) - (Cx - Ax)(By - Ay)
     * D = [A, B, C] * Translation
     * This gives us the plane equation in the form Ax + By + Cz + D = 0
     */
    final Matrix3 triangle =
        Calculations.createTriangleMatrix(rotation, translation);
    final double Ax = triangle.entry(0, 0);
    final double Ay = triangle.entry(1, 0);
    final double Az = triangle.entry(2, 0);
    final double Bx = triangle.entry(0, 1);
    final double By = triangle.entry(1, 1);
    final double Bz = triangle.entry(2, 1);
    final double Cx = triangle.entry(0, 2);
    final double Cy = triangle.entry(1, 2);
    final double Cz = triangle.entry(2, 2);

    Vector4 plane = Vector4(
        (By - Ay) * (Cz - Az) - (Cy - Ay) * (Bz - Az),
        (Bz - Az) * (Cx - Ax) - (Cz - Az) * (Bx - Ax),
        (Bx - Ax) * (Cy - Ay) - (Cx - Ax) * (By - Ay),
        0);
    plane.w = plane.x * translation.x +
        plane.y * translation.y +
        plane.z * translation.z;

    return plane;
  }

  static Vector3 createVertex(
      Vector3 rotation, Vector3 translation, double distance) {
    /**
     * The vertex is the point on the plane that is the 
     * furthest away from the camera
     * We create the vertex at point (0, 0, dist) 
     * and apply the rotation and translation
     * Vi = (0, 0, dist)
     * V = Vi * R + Translation
     */
    final Vector3 vertex = Vector3(0, 0, distance);
    final Vector3 rotatedVertex =
        Calculations.applyRotation(Vector3(0, 0, distance), rotation);
    return translation + rotatedVertex;
  }

  static double parametricEquation(
      Vector4 plane, Vector3 vertex, Vector3 point) {
    /**
     * The parametric equation is a line that passes through 
     * the vertex and any x, y, z point
     * (x0, y0, z0) + t(x1 - x0, y1 - y0, z1 - z0)
     * (x0 + t(x1 - x0), y0 + t(y1 - y0), z0 + t(z1 - z0))
     * where t is the parametric value, (x0, y0, z0) is the 
     * vertex, and (x1, y1, z1) is the point
     * 
     * Given the plane equation, we can substitiude the parametric
     * equation into the plane equation 
     * A(x0 + t(x1 - x0)) + B(y0 + t(y1 - y0)) + C(z0 + t(z1 - z0)) = D
     * 
     * And now solving for t gives us
     * A(x0) * t(x1 - x0) + B(y0) * t(y1 - y0) + C(z0) * t(z1 - z0) = D
     * t(x1 - x0) + t(y1 - y0) + t(z1 - z0) = D - A(x0) - B(y0) - C(z0)
     * t((x1 - x0) + (y1 - y0) + (z1 - z0)) = D - A(x0) - B(y0) - C(z0)
     * t = (D - A(x0) - B(y0) - C(z0)) / ((x1 - x0) + (y1 - y0) + (z1 - z0))
     * 
     */
    final double Ap = plane.x;
    final double Bp = plane.y;
    final double Cp = plane.z;
    final double Dp = plane.w;
    final double Vx = vertex.x;
    final double Vy = vertex.y;
    final double Vz = vertex.z;
    final double Px = point.x;
    final double Py = point.y;
    final double Pz = point.z;

    return (Dp - Ap * Vx - Bp * Vy - Cp * Vz) /
        (Ap * (Px - Vx) + Bp * (Py - Vy) + Cp * (Pz - Vz));
  }

  static Vector3 intersection(
      Vector3 point, Vector3 rotation, Vector3 translation, double distance) {
    /**
     * The intersection is the point on the plane that is found 
     * by plugging in the t(x, y, z) we found earlier into the
     * parametric equation 
     * (x0, y0, z0) + t(x1 - x0, y1 - y0, z1 - z0)
     * We also add a translation to the point, but this is
     * unused for the purposes of this application
     */
    final Vector4 plane = Calculations.createPlane(rotation, translation);
    final Vector3 vertex =
        Calculations.createVertex(rotation, translation, distance);

    final double t = Calculations.parametricEquation(plane, vertex, point);

    return Vector3(
      vertex.x + (point.x - vertex.x) * t + translation.x,
      vertex.y + (point.y - vertex.y) * t + translation.y,
      vertex.z + (point.z - vertex.z) * t + translation.z,
    );
  }

  static double zDepth(
      Vector3 point, Vector3 rotation, Vector3 translation, double distance) {
    /**
     * The z depth is the distance from the vertex to the point 
     * relative to the direction of the camera
     * We use this to render the point in the correct order
     * and hide the points behind the camera
     * This is done by applying the inverse rotation for the difference
     * between the point and the vertex
     * zD = ((P - V) * R').z
     */
    final Vector3 vertex =
        Calculations.createVertex(rotation, translation, distance);
    final Vector3 depth =
        Calculations.applyInverseRotation(point - vertex, rotation);
    return depth.z;
  }

  static Vector3? project(
      Vector3 point, Vector3 rotation, Vector3 translation, double distance) {
    /**
     * This is the main function that projects the 3d point onto 
     * the 2d screen with the correct z depth
     * We first find the intersection of the point with the plane 
     * and find the z depth of the point relative to the camera
     * 
     * if it is behind the camera, we return null (don't draw)
     * if it is in front of the camera, we apply the inverse rotation to
     * the intersection point and return [x, y, depth]
     * x = (Int * R').x
     * y = (Int * R').y
     * in theory, (Int * R').z is equal to 0 but because of 
     * floating precision loss it is some small value
     * z = zD
     */
    final Vector3 intersection =
        Calculations.intersection(point, rotation, translation, distance);
    final double zDepth =
        Calculations.zDepth(point, rotation, translation, distance);
    if (zDepth < 0) {
      Vector3 projected =
          Calculations.applyInverseRotation(intersection, rotation);
      return Vector3(projected.x, projected.y, zDepth);
    } else {
      return null;
    }
  }
}
