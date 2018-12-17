//
//  ViewController.swift
//  FlappyBird
//
//  Created by 田村尚利 on 2018/11/27.
//  Copyright © 2018 masatoshi.tamura. All rights reserved.
//

import UIKit
import SpriteKit


class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let skView = self.view as! SKView
        
        //fpsを表示する
        skView.showsFPS = true
        //ノードの数を表示する
        skView.showsNodeCount = true
       //ビュウーと同じサイズでシーンを作成する
        let scene = GameScence(size:skView.frame.size)
        
        //ビューにシーンを表示する
        skView.presentScene(scene)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool{
        get {
            return true
            
        }
    }


}

