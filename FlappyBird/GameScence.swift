//
//  GameScence.swift
//  FlappyBird
//
//  Created by 田村尚利 on 2018/11/27.
//  Copyright © 2018 masatoshi.tamura. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScence: SKScene,SKPhysicsContactDelegate{
    
    var scrollNode: SKNode!
    var wallNode: SKNode!
    var itemNode :SKNode!
    var bird:SKSpriteNode!
    
    
    
    //衝突判定カテゴリー
    let birdCategory:UInt32 = 1 << 0
    let groundCategory:UInt32 = 1 << 1
    let wallCategory:UInt32 = 1 << 2
    let scoreCategory:UInt32 = 1 << 3
    let itemCategory:UInt32 = 1 << 4
    
    //スコア
    var score = 0
    var itemscore = 0
    var scoreLabelNode:SKLabelNode!
    var bestScoreLabelNode:SKLabelNode!
    var itemscoreLabelNode:SKLabelNode!
    
    let userDefaults:UserDefaults = UserDefaults.standard
    
    //skview上にシーンが表示された時に呼ばれるメソッド
    override func didMove(to view: SKView) {
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx:0.0,dy:-4.0)
        physicsWorld.contactDelegate = self
        
        
        //背景色を設定
        backgroundColor = UIColor(red: 0.15,green: 0.75,blue: 0.90,alpha:1)
        
        //スクロールするスプライトの親ノード
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        itemNode = SKNode()
        scrollNode.addChild(itemNode)
        
        
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem()
        setupScoreLabel()
        setupItemScoreLabel()
    }
    
    func setupScoreLabel(){
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x:10,y:self.frame.size.height - 60)
        scoreLabelNode.zPosition = 100//いちばん手前に入力
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x:10,y:self.frame.size.height - 90)
        bestScoreLabelNode.zPosition = 100
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey:"BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
    }
    
    func setupItemScoreLabel(){
        
        itemscore = 0
        itemscoreLabelNode = SKLabelNode()
        itemscoreLabelNode.fontColor = UIColor.black
        itemscoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        itemscoreLabelNode.zPosition = 100
        itemscoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemscoreLabelNode.text = "ItemScore:\(itemscore)"
        self.addChild(itemscoreLabelNode)
        
        
    }
    
    func setupGround(){
        //地面の画像を読み込む
        let  groundTexture = SKTexture(imageNamed: "ground")
        groundTexture.filteringMode = .nearest
        
        // 必要な枚数を計算
        let needNumber = Int(self.frame.size.width / groundTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左に方向に画像一枚分スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width, y:0, duration:5.0)
        
        
        //元の位置に戻すアクション
        let restGround = SKAction.moveBy(x: groundTexture.size().width, y:0, duration:0.0)
        
        //左にスクロールー＞元の位置ー＞左にスクロールと無数に繰り替えるアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround,restGround]))
        
        
        // groundのスプライトを配置する
        for i in 0..<needNumber{
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(
                x: groundTexture.size().width * (CGFloat(i) + 0.5),
                y: groundTexture.size().height * 0.5
            )
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリー設定
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないように設定する
            sprite.physicsBody?.isDynamic = false
            
            //シーンにスプライトを追加する
            scrollNode.addChild(sprite)
        }
    }
    
    
    func setupCloud() {
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed: "cloud")
        cloudTexture.filteringMode = .nearest
        
        //必要な枚数を計算
        let needCloudNumber = Int(self.frame.size.width / cloudTexture.size().width) + 2
        
        //スクロールするアクションを作成
        //左方向に画面一枚分スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width, y: 0, duration: 20.0)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y: 0, duration: 0.0)
        
        //左にスクロールー＞元の位置ー＞左にスクロールと無限に繰り替えるアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud,resetCloud]))
        
        //スプライトを配置する
        for i in 0..<needCloudNumber{
            let sprite = SKSpriteNode(texture: cloudTexture)
            sprite.zPosition = -100//一番後ろになるようにする
            
            //スプライトの表示する位置を指定する
            sprite.position = CGPoint(x: cloudTexture.size().width * (CGFloat(i) + 0.5), y: self.size.height - cloudTexture.size().height * 0.5)
            
            //スプライトにアニメーションを設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する
            scrollNode.addChild(sprite)
            
            
        }
        
    }
    
    func setupWall(){
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = .linear
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを作成
        let moveWall = SKAction.moveBy(x: -movingDistance,  y: 0, duration: 4.0)
        
        //自信を取り除くアクションを作成
        let removeWall = SKAction.removeFromParent()
        
        //二つのアニメーションを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall,removeWall])
        
        //壁を生成するアクションを作成
        let  createWallAmimation = SKAction.run({
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x:self.frame.size.width + wallTexture.size().width/2, y:0.0)
            wall.zPosition = -50.0 //雲より手前、地面より奥
            
            
            //画面のy軸の中央値
            let center_y = self.frame.size.height/2
            //壁のY座標を上下ランダムにさせるときの最大値
            let random_y_range = self.frame.size.height/4
            //下の壁のY軸の下限
            let under_wall_lowest_y = UInt32(center_y - wallTexture.size().height/2 - random_y_range/2)
            //１〜ranndom_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform(UInt32(random_y_range))
            //Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            
            //キャラクターが通り抜ける隙間の長さ
            let slit_length = self.frame.size.height/6
            
            //下限の壁を作成
            let under = SKSpriteNode(texture: wallTexture)
            under.position = CGPoint(x:0.0,y:under_wall_y)
            
            //スプライトに物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            wall.addChild(under)
            
            //上の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x:0.0,y:under_wall_y + wallTexture.size().height + slit_length)
            
            //スプライトに物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突の時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            wall.addChild(upper)
            
            //スコアアップ用のノード
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x:upper.size.width + self.bird.size.width/2,y:self.frame.height/2.0)
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
            
        })
        
        //次の壁作成までの待ち時間のアクションを作成
        let waitAnimation = SKAction.wait(forDuration:2)
        
        //壁を作成ー＞待ち時間ー＞壁を作成を無限に繰り替えるアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAmimation,waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    }
    
    func setupBird(){
        //鳥の画像を２種類読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = .linear
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = .linear
        
        //2種類のテクスチャを交互に変更するアニメーションを作成
        let texuresAnimation = SKAction.animate(with:[birdTextureA,birdTextureB], timePerFrame: 0.2)
        let flap = SKAction.repeatForever(texuresAnimation)
        
        
        //スプライトを作成
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x:self.frame.size.width*0.2,y:self.frame.size.height*0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height/2.0)
        
        //衝突時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突のカテゴリー設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory | itemCategory
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加
        addChild(bird)
        
    }
    
    //画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if scrollNode.speed > 0{
            //鳥の速度をゼロにする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx:0,dy:15))
        }else if bird.speed == 0{
            restart()
            
        }
      }
    
    //SKPhysicsContactDelegateのメソッド。衝突した時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact) {
        //ゲームオーバーの時は何もしない
        if scrollNode.speed <= 0{
            return
        }
        
        if  (contact.bodyA.categoryBitMask  &  scoreCategory)  ==  scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) ==  scoreCategory {
            //スコア用の物体と衝突した
            print("ScoreUP")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey:"BEST")
            if score > bestScore{
                bestScore = score
                bestScoreLabelNode.text = "Best Score:\(bestScore)"
                userDefaults.set(bestScore,forKey:"BEST")
                userDefaults.synchronize()
            }
            
        } else if(contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
            print("GotItem!")
            itemscore += 1
            itemscoreLabelNode.text = "ItemScore:\(itemscore)"
            
            contact.bodyA.node?.removeFromParent()
            contact.bodyB.node?.xScale = 1.5
            
            let mySoundAction: SKAction = SKAction.playSoundFileNamed("powerup03.mp3", waitForCompletion: true)
            // 再生アクション
            self.run(mySoundAction);
        }
            
        else{
            if (bird.xScale == 1.5){
                contact.bodyB.node?.xScale = 1}
            
        else
            if(bird.xScale == 1){
                //壁か地面と衝突した
                print("GameOver")
                //スクロールを停止させる
                scrollNode.speed = 0
                
                bird.physicsBody?.collisionBitMask = groundCategory
                
                let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01,duration:1)
                bird.run(roll,completion:{
                    self.bird.speed = 0
                })
            }
        }
    }
    
        func restart(){
            score = 0
            itemscore = 0
            
            scoreLabelNode.text = String("Score:\(score)")
            itemscoreLabelNode.text = String("ItemScore:\(itemscore)")
            
            bird.position = CGPoint(x:self.frame.size.width*0.2,y:self.frame.size.height*0.7)
            bird.physicsBody?.velocity = CGVector.zero
            bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
            bird.zRotation = 0.0
            
            wallNode.removeAllChildren()
            itemNode.removeAllChildren()
            
            bird.speed = 1
            scrollNode.speed = 1
            
        }
        
        
        func setupItem(){
            //アイテムの画像を読み込む
            let itemTexture = SKTexture(imageNamed:"apple")
            itemTexture.filteringMode = .linear
            
            //移動する距離を計算
            let movingDistance1 = CGFloat(self.frame.size.width + itemTexture.size().width)
            //画面外まで移動するアクションを作成
            let moveItem = SKAction.moveBy(x: -movingDistance1, y: 0, duration: 4.0)
            //自信を取り除くアクションを作成
            let removeItem = SKAction.removeFromParent()
            //二つのアニメーションを順に実行するアクションを作成
            let itemAnimation = SKAction.sequence([moveItem,removeItem])
            
            //アイテムを生成するアクションを作成
            let createItemAnimation = SKAction.run({
                
                //壁関連のノードを乗せるノードを作成
                let item = SKNode()
                item.position = CGPoint(x:self.frame.size.width + itemTexture.size().width,y:300)
                //item.size = CGSize(width: item.size.width*0.7, height: item.size.height*0.7)
                item.zPosition = -50
                
                
                let itemobject = SKSpriteNode(texture: itemTexture)
                itemobject.position = CGPoint(x:90.0,y:150)
                
                itemobject.physicsBody = SKPhysicsBody(rectangleOf: itemTexture.size())
                itemobject.physicsBody?.categoryBitMask = self.itemCategory
                
                //衝突した時に動かないように設定する
                itemobject.physicsBody?.isDynamic = false
                
                item.addChild(itemobject)
                item.run(itemAnimation)
                self.itemNode.addChild(item)
            })
            
            let waitAnimation = SKAction.wait(forDuration: 2)
            
            // 壁を作成->待ち時間->壁を作成を無限に繰り替えるアクションを作成
            let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
            
            wallNode.run(repeatForeverAnimation)
        }
    
    
}







