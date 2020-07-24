//
//  GameScene.swift
//  AnimatedBoySwift
//
//  Created by zencher on 2020/7/18.
//  Copyright © 2020 zencher. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    let background = SKSpriteNode(imageNamed: "game background")
    let monster = SKSpriteNode(imageNamed: "monster sprite")
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var monsterMovePointsPerSec: CGFloat = 400.0 // 怪物每秒移動距離
    var velocity = CGPoint.zero
    let playableRect: CGRect
    private var boy = SKSpriteNode()
    private var boyWalkingFrames: [SKTexture] = []
    
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.black
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        background.size.width = self.frame.width
        background.size.height = self.frame.height
       
        addChild(background)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        buildBoy()
        animateBoy()
        buildMonster()
        buildGround()
    //    view.gestureRecognizers = [UISwipeGestureRecognizer(target: self, action: #selector(swipe))]
        let swipeUp = UISwipeGestureRecognizer()
        swipeUp.addTarget(self, action:#selector(GameScene.swipedUp) )
        swipeUp.direction = .up
        self.view!.addGestureRecognizer(swipeUp)
    //    let yConstraint = SKConstraint.positionY(SKRange(constantValue: 80))
    //    boy.constraints = [yConstraint]
        
        
        
    }
     @objc func swipedUp() {
        
            let boySpeed = frame.size.width / 15.0
            
            let a = CGPoint(x:boy.position.x,y:boy.position.y+10)
            let moveDifference = CGPoint(x: 0, y: a.y - boy.position.y)
            let distanceToMove = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y)
            let moveDuration = distanceToMove / boySpeed
    //        boy.run(SKAction.moveBy(x: -size.width - boy.size.width, y: 0.0,duration: TimeInterval(moveDuration)))
    //        boy.run(SKAction.moveBy(x: size.width  + boy.size.width, y: 0.0,duration: TimeInterval(moveDuration)))

            boy.run(SKAction.moveBy(x: 0.0, y: 200,duration: TimeInterval(moveDuration)))
            
            print(boy.position.y)
        
    }
    
    func buildMonster() {
        
        let randomMonster = CGFloat.random(in: 0.0 ... self.frame.width)
        monster.size.width = self.frame.width / 8
        monster.size.height = self.frame.height / 6
        monster.position = CGPoint(x: randomMonster, y: 65.0)
        var monsterXTime: CGFloat = monster.position.x / self.frame.width * 6.0
       
        monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size)

        monster.run(SKAction.sequence([SKAction.moveBy(x: 0.0, y: 0, duration: TimeInterval(monsterXTime))]))
        monster.run(SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: self.frame.minX, y: 0, duration: 6), SKAction.moveBy(x: self.frame.maxX, y: 0, duration: 6)])))
//        monster.run(SKAction.sequence([SKAction.moveBy(x: self.frame.maxX, y: 0, duration: 5)]))
//        monster.run(SKAction.sequence([SKAction.moveBy(x: self.frame.minX, y: 0, duration: 5)]))

