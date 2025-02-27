import Foundation

struct GameState {
    var currentSet: Int = 1
    var player1Sets: Int = 0
    var player2Sets: Int = 0
    var currentLeg: Int = 1
    var player1Legs: Int = 0
    var player2Legs: Int = 0
    var isPlayer1Starting: Bool = true
    
    var winner: String? {
        if player1Sets > player2Sets {
            return player1Name
        } else if player2Sets > player1Sets {
            return player2Name
        }
        return nil
    }
    
    var player1Name: String
    var player2Name: String
    
    init(player1Name: String, player2Name: String) {
        self.player1Name = player1Name
        self.player2Name = player2Name
        // Bei einem neuen Spiel beginnt Spieler 1 (Heimspieler) das erste Leg
        self.isPlayer1Starting = true
    }
    
    
    mutating func handleLegWin(wonByPlayer1: Bool) {
        if wonByPlayer1 {
            player1Legs += 1
        } else {
            player2Legs += 1
        }
        
        if player1Legs == 3 || player2Legs == 3 {
            // Set ist zu Ende
            if player1Legs > player2Legs {
                player1Sets += 1
            } else {
                player2Sets += 1
            }
            player1Legs = 0
            player2Legs = 0
            currentSet += 1
            currentLeg = 1
            
            // Starter für den neuen Set (ungerade Sets -> Spieler 1, gerade Sets -> Spieler 2)
            isPlayer1Starting = currentSet % 2 == 1
        } else {
            // Nächstes Leg innerhalb des Sets
            currentLeg += 1
            // Wechsel des Starters für das nächste Leg
            isPlayer1Starting = !isPlayer1Starting
        }
    }
}
