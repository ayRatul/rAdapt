import 'rWrapper.dart';
extension RNumber on num {
  double get d => RController.getMultipliedValue(this);
  int get i => this.d.toInt();
}
