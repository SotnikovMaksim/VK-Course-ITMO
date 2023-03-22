import Cocoa

/*:
 
 # IOS @ ITMO 2022
 ## ДЗ №1
 ### Написать калькулятор
 1. Создать два типа IntegralCalculator и RealCalculator
 2. Поддержать для них протокол Calculator с типами Int и Double соответственно

 ### Бонус
 За удвоенные баллы:
 1. Поддержать унарный минус
 2. Поддержать скобки
 
 ### Критерии оценки
 0. Общая рациональность
 1. Корректность
 2. Красота и качество кода
*/

// ========================================================================

// E -> I
// E -> M '*' M
// E -> E '+' E
// M -> I
// M -> M '*' M
// M -> '(' E '+' E ')'

func generate(type: String, _ depth: Int, _ currentDepth: Int) -> String {
    if currentDepth > depth {
        return "\(Int.random(in: 1...127))"
    }

    if type == "E" {
        let p = UInt8.random(in: 1...150)

        switch p {
        case 1...90: return "\(Int.random(in: 1...127))"
        case 91...100: return "\(generate(type: "M", depth, currentDepth + 1)) * \(generate(type: "M", depth, currentDepth + 1))"
        case 101...120: return "\(generate(type: "E", depth, currentDepth + 1)) + \(generate(type: "E", depth, currentDepth + 1))"
        case 121...140: return "\(generate(type: "E", depth, currentDepth + 1)) - \(generate(type: "E", depth, currentDepth + 1))"
        case 141...150: return "\(generate(type: "M", depth, currentDepth + 1)) / \(generate(type: "M", depth, currentDepth + 1))"
        default: return ""
        }
    } else {
        let p = UInt8.random(in: 1...150)

        switch p {
        case 1...90: return "\(Int.random(in: 1...127))"
        case 91...100: return "(\(generate(type: "M", depth, currentDepth + 1)) * \(generate(type: "M", depth, currentDepth + 1)))"
        case 101...125: return "(\(generate(type: "E", depth, currentDepth + 1)) + \(generate(type: "E", depth, currentDepth + 1)))"
        case 126...150: return "(\(generate(type: "E", depth, currentDepth + 1)) - \(generate(type: "E", depth, currentDepth + 1)))"
        default: return ""
        }
    }
}

func test(calculator type: CommonCalculator<Int>.Type) throws {
    let calculator = type.init(operators: [
        "+": Operator(precedence: 10, associativity: .left, function: +),
        "-": Operator(precedence: 10, associativity: .left, function: -),
        "*": Operator(precedence: 20, associativity: .left, function: *),
        "/": Operator(precedence: 20, associativity: .left, function: /),
    ])

    let expression = generate(type: "E", 3, 0)
    print(expression)
    let result1 = try calculator.evaluate(expression)
    let answer = NSExpression(format: expression).expressionValue(with: nil, context: nil) as! Int

    if result1 != answer {
        throw CalculatorError.IntegerWrongAnswer(answer: answer, calculatorAnswer: result1, expression: expression)
    }
}

func test(calculator type: CommonCalculator<Double>.Type) throws {
    let calculator = type.init(operators: [
        "+": Operator(precedence: 10, associativity: .left, function: +),
        "-": Operator(precedence: 10, associativity: .left, function: -),
        "*": Operator(precedence: 20, associativity: .left, function: *),
        "/": Operator(precedence: 20, associativity: .left, function: /),
    ])

    let expression = generate(type: "E", 5, 0)
    print(expression)
    let result1 = try calculator.evaluate(expression)
    let answer = NSExpression(format: expression).expressionValue(with: nil, context: nil) as! Double

    if result1 != answer {
        throw CalculatorError.RealWrongAnswer(answer: answer, calculatorAnswer: result1, expression: expression)
    }
}

let testsCount: Int = 10000
for i in 1...testsCount {
    do {
        try test(calculator: CommonCalculator<Int>.self)
    } catch CalculatorError.InvalidDataCount(let message) {
        print("InvalidDataCount.\nMessage: \(message)")
        break
    } catch CalculatorError.InvalidBracketBalance(let message) {
        print("InvalidBracketBalance.\nMessage: \(message)")
        break
    } catch CalculatorError.UndefinedItem(let message) {
        print("UndefinedItem.\nMessage: \(message)")
        break
    } catch CalculatorError.EmptyInputData(let message) {
        print("EmptyInputData.\nMessage: \(message)")
        break
    } catch CalculatorError.IntegerWrongAnswer(let answer, let calculatorAnswer, let expression) {
        print("Wrong answer!\nExression: \(expression)\nCalculator Answer: \(calculatorAnswer)\nCorrect answer: \(answer)")
        break
    } catch {
        print("Undefined exception")
        break
    }
    if i % 100 == 0 {
        print("\(i) tests passed")
    }
}
