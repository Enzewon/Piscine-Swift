let theFirstSameCard = Card(withColor: .Club, withValue: .Ace)
let theSecondSameCard = Card(withColor: .Club, withValue: .Ace)
let theDifferentCard = Card(withColor: .Heart, withValue: .Eight)

print(theFirstSameCard)
print(theSecondSameCard)
print(theDifferentCard)

print(theFirstSameCard == theSecondSameCard)
print(theDifferentCard == theSecondSameCard)
print(theFirstSameCard == theDifferentCard)