//        monster.physicsBody?.isDynamic = true
        addChild(monster)
    }
    
    func buildGround(){
        let ground = SKSpriteNode(color: UIColor.blue, size: CGSize.init(width:self.frame.width, height: 10))
        let leftWall = SKSpriteNode(color: UIColor.red, size: CGSize.init(width: 10, height: self.frame.maxY))
        let rightWall = SKSpriteNode(color: UIColor.red, size: CGSize.init(width: 10, height: self.frame.maxY))
        leftWall.position = CGPoint(x: 0, y: 0)
        rightWall.position = CGPoint(x: self.frame.maxX, y: 0)
        ground.position = CGPoint(x: self.frame.midX, y: 0)
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        leftWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.isDynamic = false
        ground.physicsBody?.isDynamic = false
        addChild(ground)
        addChild(leftWall)
        addChild(rightWall)
    }
    func buildBoy() {
        let boyAnimatedAtlas = SKTextureAtlas(named: "boyImage")
        var walkFrames: [SKTexture] = []
        let numImages = boyAnimatedAtlas.textureNames.count
        for i in 1...numImages {
            let boyTextureName = "boy\(i)"
            walkFrames.append(boyAnimatedAtlas.textureNamed(boyTextureName))
            
        }
        boyWalkingFrames = walkFrames
        let firstFrameTexture = boyWalkingFrames[0]
        boy = SKSpriteNode(texture: firstFrameTexture)
        boy.size.width = self.frame.width * 1 / 6
        boy.size.height = boy.size.width
        boy.position = CGPoint(x: 500, y: 65)
        boy.physicsBody = SKPhysicsBody(rectangleOf:boy.size)
        addChild(boy)
       
    }
    func animateBoy() {
        boy.run(SKAction.repeatForever(
        SKAction.animate(with: boyWalkingFrames,timePerFrame: 0.1,resize: false,restore: true)),
        withKey:"walkingInPlaceBoy")
    }
    func boyMoveEnded() {
        boy.removeAllActions()
    }
    func moveBoy(location: CGPoint) {
        // 1
        var multiplierForDirection: CGFloat
        // 2
        let boySpeed = frame.size.width / 3.0
        // 3
        let moveDifference = CGPoint(x: location.x - boy.position.x, y: location.y - boy.position.y)
        let distanceToMove = sqrt(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y)
        // 4
        let moveDuration = distanceToMove / boySpeed
        // 5
        if moveDifference.x < 0 {
            multiplierForDirection = 1.0
        } else {
            multiplierForDirection = -1.0
        }
        boy.xScale = abs(boy.xScale) * multiplierForDirection
        // 1
        if boy.action(forKey: "walkingInPlaceBoy") == nil {
        // if legs are not moving, start them
            animateBoy()
        }
        //2
        let moveAction = SKAction.move(to: location, duration:(TimeInterval(moveDuration)))
        // 3
        let doneAction = SKAction.run({ [weak self] in self?.boyMoveEnded()})
        // 4
        let moveActionWithDone = SKAction.sequence([moveAction, doneAction])
        boy.run(moveActionWithDone, withKey:"boyMoving")
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        moveBoy(location: CGPoint(x: location.x,y: 70.0))
    }
    
    override func update(_ currentTime: TimeInterval) {
/*        monster.position = CGPoint(x: monster.position.x, y: monster.position.y) */
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        } else {
            dt = 0
        }
        lastUpdateTime = currentTime
//        print("\(dt*1000) milliseconds since last update")
        
//        move(sprite: monster, velocity: CGPoint(x: monsterMovePointsPerSec, y: 0))
        monsterMoveAndBack()
    }
        
/*    func move(sprite: SKSpriteNode, velocity: CGPoint) {
        let amountToMove = velocity * CGFloat(dt)
//        速度 * 時間 = 距離
//        amountToMove = CGPoint(x: velocity.x 從 monsterMovePointsPerSec賦值 * CGFloat(dt), y: velocity.y * CGFloat(dt))
//        print("Amount to move: \(amountToMove)")
        sprite.position += amountToMove
//        sprite.position + amountToMove = 現在的位置 + amountToMove
        }
*/
    
//    func moveMonsterToward(location: CGPoint) {
//        let offset = CGPoint(x: location.x - monster.position.x, y: location.y - monster.position.y)
//    }
        

    func monsterMoveAndBack() {
        if monster.position.x <= self.frame.minX {
            monster.xScale = monster.xScale * -1
           
        }
        if monster.position.x >= self.frame.maxX {
            monster.xScale = monster.xScale * -1
           
            
        }
//        print(monster.position)
    }

    override init(size: CGSize) {
        let maxAspectRatio:CGFloat = 16.0/9.0
        let playableHeight = size.width / maxAspectRatio
        let playableMargin = (size.height - playableHeight) / 2
        playableRect =  CGRect(x: 0, y: playableMargin, width: size.width, height: playableHeight)
        super.init(size:size)
    }
        
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
