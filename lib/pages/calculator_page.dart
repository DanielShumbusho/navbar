import 'package:flutter/material.dart';

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _output = "0";
  String _currentInput = "";
  double _num1 = 0;
  double _num2 = 0;
  String _operator = "";

  void _buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _output = "0";
      _currentInput = "";
      _num1 = 0;
      _num2 = 0;
      _operator = "";
    } else if (buttonText == "+/-") {
      if (_currentInput.isNotEmpty) {
        _currentInput = (-double.parse(_currentInput)).toString();
        _output = _currentInput;
      }
    } else if (buttonText == "%") {
      if (_currentInput.isNotEmpty) {
        _currentInput = (double.parse(_currentInput) / 100).toString();
        _output = _currentInput;
      }
    } else if (buttonText == "+" || buttonText == "-" || buttonText == "X" || buttonText == "/") {
      _num1 = double.parse(_currentInput);
      _operator = buttonText;
      _currentInput = "";
    } else if (buttonText == "=") {
      _num2 = double.parse(_currentInput);
      switch (_operator) {
        case "+":
          _output = (_num1 + _num2).toString();
          break;
        case "-":
          _output = (_num1 - _num2).toString();
          break;
        case "X":
          _output = (_num1 * _num2).toString();
          break;
        case "/":
          _output = (_num1 / _num2).toString();
          break;
      }
      _currentInput = _output;
      _num1 = 0;
      _num2 = 0;
      _operator = "";
    } else {
      _currentInput += buttonText;
      _output = _currentInput;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              alignment: Alignment.bottomRight,
              child: Text(
                _output,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 60,
                ),
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 4,
            children: [
              _buildButton("C", Colors.grey),
              _buildButton("%", Colors.grey),
              _buildButton("+/-", Colors.grey),
              _buildButton("/", Colors.orange),
              _buildButton("7", Colors.grey[850]!),
              _buildButton("8", Colors.grey[850]!),
              _buildButton("9", Colors.grey[850]!),
              _buildButton("X", Colors.orange),
              _buildButton("4", Colors.grey[850]!),
              _buildButton("5", Colors.grey[850]!),
              _buildButton("6", Colors.grey[850]!),
              _buildButton("-", Colors.orange),
              _buildButton("1", Colors.grey[850]!),
              _buildButton("2", Colors.grey[850]!),
              _buildButton("3", Colors.grey[850]!),
              _buildButton("+", Colors.orange),
              _buildButton("0", Colors.grey[850]!, isZero: true),
              _buildButton(".", Colors.grey[850]!),
              _buildButton("=", Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String buttonText, Color color, {bool isZero = false}) {
    return Container(
      margin: EdgeInsets.all(8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: isZero
              ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          )
              : CircleBorder(),
          padding: isZero ? EdgeInsets.symmetric(horizontal: 40) : EdgeInsets.all(20),
        ),
        onPressed: () => _buttonPressed(buttonText),
        child: Text(
          buttonText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
          ),
        ),
      ),
    );
  }
}