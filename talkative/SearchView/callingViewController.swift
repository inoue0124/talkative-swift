//
//  callingViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import SkyWay
import FirebaseFirestore

class callingViewController: UIViewController {
    var offer: OfferModel?
    fileprivate var peer: SKWPeer?
    fileprivate var mediaConnection: SKWMediaConnection?
    fileprivate var localStream: SKWMediaStream?
    fileprivate var remoteStream: SKWMediaStream?


    @IBOutlet weak var remoteStreamView: SKWVideo!
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var endCallButton: UIButton!
    let offersDb = Firestore.firestore().collection("offers")


        override func viewDidLoad() {
            self.offersDb.document(self.offer!.offerID).setData([
                "learnerID" : self.getUserUid(),
                "learnerName" : self.getUserData().name,
                "learnerNationality" : self.getUserData().nationality,
                "learnerRating" : self.getUserData().rating,
                "learnerImageURL" : self.getUserData().imageURL
            ], merge: true)
            super.viewDidLoad()
            //endCallButton.layer.backgroundColor = UIColor.white.cgColor
            //endCallButton.layer.cornerRadius = 50
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            tabBarController?.tabBar.isHidden = true
            self.setup()
        }

        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            self.mediaConnection?.close()
            self.peer?.destroy()
        }

        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }

        func tapCall(){
            guard let _peer = self.peer else{
                return
            }
            self.call(targetPeerId: self.offer!.peerID)
        }

        @IBAction func tapEndCall(){
            let alertController = UIAlertController(title: "終了確認", message: "通話を終了します。よろしいですか？", preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "終了", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                self.offersDb.document(self.offer!.offerID).setData([
                    "finishedAt" : FieldValue.serverTimestamp()
                ], merge: true)
                self.mediaConnection?.close()
                self.performSegue(withIdentifier: "showReview", sender: nil)
            })
            let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
                 return
            })
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReview" {
            let ReviewVC = segue.destination as! ReviewViewController
            ReviewVC.offer = self.offer!
        }
    }
}

    // MARK: setup skyway

    extension callingViewController{

        func setup(){

            guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
                print("Not set apikey or domain")
                return
            }

            let option: SKWPeerOption = SKWPeerOption.init();
            option.key = apikey
            option.domain = domain

            peer = SKWPeer(options: option)

            if let _peer = peer{
                self.setupPeerCallBacks(peer: _peer)
                self.setupStream(peer: _peer)
            }else{
                print("failed to create peer setup")
            }
        }

        func setupStream(peer:SKWPeer){
            SKWNavigator.initialize(peer);
            let constraints:SKWMediaConstraints = SKWMediaConstraints()
            self.localStream = SKWNavigator.getUserMedia(constraints)
            self.localStream?.addVideoRenderer(self.localStreamView, track: 0)
        }

        func call(targetPeerId:String){
            let option = SKWCallOption()

            if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
                self.mediaConnection = mediaConnection
                self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
            }else{
                print("failed to call :\(targetPeerId)")
            }
        }
    }

    // MARK: skyway callbacks

    extension callingViewController{

        func setupPeerCallBacks(peer:SKWPeer){

            // MARK: PEER_EVENT_ERROR
            peer.on(SKWPeerEventEnum.PEER_EVENT_ERROR, callback:{ (obj) -> Void in
                if let error = obj as? SKWPeerError{
                    print("\(error)")
                }
            })

            // MARK: PEER_EVENT_OPEN
            peer.on(SKWPeerEventEnum.PEER_EVENT_OPEN,callback:{ (obj) -> Void in
                if let peerId = obj as? String{
                    print("your peerId: \(peerId)")
                    self.tapCall()
                }
            })

            // MARK: PEER_EVENT_CONNECTION
            peer.on(SKWPeerEventEnum.PEER_EVENT_CALL, callback: { (obj) -> Void in
                if let connection = obj as? SKWMediaConnection{
                    self.setupMediaConnectionCallbacks(mediaConnection: connection)
                    self.mediaConnection = connection
                    connection.answer(self.localStream)
                }
            })
        }

        func setupMediaConnectionCallbacks(mediaConnection:SKWMediaConnection){

            // MARK: MEDIACONNECTION_EVENT_STREAM
            mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_STREAM, callback: { (obj) -> Void in
                if let msStream = obj as? SKWMediaStream{
                    self.remoteStream = msStream
                    DispatchQueue.main.async {
                        self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                    }
                }
            })

            // MARK: MEDIACONNECTION_EVENT_CLOSE
            mediaConnection.on(SKWMediaConnectionEventEnum.MEDIACONNECTION_EVENT_CLOSE, callback: { (obj) -> Void in
                if let _ = obj as? SKWMediaConnection{
                    DispatchQueue.main.async {
                        self.remoteStream?.removeVideoRenderer(self.remoteStreamView, track: 0)
                        self.remoteStream = nil
                        self.mediaConnection = nil
                    }
                    self.performSegue(withIdentifier: "showReview", sender: nil)
                }
            })
        }
}
