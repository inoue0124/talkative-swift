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
    var offerListener: ListenerRegistration?
    var selectedChatroom: ChatroomModel?
    var chatPartnerName: String?
    var avatarImage: UIImage?
    var isPresentedExtensionAlert = false
    var isCanceledExtension = false
    var isMute = false
    var isMuteVideo: Bool?

    @IBOutlet weak var remoteStreamView: SKWVideo!
    @IBOutlet weak var localStreamView: SKWVideo!
    @IBOutlet weak var endCallButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var changeCamera: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var remoteImage: UIImageView!
    @IBOutlet weak var localImage: UIImageView!

    let offersDb = Firestore.firestore().collection("offers")

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        tabBarController?.tabBar.isHidden = true
        setup()
        if isMuteVideo == true {
            videoButton.tintColor = UIColor.blue
            localStream?.setEnableVideoTrack(0, enable: false)
            localImage.image = UIImage(named: "muteVideo_button")
        } else {
            isMuteVideo = false
        }
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
                    self.offersDb.document(self.offer!.offerID).setData([
                        "peerID" : "",
                        "isSelected" : false,
                        "isOnline" : true
                    ], merge: true)
                    self.mediaConnection?.close()
                    self.navigationController?.popViewController(animated: true)
                }
                self.errorAlert!.showError(self.LString("Error"), subTitle:self.LString("No answer"), closeButtonTitle: nil)
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        mediaConnection?.close()
        peer?.destroy()
        waitingAlert?.hideView()
        errorAlert?.hideView()
        waitingTimer.invalidate()
        timer.invalidate()
        offerListener?.remove()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func tapEndCall() {
        let alertController = UIAlertController(title: LString("Finish calling?"), message: LString("Do you want to finish calling?"), preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: LString("Finish"), style: UIAlertAction.Style.default, handler:{(action: UIAlertAction!) in
            self.timer.invalidate()
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
        isMuteVideo!.toggle()
        if isMuteVideo! {
            videoButton.tintColor = UIColor.blue
            localStream?.setEnableVideoTrack(0, enable: false)
            localImage.image = UIImage(named: "muteVideo_button")
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                showCloseButton: false
            )
            let videoAlert = SCLAlertView(appearance: appearance)
            videoAlert.addButton(self.LString("OK")) {
                self.videoButton.tintColor = UIColor.gray
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
            let ReviewVC = segue.destination as! ReviewViewController
            ReviewVC.offer = self.offer!
        }
        if segue.identifier == "showChatroomView" {
            let chatroomVC = segue.destination as! ChatroomViewController
            chatroomVC.chatroom = self.selectedChatroom
            chatroomVC.chatPartnerName = chatPartnerName
            chatroomVC.avatarImage = self.avatarImage
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

        peer = SKWPeer(options: option)

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

    func call(targetPeerId:String){
        let option = SKWCallOption()

        if let mediaConnection = self.peer?.call(withId: targetPeerId, stream: self.localStream, options: option){
            self.mediaConnection = mediaConnection
            self.setupMediaConnectionCallbacks(mediaConnection: mediaConnection)
        }else{
            print("failed to call :\(targetPeerId)")
        }
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
                self.offersDb.document(self.offer!.offerID).setData([
                    "peerID" : peerId,
                    "learnerID" : self.getUserUid(),
                    "learnerName" : self.getUserData().name,
                    "learnerNationality" : self.getUserData().nationality,
                    "learnerProficiency" : self.getUserData().proficiency,
                    "learnerRating" : self.getUserData().ratingAsLearner,
                    "learnerImageURL" : self.getUserData().imageURL,
                    "isSelected" : true,
                    "isOnline" : false
                ], merge: true)
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
                    self.waitingAlert?.hideView()
                    self.errorAlert?.hideView()
                    self.waitingTimer.invalidate()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "mm:ss"
                    self.offerListener = self.offersDb.whereField("offerID", isEqualTo: self.offer!.offerID).addSnapshotListener() { snapshot, error in
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
                            if (timeRemaining < 60 * 3) && !self.isCanceledExtension {
                                let appearance = SCLAlertView.SCLAppearance(
                                    showCloseButton: false
                                )
                                let extentionAlert = SCLAlertView(appearance: appearance)
                                extentionAlert.addButton(self.LString("OK")) {
                                    self.offersDb.document(self.offer!.offerID).setData([
                                        "offerTime" : self.offer!.offerTime + 5
                                    ], merge: true)
                                    self.isPresentedExtensionAlert = false
                                }
                                extentionAlert.addButton(self.LString("Cancel")) {
                                    self.isCanceledExtension = true
                                }
                                guard (self.getTopViewController() as? callingViewController) != nil else {
                                    self.timer.invalidate()
                                    return
                                }
                                if !self.isPresentedExtensionAlert {
                                    extentionAlert.showInfo(self.LString("Confirm extension"), subTitle:self.LString("Do you want to extend 5 minutes?"), closeButtonTitle: nil)
                                    self.isPresentedExtensionAlert = true
                                }
                            }
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
