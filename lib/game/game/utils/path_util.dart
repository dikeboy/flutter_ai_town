import 'dart:convert';
import 'dart:math';

List<Obstacle> lastPathList = [];

class Obstacle {
  final int x, y, width, height;
   String? name;
   String? type;
  Obstacle(this.x, this.y, this.width, this.height);

  bool contains(int px, int py) {
    return px >= x && px <= x + width && py >= y && py <= y + height;
  }
}

class Node {
  int x, y;
  double g = 0, h = 0;
  double directionPenalty = 0; // 方向权重
  Node? parent;

  Node(this.x, this.y);

  double get f => g + h + directionPenalty;

  @override
  bool operator ==(Object other) => other is Node && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class PathFinder {
  List<Obstacle> obstacles = [];
  final int step = 10; // 步长

  PathFinder(List<Obstacle> pathList, int startX, int startY, int endX, int endY) {
    for (var item in pathList) {
      List<int> pos = [item.x, item.y, item.width, item.height];
      // 忽略包含起点或终点的障碍物
      Obstacle obs = Obstacle(pos[0], pos[1], pos[2], pos[3]);
      if (!obs.contains(startX, startY) && !obs.contains(endX, endY)) {
        obstacles.add(obs);
      }
    }
  }

  bool isWalkable(int x, int y) {
    for (var obs in obstacles) {
      if (obs.contains(x, y)) return false;
    }
    return true;
  }

  List<List<int>> plan(int startX, int startY, int endX, int endY) {
    List<Node> openList = [];
    Set<Node> closedList = {};

    Node startNode = Node(startX, startY);
    openList.add(startNode);

    while (openList.isNotEmpty) {
      openList.sort((a, b) => a.f.compareTo(b.f));
      Node current = openList.removeAt(0);
      closedList.add(current);

      // 判断是否接近终点
      if ((current.x - endX).abs() <= step && (current.y - endY).abs() <= step) {
        return _simplifyPath(current, startX, startY, endX, endY);
      }

      // 8方向移动
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          if (dx == 0 && dy == 0) continue;

          int nextX = current.x + dx * step;
          int nextY = current.y + dy * step;

          if (isWalkable(nextX, nextY)) {
            Node neighbor = Node(nextX, nextY);
            if (closedList.contains(neighbor)) continue;

            // 计算基础移动代价 (对角线略贵)
            double moveCost = (dx == 0 || dy == 0) ? step.toDouble() : step * 1.414;
            double tentativeG = current.g + moveCost;

            // --- 核心优化：减少拐弯 ---
            double penalty = 0;
            if (current.parent != null) {
              int prevDx = current.x - current.parent!.x;
              int prevDy = current.y - current.parent!.y;
              // 如果当前移动方向与上一次不同，增加惩罚分
              if (dx * step != prevDx || dy * step != prevDy) {
                penalty = step * 0.5; // 惩罚值，数值越大越倾向于走直线
              }
            }

            Node? existing = openList.firstWhere((n) => n == neighbor, orElse: () => Node(-1, -1));
            if (existing.x == -1) {
              neighbor.parent = current;
              neighbor.g = tentativeG;
              neighbor.h = _heuristic(nextX, nextY, endX, endY);
              neighbor.directionPenalty = penalty;
              openList.add(neighbor);
            } else if (tentativeG < existing.g) {
              existing.parent = current;
              existing.g = tentativeG;
              existing.directionPenalty = penalty;
            }
          }
        }
      }
    }
    return []; // 找不到路径
  }

  double _heuristic(int x1, int y1, int x2, int y2) {
    return sqrt(pow(x1 - x2, 2) + pow(y1 - y2, 2));
  }

  // 将节点链表转换为合并后的位移数组
  List<List<int>> _simplifyPath(Node endNode, int startX, int startY, int targetX, int targetY) {
    List<Point<int>> points = [];
    Node? curr = endNode;
    while (curr != null) {
      points.add(Point(curr.x, curr.y));
      curr = curr.parent;
    }
    points = points.reversed.toList();
    points.add(Point(targetX, targetY)); // 强制加上终点

    if (points.length < 2) return [];

    List<List<int>> movements = [];
    int lastX = startX;
    int lastY = startY;

    // 路径平滑合并：合并相同方向的位移
    for (int i = 1; i < points.length; i++) {
      int dx = points[i].x - lastX;
      int dy = points[i].y - lastY;

      if (movements.isNotEmpty) {
        var lastMove = movements.last;
        // 检查是否在同一斜率直线上
        if (_isSameDirection(lastMove[0], lastMove[1], dx, dy)) {
          movements.last = [lastMove[0] + dx, lastMove[1] + dy];
        } else {
          movements.add([dx, dy]);
        }
      } else {
        movements.add([dx, dy]);
      }

      lastX = points[i].x;
      lastY = points[i].y;
    }
    return movements;
  }

  bool _isSameDirection(int dx1, int dy1, int dx2, int dy2) {
    if (dx1 == 0 && dx2 == 0) return true;
    if (dy1 == 0 && dy2 == 0) return true;
    if (dx1 != 0 && dx2 != 0 && dy1 != 0 && dy2 != 0) {
      return (dx1.toDouble() / dy1).toStringAsFixed(2) == (dx2.toDouble() / dy2).toStringAsFixed(2);
    }
    return false;
  }
}
void initPathFile(String file){
  // 1. 解析障碍物数据
  List<dynamic> rawList = jsonDecode(file);
  List<Obstacle> pathList = [];
  for (var item in rawList) {
    List<String> posParts = item['position'].split(',');
    Obstacle rect = Obstacle(
      int.parse(posParts[0]),
      int.parse(posParts[1]),
      int.parse(posParts[2]),
      int.parse(posParts[3]),
    );
    rect.name = item['name'];
    rect.type = item['type'];
    pathList.add(rect);
  }
  lastPathList.clear();
  lastPathList.addAll(pathList);

}

