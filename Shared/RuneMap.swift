import Foundation

/// Tabella lettera -> rune. Le rune sono SOLO grafiche: il testo inserito resta latino.
enum RuneMap {
    static let table: [(letter: String, rune: String)] = [
        ("A","ᚨ"),("B","ᛒ"),("C","ᚲ"),("D","ᛞ"),("E","ᛖ"),("F","ᚠ"),("G","ᚷ"),
        ("H","ᚻ"),("I","ᛁ"),("J","ᛁ"),("K","ᚲ"),("L","ᛚ"),("M","ᛗ"),("N","ᚾ"),
        ("O","ᛟ"),("P","ᛈ"),("Q","ᚲᚢ"),("R","ᚱ"),("S","ᛋ"),("T","ᛏ"),("U","ᚢ"),
        ("V","ᚢ"),("W","ᚹ"),("X","X"),("Y","ᛦ"),("Z","ᛉ")
    ]
    private static let dict: [String: String] = Dictionary(uniqueKeysWithValues: table.map { ($0.letter, $0.rune) })

    static func rune(for letter: String) -> String { dict[letter.uppercased()] ?? letter }
}
