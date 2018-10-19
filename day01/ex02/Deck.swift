import Foundation

class Deck: NSObject {
    static let allSpades: [Card] = Value.allValues.map({ Card(withColor: .Spade, withValue: $0) })
    static let allDiamonds: [Card] = Value.allValues.map({ Card(withColor: .Diamond, withValue: $0) })
    static let allHearts: [Card] = Value.allValues.map({ Card(withColor: .Heart, withValue: $0) })
    static let allClubs: [Card] = Value.allValues.map({ Card(withColor: .Club, withValue: $0) })

    static let allCards: [Card] = allSpades + allDiamonds + allHearts + allClubs
}