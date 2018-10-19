let values: [Value] = Value.allValues
let colors: [Color] = Color.allColors

for value in values {
    print("\(value) => \(value.rawValue)")
}

print("----------------")

for color in colors {
    print("\(color) => \(color.rawValue)")
}