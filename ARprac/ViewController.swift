//
//  ViewController.swift
//  ARprac
//
//  Created by Zhengyang Duan on 2018-07-09.
//  Copyright © 2018 Zhengyang Duan. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    var diceArray: [SCNNode] = []
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        
        sceneView.delegate = self
        sceneView.showsStatistics = false

        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            if let hitResult = results.first{
                addDice(atLocation: hitResult)
            }
        }
    }
    func rollAll() {
        if !diceArray.isEmpty{
            diceArray.map{roll(dice: $0)}
        }
    }
    func roll(dice: SCNNode){
        let randomX = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        let randomY = Float(arc4random_uniform(4) + 1 ) * (Float.pi/2)
        dice.runAction(
            SCNAction.rotateBy(x: CGFloat(randomX * 5), y: CGFloat(randomY * 5), z: CGFloat(randomZ * 5), duration: 0.5)
        )
    }
    
    func addDice(atLocation location: ARHitTestResult){
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true) {
            diceNode.position = SCNVector3(x: location.worldTransform.columns.3.x, y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius, z: location.worldTransform.columns.3.z)
            diceArray.append(diceNode)
            sceneView.scene.rootNode.addChildNode(diceNode)
            roll(dice: diceNode)
        }
    }
    
    @IBAction func rollButtonPressed(_ sender: UIBarButtonItem) {
        rollAll()
    }
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAll(_ sender: UIBarButtonItem) {
        if !diceArray.isEmpty {
            diceArray.map{$0.removeFromParentNode()}
        }
    }
    
    //MARK: - ARDelegate method
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        let planeNode = createPlane(with: planeAnchor)
        node.addChildNode(planeNode)
    }
    
    func createPlane(with planeAnchor: ARPlaneAnchor) -> SCNNode{
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode()
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: planeAnchor.center.y, z: planeAnchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        let gridMaterial = SCNMaterial()
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        plane.materials = [gridMaterial]
        planeNode.geometry = plane
        return planeNode
        

    }
}


