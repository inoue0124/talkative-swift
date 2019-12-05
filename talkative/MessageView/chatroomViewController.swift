//
//  ChatroomChatroomViewController.swift
//  talkative
//
//  Created by Yusuke Inoue on 2019/10/10.
//  Copyright © 2019 Yusuke Inoue. All rights reserved.
//

import UIKit
import MessageKit
import Foundation
import CoreLocation
import InputBarAccessoryView
import FirebaseAuth
import FirebaseFirestore
import Photos
import FirebaseStorage
import Firebase
import SDWebImage

class ChatroomViewController: MessagesViewController {

    var chatroom: ChatroomModel?
    var avatarImage: UIImage?
    var messageList: [MockMessage] = []
    var chatPartnerName: String?
    let usersDB = Firestore.firestore().collection("Users")
    var user: UserModel?
    var isSendingPhoto: Bool?
    private var messageListener: ListenerRegistration?
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTitle()
        maintainPositionOnKeyboardFrameChanged = true
        scrollsToBottomOnKeyboardBeginsEditing = true
        if let layout = self.messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            // アイコンを非表示
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageIncomingAvatarSize(.zero)
            // 非表示の分、吹き出しを移動して空白を埋める
            let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
            layout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))
            layout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: insets))
        }
        let messageDb = Firestore.firestore().collection(["chatrooms", self.chatroom!.chatroomID, "messages"].joined(separator: "/"))
        messageDb.getDocuments() { snapshot, error in
            guard let snapshot = snapshot else {
               print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
               return
             }
            snapshot.documentChanges.forEach { change in
              self.handleDocumentChange(change)
            }
        }
        self.messageListener = messageDb.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
               print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
               return
             }
            snapshot.documentChanges.forEach { change in
              self.handleListenerDocumentChange(change)
            }
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray
        setupCollectionView()
        inputStyle()
    }

    func setupTitle() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        tabBarController?.tabBar.isHidden = true
        let label = UILabel()
        label.text = chatPartnerName!
        label.sizeToFit()
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(ChatroomViewController.tappedTitle(_:))))
        label.isUserInteractionEnabled = true
        navigationItem.titleView = label
        let items = [
            makeButton(named: "album").onTextViewDidChange { button, textView in
                button.tintColor = UIColor.lightGray
                button.isEnabled = textView.text.isEmpty
            }
        ]
        items.forEach { $0.tintColor = .lightGray }
        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 40, animated: false)
        messageInputBar.leftStackView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        messageInputBar.leftStackView.isLayoutMarginsRelativeArrangement = true
    }

    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem()
        .configure {
            $0.spacing = .fixed(10)
            $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
            $0.setSize(CGSize(width: 24, height: 24), animated: true)
        }.onSelected {
            $0.tintColor = UIColor.gray
        }.onDeselected {
            $0.tintColor = UIColor.lightGray
        }.onTouchUpInside { _ in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            self.present(picker, animated: true, completion: nil)
        }
    }

    private func sendPhoto(_ image: UIImage) {
      isSendingPhoto = true
      uploadImage(image, to: chatroom!) { [weak self] url in
        guard let `self` = self else {
            return
        }
        self.isSendingPhoto = false

        guard let url = url else {
            return
        }
        let chatroomsDb = Firestore.firestore().collection("chatrooms")
        let messageDb = Firestore.firestore().collection(["chatrooms", self.chatroom!.chatroomID, "messages"].joined(separator: "/"))
        chatroomsDb.document(self.chatroom!.chatroomID).setData(["latestMsg": self.LString("photo"),
                                                                 "senderID": self.getUserUid(),
                                                                "updatedAt": FieldValue.serverTimestamp(),
                                                                "chatroomID": self.chatroom!.chatroomID,
                                                                "viewableUserIDs": self.chatroom!.viewableUserIDs,
                                                                "viewableUserNames": self.chatroom!.viewableUserNames], merge: true)
        messageDb.addDocument(data: ["createdAt": FieldValue.serverTimestamp(),
                                     "senderID": self.getUserUid(),
                                     "senderName": self.getUserData().name,
                                     "downloadURL": url.absoluteString])
        self.messagesCollectionView.scrollToBottom()
      }
    }

    private func uploadImage(_ image: UIImage, to chatroom: ChatroomModel, completion: @escaping (URL?) -> Void) {
        let chatroomID = chatroom.chatroomID
        guard let scaledImage = image.scaledToSafeUploadSize,
            let data = scaledImage.jpegData(compressionQuality: 1.0) else {
            completion(nil)
            return
        }

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        let imageName = [getUserUid(), String(Date().timeIntervalSince1970)].joined()
        storage.child(chatroomID).child(imageName).putData(data, metadata: metadata) { meta, error in
            self.storage.child(chatroomID).child(imageName).downloadURL { downloadURL, error in
            completion(downloadURL)
            }
        }
    }

    @objc func tappedTitle(_ sender: UITapGestureRecognizer) {
        usersDB.whereField("uid", isEqualTo: chatroom!.viewableUserIDs.filter{ $0.key != getUserUid() }[0].key).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else if querySnapshot!.documents.isEmpty {
                print("user is not exist")
            } else {
                print("user is exist")
                self.user = UserModel(from: querySnapshot!.documents[0])
                self.performSegue(withIdentifier: "showDetailView", sender: nil)
            }
        }
    }

    func configureMediaMessageImageView(_ imageView: UIImageView,
                                        for message: MessageType,
                                        at indexPath: IndexPath,
                                        in messagesCollectionView: MessagesCollectionView) {
       guard case .photo(let mediaItem) = message.kind else { fatalError() }
        if let url = mediaItem.url {
            imageView.sd_setImage(with: url)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        self.becomeFirstResponder()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    private func insertNewMessage(_ message: MockMessage) {
      guard !messageList.contains(message) else {
        return
      }
      messageList.append(message)
      messageList.sort()
      let isLatestMessage = messageList.firstIndex(of: message) == (messageList.count - 1)
      let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
      messagesCollectionView.reloadData()
      if shouldScrollToBottom {
        DispatchQueue.main.async {
          self.messagesCollectionView.scrollToBottom(animated: true)
        }
      }
    }

    private func handleDocumentChange(_ change: DocumentChange) {
      guard let message = MockMessage(document: change.document) else {
        return
      }
        insertNewMessage(message)
    }

    private func handleListenerDocumentChange(_ change: DocumentChange) {
      guard let message = MockMessage(document: change.document) else {
        return
      }
        if message.sender.senderId == getUserUid() {
            return
        }
        insertNewMessage(message)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetailView" {
            let userDetailVC = segue.destination as! userDetailViewController
            userDetailVC.user = self.user!
            userDetailVC.tabIndex = 0
        }
    }
}

