import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:mini_game/game/game/viewmodel/share_utils.dart';

import '../pop_main.dart';

class SelectionDialog extends StatelessWidget {
  final MyGame game;

  const SelectionDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material( // 确保文字有 Material 样式
        color: Colors.transparent,
        child: Container(
          width: 300, // 固定宽度
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // 弹窗高度自适应
            children: [
              Text(
                "选择大模型",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.white24),

              // 核心部分：使用 ConstrainedBox 限制滚动区最大高度
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 300, // 超过这个高度（约 6 个按钮的高度）就会开启滚动
                ),
                child: ListView.builder(
                  shrinkWrap: true, // 关键：让 ListView 只占用实际内容高度
                  itemCount: game.options.length,
                  itemBuilder: (context, index) {
                    final option = game.options[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          print("选择了: $option");
                          ShareUtils.putStringData("chooseModel", option);
                          game.overlays.remove('ChoiceMenu');
                        },
                        child: Text(option),
                      ),
                    );
                  },
                ),
              ),

              const Divider(color: Colors.white24),
              TextButton(
                onPressed: () => game.overlays.remove('ChoiceMenu'),
                child: const Text("关闭", style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}