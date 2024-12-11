//IM_2021_006 - K D N Rasanjana
import 'package:flutter/material.dart'; //Flutter and Math Expressions packages
import 'package:math_expressions/math_expressions.dart';
import 'dart:math'; //for sqrt

class CalculatorScreen extends StatefulWidget {
  // defining the CalculatorScreen widget as a StatefulWidget to manage dynamic state changes
  const CalculatorScreen({Key? key}) : super(key: key);

  // Creating the state for the CalculatorScreen
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  // variables to store operands, user input, and output
  double num1 = 0.0; // 1st operand
  double num2 = 0.0; // 2nd operand
  var input = ''; // current input string
  var output = ''; // calculated output
  var operation = ''; //current operation symbol
  var outputSize = 32.0; //  font size for output text

// function to replace √ followed by a number or an expression with sqrt function
  String replaceSqrt(String input) {
    return input.replaceAllMapped(
      RegExp(r'√(\d+(\.\d+)?|\([^)]*\))'),
      (match) => 'sqrt(${match.group(1)})',
    );
  }

  //  function to check if the input contains division by zero
  bool _containsDivisionByZero(String input) {
    RegExp regExp = RegExp(
        r'\/\s*0(\s*[\+\-\*\/\%]|\s*$)'); //regular expression to detect divisions wheredenominator is zero
    return regExp.hasMatch(input);
  }

  // method to handle button presses and manage calculator logic
  void _buttonPressed(String buttonText) {
    if (buttonText == 'AC') {
      _clear(); // clear all inputs and outputs
    } else if (buttonText == 'C') {
      if (input.isNotEmpty) {
        // deletes the last character in the input string or clears it if empty
        input = input.substring(0, input.length - 1);
      }
    } else if (buttonText == "=") {
      if (input.isNotEmpty) {
        //evaluate the input expression
        try {
          //check if input contains any operators
          if (!RegExp(r'[+\-×÷%√]').hasMatch(input)) {
            // ifno operators in input, do nothing
            output = '';
            setState(() {});
            return;
          }

          String userInput = replaceSqrt(input)
              .replaceAll('×', '*')
              .replaceAll('÷', '/')
              .replaceAll('%', '/100');

          // handle 0/0 as "Undefined"
          if (userInput.contains(RegExp(r'^\s*0\s*/\s*0\s*$'))) {
            output = "Undefined";
            setState(() {});
            return;
          }

          // handle divide by zero
          if (_containsDivisionByZero(userInput)) {
            output = "Can't divide by zero";
            setState(() {});
            return;
          }
          Parser p = Parser();
          Expression expression = p.parse(userInput);
          ContextModel cm = ContextModel();
          var finalValue = expression.evaluate(EvaluationType.REAL, cm);

          // handle other cases and remove unnecessary ".0"
          if (finalValue.isNaN) {
            output = "Undefined";
          } else {
            output = finalValue.toString();
            if (output.endsWith(".0")) {
              output = output.substring(0, output.length - 2);
            }
          }
        } catch (e) {
          output = "Error";
        }
      }
    } else if (buttonText == '√') {
      //if output exists, we use it as input for the next calculation
      if (output.isNotEmpty) {
        try {
          double currentOutput = double.parse(
              output); // Parse the current output to compute the square root
          if (currentOutput < 0) {
            output = "Error"; // Square root of negative numbers is not valid
          } else {
            double sqrtResult = sqrt(currentOutput);
            input = "√" +
                (output.endsWith(".0")
                    ? currentOutput.toInt().toString()
                    : currentOutput.toString());
            output = sqrtResult.toString();
            if (output.endsWith(".0")) {
              output = output.substring(0, output.length - 2);
            }
          }
        } catch (e) {
          output = "Error";
        }
      } else {
        // add √ symbol if the input is valid
        if (input.isEmpty ||
            ['+', '-', '×', '÷', '('].contains(input[input.length - 1])) {
          input += '√';
        }
      }
    } else if (buttonText == '%') {
      // add % as part of the input string
      if (input.isNotEmpty &&
          !['+', '-', '×', '÷', '%', '.'].contains(input[input.length - 1])) {
        input += '%';
      }
    } else {
      // prevent starting input with an operator Ignore if input is empty and button is operator
      if (input.isEmpty && ['+', '×', '÷', '%'].contains(buttonText)) {
        return; //
      }

      // Prevent consecutive operators, ignore if last character is operator and button is also operator
      if (input.isNotEmpty &&
          ['+', '-', '×', '÷'].contains(input[input.length - 1]) &&
          ['+', '-', '×', '÷', '%'].contains(buttonText)) {
        return;
      }

      // prevent multiple decimal points in a single number Ignore if the current number already has a decimal point
      if (buttonText == '.') {
        List<String> parts = input.split(RegExp(r'[+\-×÷%]'));
        String lastPart = parts.isNotEmpty ? parts.last : '';
        if (lastPart.contains('.')) {
          return;
        }
      }

// Check for invalid input such as numbers directly after the '%' sign
      if (input.isNotEmpty &&
          input[input.length - 1] == '%' &&
          RegExp(r'\d').hasMatch(buttonText)) {
        input = buttonText;
        output = '';
        setState(() {});
        return;
      }

      //prevent operators after decimal point
      if (buttonText == '=' && input.endsWith('.')) {
        return;
      }

      // Prevent operators after the decimal point
      if (['+', '-', '×', '÷', '%'].contains(buttonText)) {
        if (input.endsWith('.')) {
          return;
        }
      }

//make sure output is a valid numeric value
      if (output.isNotEmpty && ['+', '-', '×', '÷', '%'].contains(buttonText)) {
        if (double.tryParse(output) != null) {
          input = output;
          output = '';
        } else {
          return;
        }
      }

      // if output exists and a number button is pressed, reset input to the pressed number
      if (output.isNotEmpty && RegExp(r'\d').hasMatch(buttonText)) {
        input = buttonText;
        output = '';
        setState(() {});
        return;
      }

      //remove leading '0' if a number is pressed after 0 rreplace 0 with the pressed number
      if (input == '0' && RegExp(r'\d').hasMatch(buttonText)) {
        input = buttonText;
        setState(() {});
        return;
      }

      // Append the pressed button text to the input string
      input += buttonText;
    }

    // update the state to reflect changes in  ui
    setState(() {});
  }

