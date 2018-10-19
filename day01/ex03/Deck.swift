import Foundation

class Deck: NSObject {
    static let allSpades: [Card] = Value.allValues.map({ Card(withColor: .Spade, withValue: $0) })
    static let allDiamonds: [Card] = Value.allValues.map({ Card(withColor: .Diamond, withValue: $0) })
    static let allHearts: [Card] = Value.allValues.map({ Card(withColor: .Heart, withValue: $0) })
    static let allClubs: [Card] = Value.allValues.map({ Card(withColor: .Club, withValue: $0) })

    static let allCards: [Card] = allSpades + allDiamonds + allHearts + allClubs
}

extension Array {
    func shuffle() -> Array {
        guard count > 1 else { return self }
        var shuffled: Array = []
        var save = self
        
        for _ in 0 ..< save.count {
            let rand = Int(arc4random_uniform(UInt32(save.count)))
            shuffled.append(save[rand])
            save.remove(at: rand)
        }
        
        return shuffled
    }
}