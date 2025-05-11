import 'package:flutter/material.dart';
import 'package:i_presence/models/auth_model.dart';
import 'package:i_presence/utils/constante.dart';
import 'package:provider/provider.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScannerScreen extends StatefulWidget {
  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  String? _lastScanned;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Présence'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
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
                cutOutSize: 300,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: _isProcessing
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Scannez le code QR d\'un étudiant',
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (_lastScanned != null)
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: Text('Présence marquée'),
                              subtitle: Text(_lastScanned!),
                            ),
                          ),
                      ],
                    ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing || scanData.code == null) return;
      
      setState(() {
        _isProcessing = true;
      });
      
      try {
        final authModel = Provider.of<AuthModel>(context, listen: false);
        final response = await http.post(
          Uri.parse('$KbaseUrl/attendance/scan'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${authModel.token}',
          },
          body: json.encode({
            'qr_data': scanData.code,
          }),
        );
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _lastScanned = data['student']['user']['name'];
          });
          
          // Vibrer ou jouer un son pour indiquer le succès
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors du scan. Veuillez réessayer.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isProcessing = false;
        });
        
        // Pause brève pour éviter les scans multiples
        await Future.delayed(const Duration(seconds: 2));
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}