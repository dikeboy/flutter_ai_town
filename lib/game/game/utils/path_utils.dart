import 'dart:convert';
import 'dart:math';

class Obstacle {
  final int x, y, width, height;
  Obstacle(this.x, this.y, this.width, this.height);

  bool contains(int px, int py) {
    return px >= x && px < x + width && py >= y && py < y + height;
  }
}

class Node {
  int x, y;
  double g = 0, h = 0;
  Node? parent;

  Node(this.x, this.y);

  double get f => g + h;

  @override
  bool operator ==(Object other) => other is Node && x == other.x && y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}

class PathFinder {
  List<Obstacle> obstacles = [];
  final int step = 20; // 步长，步长越小路径越精确但计算越慢

  PathFinder(String jsonStr, int startX, int startY, int endX, int endY) {
    List<dynamic> data = jsonDecode(jsonStr);
    for (var item in data) {
      List<int> pos = item['position'].split(',').map((e) => int.parse(e.trim())).toList().cast<int>();
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

  List<List<int>> findPath(int startX, int startY, int endX, int endY) {
    List<Node> openList = [];
    Set<Node> closedList = {};

    Node startNode = Node(startX, startY);
    Node endNode = Node(endX, endY);
    openList.add(startNode);

    while (openList.isNotEmpty) {
      // 获取 F 值最低的点
      openList.sort((a, b) => a.f.compareTo(b.f));
      Node current = openList.removeAt(0);
      closedList.add(current);

      // 到达终点附近
      if (sqrt(pow(current.x - endX, 2) + pow(current.y - endY, 2)) < step) {
        return _reconstructPath(current, startNode);
      }

      // 检查 8 个方向
      for (int dx = -1; dx <= 1; dx++) {
        for (int dy = -1; dy <= 1; dy++) {
          if (dx == 0 && dy == 0) continue;

          int nextX = current.x + dx * step;
          int nextY = current.y + dy * step;

          if (isWalkable(nextX, nextY)) {
            Node neighbor = Node(nextX, nextY);
            if (closedList.contains(neighbor)) continue;

            double tentativeG = current.g + sqrt(dx * dx + dy * dy) * step;

            Node? existingNode = openList.firstWhere((n) => n == neighbor, orElse: () => Node(-1, -1));

            if (existingNode.x == -1) {
              neighbor.parent = current;
              neighbor.g = tentativeG;
              neighbor.h = sqrt(pow(nextX - endX, 2) + pow(nextY - endY, 2));
              openList.add(neighbor);
            } else if (tentativeG < existingNode.g) {
              existingNode.parent = current;
              existingNode.g = tentativeG;
            }
          }
        }
      }
    }
    return [];
  }

  List<List<int>> _reconstructPath(Node node, Node startNode) {
    List<List<int>> path = [];
    Node? temp = node;
    List<Point<int>> points = [];

    while (temp != null) {
      points.add(Point(temp.x, temp.y));
      temp = temp.parent;
    }
    points = points.reversed.toList();

    // 转换为位移格式 [dx, dy]
    int currentX = startNode.x;
    int currentY = startNode.y;

    for (var p in points) {
      int dx = p.x - currentX;
      int dy = p.y - currentY;
      if (dx != 0 || dy != 0) {
        path.add([dx, dy]);
      }
      currentX = p.x;
      currentY = p.y;
    }
    return path;
  }
}

void main() {
  String obstacleJson = '''
  [{"name": "房子1", "position": "175,175,224,224", "type": "房子"}, {"name": "房子2", "position": "625,175,224,224", "type": "房子"}, {"name": "房子3", "position": "175,625,224,224", "type": "房子"}, {"name": "房子4", "position": "625,625,224,224", "type": "房子"}, {"name": "门1", "position": "263,375,48,32", "type": "门"}, {"name": "门2", "position": "713,375,48,32", "type": "门"}, {"name": "门3", "position": "263,825,48,32", "type": "门"}, {"name": "门4", "position": "713,825,48,32", "type": "门"}, {"name": "灌木1", "position": "215,420,48,48", "type": "灌木"}, {"name": "灌木2", "position": "320,420,48,48", "type": "灌木"}, {"name": "灌木3", "position": "655,420,48,48", "type": "灌木"}, {"name": "灌木4", "position": "760,420,48,48", "type": "灌木"}, {"name": "灌木5", "position": "215,860,48,48", "type": "灌木"}, {"name": "灌木6", "position": "320,860,48,48", "type": "灌木"}, {"name": "灌木7", "position": "655,860,48,48", "type": "灌木"}, {"name": "灌木8", "position": "760,860,48,48", "type": "灌木"}, {"name": "树木1", "position": "110,85,64,85", "type": "树木"}, {"name": "树木2", "position": "210,85,64,85", "type": "树木"}, {"name": "树木3", "position": "345,55,64,85", "type": "树木"}, {"name": "树木4", "position": "415,90,64,85", "type": "树木"}, {"name": "树木5", "position": "55,160,64,85", "type": "树木"}, {"name": "树木6", "position": "55,270,64,85", "type": "树木"}, {"name": "树木7", "position": "55,405,64,85", "type": "树木"}, {"name": "树木8", "position": "115,415,64,85", "type": "树木"}, {"name": "树木9", "position": "415,285,64,85", "type": "树木"}, {"name": "树木10", "position": "470,95,64,85", "type": "树木"}, {"name": "树木11", "position": "660,95,64,85", "type": "树木"}, {"name": "树木12", "position": "780,55,64,85", "type": "树木"}, {"name": "树木13", "position": "850,105,64,85", "type": "树木"}, {"name": "树木14", "position": "910,145,64,85", "type": "树木"}, {"name": "树木15", "position": "850,215,64,85", "type": "树木"}, {"name": "树木16", "position": "910,345,64,85", "type": "树木"}, {"name": "树木17", "position": "850,410,64,85", "type": "树木"}, {"name": "树木18", "position": "550,275,64,85", "type": "树木"}, {"name": "树木19", "position": "550,400,64,85", "type": "树木"}, {"name": "树木20", "position": "55,595,64,85", "type": "树木"}, {"name": "树木21", "position": "115,610,64,85", "type": "树木"}, {"name": "树木22", "position": "55,735,64,85", "type": "树木"}, {"name": "树木23", "position": "115,835,64,85", "type": "树木"}, {"name": "树木24", "position": "205,860,64,85", "type": "树木"}, {"name": "树木25", "position": "345,910,64,85", "type": "树木"}, {"name": "树木26", "position": "415,550,64,85", "type": "树木"}, {"name": "树木27", "position": "415,730,64,85", "type": "树木"}, {"name": "树木28", "position": "910,545,64,85", "type": "树木"}, {"name": "树木29", "position": "850,610,64,85", "type": "树木"}, {"name": "树木30", "position": "910,670,64,85", "type": "树木"}, {"name": "树木31", "position": "910,775,64,85", "type": "树木"}, {"name": "树木32", "position": "785,905,64,85", "type": "树木"}, {"name": "树木33", "position": "620,915,64,85", "type": "树木"}, {"name": "树木34", "position": "555,730,64,85", "type": "树木"}, {"name": "树木35", "position": "555,860,64,85", "type": "树木"}]
  ''';
  int startX = 20, startY = 20;
  int endX = 760, endY = 720;
  PathFinder finder = PathFinder(obstacleJson, startX, startY, endX, endY);
  List<List<int>> result = finder.findPath(startX, startY, endX, endY);

  print("规划路径位移序列:");
  print(result);
}