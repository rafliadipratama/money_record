/// Custom Shunting-Yard Algorithm Expression Evaluator
/// Designed for in-app financial keypads to evaluate real-time arithmetic expressions
/// like "25000 + 15000 * 2" with standard operator precedence and zero-division guards.
class ExpressionEvaluator {
  ExpressionEvaluator._();

  /// Evaluates a math string expression and returns the double result.
  /// Throws [FormatException] if the syntax is malformed.
  static double evaluate(String expression) {
    final sanitized = expression.replaceAll(' ', '').replaceAll(',', '');
    if (sanitized.isEmpty) return 0.0;

    final tokens = _tokenize(sanitized);
    if (tokens.isEmpty) return 0.0;

    final postfix = _toPostfix(tokens);
    return _evaluatePostfix(postfix);
  }

  /// Tokenizes string into numbers, operators, and parentheses.
  static List<String> _tokenize(String input) {
    final List<String> tokens = [];
    final StringBuffer numberBuffer = StringBuffer();

    for (int i = 0; i < input.length; i++) {
      final char = input[i];

      if (_isDigit(char) || char == '.') {
        numberBuffer.write(char);
      } else if (_isOperator(char) || char == '(' || char == ')') {
        if (numberBuffer.isNotEmpty) {
          tokens.add(numberBuffer.toString());
          numberBuffer.clear();
        }

        // Handle unary minus: e.g. at start or after another operator / '('
        if (char == '-' &&
            (tokens.isEmpty ||
                _isOperator(tokens.last) ||
                tokens.last == '(')) {
          numberBuffer.write('-');
        } else {
          tokens.add(char);
        }
      } else {
        throw FormatException('Unexpected character in expression: $char');
      }
    }

    if (numberBuffer.isNotEmpty) {
      tokens.add(numberBuffer.toString());
    }

    return tokens;
  }

  /// Converts infix tokens to postfix (Reverse Polish Notation) using Shunting-Yard.
  static List<String> _toPostfix(List<String> tokens) {
    final List<String> output = [];
    final List<String> operators = [];

    for (final token in tokens) {
      if (_isNumber(token)) {
        output.add(token);
      } else if (_isOperator(token)) {
        while (operators.isNotEmpty &&
            operators.last != '(' &&
            _precedence(operators.last) >= _precedence(token)) {
          output.add(operators.removeLast());
        }
        operators.add(token);
      } else if (token == '(') {
        operators.add(token);
      } else if (token == ')') {
        while (operators.isNotEmpty && operators.last != '(') {
          output.add(operators.removeLast());
        }
        if (operators.isEmpty || operators.last != '(') {
          throw const FormatException('Mismatched parentheses in expression');
        }
        operators.removeLast(); // Pop '('
      }
    }

    while (operators.isNotEmpty) {
      final op = operators.removeLast();
      if (op == '(' || op == ')') {
        throw const FormatException('Mismatched parentheses in expression');
      }
      output.add(op);
    }

    return output;
  }

  /// Evaluates postfix token queue into a scalar double.
  static double _evaluatePostfix(List<String> postfix) {
    final List<double> stack = [];

    for (final token in postfix) {
      if (_isNumber(token)) {
        final val = double.tryParse(token);
        if (val == null) throw FormatException('Invalid number: $token');
        stack.add(val);
      } else if (_isOperator(token)) {
        if (stack.length < 2) {
          throw const FormatException(
            'Malformed expression: insufficient operands',
          );
        }
        final right = stack.removeLast();
        final left = stack.removeLast();

        switch (token) {
          case '+':
            stack.add(left + right);
            break;
          case '-':
            stack.add(left - right);
            break;
          case '*':
          case '×':
            stack.add(left * right);
            break;
          case '/':
          case '÷':
            if (right == 0) {
              throw UnsupportedError('Division by zero is undefined');
            }
            stack.add(left / right);
            break;
          default:
            throw FormatException('Unknown operator: $token');
        }
      }
    }

    if (stack.length != 1) {
      throw const FormatException('Malformed expression');
    }

    return stack.single;
  }

  static bool _isDigit(String s) => RegExp(r'^[0-9]$').hasMatch(s);

  static bool _isOperator(String s) =>
      s == '+' || s == '-' || s == '*' || s == '/' || s == '×' || s == '÷';

  static bool _isNumber(String s) => double.tryParse(s) != null;

  static int _precedence(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/' || op == '×' || op == '÷') return 2;
    return 0;
  }
}
