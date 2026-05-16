import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:io';
import 'package:hqapp/localization/app_localizations.dart';

class MapTrackingScreen extends StatefulWidget {
  const MapTrackingScreen({super.key});

  @override
  State<MapTrackingScreen> createState() => _MapTrackingScreenState();
}

class _MapTrackingScreenState extends State<MapTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('map_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: Image.asset(
                      'lib/dependencies/images/fullMap.png',
                      filterQuality: FilterQuality.high,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Text(l.t('map_image_not_found')),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 100),
              _buildGradientButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrCode()),
                  );
                },
                text: l.t('map_find_location_button'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, VoidCallback? onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6B4423), const Color(0xFF8B4513)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4423).withOpacity(0.3),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
}

class QrCode extends StatefulWidget {
  const QrCode({super.key});

  @override
  State<QrCode> createState() => _QrCodeState();
}

class _QrCodeState extends State<QrCode> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  bool screenOpen = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();
    screenOpen = false;
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l.t('qr_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: _buildGradientButton(
                  onPressed: () {
                    setState(() {
                      screenOpen = false;
                    });
                    controller?.resumeCamera();
                  },
                  text: l.t('qr_scan_again'),
                ),
              ),
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
        if (!screenOpen && result?.code != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoundCodeScreen(value: result),
            ),
          );
          controller.pauseCamera();
          screenOpen = true;
        }
      });
    });
  }

  Widget _buildGradientButton({required String text, VoidCallback? onPressed}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6B4423), const Color(0xFF8B4513)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4423).withOpacity(0.3),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
}

class FoundCodeScreen extends StatefulWidget {
  final Barcode? value;

  const FoundCodeScreen({super.key, required this.value});

  @override
  State<FoundCodeScreen> createState() => _FoundCodeScreenState();
}

class _FoundCodeScreenState extends State<FoundCodeScreen> {
  late String? qrValue= widget.value?.code;
  late String? imageValue= widget.value?.code;
  List<String> items = [];
  List<String> items2 = [];
  String? value1;
  //String? selectedValue;
  void checkImage(){
    final l = AppLocalizations.of(context);
    if (qrValue == 'location1'){
      items = [l.t('default'),l.t('35-38_student_rooms'),l.t('40-41_sitting_area'),l.t('44-46_kitchen'),l.t('56_imam_room'),l.t('58_walis_barza')];
    }
    else if (qrValue == 'location3'){
      items = [l.t('default'),l.t('56_imam_room'),l.t('58_walis_barza')];
      //items = items2;
    }
  }
  void changeImage(){
    final l = AppLocalizations.of(context);
    //location 1
    if (qrValue=='location1') {
      if (value1 == items[0]) {
        imageValue = widget.value?.code;
      } else if (value1 == items[1]) {
        imageValue = 'route/route_to_35-38';
      } else if (value1 == items[2]) {
        imageValue = 'route/route_to_40-41';
      } else if (value1 == items[3]) {
        imageValue = 'route/route_to_44-46';
      } else if (value1 == items[4]) {
        imageValue = 'route/route_to_56';
      } else if (value1 == items[5]) {
        imageValue = 'route/route_to_58';
      }
    }else if(qrValue=='location3') {
      //location 3
      if (value1 == items[0]) {
        imageValue = widget.value?.code;
      } else if (value1 == items[1]) {
        imageValue = 'route/route2_to_56';
      } else if (value1 == items[2]) {
        imageValue = 'route/route2_to_58';
      }
    }

  }

  @override
  void initState() {
    super.initState();
    checkImage();
    //selectedValue = items[0];
  }
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          l.t('qr_location_title'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF6B4423),
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.0),
                    child: widget.value?.code != null
                        ? Image.asset(
                            'lib/dependencies/images/$imageValue.png',
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Text(
                                  l.t('qr_location_image_not_found'),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(l.t('qr_no_location_image')),
                          ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.symmetric(horizontal: 12,vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFF8E5C34),width: 4)
                ),

                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    hint: Text(l.t('Select Route For a Room')),
                    value: value1,
                    isExpanded: true,
                    iconSize:  36,
                    icon: Icon(Icons.arrow_drop_down,color: Color(0xFF8E5C34),),
                    items: items.map(buildMenuItem).toList(),
                    onChanged: (value) => setState(() {
                      this.value1 = value;
                      changeImage();
                      print(value1);
                      print(imageValue);
                    }),
                    menuMaxHeight: 200,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20,color: Color(0xFF593A1D)),
        ),
      );

  Widget _buildGradientButton({required String text, VoidCallback? onPressed}) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF6B4423), const Color(0xFF8B4513)],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4423).withOpacity(0.3),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
}
