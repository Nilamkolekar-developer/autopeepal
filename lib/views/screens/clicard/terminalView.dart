import 'package:autopeepal/logic/controller/cliCard/terminalController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TerminalView extends StatelessWidget {

  final TerminalController controller = Get.put(TerminalController());
  final TextEditingController textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
final Color primaryColor = const Color(0xFFFF7A00);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text("Device Terminal"),
       
      ),
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                ),
                child: Obx(() {
                  // AUTO-SCROLL LOGIC: Moves to bottom when new data arrives
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      final log = controller.logs[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: SelectableText( // Allows copying Hex codes
                          log['msg'] ?? "",
                          style: TextStyle(
                            color: log['color'] ?? Colors.black,
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),

            // 2. INPUT AREA
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              color: Colors.grey[900],
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      // FIXED: Text is now white so it's visible on dark background
                      style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                      decoration: InputDecoration(
                        hintText: "Enter Hex (e.g. 500A...)",
                        hintStyle: const TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (value) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _handleSend,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend() {
    if (textController.text.trim().isNotEmpty) {
     controller.executeCommand(textController.text.trim());
      textController.clear();
    }
  }
}