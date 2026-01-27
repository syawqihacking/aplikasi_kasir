import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  
  factory PrinterService() {
    return _instance;
  }

  PrinterService._internal();

  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  BluetoothDevice? _selectedDevice;
  bool _isConnected = false;

  // Getters
  BlueThermalPrinter get bluetooth => _bluetooth;
  BluetoothDevice? get selectedDevice => _selectedDevice;
  bool get isConnected => _isConnected;

  // Get bonded devices
  Future<List<BluetoothDevice>> getBondedDevices() async {
    try {
      return await _bluetooth.getBondedDevices();
    } catch (e) {
      throw Exception('Error getting devices: $e');
    }
  }

  // Connect to device
  Future<void> connect(BluetoothDevice device) async {
    try {
      await _bluetooth.connect(device);
      _selectedDevice = device;
      _isConnected = true;
    } catch (e) {
      throw Exception('Error connecting: $e');
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
      _selectedDevice = null;
      _isConnected = false;
    } catch (e) {
      throw Exception('Error disconnecting: $e');
    }
  }

  // Write to printer
  Future<void> write(String data) async {
    if (!_isConnected) {
      throw Exception('Printer not connected');
    }
    try {
      await _bluetooth.write(data);
    } catch (e) {
      throw Exception('Error writing to printer: $e');
    }
  }
}
