import Foundation

/// Общий протокол для операторов
public protocol OperatorType {
    var precedence: Int { get }
    var associativity: Associativity { get }
}

/// Ассоциативность оператора
public enum Associativity {
    case left, right, none
}

/// Оператор
public struct Operator<T: Numeric> {
    public let precedence: Int
    public let associativity: Associativity
    private let function: (T, T) throws -> T
    
    /// Конструктор с параметрами
    /// - Parameters:
    ///   - precedence: приоритет
    ///   - associativity: ассоциативность
    ///   - function: вычислимая бинарная функция
    public init(precedence: Int, associativity: Associativity, function: @escaping (T, T) -> T) {
        self.precedence = precedence
        self.associativity = associativity
        self.function = function
    }
    
    /// Применить оператор
    /// - Parameters:
    ///   - lhs: первый аргумент
    ///   - rhs: второй аргумент
    /// - Returns: результат, либо исключение
    public func apply(_ lhs: T, _ rhs: T) throws -> T {
        try self.function(lhs, rhs)
    }
}

/// Унарный оператор
public struct UnaryOperator<T: Numeric> {
    public let precedence: Int
    private let function: (T) throws -> T
    public let associativity: Associativity = .none
    
    /// Конструктор с параметрами
    /// - Parameters:
    ///   - precedence: приоритет
    ///   - function: вычислимая бинарная функция
    public init(precedence: Int, function: @escaping (T) -> T) {
        self.precedence = precedence
        self.function = function
    }
    
    /// Применить оператор
    /// - Parameters:
    ///   - element: аргумент
    /// - Returns: результат, либо исключение
    public func apply(_ element: T) throws -> T {
        try self.function(element)
    }
}


/// Калькулятор
public protocol Calculator {
    /// Тип чисел, с которыми работает данный калькулятор
    associatedtype Number: Numeric
    
    init(operators: Dictionary<String, Operator<Number>>)
    
    func evaluate(_ input: String) throws -> Number
}

extension Operator: OperatorType where T: Numeric {}

extension UnaryOperator: OperatorType where T: Numeric {}

enum CalculatorError: Error {
    case emptyInputData(message: String)
    case invalidBracketBalance(message: String)
    case undefinedItem(message: String)
    case invalidDataCount(message: String)
    case integerWrongAnswer(answer: Int, calculatorAnswer: Int, expression: String)
    case realWrongAnswer(answer: Double, calculatorAnswer: Double, expression: String)
}

class CommonCalculator<NumberType: Numeric & LosslessStringConvertible>: Calculator {
    private enum TokenType {
        case bianryOperator(_ operation: Operator<Number>)
        case unaryOperator(_ operation: UnaryOperator<Number>)
        case number(Number)
        case leftBracket
        case rightBracket
    }
    
    typealias Number = NumberType
        
    var operators: Dictionary<String, OperatorType>

    required init(operators: Dictionary<String, Operator<Number>>) {
        self.operators = operators

        self.operators["#"] = UnaryOperator<Number>(
                                                     precedence: 30,
                                                     function: { $0 * -1 }
                                                   )
    }

    func evaluate(_ expr: String) throws -> Number {
        var expression = expr
        
        ["+", "-", "*", "/", "(", ")"].forEach { expression = expression.replacingOccurrences(of: $0, with: " \($0) ") }

        let tokens = expression.components(separatedBy: .whitespaces).filter { $0 != "" }
        
        guard tokens.count > 0 else {
            throw CalculatorError.emptyInputData(message: "\(tokens)")
        }

        var commonStack: [TokenType] = []
        var operatorsStack: [String] = []
        var prevTokenIsOpreator: Bool = true

        for token in tokens {
            if let oper = self.operators[token] {
                if prevTokenIsOpreator {
                    operatorsStack.append("#")
                } else {
                    if operatorsStack.count > 0 {
                        while let prevOperString = operatorsStack.last, let prevOper = self.operators[prevOperString],
                                  (oper.precedence < prevOper.precedence)
                                  || (oper.precedence == prevOper.precedence && oper.associativity == .left)
                        {
                            operatorsStack.popLast()
                            
                            if let binaryOperator = prevOper as? Operator<Number> {
                                commonStack.append(.bianryOperator(binaryOperator))
                            } else if let unary = prevOper as? UnaryOperator<Number> {
                                commonStack.append(.unaryOperator(unary))
                            }
                        }
                    }
                    operatorsStack.append(token)
                }
                
                prevTokenIsOpreator = true
            } else if token == "(" {
                operatorsStack.append("(")
                prevTokenIsOpreator = true
            } else if token == ")" {
                while let element = operatorsStack.last, element != "(", let oper = self.operators[element] {
                    operatorsStack.popLast()
                    
                    if let binaryOperator = oper as? Operator<Number> {
                        commonStack.append(.bianryOperator(binaryOperator))
                    } else if let unaryOperator = oper as? UnaryOperator<Number> {
                        commonStack.append(.unaryOperator(unaryOperator))
                    }
                }
                
                if operatorsStack.count == 0 {
                    throw CalculatorError.invalidBracketBalance(message: expr)
                }
                
                operatorsStack.popLast()
                prevTokenIsOpreator = false
            } else {
                guard let number = Number(token) else {
                    throw CalculatorError.undefinedItem(message: token)
                }
                
                commonStack.append(.number(number))
                prevTokenIsOpreator = false
            }
        }
        
        commonStack += try operatorsStack.reversed().compactMap {
            guard let oper = self.operators[$0] else {
                throw CalculatorError.undefinedItem(message: $0)
            }
            return oper
        }.map { (_ oper: OperatorType) throws -> TokenType in
            if let binaryOperator = oper as? Operator<Number> {
                return .bianryOperator(binaryOperator)
            } else if let unaryOperator = oper as? UnaryOperator<Number> {
                return .unaryOperator(unaryOperator)
            }
            
            throw CalculatorError.undefinedItem(message: "failed to convert operator: \(oper)")
        }
        
        var values: [Number] = []
        
        for element in commonStack {
            switch element {
                case .bianryOperator(let binaryOperator):
                    guard let rhs = values.popLast(), let lhs = values.popLast() else {
                        throw CalculatorError.invalidDataCount(message: "failed to evaluate expression. Insufficient number of operands.")
                    }
                
                    values.append(try binaryOperator.apply(lhs, rhs))
                case .unaryOperator(let unaryOperator):
                    guard let value = values.popLast() else {
                        throw CalculatorError.invalidDataCount(message: "failed to evaluate expression. Insufficient number of operands.")
                    }
                    
                    values.append(try unaryOperator.apply(value))
                case .number(let number):
                    values.append(number)
                default:
                    throw CalculatorError.invalidDataCount(message: "failed to evaluate expression. Undefined item.")
            }
        }
        
        if let answer = values.first {
            return answer
        }
        throw CalculatorError.invalidDataCount(message: "tokens: \(tokens)\ncommonStack: \(commonStack)\noperatorsStack: \(operatorsStack)")
    }
}
