//
//  UserDefault.swift
//  Cobrowse
//

import Foundation

@propertyWrapper
class UserDefault<Value> where Value: Equatable {
    let key: String
    let defaultValue: Value
    private var container: UserDefaults

    @Published var value: Value

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            container.set(newValue, forKey: key)
        }
    }

    var projectedValue: Published<Value>.Publisher {
        $value
    }

    init(key: String, defaultValue: Value, container: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.container = container
        self.value = container.object(forKey: key) as? Value ?? defaultValue
    }
}
