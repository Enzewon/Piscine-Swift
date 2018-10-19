import Foundation

class Deck: NSObject {
    
    var cards: [Card]
    var discards: [Card]
    var outs: [Card]
    
    override var description: String {
        return "\(self.cards)"
    }
    
    static let allSpades: [Card] = Value.allValues.map({Card(withColor: .Spade, withValue: $0)})
    static let allHearts: [Card] = Value.allValues.map({Card(withColor: .Heart, withValue: $0)})
    static let allDiamonds: [Card] = Value.allValues.map({Card(withColor: .Diamond, withValue: $0)})
    static let allClubs: [Card] = Value.allValues.map({Card(withColor: .Club, withValue: $0)})
    
    static let allCards: [Card] = allSpades + allHearts + allDiamonds + allClubs
    
    init(isShuffled shuffled: Bool) {
        self.cards = shuffled == true ? Deck.allCards.shuffle() : Deck.allCards
        self.discards = []
        self.outs = []
        super.init()
    }
    
    func draw() -> Card? {
        guard self.cards.count > 0 else { return nil }
        let theCard = self.cards.removeFirst()
        self.outs.append(theCard)
        return theCard
    }
    
    func fold(c: Card) {
        guard let theFoundCardIndex = self.outs.index(where: { $0.color == c.color && $0.value == c.value }) else { return }
        self.discards.append(self.outs[theFoundCardIndex])
        self.outs.remove(at: theFoundCardIndex)
    }
    
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