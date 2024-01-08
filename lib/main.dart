import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalkulator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Montserrat',
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),
          labelLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  CalculatorPageState createState() => CalculatorPageState();
}

class CalculatorPageState extends State<CalculatorPage> {
  String currentInput = '';
  String expression = '';
  double? result;
  bool allowInput = true;
  bool hasError = false;




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(
              expression,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              currentInput.isEmpty ? '0' : currentInput,
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            buildButtonRow(['7', '8', '9', '/']),
            const SizedBox(height: 20),
            buildButtonRow(['4', '5', '6', '*']),
            const SizedBox(height: 20),
            buildButtonRow(['1', '2', '3', '-']),
            const SizedBox(height: 20),
            buildButtonRow(['C', '0', '=', '+']),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }




  bool isOperator(String text) {
    return text == '+' || text == '-' || text == '*' || text == '/';
  }

  List<String> tokenizeExpression() {
    List<String> chars = [];
    String currentChar = '';

    for (int i = 0; i < currentInput.length; i++) {
      String char = currentInput[i];

      if (isOperator(char)) {
        if (currentChar.isNotEmpty) {
          chars.add(currentChar);
        }
        chars.add(char);
        currentChar = '';
      } else {
        currentChar += char;
      }
    }

    if (currentChar.isNotEmpty) {
      chars.add(currentChar);
    }

    return chars;
  }



  void calculateResult() {
    if (!allowInput || hasError) {
      return;
    }
    try {
      result = evaluateExpression();

      if (result == double.infinity || result == double.negativeInfinity) {
        hasError = true;
        showError('Nie można dzielić przez zero');
      } else {
        expression += ' =';

        String resultText = result?.toString() ?? '0';

        if (resultText.endsWith('.0')) {
          resultText = resultText.substring(0, resultText.length - 2);
        }

        currentInput = resultText;
      }
    } catch (e) {
      hasError = true;
      showError('Nieprawidłowe wyrażenie');
    }
  }

  void showError(String errorMessage) {
    currentInput = 'Błąd';
    expression = errorMessage;
    allowInput = false;
    setState(() {});
  }

  void handleButtonClick(String buttonText) {
    setState(() {
      if (hasError && buttonText != 'C') {
        return;
      }

      if (isOperator(buttonText)) {
        if (expression.isNotEmpty && isOperator(expression[expression.length - 1])) {
          return;
        }
      }

      if (buttonText == '=') {
        calculateResult();
      } else if (buttonText == 'C') {
        clearInput();
      } else {
        currentInput += buttonText;
        expression += buttonText;
      }
    });
  }

  void clearInput() {
    currentInput = '';
    expression = '';
    result = null;
    hasError = false;
    allowInput = true;
  }

  double evaluateExpression() {
    List<String> tokens = tokenizeExpression();
    List<String> postfix = convertToPostfix(tokens);
    return evaluatePostfix(postfix);
  }

  List<String> convertToPostfix(List<String> infixTokens) {
    List<String> postfix = [];
    List<String> operators = [];
    Map<String, int> priority = {'+': 1, '-': 1, '*': 2, '/': 2};
    //coconut code
    for (String token in infixTokens) {
      if (double.tryParse(token) != null) {
        postfix.add(token);
      } else if (token == '(') {
        operators.add(token);
      } else if (token == ')') {
        while (operators.isNotEmpty && operators.last != '(') {
          postfix.add(operators.removeLast());
        }
        operators.removeLast();
      } else {
        while (operators.isNotEmpty && priority[operators.last]! >= priority[token]!) {
          postfix.add(operators.removeLast());
        }
        operators.add(token);
      }
    }

    postfix.addAll(operators.reversed);

    return postfix;
  }

  double evaluatePostfix(List<String> postfixTokens) {
    List<double> stack = [];

    for (String token in postfixTokens) {
      if (double.tryParse(token) != null) {
        stack.add(double.parse(token));
      } else {
        double operand2 = stack.removeLast();
        double operand1 = stack.removeLast();
        switch (token) {
          case '+':
            stack.add(operand1 + operand2);
            break;
          case '-':
            stack.add(operand1 - operand2);
            break;
          case '*':
            stack.add(operand1 * operand2);
            break;
          case '/':
            stack.add(operand1 / operand2);
            break;
        }
      }
    }

    return stack.first;
  }

  Widget buildButtonRow(List<String> buttons) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: buttons.map((button) => buildButton(button)).toList(),
    );
  }

  Widget buildButton(String buttonText) {
    return ElevatedButton(
      onPressed: () => handleButtonClick(buttonText),
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonText == '=' ? Colors.deepPurple : Colors.deepPurpleAccent,
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: Text(
        buttonText,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}