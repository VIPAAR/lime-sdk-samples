//
//  JoinViewController.swift
//  SampleSwift
//
//  Created by Hale Xie on 2020/1/21.
//  Copyright © 2020 Helplightning. All rights reserved.
//

import UIKit
import HLSDKCommon
import HLSDK
import HLSDKSwift
import FBLPromises
import Promises

let kDefaultUserName = "[YOUR_USER_NAME]";
let kHLApiKey = "[YOUR_HL_API_KEY]";

class JoinViewController: UIViewController, HLClientDelegate {
    @IBOutlet private var gssServerURLTextField: UITextField!
    @IBOutlet private var sessionIDTextField: UITextField!
    @IBOutlet private var sessionPINTextField: UITextField!
    @IBOutlet private var sessionTokenTextView: UITextView!
    @IBOutlet private var userAvatarTextField: UITextField!
    @IBOutlet private var userNameTextField: UITextField!
    @IBOutlet private weak var joinButton: UIButton!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var imagePreview: UIImageView!
    @IBOutlet private weak var camOnSwitch: UISwitch!
    @IBOutlet private weak var micOnSwitch: UISwitch!
    
    var sharedDocManager:DocumentManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sessionPINTextField.text = CallManager.sharedInstance().sessionPIN
        sessionIDTextField.text = CallManager.sharedInstance().sessionID
        sessionTokenTextView.text = CallManager.sharedInstance().sessionToken
        userNameTextField.text = CallManager.sharedInstance().userName;
        userAvatarTextField.text = CallManager.sharedInstance().userAvatar;
        gssServerURLTextField.text = CallManager.sharedInstance().gssServerURL;
        userNameTextField.text = kDefaultUserName;
        camOnSwitch.isOn = CallManager.sharedInstance().camOn;
        micOnSwitch.isOn = CallManager.sharedInstance().micOn;
        
