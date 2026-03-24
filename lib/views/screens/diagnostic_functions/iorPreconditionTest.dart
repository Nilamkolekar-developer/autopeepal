import 'package:autopeepal/models/iotTest_model.dart';
import 'package:flutter/material.dart';

class IorPreconditionPage extends StatelessWidget {
  final List<IorPid> iorPidList;
  final List<IorStatic> iorStaticList;
  final List<IorManual> iorManualList;
  final bool isBusy;

  const IorPreconditionPage(
    IorResult? iorResult,
    String? seedIndex,
    String? writeFnIndex,
    int? noOfInjectors,
    List<int>? firingOrder, {
    super.key,
     required this.iorPidList,
     required this.iorStaticList,
     required this.iorManualList,
    this.isBusy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preconditions')),
      backgroundColor: Colors.grey[100], // page_bg_color
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        // IorStaticList
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: iorStaticList.length,
                          itemBuilder: (context, index) {
                            final item = iorStaticList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  item.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // IorPidList
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: iorPidList.length,
                          itemBuilder: (context, index) {
                            final item = iorPidList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.description ?? '',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text('Min  : ',
                                                style: TextStyle(fontSize: 14)),
                                            Text(item.lowerLimit.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                        Row(
                                          children: [
                                            const Text('Value  : ',
                                                style: TextStyle(fontSize: 14)),
                                            Text(item.currentValue.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ],
                                        ),
                                        const SizedBox(width: 30),
                                        Row(
                                          children: [
                                            const Text('Max  : ',
                                                style: TextStyle(fontSize: 14)),
                                            Text(item.upperLimit.toString(),
                                                style: const TextStyle(
                                                    fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // IorManualList
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: iorManualList.length,
                          itemBuilder: (context, index) {
                            final item = iorManualList[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              elevation: 4,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.description,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                      ),
                                    ),
                                    Checkbox(
                                      value: item.isChecked,
                                      onChanged: (value) {
                                        // handle checkbox change
                                      },
                                      activeColor: Colors.blue, // theme_color
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // RedBtnStyle
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            color: Colors.blue)), // theme_color
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () {
                    // ContinueClicked
                  },
                  child: const Text('Continue'),
                ),
              )
            ],
          ),

          // Loader overlay
          if (isBusy)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

// Example models
class IorPid {
  String? description;
  double? lowerLimit;
  double? currentValue;
  double? upperLimit;

  IorPid({
    this.description,
    this.lowerLimit,
    this.currentValue,
    this.upperLimit,
  });
}

class IorStatic {
  String description;

  IorStatic({required this.description});
}

class IorManual {
  String description;
  bool isChecked;

  IorManual({required this.description, this.isChecked = false});
}
