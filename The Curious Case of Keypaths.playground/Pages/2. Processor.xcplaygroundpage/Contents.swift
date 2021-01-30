//: [Previous](@previous)

struct Person {
    var name: String
    var age: Int
}

protocol Processor {
    associatedtype T
    //: Notice we're working on the object, not any underlying value. Remember the function signature (Person) -> Person.
    func process(object: T) -> T
}

extension Processor {
    func erased()-> AnyProcessor<T> {
        AnyProcessor(base: self)
    }
}

//: When erasing an object, you need to save some wort of reference to the inital implementation
struct AnyProcessor<T>: Processor {
    private var _process: (T) -> T
    
    init<Base: Processor>(base: Base) where Base.T == T {
        _process = base.process
    }
    
    func process(object: T) -> T {
        _process(object)
    }
}

//: Erasing can also remove some placeholder types
struct AgeMultiplier<T, K: Numeric>: Processor {
    let multiplier: K
    let keyPath: WritableKeyPath<T, K>
    
    private func f(_ value: K) -> K {
        value * multiplier
    }
    
    func process(object: T) -> T {
        var writable = object
        writable[keyPath: keyPath] = f(object[keyPath: keyPath])
        return writable
    }
}

struct NameUppercaser<T>: Processor {
    let keyPath: WritableKeyPath<T, String>
    
    private func f(_ value: String) -> String {
        value.uppercased()
    }
    
    func process(object: T) -> T {
        var writable = object
        writable[keyPath: keyPath] = f(object[keyPath: keyPath])
        return writable
    }
}

struct ObjectProcessor<T>: Processor {
    //: This is essentially the same as when using function composition. Functions are now methods, but all the objects in the array have the same type
    private var processers = [AnyProcessor<T>]()
    
    mutating func add(processor: AnyProcessor<T>) {
        processers.append(processor)
    }
    
    func process(object: T) -> T {
        var object = object
        
        for processor in processers {
            object = processor.process(object: object)
        }
        
        return object
    }
}

var holyGrail = ObjectProcessor<Person>()
holyGrail.add(processor: NameUppercaser(keyPath: \Person.name).erased())
holyGrail.add(processor: AgeMultiplier(multiplier: 2, keyPath: \Person.age).erased())
holyGrail.add(processor: AgeMultiplier(multiplier: 3, keyPath: \Person.age).erased())

let bradPitt = Person(name: "Brad Pitt", age: 57)
let immortalBradPitt = holyGrail.process(object: bradPitt)

print(immortalBradPitt)
