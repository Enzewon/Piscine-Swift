var theDeck = Deck(isShuffled: true)
var theCards: [Card] = []
let theDrawedCard = theDeck.draw()
let theDifferentDrawCard = Card(withColor: .Heart, withValue: .Ace)
print("<=== DRAWING ONE CARD AND DISCARDING DIFFERENT ===>")
print("\(theDeck.outs) -> outs")
print("\(theDeck.discards) -> discards")
print("Trying to discard different card that drawed")
theDeck.fold(c: theDifferentDrawCard)
print("\(theDeck.outs) -> outs")
print("\(theDeck.discards) -> discards")
print("Trying to discard same card that drawed")
theDeck.fold(c: theDrawedCard!)
print("\(theDeck.outs) -> outs")
print("\(theDeck.discards) -> discards")
print("<=== DRAWING A LOT ===>")
for _ in 0..<69 {
    if let theCard = theDeck.draw() {
        theCards.append(theCard)
    }
}
print(theDeck)
print(theCards)
print("<=== FOLDING A LOT ===>")
for _ in 0..<69 {
    if theCards.count > 0 {
        let theCard = theCards.removeFirst()
        theDeck.fold(c: theCard)
    }
}
print(theDeck)
print(theCards)