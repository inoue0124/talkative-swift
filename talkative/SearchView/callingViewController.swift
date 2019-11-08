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
import SCLAlertView

class callingViewController: UIViewController {
    var offer: OfferModel?
    fileprivate var peer: SKWPeer?
    fileprivate var mediaConnection: SKWMediaConnection?
    fileprivate var localStream: SKWMediaStream?
    fileprivate var remoteStream: SKWMediaStream?
    var waitingTimer = Timer()
    var timer = Timer()
    var waitingAlert: SCLAlertView?
    var errorAlert: SCLAlertView?

    @IBOutlet weak var remoteStreamView: SKWVideo!
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!

    let offersDb = Firestore.firestore().collection("offers")


    override func viewDidLoad() {
        self.offersDb.document(self.offer!.offerID).setData([
            "learnerID" : self.getUserUid(),
            "learnerName" : self.getUserData().name,
            "learnerNationality" : self.getUserData().nationality,
            "learnerLevel" : self.getUserData().level,
            "learnerRating" : self.getUserData().ratingAsLearner,
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
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
        self.mediaConnection?.close()
        self.peer?.destroy()
        self.waitingAlert?.hideView()
        self.errorAlert?.hideView()
        self.waitingTimer.invalidate()
        self.timer.invalidate()
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
        let appearance = SCLAlertView.SCLAppearance(
            showCloseButton: false
        )
        waitingAlert = SCLAlertView(appearance: appearance)
        waitingAlert!.showWait(LString("Waiting for answering"), subTitle: LString("Please wait a moment"), closeButtonTitle: nil, timeout: nil, colorStyle: nil, colorTextButton: 0xFFFFFF, circleIconImage: UIImage.gif(name: "Preloader2"), animationStyle: SCLAnimationStyle.topToBottom)
        waitingTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true, block: { (waitingTimer) in
            if self.remoteStream == nil {
                self.errorAlert?.hideView()
                self.errorAlert = SCLAlertView(appearance: appearance)
                self.errorAlert!.addButton(self.LString("Continue")) {}
                self.errorAlert!.addButton(self.LString("Quit")) {
                    self.mediaConnection?.close()
                    self.navigationController?.popViewController(animated: true)
                }
                self.errorAlert!.showError(self.LString("Error"), subTitle:self.LString("No answer"), closeButtonTitle: nil)
            }
        })
    }

    @IBAction func tapEndCall() {
        let alertController = UIAlertController(title: LString("Finish calling?"), message: LString("Do you want to finish calling?"), preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: LString("Finish"), style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
            self.offersDb.document(self.offer!.offerID).setData([
                "finishedAt" : FieldValue.serverTimestamp()
            ], merge: true)
            self.mediaConnection?.close()
        })
        let cancelAction = UIAlertAction(title: LString("Cancel"), style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
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
                    self.waitingAlert?.hideView()
                    self.errorAlert?.hideView()
                    self.waitingTimer.invalidate()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "mm:ss"
                    self.offersDb.whereField("offerID", isEqualTo: self.offer!.offerID).addSnapshotListener() { snapshot, error in
                         if let _error = error {
                             print("error\(_error)")
                             return
                         }
                         guard let documents = snapshot?.documents else {
                         print("error")
                            return
                        }
                        self.offer = documents.map{ OfferModel(from: $0) }[0]
                        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
                            let timeRemaining = Double(self.offer!.offerTime * 60) + self.offer!.acceptedAt.timeIntervalSinceNow
                            self.timerLabel.text = formatter.string(from: Date(timeIntervalSinceReferenceDate: timeRemaining))
                            if timeRemaining < 0 {
                                self.timerLabel.text = formatter.string(from: Date(timeIntervalSinceReferenceDate: 0.0))
                                self.timerLabel.textColor = .red
                                self.timer.invalidate()
                            }
                        })
                    }
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
