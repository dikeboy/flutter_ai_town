import 'actor_all.dart';

typedef AnimationFinish = void Function();
typedef AnimationChange = void Function(int value);

class BaseAnimation {
  AnimationFinish? finishListener;
  int duration = 0;
  double coastDuration = 0;
  bool start = false;
  int delay = 0;
  bool finish = false;

  void delayAnim(int delay) {
    this.delay = delay;
  }

  void setDuration(int duration) {
    this.duration = duration;
  }

  void startAnimation() {
    start = true;
  }

  void setOnFinish(AnimationFinish listener) {
    finishListener = listener;
  }

  void onAnimation(double dt) {
    if (!start || finish) return;
    coastDuration += dt * 1000;
    if (coastDuration < delay) {
      return;
    }
    var cost = coastDuration - delay;
    if (cost >= duration) {
      finish = true;
      onRend(cost);
      finishListener?.call();
    } else {
      onRend(cost);
    }
  }

  void onRend(double cost) {}
}

class TranslateAnimation extends BaseAnimation {
  late BaseActor baseActor;

  TranslateAnimation(this.baseActor);

  double destX = 0;
  double destY = 0;
  double beginX = 0;
  double beginY = 0;

  TranslateAnimation translateTo(double px, double py) {
    destX = px;
    destY = py;
    beginX = baseActor.position.x;
    beginY = baseActor.position.y;
    return this;
  }

  @override
  void onRend(double cost) {
    super.onRend(cost);
    var px = beginX + (destX - beginX) * cost / duration;
    var py = beginY + (destY - beginY) * cost / duration;
    baseActor.position.x = px;
    baseActor.position.y = py;
    if (finish) {
      baseActor.position.x = destX;
      baseActor.position.y = destY;
    }
  }
}

class ValueAnimation extends BaseAnimation {
  AnimationChange? change;

  ValueAnimation();

  int destX = 0;
  int beginX = 0;

  void translateTo(int startValue, int destValue) {
    destX = destValue;
    change = change;
    beginX = startValue;
  }

  void setValueChange(AnimationChange animationChange) {
    change = animationChange;
  }

  @override
  void onRend(double cost) {
    var px = beginX + (destX - beginX) * cost / duration;
    change?.call(px.toInt());
  }
}
