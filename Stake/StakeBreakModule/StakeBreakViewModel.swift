import SwiftUI

class StakeBreakViewModel: ObservableObject {
    let contact = StakeBreakModel()
    
    func createGameScene(gameData: GameData) -> GameSpriteKit {
        let scene = GameSpriteKit()
        scene.game  = gameData
        return scene
    }
}
