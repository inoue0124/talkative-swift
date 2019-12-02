//
//  callingViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/09.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import AVFoundation
import SkyWay
import FirebaseFirestore
import SCLAlertView

class teachCallingViewController: UIViewController {
    var offer: OfferModel?
    var peerID: String?
    var peer: SKWPeer?
    var mediaConnection: SKWMediaConnection?
    fileprivate var localStream: SKWMediaStream?
    fileprivate var remoteStream: SKWMediaStream?
    let offersDb = Firestore.firestore().collection("offers")
    var offerID: String?
    var timer = Timer()
    var offerListener: ListenerRegistration?
    var chatroom: ChatroomModel?
    var chatPartnerName: String?
    var avatarImage: UIImage?
    var isMute = false
    var isMuteVideo = false

    @IBOutlet weak var remoteStreamView: SKWVideo!
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var muteVideoButton: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var localImage: UIImageView!
    @IBOutlet weak var remoteImage: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
        setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mediaConnection?.close()
        peer?.destroy()
        timer.invalidate()
        offerListener?.remove()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapEndCall(){
        let alertController = UIAlertController(title: LString("Finish calling?"), message: LString("Do you want to finish calling?"), preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: LString("Finish"), style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
            self.offersDb.document(self.offerID!).setData([
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

    @IBAction func tappedMuteButton(_ sender: Any) {
        isMute.toggle()
        if isMute {
            muteButton.tintColor = UIColor.blue
            localStream?.setEnableAudioTrack(0, enable: false)
        } else {
            muteButton.tintColor = UIColor.gray
            localStream?.setEnableAudioTrack(0, enable: true)
        }
    }

    @IBAction func tappedVideoButton(_ sender: Any) {
        isMuteVideo.toggle()
        if isMuteVideo {
            muteVideoButton.tintColor = UIColor.blue
            localStream?.setEnableVideoTrack(0, enable: false)
            localImage.image = UIImage(named: "muteVideo_button")
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let videoAlert = SCLAlertView(appearance: appearance)
            videoAlert.addButton(self.LString("OK")) {
                self.muteVideoButton.tintColor = UIColor.gray
                self.localStream?.setEnableVideoTrack(0, enable: true)
                self.localImage.image = nil
            }
            videoAlert.addButton(self.LString("Cancel")) { return }
            videoAlert.showInfo(self.LString("Confirm video usage"), subTitle:self.LString("Do you want to turn on the camera?"), closeButtonTitle: nil)
        }
    }

    @IBAction func tappedSwitchCameraButton(_ sender: Any) {
        localStream?.switchCamera()
    }

    override func prepare (for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showReview" {
            let ReviewVC = segue.destination as! teachReviewViewController
            ReviewVC.offer = offer!
        }
        if segue.identifier == "showChatroomView" {
            let chatroomVC = segue.destination as! ChatroomViewController
            chatroomVC.chatroom = chatroom
            chatroomVC.avatarImage = avatarImage
            chatroomVC.chatPartnerName = chatPartnerName
        }
    }


    func setup(){

        guard let apikey = (UIApplication.shared.delegate as? AppDelegate)?.skywayAPIKey, let domain = (UIApplication.shared.delegate as? AppDelegate)?.skywayDomain else{
            print("Not set apikey or domain")
            return
        }

        let option: SKWPeerOption = SKWPeerOption.init();
        option.key = apikey
        option.domain = domain

        self.peer = SKWPeer(options: option)

        if let _peer = peer {
            self.setupPeerCallBacks(peer: _peer)
            self.setupStream(peer: _peer)
        } else {
            print("failed to create peer setup")
        }
    }

    func setupStream(peer:SKWPeer){
        SKWNavigator.initialize(peer);
        let constraints:SKWMediaConstraints = SKWMediaConstraints()
        self.localStream = SKWNavigator.getUserMedia(constraints)
        self.localStream?.addVideoRenderer(self.localStreamView, track: 0)
    }

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
                print(peerId)
                self.call(targetPeerId: self.peerID!)
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let audioSession = AVAudioSession.sharedInstance()
                    try! audioSession.setCategory(AVAudioSession.Category.playAndRecord,
                                                  mode: AVAudioSession.Mode.default)
                    try! audioSession.overrideOutputAudioPort(.speaker)
                }
                self.remoteStream = msStream
                DispatchQueue.main.async {
                    self.remoteStream?.addVideoRenderer(self.remoteStreamView, track: 0)
                    let formatter = DateFormatter()
                    formatter.dateFormat = "mm:ss"
                    self.offerListener = self.offersDb.whereField("offerID", isEqualTo: self.offerID!).addSnapshotListener() { snapshot, error in
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