void main() {
  String jsonData = '''
  [{"name": "房子1", "position": "175,175,224,224", "type": "房子"},
  {"name": "房子2", "position": "625,175,224,224", "type": "房子"},
  {"name": "房子3", "position": "175,625,224,224", "type": "房子"},
  {"name": "房子4", "position": "625,625,224,224", "type": "房子"},
  {"name": "门1", "position": "263,375,48,32", "type": "门"},
  {"name": "门2", "position": "713,375,48,32", "type": "门"},
  {"name": "门3", "position": "263,825,48,32", "type": "门"},
  {"name": "门4", "position": "713,825,48,32", "type": "门"},
  {"name": "灌木1", "position": "215,420,48,48", "type": "灌木"},
  {"name": "灌木2", "position": "320,420,48,48", "type": "灌木"},
  {"name": "灌木3", "position": "655,420,48,48", "type": "灌木"},
  {"name": "灌木4", "position": "760,420,48,48", "type": "灌木"},
  {"name": "灌木5", "position": "215,860,48,48", "type": "灌木"},
  {"name": "灌木6", "position": "320,860,48,48", "type": "灌木"},
  {"name": "灌木7", "position": "655,860,48,48", "type": "灌木"},
  {"name": "灌木8", "position": "760,860,48,48", "type": "灌木"},
  {"name": "树木1", "position": "110,85,64,85", "type": "树木"},
  {"name": "树木2", "position": "210,85,64,85", "type": "树木"},
  {"name": "树木3", "position": "345,55,64,85", "type": "树木"},
  {"name": "树木4", "position": "415,90,64,85", "type": "树木"},
  {"name": "树木5", "position": "55,160,64,85", "type": "树木"},
  {"name": "树木6", "position": "55,270,64,85", "type": "树木"},
  {"name": "树木7", "position": "55,405,64,85", "type": "树木"},
  {"name": "树木8", "position": "115,415,64,85", "type": "树木"},
  {"name": "树木9", "position": "415,285,64,85", "type": "树木"},
  {"name": "树木10", "position": "470,95,64,85", "type": "树木"},
  {"name": "树木11", "position": "660,95,64,85", "type": "树木"},
  {"name": "树木12", "position": "780,55,64,85", "type": "树木"},
  {"name": "树木13", "position": "850,105,64,85", "type": "树木"},
  {"name": "树木14", "position": "910,145,64,85", "type": "树木"},
  {"name": "树木15", "position": "850,215,64,85", "type": "树木"},
  {"name": "树木16", "position": "910,345,64,85", "type": "树木"},
  {"name": "树木17", "position": "850,410,64,85", "type": "树木"},
  {"name": "树木18", "position": "550,275,64,85", "type": "树木"},
  {"name": "树木19", "position": "550,400,64,85", "type": "树木"},
  {"name": "树木20", "position": "55,595,64,85", "type": "树木"},
  {"name": "树木21", "position": "115,610,64,85", "type": "树木"},
  {"name": "树木22", "position": "55,735,64,85", "type": "树木"},
  {"name": "树木23", "position": "115,835,64,85", "type": "树木"},
  {"name": "树木24", "position": "205,860,64,85", "type": "树木"},
  {"name": "树木25", "position": "345,910,64,85", "type": "树木"},
  {"name": "树木26", "position": "415,550,64,85", "type": "树木"},
  {"name": "树木27", "position": "415,730,64,85", "type": "树木"},
  {"name": "树木28", "position": "910,545,64,85", "type": "树木"},
  {"name": "树木29", "position": "850,610,64,85", "type": "树木"},
  {"name": "树木30", "position": "910,670,64,85", "type": "树木"},
  {"name": "树木31", "position": "910,775,64,85", "type": "树木"},
  {"name": "树木32", "position": "785,905,64,85", "type": "树木"},
  {"name": "树木33", "position": "620,915,64,85", "type": "树木"},
  {"name": "树木34", "position": "555,730,64,85", "type": "树木"},
  {"name": "树木35", "position": "555,860,64,85", "type": "树木"}
]
  ''';

  initPathFile(jsonData);
  var destX = (700*1024/800).toInt();
  var destY = (520*1024/600).toInt();
  var startX = (20*1024/800).toInt();
  var startY = (20*1024/600).toInt();

  var planner = PathFinder(lastPathList,startX, startY, destX, destY);
  List<List<int>> route = planner.plan( startX, startY, destX,destY);

  print("规划移动路径: $route");
}