extension ChatroomViewController: MessagesDataSource {

    func currentSender() -> SenderType {
        return Sender(id: self.getUserUid(), displayName: self.getUserData().name)
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }

    // メッセージの上に文字を表示
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(
                string: MessageKitDateFormatter.shared.string(from: message.sentDate),
                attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10),
                             NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            )
        }
        return nil
    }
    // メッセージの下に文字を表示（日付）
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
}

// メッセージのdelegate
extension ChatroomViewController: MessagesDisplayDelegate {

    // メッセージの色を変更（デフォルトは自分：白、相手：黒）
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }

    // メッセージの背景色を変更している（デフォルトは自分：緑、相手：グレー）
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ?
            UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1) :
            UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }

    // メッセージの枠にしっぽを付ける
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }

    // アイコンをセット
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // message.sender.displayNameとかで送信者の名前を取得できるので
        // そこからイニシャルを生成するとよい
        
        let avatar = Avatar(initials: "人")
        avatarView.set(avatar: avatar)
    }
    // URL青色、下線を表示
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        let detectorAttributes: [NSAttributedString.Key: Any] = {
            [
                NSAttributedString.Key.foregroundColor: UIColor.blue,
                NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                NSAttributedString.Key.underlineColor: UIColor.blue,
            ]
        }()
        MessageLabel.defaultAttributes = detectorAttributes
        return MessageLabel.defaultAttributes
    }

    // メッセージのURLに属性を適用
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url]
    }

    func setupCollectionView() {
        guard let flowLayout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            print("Can't get flowLayout")
            return
        }
        if #available(iOS 13.0, *) {
            flowLayout.collectionView?.backgroundColor = .systemBackground
        }
    }
    func inputStyle() {
        if #available(iOS 13.0, *) {
            messageInputBar.inputTextView.textColor = .label
            messageInputBar.inputTextView.placeholderLabel.textColor = .secondaryLabel
            messageInputBar.backgroundView.backgroundColor = .systemBackground
        } else {
            messageInputBar.inputTextView.textColor = .black
            messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        }
    }
}


// 各ラベルの高さを設定（デフォルト0なので必須）
extension ChatroomViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 { return 10 }
        return 0
    }

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
}

