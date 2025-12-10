import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F1EB),
      appBar: AppBar(
        title: const Text(
          'Map',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),

      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0,), // Match the image's border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5,), // Shadow color and opacity
                      spreadRadius: 2, // How far the shadow spreads
                      blurRadius: 5, // How blurry the shadow is
                      offset: Offset(0, 3), // X and Y offset of the shadow
                    ),
                  ],
                ),

                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: ClipRRect(
                    // Or your Container with BoxDecoration for rounded corners
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      'images/fullMap.png',
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 100),

              _buildGradientButton(onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QrCode()
                    ));
              }, text: "Find your current location",),

            ],
          ),
        ),
      ),

    );
  }
}


class QrCode extends StatefulWidget {
  const QrCode() : super();
  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool screenOpen = false;
  bool show = false;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    bool screenOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Map Scan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(key: qrKey, onQRViewCreated: _onQRViewCreated),
          ),
          /*
          Expanded(
            flex: 1,
            child: Center(
              child: (result != null)
                  ? Text(
                      'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  : Text('Scan a code'),
            ),
          ),*/
          Expanded(
            child: Center(
              child: (!screenOpen)
                  ? null
                  : _buildGradientButton(
                onPressed: () {
                  screenOpen = false;
                }, text: "Scan again!",),

              //ElevatedButton(onPressed: (){screenOpen=false;}, child: Text("Scan again!"), style: ElevatedButton.styleFrom(),),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (!screenOpen) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoundCodeScreen(value: result),
            ),
          );
          controller.pauseCamera();
          screenOpen = true;
        }
        if (screenOpen) {
          controller.resumeCamera();
        }
      });
    });
  }
}


class FoundCodeScreen extends StatefulWidget {
  final Barcode? value;
  //final Function() screenClosed;
  const FoundCodeScreen({
    Key? key,
    required this.value,
    //required this.screenClosed,
  }) : super(key: key);

  @override
  State<FoundCodeScreen> createState() => _FoundCodeScreenState();
}

class _FoundCodeScreenState extends State<FoundCodeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F1EB),
      appBar: AppBar(
        title: const Text(
          'Your Location',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        /*
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_outlined,),
        ),*/
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),

              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0,), // Match the image's border radius
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5,), // Shadow color and opacity
                      spreadRadius: 2, // How far the shadow spreads
                      blurRadius: 5, // How blurry the shadow is
                      offset: Offset(0, 3), // X and Y offset of the shadow
                    ),
                  ],
                ),

                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: ClipRRect(
                    // Or your Container with BoxDecoration for rounded corners
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      'images/${widget.value!.code}.png',
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildGradientButton({required String text, VoidCallback? onPressed}) {
  return Container(
    height: 56,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [Color(0xFF6B4423), Color(0xFF8B4513)]),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Color(0xFF6B4423).withOpacity(0.3),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}