        HLClient.sharedInstance.delegate = self;
    }
    
    @IBAction func OnCancel(_ sender: Any) {
        HLClientSwift.shared.stopCurrentCall().always {
            self.presentingViewController?.dismiss(animated: true, completion: nil);
        };
    }
    
    @IBAction func OnJoinCall(_ sender: Any) {
        _setupTheme()
        
        CallManager.sharedInstance().sessionID = sessionIDTextField.text
        CallManager.sharedInstance().sessionToken = sessionTokenTextView.text
        CallManager.sharedInstance().userName = userNameTextField.text
        CallManager.sharedInstance().userAvatar = userAvatarTextField.text
        CallManager.sharedInstance().gssServerURL = gssServerURLTextField.text
        CallManager.sharedInstance().camOn = camOnSwitch.isOn;
        CallManager.sharedInstance().micOn = micOnSwitch.isOn;
        
        CallManager.sharedInstance().gssServerURL = gssServerURLTextField.text
        guard let call = HLCall(sessionId: CallManager.sharedInstance().sessionID, sessionToken: CallManager.sharedInstance().sessionToken, userToken: CallManager.sharedInstance().userToken, gssUrl: CallManager.sharedInstance().gssServerURL, helplightningAPIKey: kHLApiKey, localUserDisplayName: CallManager.sharedInstance().userName, localUserAvatarUrl: CallManager.sharedInstance().userAvatar, autoEnableCamera: CallManager.sharedInstance().camOn, autoEnableMicrophone: CallManager.sharedInstance().micOn) else { return; }
        
        
        //  Converted to Swift 5.1 by Swiftify v5.1.33915 - https://objectivec2swift.com/
        joinButton.isEnabled = false
        indicator.isHidden = false
        //TODO kHLDataCenterID_EU1 kHLDataCenterID_US1
        HLClientSwift.shared.startCall(call: call, viewController: self, dataCenterId: kHLDataCenterID_US1).then({ value in
            print("The call has started")
        }).catch({ error in
            print("Cannot start the call:\(error)")
        }).always({
            self.indicator.isHidden = true
            self.joinButton.isEnabled = true
        })
                    
    }
    
    func _setupTheme () {
        let theme: HLTheme = HLTheme()
        theme.setImage(kHLImageMainMenuTorchOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageMainMenuTorchOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageMainMenu, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageMainMenuInvite, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCameraMenuPhotoOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCameraMenuFreezeOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCameraMenuFreezeOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCameraMenuSwitchCamera, image: UIImage(named: "Lightning"))
        //mic
        theme.setImage(kHLImageMicOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageMicOff, image: UIImage(named: "Lightning"))
        
        theme.setImage(kHLImageTelestrationMenuArrowOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuArrowOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuPenOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuPenOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuPushPinOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuPushPinOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenu3DArrowOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenu3DArrowOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenu3DPenOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenu3DPenOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenu3DPushPinOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenu3DPushPinOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestration3DIndicator, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestration3DIconBorder, image: UIImage(named: "Lightning"))
        //clear
        theme.setImage(kHLImageTelestrationUndo, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationClearAll, image: UIImage(named: "Lightning"))
        //end call
        theme.setImage(kHLImageEndCall, image: UIImage(named: "Lightning"))
        //screen capture
        theme.setImage(kHLImageScreenCaptureUnpressed, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageScreenCaptureTransition, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageScreenCapturePressed, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageDefaultProfileIcon, image: UIImage(named: "Lightning"))
        //audio plus mode
        theme.setImage(kHLImageAudioPlusMode, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCallQualityAudio, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCallQualityHD, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCallQualitySD, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCameraDisabled, image: UIImage(named: "Lightning"))
        
        //chat
        theme.setImage(kHLImageChatGroupAvatar, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageChatMoreAction, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageChatSend, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageChatPlaceholder, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageChatMenu, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageChatAttachment, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageChatCamera, image: UIImage(named: "Lightning"))
        
        theme.setImage(kHLImageBannerRote, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageActionBarMergeNormal, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageActionBarMergeSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageActionBarShareNormal, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageActionBarShareSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotation3DColorBorderRed, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotation3DColorBorderYellow, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotation3DColorBorderGreen, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotation3DColorBorderBlue, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorBorderRed, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorBorderYellow, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorBorderGreen, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorBorderBlue, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorRed, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorYellow, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorGreen, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorBlue, image: UIImage(named: "Lightning"))
        
        theme.setImage(kHLIconAnnotationColorRedSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorYellowSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorGreenSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLIconAnnotationColorBlueSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageScreenCapture, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageEndCap, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTick, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCameraMenuCameraOn, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageCameraMenuCameraOff, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuFile, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuFileSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuGallery, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuGallerySelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMyCamera, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuTakePhoto, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuTakePhotoSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuVideo, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuWhiteBoard, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuWhiteBoardSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageChevron, image: UIImage(named: "Lightning"))
        
        
        //16.4
        theme.setImage(kHLImageShareMenuKnowledge, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageShareMenuKnowledgeSelected, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageQuickKnowledge, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageQuickKnowledgeHighlight, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageQuickKnowledgeDelete, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageQuickKnowledgeResize, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageQuickKnowledgeSelection, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageQuickKnowledgeSelectionHighlight, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuPushPinNormal, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuCurveNormal, image: UIImage(named: "Lightning"))
        theme.setImage(kHLImageTelestrationMenuArrowNormal, image: UIImage(named: "Lightning"))
        
        HLClientSwift.shared.setTheme(theme: theme);
    }
    
    func hlCall(_ call: HLCall!, didEndWithReason reason: String!) {
        NSLog("The call has ended: %@", call.sessionId)
    }
    
    func hlCall(_ call: HLCall!, didCaptureScreen image: UIImage!) {
        NSLog("screen captured.")
        self.imagePreview.image = image
    }
    
    internal func hlCallCanShareKnowledge(_ call: HLGenericCall!) -> FBLPromise<AnyObject>! {
        let promise = Promise<AnyObject>.pending()
        promise.fulfill(true as AnyObject)
        return promise.asObjCPromise()
    }
    
    internal func hlCall(_ call: HLGenericCall!, needShareKnowledgeWithUserInfo userInfo: [String : Any]! = [:]) -> FBLPromise<AnyObject>! {
        return self.hlCall(call, userInfo, DocumentManager.supportedShareKnowledgeTypes())
    }

    internal func hlCallSupportKnowledgeOverlay(_ call: HLGenericCall!) -> FBLPromise<AnyObject>! {
        let promise = Promise<AnyObject>.pending()
        promise.fulfill(true as AnyObject)
        return promise.asObjCPromise()
    }
        
    internal func hlCall(_ call: HLGenericCall!, needKnowledgeOverlayWithUserInfo userInfo: [String : Any]! = [:]) -> FBLPromise<AnyObject>! {
        return self.hlCall(call, userInfo, DocumentManager.supportedKnowledgeOverlayTypes())
    }
    
    internal func hlCall(_ call: HLGenericCall!, _ userInfo: [String : Any]!, _ supportedType:[UTType]) -> FBLPromise<AnyObject>! {
        
        let promise = Promise<AnyObject>.pending()
        let presentingViewController = userInfo[kHLCallPluginPresentingViewController] as! UIViewController
        if let sharedDocManager = self.sharedDocManager {
            sharedDocManager.tearDown()
        }
        self.sharedDocManager = DocumentManager.init(viewController: presentingViewController)
        self.sharedDocManager?.selectDocument(withType: supportedType, read: { [weak self] url in
            if let url = url {
                let dic = [kHLCallPluginURL : url]
                promise.fulfill(dic as AnyObject)
            } else {
                self?.sharedDocManager?.tearDown()
            }
        }, completionBlock: { [weak self] error in
            if error is Error {
                promise.reject((error as AnyObject) as! Error)
                self?.sharedDocManager?.tearDown()
            }
        })
        return promise.asObjCPromise();
    }
}