extension ChatroomViewController: MessageCellDelegate {
    // メッセージをタップした時の挙動
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
}

extension ChatroomViewController: MessageInputBarDelegate {
    // メッセージ送信ボタンをタップした時の挙動
    func inputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        self.messageInputBar.inputTextView.resignFirstResponder()
        let chatroomsDb = Firestore.firestore().collection("chatrooms")
        let messageDb = Firestore.firestore().collection(["chatrooms", self.chatroom!.chatroomID, "messages"].joined(separator: "/"))
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
                messagesCollectionView.scrollToBottom()
                sendPhoto(image)
            } else if let text = component as? String {
                let message = MockMessage(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(message)
                messagesCollectionView.insertSections([messageList.count - 1])
                chatroomsDb.document(chatroom!.chatroomID).setData(["latestMsg": text,
                                                                    "senderID": self.getUserUid(),
                                                                    "updatedAt": FieldValue.serverTimestamp(),
                                                                    "chatroomID": chatroom!.chatroomID,
                                                                    "viewableUserIDs": chatroom!.viewableUserIDs,
                                                                    "viewableUserNames": chatroom!.viewableUserNames], merge: true)
                messageDb.addDocument(data: ["createdAt": FieldValue.serverTimestamp(),
                                             "senderID": self.getUserUid(),
                                             "senderName": self.getUserData().name,
                                             "text":text])
            }
        }
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
}



private struct MockLocationItem: LocationItem {

    var location: CLLocation
    var size: CGSize

    init(location: CLLocation) {
        self.location = location
        self.size = CGSize(width: 240, height: 240)
    }
}

private struct MockMediaItem: MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(url: URL) {
        self.url = url
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }

    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}


internal struct MockMessage: MessageType {

    var messageId: String
    var sender: SenderType
    var sentDate: Date
    var kind: MessageKind

    private init(kind: MessageKind, sender: SenderType, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let sentDate = data["createdAt"] as? Timestamp else {
            print("sentdate")
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            print("senderID")
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            print("sendername")
            return nil
        }
        if let text = data["text"] as? String {
            self.init(kind: .text(text), sender: Sender(id: senderID, displayName: senderName), messageId: document.documentID, date: sentDate.dateValue())
        } else if let downloadURL = URL(string: data["downloadURL"] as! String) {
            self.init(kind: .photo(MockMediaItem(url: downloadURL)), sender: Sender(id: senderID, displayName: senderName), messageId: document.documentID, date: sentDate.dateValue())
        } else {
            return nil
        }
    }

    init(text: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }

    init(attributedText: NSAttributedString, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }

    init(image: UIImage, sender: SenderType, messageId: String, date: Date) {
        let mediaItem = MockMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }

    init(thumbnail: UIImage, sender: SenderType, messageId: String, date: Date) {
        let mediaItem = MockMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
    }

    init(location: CLLocation, sender: SenderType, messageId: String, date: Date) {
        let locationItem = MockLocationItem(location: location)
        self.init(kind: .location(locationItem), sender: sender, messageId: messageId, date: date)
    }

    init(emoji: String, sender: SenderType, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
    }
}

extension MockMessage: Comparable {

  static func == (lhs: MockMessage, rhs: MockMessage) -> Bool {
    return lhs.messageId == rhs.messageId
  }

  static func < (lhs: MockMessage, rhs: MockMessage) -> Bool {
    return lhs.sentDate < rhs.sentDate
  }

}

extension UIScrollView {

  var isAtBottom: Bool {
    return contentOffset.y >= verticalOffsetForBottom
  }

  var verticalOffsetForBottom: CGFloat {
    let scrollViewHeight = bounds.height
    let scrollContentSizeHeight = contentSize.height
    let bottomInset = contentInset.bottom
    let scrollViewBottomOffset = scrollContentSizeHeight + bottomInset - scrollViewHeight
    return scrollViewBottomOffset
  }

}

extension ChatroomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let asset = info[.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFit, options: nil) { result, info in
                guard let image = result else {
                    return
                }
                let imageMessage = MockMessage(image: image, sender: self.currentSender(), messageId: UUID().uuidString, date: Date())
                self.messageList.append(imageMessage)
                self.messagesCollectionView.insertSections([self.messageList.count - 1])
                self.sendPhoto(image)
            }
        } else if let image = info[.originalImage] as? UIImage {
            let imageMessage = MockMessage(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
            messageList.append(imageMessage)
            messagesCollectionView.insertSections([messageList.count - 1])
            sendPhoto(image)
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
