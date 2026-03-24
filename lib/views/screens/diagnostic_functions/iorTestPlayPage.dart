import 'package:autopeepal/models/iotTest_model.dart';
import 'package:flutter/material.dart';

class IorTestPlayPage extends StatelessWidget {
  final List<TestItem>? iorTestList;
  final List<TestOutput>? testOutputList;
  final bool inputViewVisible;
  final bool outputViewVisible;
  final bool violationOutputViewVisible;
  final bool shutOffPopupVisible;
  final bool isBusy;

  const IorTestPlayPage(
    IorResult iorResult,
    String seedIndex,
    String writeFnIndex,
    int? noOfInjectors,
    List<int> firingOrder, {
    super.key,
     this.iorTestList,
     this.testOutputList,
    this.inputViewVisible = false,
    this.outputViewVisible = false,
    this.violationOutputViewVisible = false,
    this.shutOffPopupVisible = false,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Self Test')),
      backgroundColor: Colors.grey[100], // page_bg_color
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  // IorTestList
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: iorTestList!.length,
                    itemBuilder: (context, index) {
                      final test = iorTestList![index];
                      if (!test.testVisible) return const SizedBox.shrink();
                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      test.description,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  if (test.btnVisible)
                                    IconButton(
                                      onPressed: test.btnActivationStatus
                                          ? () {
                                              // TestActionClicked
                                            }
                                          : null,
                                      icon: Icon(
                                        Icons.play_arrow,
                                        color: test.btnBackgroundColor,
                                      ),
                                    ),
                                ],
                              ),
                              if (test.descriptionVisible)
                                Text(
                                  test.testInstruction,
                                  style: const TextStyle(fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // TxtAction Label
                  const Text(
                    'Action Text Here', // bind to TxtAction
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  // Timer & TestStatus Grid
                  Column(
                    children: [
                      Text(
                        '00:10', // bind to Timer
                        style: const TextStyle(fontSize: 25),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Test Passed', // bind to TestStatus
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // TestOutputList
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: testOutputList!.length,
                    itemBuilder: (context, index) {
                      final output = testOutputList![index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: Colors.blue,
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              output.header,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: output.piCodeVariable.length,
                            itemBuilder: (context, idx) {
                              final pi = output.piCodeVariable[idx];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2, horizontal: 8),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(pi.shortName)),
                                    Text(pi.showResolution),
                                    const SizedBox(width: 8),
                                    Text(pi.unit),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Overlays like InputView, OutputView, ViolationOutputView, ShutOffPopup
          if (inputViewVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: Center(
                  child: Card(
                    child: SizedBox(
                      width: 250,
                      height: 300,
                      child: Column(
                        children: [
                          Container(
                            height: 40,
                            color: Colors.blue,
                            alignment: Alignment.center,
                            child: const Text(
                              'Input PIDs',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // CollectionView equivalent
                          const Expanded(
                              child: Center(child: Text('Inputs Here'))),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Start')),
                              ),
                              Expanded(
                                child: ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Cancel')),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Loader
          if (isBusy)
            const Positioned.fill(
                child: ColoredBox(
              color: Colors.black54,
              child: Center(child: CircularProgressIndicator()),
            )),
        ],
      ),
    );
  }
}

// Example models
class TestItem {
  String description;
  String testInstruction;
  bool testVisible;
  bool descriptionVisible;
  bool btnVisible;
  bool btnActivationStatus;
  Color btnBackgroundColor;

  TestItem({
    required this.description,
    required this.testInstruction,
    this.testVisible = true,
    this.descriptionVisible = true,
    this.btnVisible = true,
    this.btnActivationStatus = true,
    this.btnBackgroundColor = Colors.blue,
  });
}

class TestOutput {
  String header;
  List<PICodeVariable> piCodeVariable;

  TestOutput({required this.header, required this.piCodeVariable});
}

class PICodeVariable {
  String shortName;
  String showResolution;
  String unit;

  PICodeVariable(
      {required this.shortName,
      required this.showResolution,
      required this.unit});
}
