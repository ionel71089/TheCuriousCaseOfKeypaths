precedencegroup CompositionPrecedence {
    associativity: left
}

infix operator >>>: CompositionPrecedence

func >>> <T, U, V>(lhs: @escaping (T) -> U, rhs: @escaping (U) -> V) -> (T) -> V {
    return { rhs(lhs($0)) }
}

func getProperty<O,K>(keyPath: KeyPath<O, K>) -> (O) -> K {
    return { object in
        object[keyPath: keyPath]
    }
}

struct Person {
    var name: String
    var age: Int
}

func reverse(string: String) -> String {
    String(string.reversed())
}

func half(number: Int) -> Int {
    number / 2
}

let getName = getProperty(keyPath: \Person.name)
let getAge = getProperty(keyPath: \Person.age)
/*: Notice the signature need to align for function composition to work.
 
(Person) -> (String) -> (String) */
let getReversedName = getName >>> reverse
let getHalfAge = getAge >>> half

let bradPitt = Person(name: "Brad Pitt", age: 57)

getName(bradPitt)
getReversedName(bradPitt)
getHalfAge(bradPitt)

func process<O, K>(keyPath: WritableKeyPath<O, K>, _ f: @escaping (K) -> K) -> (O) -> O {
    return { object in
        var writable = object
        writable[keyPath: keyPath] = f(object[keyPath: keyPath])
        return writable
    }
}

let reverseName = process(keyPath: \Person.name, reverse)
let halfAge = process(keyPath: \Person.age, half)
/*: The final function signature is (Person) -> Person
  
 You can compose as many functions as you need
 */
let benjaminButton = reverseName >>> halfAge

let youngBradPitt = benjaminButton(bradPitt)

print(youngBradPitt)

//: [Next](@next)
