import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Para formatear la hora
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const EVChargeCalculatorApp());
}

class EVChargeCalculatorApp extends StatelessWidget {
  const EVChargeCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculadora Carga EV',
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 183, 58, 75),
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const ChargeCalculatorScreen(),
    );
  }
}

class ChargeCalculatorScreen extends StatefulWidget {
  const ChargeCalculatorScreen({super.key});

  @override
  State<ChargeCalculatorScreen> createState() => _ChargeCalculatorScreenState();
}

class _ChargeCalculatorScreenState extends State<ChargeCalculatorScreen> {
  double batteryCapacity = 0;
  double currentPercentage = 20;
  double targetPercentage = 80;
  bool isAC = true;
  double amperage = 16;

  late TextEditingController _batteryController;

  @override
  void initState() {
    super.initState();
    _batteryController = TextEditingController();
    _loadSavedPreferences();
  }

  @override
  void dispose() {
    _batteryController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      batteryCapacity = prefs.getDouble('batteryCapacity') ?? 0;
      currentPercentage = prefs.getDouble('currentPercentage') ?? 20;
      targetPercentage = prefs.getDouble('targetPercentage') ?? 80;
      isAC = prefs.getBool('isAC') ?? true;
      amperage = prefs.getDouble('amperage') ?? 16;

      // Actualiza el controlador al cargar la preferencia
      _batteryController.text =
          batteryCapacity > 0
              ? (batteryCapacity.truncateToDouble() == batteryCapacity
                  ? batteryCapacity.toInt().toString()
                  : batteryCapacity.toString())
              : '';
    });
  }

  Future<void> _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('batteryCapacity', batteryCapacity);
    await prefs.setDouble('currentPercentage', currentPercentage);
    await prefs.setDouble('targetPercentage', targetPercentage);
    await prefs.setBool('isAC', isAC);
    await prefs.setDouble('amperage', amperage);
  }

  double _calculateChargingTime() {
    if (batteryCapacity <= 0 || targetPercentage <= currentPercentage) return 0;

    double kWhToCharge =
        batteryCapacity * (targetPercentage - currentPercentage) / 100;
    double voltage = isAC ? 230 : 400;
    double power = voltage * amperage / 1000; // en kW
    return kWhToCharge / power; // tiempo en horas
  }

  @override
  Widget build(BuildContext context) {
    double timeInHours = _calculateChargingTime();
    Duration duration = Duration(minutes: (timeInHours * 60).round());
    DateTime finishTime = DateTime.now().add(duration);
    String formattedTime = DateFormat('HH:mm').format(finishTime);

    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora Carga EV')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(255, 58, 68, 0.71),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(255, 58, 68, 0.71),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(255, 58, 68, 0.71),
                    width: 2.0,
                  ),
                ),
                labelText: 'Capacidad de batería (kWh)',
                labelStyle: TextStyle(
                  color: Color.fromRGBO(223, 82, 89, 0.71),
                  fontWeight: FontWeight.bold,
                ),
              ),
              controller: _batteryController,
              onChanged: (value) {
                setState(() {
                  batteryCapacity = double.tryParse(value) ?? 0;
                });
                _savePreferences();
              },
            ),
            const SizedBox(height: 24),
            Text('Porcentaje actual: ${currentPercentage.toInt()}%'),
            Slider(
              value: currentPercentage,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: Colors.red,
              label: '${currentPercentage.toInt()}%',
              onChanged: (value) {
                setState(() {
                  currentPercentage = value;
                });
                _savePreferences();
              },
            ),
            Text('Porcentaje objetivo: ${targetPercentage.toInt()}%'),
            Slider(
              value: targetPercentage,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: Colors.green,
              label: '${targetPercentage.toInt()}%',
              onChanged: (value) {
                setState(() {
                  targetPercentage = value;
                });
                _savePreferences();
              },
            ),
            const SizedBox(height: 12),
            const Text('Tipo de corriente'),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('AC'),
                  selected: isAC,
                  onSelected: (selected) {
                    setState(() {
                      isAC = true;
                    });
                    _savePreferences();
                  },
                  selectedColor: Colors.blue,
                ),
                const SizedBox(width: 10),
                ChoiceChip(
                  label: const Text('DC'),
                  selected: !isAC,
                  onSelected: (selected) {
                    setState(() {
                      isAC = false;
                    });
                    _savePreferences();
                  },
                  selectedColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('Amperaje de carga: ${amperage.toInt()}A'),
            Slider(
              value: amperage,
              min: 6,
              max: 32,
              divisions: 26,
              activeColor: Colors.yellow,
              label: '${amperage.toInt()}A',
              onChanged: (value) {
                setState(() {
                  amperage = value;
                });
                _savePreferences();
              },
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Text(
                    timeInHours > 0
                        ? 'Tiempo estimado: ${duration.inHours}h ${duration.inMinutes % 60}min'
                        : 'Introduce los datos para calcular el tiempo',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (timeInHours > 0)
                    Text(
                      'Hora estimada de finalización: $formattedTime',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
