import 'package:autopeepal/logic/controller/cliCard/usbDiscoveryForWebController.dart';
import 'package:autopeepal/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:get/get.dart';


class UsbDeviceList extends StatelessWidget {
  final controller = Get.put(UsbController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       backgroundColor: AppColors.pagebgColor,
      appBar: AppBar(
        title: const Text("Windows VCI Discovery"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshPorts,
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (controller.availablePorts.isEmpty) {
          return const Center(child: Text("No COM Ports detected. Check VCI connection."));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.availablePorts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final address = controller.availablePorts[index];
            final port = SerialPort(address);
            
            // Check if this specific card is the one connected
            final isThisConnected = controller.isConnected.value && 
                                   controller.selectedAddress.value == address;

            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: isThisConnected ? Colors.green.shade50 : Colors.grey.shade50,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                leading: CircleAvatar(
                  backgroundColor: isThisConnected ? Colors.green : Colors.blueGrey,
                  child: const Icon(Icons.usb, color: Colors.white),
                ),
                title: Text(
                  "Port: $address",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Device: ${port.productName ?? 'Generic Serial Device'}"),
                    Text("VID: ${port.vendorId} | PID: ${port.productId}"),
                  ],
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isThisConnected ? Colors.green : Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: controller.isLoading.value 
                      ? null 
                      : (isThisConnected ? null : () => controller.connectToUsb(address)),
                  child: Text(isThisConnected ? "Active" : "Connect"),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}