  // all clear button
  void _clear() {
    input = '';
    output = '';
  }

  //function for changing input font size when overflow
  double _getDynamicFontSize(int length, BuildContext context) {
    double baseFontSize = 48.0; // default font size
    double screenWidth = MediaQuery.of(context).size.width;

    if (length > 70) {
      return (screenWidth / length).clamp(18.0, baseFontSize);
    } else if (length > 50) {
      return (screenWidth / length).clamp(28.0, baseFontSize);
    } else if (length > 30) {
      return (screenWidth / length).clamp(38.0, baseFontSize);
    } else {
      return baseFontSize; // default font size for shorter text
    }
  }

  // m,ain UI of the calculator
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        //  main column containing all components of the calculator
        children: [
          // expanded widget for the input and output display area
          Expanded(
            child: Container(
              height: 200, // height of the display area
              width: double.infinity, // full width of the screenr
              padding: EdgeInsets.only(right: 14.0), // add padding on the right

              decoration: BoxDecoration(
                color: Color.fromARGB(139, 229, 229, 229),
                borderRadius: BorderRadius.vertical(
                    bottom:
                        Radius.circular(24)), // rounded corners at the bottom
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end, // aligns text to the right
                mainAxisAlignment:
                    MainAxisAlignment.end, // aligns text to the bottom
                children: [
                  Text(
                    // display the input string
                    input,
                    style: TextStyle(
                        fontSize: _getDynamicFontSize(input.length, context),
                        color: const Color.fromARGB(209, 0, 0, 0)),
                  ),
                  SizedBox(height: 10), // adds spacing between input and output

                  Text(
                    // display the output
                    output,
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.black.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 10), // adds spacing below the output
                ],
              ),
            ),
          ),

          // divider to separate input/output area from buttons
          Divider(
            color: const Color.fromARGB(0, 0, 0, 0), // divider color
          ),

          // Rows of calculator buttons
          // each Row widget groups four buttons together
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Each button is implemented as an ElevatedButton
              ElevatedButton(
                // 'AC' button to clear all inputs and outputs
                onPressed: () => _buttonPressed(
                    'AC'), // Calls the function to reset the calculator
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(209, 237, 240, 1)),
                child: Text(
                  'AC',
                  style: TextStyle(
                      color: const Color.fromARGB(
                          185, 244, 67, 54)), // red text for AC button
                ),
              ),
              ElevatedButton(
                // 'C' button to delete the last entered character
                onPressed: () => _buttonPressed('C'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(209, 237, 240, 1)),
                child: Text(
                  'C',
                  style:
                      TextStyle(color: const Color.fromARGB(185, 244, 67, 54)),
                ),
              ),
              ElevatedButton(
                // '%' button for percentage calculations
                onPressed: () => _buttonPressed('%'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(209, 237, 240, 1)),
                child: Text('%'),
              ),
              ElevatedButton(
                // '÷' button for division
                onPressed: () => _buttonPressed('÷'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(209, 237, 240, 1)),
                child: Text('÷'),
              ),
            ],
          ),

          SizedBox(height: 10), //adding spacing between rows
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _buttonPressed('7'), // Button for number 7
                child: Text('7'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('8'), // Button for number 8
                child: Text('8'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('9'), // Button for number 9
                child: Text('9'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('×'), // Multiplication operator
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(209, 237, 240, 1)),
                child: Text('×'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _buttonPressed('4'), // Button for number 4
                child: Text('4'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('5'), // Button for number 5
                child: Text('5'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('6'), // Button for number 6
                child: Text('6'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('-'), //button -
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(209, 237, 240, 1)),
                child: Text('-'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _buttonPressed('1'), //Button for number 1
                child: Text('1'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('2'), // Button for number 2
                child: Text('2'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('3'), // button for number 3
                child: Text('3'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('+'), // button for +_
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(209, 237, 240, 1)),
                child: Text('+'),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _buttonPressed('√'), //button for √
                child: Text('√'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('0'), // button for 0
                child: Text('0'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('.'), // butto for .
                child: Text('.'),
              ),
              ElevatedButton(
                onPressed: () => _buttonPressed('='),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromRGBO(126, 179, 182, 1)),
                child: Text('='),
              ),
            ],
          ),
          SizedBox(height: 10), //adds final spacing below the last row
        ],
      ),
    );
  }
}
