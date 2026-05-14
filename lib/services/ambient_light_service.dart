import 'dart:async';

import 'package:ambient_light/ambient_light.dart';
import 'package:flutter/foundation.dart';

enum AmbientLightMode { normal, dim, bright }

class AmbientLightService {
  AmbientLightService._();

  static final AmbientLight _sensor = AmbientLight();

  static Stream<AmbientLightMode> watchMode() async* {
    if (kIsWeb) {
      yield AmbientLightMode.normal;
      return;
    }

    try {
      await for (final lux
          in _sensor.ambientLightStream
              .transform(_smoothLux())
              .handleError((_) {})) {
        yield _modeFromLux(lux);
      }
    } catch (_) {
      yield AmbientLightMode.normal;
    }
  }

  static StreamTransformer<double, double> _smoothLux() {
    final values = <double>[];
    return StreamTransformer<double, double>.fromHandlers(
      handleData: (lux, sink) {
        values.add(lux);
        if (values.length > 5) values.removeAt(0);
        final average = values.reduce((a, b) => a + b) / values.length;
        sink.add(average);
      },
    );
  }

  static AmbientLightMode _modeFromLux(double lux) {
    if (lux < 25) return AmbientLightMode.dim;
    if (lux > 700) return AmbientLightMode.bright;
    return AmbientLightMode.normal;
  }
}
