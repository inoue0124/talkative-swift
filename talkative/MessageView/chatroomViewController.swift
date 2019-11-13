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

class ChatroomViewController: MessagesViewController {

    var chatroom: ChatroomModel?
    var avatarImage: UIImage?
    var messageList: [MockMessage] = []
    private var messageListener: ListenerRegistration?

    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .none
        return formatter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        //self.navigationItem.title = chatroom!.nativeName
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
        self.messageListener = messageDb.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot else {
               print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
               return
             }
            snapshot.documentChanges.forEach { change in
              self.handleDocumentChange(change)
            }
        }

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self

        messageInputBar.delegate = self
        messageInputBar.sendButton.tintColor = UIColor.lightGray
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

      let isLatestMessage = messageList.index(of: message) == (messageList.count - 1)
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
//      switch change.type {
//      case .added:
//          insertNewMessage(message)
//      default:
//        print("not added")
//        break
//      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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

    // メッセージの上に文字を表示（名前）
//    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        let name = message.sender.displayName
//        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
//    }

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
            } else if let text = component as? String {
                chatroomsDb.document(chatroom!.chatroomID).setData(["latestMsg": text, "updatedAt": FieldValue.serverTimestamp(), "chatroomID": chatroom!.chatroomID, "viewableUserIDs": chatroom!.viewableUserIDs], merge: true)
                messageDb.addDocument(data: ["createdAt": FieldValue.serverTimestamp(),"senderID": self.getUserUid(),"senderName": self.getUserData().name,"text":text])
//                let attributedText = NSAttributedString(string: text, attributes: [.font: UIFont.systemFont(ofSize: 15),
//                                                                                   .foregroundColor: UIColor.white])
//                let message = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: UUID().uuidString, date: Date())
//                messageList.append(message)
//                messagesCollectionView.insertSections([messageList.count - 1])
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
        guard let text = data["text"] as? String else {
            print("text")
            return nil
        }
        self.init(kind: .text(text), sender: Sender(id: senderID, displayName: senderName), messageId: document.documentID, date: sentDate.dateValue())
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
        // メッセージ入力欄の左に画像選択ボタンを追加
//        let items = [
//            makeButton(named: "camera").onTextViewDidChange { button, textView in
//                button.tintColor = UIColor.lightGray
//                button.isEnabled = textView.text.isEmpty
//            }
//        ]
//        items.forEach { $0.tintColor = .lightGray }
//        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
//        messageInputBar.setLeftStackViewWidthConstant(to: 45, animated: false)
//
//
//        // メッセージ入力時に一番下までスクロール
//        scrollsToBottomOnKeyboardBeginsEditing = true // default false
//        maintainPositionOnKeyboardFrameChanged = true // default false

    // ボタンの作成
//    func makeButton(named: String) -> InputBarButtonItem {
//        return InputBarButtonItem()
//            .configure {
//                $0.spacing = .fixed(10)
//                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
//                $0.setSize(CGSize(width: 30, height: 30), animated: true)
//            }.onSelected {
//                $0.tintColor = UIColor.gray
//            }.onDeselected {
//                $0.tintColor = UIColor.lightGray
//            }.onTouchUpInside { _ in
//                print("Item Tapped")
//        }
//    }
