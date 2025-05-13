import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:i_presence/models/coursesession_model.dart';
import 'package:i_presence/models/attendance_model.dart';
import 'package:i_presence/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:i_presence/models/auth_model.dart';

class ScannerScreen extends StatefulWidget {
  final CourseSession? session;

  const ScannerScreen({Key? key, this.session}) : super(key: key);

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!_isProcessing && scanData.code != null) {
        setState(() => _isProcessing = true);
        await _processQRCode(scanData.code!);
        setState(() => _isProcessing = false);
      }
    });
  }

  Future<void> _processQRCode(String code) async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final apiService = APIService(authModel.token!);
      
      // TODO: Implement attendance marking logic
      // This is where you'll make the API call to mark attendance
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Présence enregistrée pour: $code'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: Text('Scanner QR')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Permission de la caméra requise'),
              ElevatedButton(
                onPressed: _checkPermission,
                child: Text('Demander la permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner QR'),
        actions: [
          IconButton(
            icon: Icon(Icons.flip_camera_android),
            onPressed: () async {
              await controller?.flipCamera();
            },
          ),
          IconButton(
            icon: Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleFlash();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Theme.of(context).primaryColor,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.session != null) ...[
                    Text(
                      'Session: ${widget.session!.courseName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Classe: ${widget.session!.className}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (_isProcessing)
                    Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}