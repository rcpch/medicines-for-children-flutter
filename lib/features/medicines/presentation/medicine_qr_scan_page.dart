// QR scan screen for medicine lookup.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:medicines_for_children_flutter/app/router/app_router.dart';
import 'package:medicines_for_children_flutter/core/domain/models/medicine.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/medicine_draft.dart';
import 'package:medicines_for_children_flutter/features/medicines/domain/qr_medicine_catalog.dart';

class MedicineQrScanPage extends ConsumerStatefulWidget {
  const MedicineQrScanPage({super.key});

  @override
  ConsumerState<MedicineQrScanPage> createState() => _MedicineQrScanPageState();
}

class _MedicineQrScanPageState extends ConsumerState<MedicineQrScanPage> {
  bool _isHandling = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR code')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Point the camera at a Medicines for Children QR code to add a medicine quickly.',
            ),
          ),
          Expanded(
            child: MobileScanner(
              onDetect: _handleDetect,
              errorBuilder: (context, error) {
                return _ScannerError(message: _errorMessage(error));
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isHandling) {
      return;
    }
    final barcode = capture.barcodes.cast<Barcode?>().firstWhere(
      (barcode) =>
          barcode?.rawValue != null && barcode!.rawValue!.trim().isNotEmpty,
      orElse: () => null,
    );
    final rawValue = barcode?.rawValue?.trim();
    if (rawValue == null || rawValue.isEmpty) {
      return;
    }
    setState(() => _isHandling = true);

    final result = parseQrScanResult(rawValue);
    switch (result.type) {
      case QrScanType.medicine:
        final entry = result.medicine!;
        final draft = MedicineDraft(
          name: entry.name,
          alias: '',
          type: MedicineType.everyday,
          dose: '',
          doseUnit: '',
          route: '',
          frequency: '',
          notes:
              'Quick add from Medicines for Children QR.\n${entry.title}\n${entry.url}',
        );
        if (!mounted) {
          return;
        }
        await context.pushNamed(AppRoute.addMedicine.name, extra: draft);
        break;
      case QrScanType.advice:
        if (!mounted) {
          return;
        }
        await _showLinkDialog(
          context,
          title: result.advice!.title,
          url: result.advice!.url,
        );
        break;
      case QrScanType.external:
        if (!mounted) {
          return;
        }
        await _showLinkDialog(
          context,
          title: result.external!.title,
          url: result.external!.url,
        );
        break;
      case QrScanType.unknown:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('QR code not recognized.')),
          );
        }
        break;
    }

    if (mounted) {
      setState(() => _isHandling = false);
    }
  }

  Future<void> _showLinkDialog(
    BuildContext context, {
    required String title,
    required String url,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(url),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () async {
              final uri = Uri.tryParse(url);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Open link'),
          ),
        ],
      ),
    );
  }

  String _errorMessage(MobileScannerException error) {
    return 'Camera not available on this device. Use a device with a camera to scan QR codes.';
  }
}

class _ScannerError extends StatelessWidget {
  const _ScannerError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
