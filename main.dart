import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false, // Remove the debug banner
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _display = '';
  String _result = '';
  String _operation = '';
  double _firstOperand = 0.0;
  double _secondOperand = 0.0;
  List<String> _history = [];

  @override
  void initState() {
    super.initState();
    _loadDisplayValue();
    _loadHistory();
  }

  void _loadDisplayValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _display = prefs.getString('display') ?? '';
    });
  }

  void _saveDisplayValue(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('display', value);
  }

  void _saveHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('history', _history);
  }

  void _loadHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _history = prefs.getStringList('history') ?? [];
    });
  }

  void _inputDigit(String digit) {
    setState(() {
      _display += digit;
      _saveDisplayValue(_display);
    });
  }

  void _inputOperation(String operation) {
    if (_display.isNotEmpty) {
      _firstOperand = double.parse(_display);
      _display = '';
      _operation = operation;
    }
  }

  void _calculateResult() {
    if (_display.isNotEmpty) {
      _secondOperand = double.parse(_display);
      switch (_operation) {
        case '+':
          _result = (_firstOperand + _secondOperand).toString();
          break;
        case '-':
          _result = (_firstOperand - _secondOperand).toString();
          break;
        case '*':
          _result = (_firstOperand * _secondOperand).toString();
          break;
        case '/':
          if (_secondOperand != 0) {
            _result = (_firstOperand / _secondOperand).toString();
          } else {
            _result = 'ERROR';
          }
          break;
        default:
          _result = 'ERROR';
          break;
      }
      setState(() {
        _display = _result;
        _saveDisplayValue(_display);
        _history.insert(0, '$_firstOperand $_operation $_secondOperand = $_result');
        _saveHistory();
      });
    }
  }

  void _clear() {
    setState(() {
      _display = '';
      _result = '';
      _operation = '';
      _firstOperand = 0.0;
      _secondOperand = 0.0;
      _saveDisplayValue(_display);
    });
  }

  void _clearEntry() {
    setState(() {
      _display = '';
      _saveDisplayValue(_display);
    });
  }

  void _showHistory() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('History'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_history[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            setState(() {
                              _history.removeAt(index);
                              _saveHistory();
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.centerRight,
            child: Text(
              _display,
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButtonRow(['7', '8', '9', '/']),
                _buildButtonRow(['4', '5', '6', '*']),
                _buildButtonRow(['1', '2', '3', '-']),
                _buildButtonRow(['CE', '0', 'C', '+']),
                _buildButtonRow(['=']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String label, {Color? backgroundColor, Color? textColor}) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.white,
          side: BorderSide(color: Colors.grey.shade300),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), // Oval shape
          ),
          padding: EdgeInsets.all(20),
        ),
        onPressed: () {
          if (label == 'C') {
            _clear();
          } else if (label == 'CE') {
            _clearEntry();
          } else if (label == '=') {
            _calculateResult();
          } else if (['+', '-', '*', '/'].contains(label)) {
            _inputOperation(label);
          } else {
            _inputDigit(label);
          }
        },
        child: Text(
          label,
          style: TextStyle(
            fontSize: 24,
            color: textColor ?? Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(List<String> labels) {
    return Row(
      children: labels.map((label) {
        if (label == '=') {
          return _buildButton(label, backgroundColor: Colors.grey, textColor: Colors.white);
        } else if (['+', '-', '*', '/'].contains(label)) {
          return _buildButton(label, backgroundColor: Colors.orange, textColor: Colors.white);
        } else if (label == 'CE') {
          return _buildButton(label, backgroundColor: Colors.grey.shade200);
        } else if (label == 'C') {
          return _buildButton(label, backgroundColor: Colors.orange, textColor: Colors.white);
        } else {
          return _buildButton(label);
        }
      }).toList(),
    );
  }
}
