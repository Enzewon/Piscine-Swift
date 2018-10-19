import Foundation

class Card: NSObject {
    let color: Color
    let value: Value
    override var description: String {
        return "(\(self.value.rawValue), \(self.color.rawValue))"
    }
    
    init(withColor aColor: Color, withValue aValue: Value) {
        self.color = aColor
        self.value = aValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let card = object as? Card else { return false }
        return card.color == self.color && card.value == self.value
    }
    
    static func ==(left: Card, right: Card) -> Bool {
        return left.isEqual(right)
    }
}
