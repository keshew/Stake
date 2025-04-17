import SwiftUI

class StakePenaltyViewModel: ObservableObject {
    let contact = StakePenaltyModel()

    func createGameScene(gameData: FootballGameData) -> FootballGameSpriteKit {
        let scene = FootballGameSpriteKit()
        scene.game  = gameData
        return scene
    }
}
