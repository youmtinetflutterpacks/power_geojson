import 'dart:math';

import 'package:dart_jts/dart_jts.dart';

CoordinateSequence createCircularString(
  CoordinateSequenceFactory factory,
  int dimension,
  Coordinate center,
  double radius,
  double startAngle,
  int numPoints,
) {
//   const int numSegmentsCircle = 48;
  const double angleCircle = 2 * pi;
  double angleStep = angleCircle / numPoints;

  CoordinateSequence sequence = factory.createSizeDim(numPoints, dimension);
  PrecisionModel pm = PrecisionModel.fixedPrecision(100);
  double angle = startAngle;
  for (int i = 0; i < numPoints; i++) {
    double dx = cos(angle) * radius;
    double dy = sin(angle) * radius;
    sequence.setOrdinate(i, 0, pm.makePrecise(center.x + dx));
    sequence.setOrdinate(i, 1, pm.makePrecise(center.y + dy));

    // set other ordinate values to predictable values
    /* for (int j = 2; j < dimension; j++) {
      sequence.setOrdinate(i, j, (pow(10, j - 1) * i).toDouble());
    } */

    angle += angleStep;
    angle %= angleCircle;
  }

  return sequence;
}
