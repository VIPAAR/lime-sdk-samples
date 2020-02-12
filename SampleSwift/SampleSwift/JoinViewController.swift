//
//  JoinViewController.swift
//  SampleSwift
//
//  Created by Hale Xie on 2020/1/21.
//  Copyright © 2020 Helplightning. All rights reserved.
//

import UIKit
import HLSDK
import HLSDKSwift

let kDefaultUserName = "small_u13";
let kHLApiKey = "9BoKBM2MQ27nPdHW0XckRw";

class JoinViewController: UIViewController, HLClientDelegate {
    @IBOutlet private var gssServerURLTextField: UITextField!
    @IBOutlet private var sessionIDTextField: UITextField!
    @IBOutlet private var sessionPINTextField: UITextField!
    @IBOutlet private var sessionTokenTextView: UITextView!
    @IBOutlet private var userAvatarTextField: UITextField!
    @IBOutlet private var userNameTextField: UITextField!
    @IBOutlet private weak var joinButton: UIButton!
    @IBOutlet private weak var indicator: UIActivityIndicatorView!
    @IBOutlet private weak var themColorPicker: UISegmentedControl!
    @IBOutlet private weak var imagePreview: UIImageView!
    @IBOutlet private weak var camOnSwitch: UISwitch!
    @IBOutlet private weak var micOnSwitch: UISwitch!
    
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
        HLClientSwift.shared.startCall(call: call, viewController: self).then({ value in
            print("The call has started")
        }).catch({ error in
            print("Cannot start the call:\(error)")
        }).always({
            self.indicator.isHidden = true
            self.joinButton.isEnabled = true
        })

    }
    
    func _setupTheme () {
        let index = themColorPicker.selectedSegmentIndex
        var theme: HLTheme? = nil
        switch index {
            case 1:
                theme = HLTheme()
                theme?.setColor(kHLMainColor, color: UIColor.darkGray)
            case 2:
                theme = HLTheme()
                theme?.setColor(kHLMainColor, color: UIColor.orange)
            case 3:
                theme = HLTheme()
                theme?.setColor(kHLMainColor, color: UIColor.purple)
                //main menu
                theme?.setImage(kHLImageMainMenuDocumentOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageMainMenuDocumentOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageMainMenuTorchOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageMainMenuTorchOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageMainMenu, image: UIImage(named: "Lightning"))

                //mode
                theme?.setImage(kHLImageModeMenuFaceToFaceOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageModeMenuFaceToFaceOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageModeMenuReceiverOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageModeMenuReceiverOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageModeMenuGiverOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageModeMenuGiverOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuPhotoOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuPhotoOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuFreezeOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuFreezeOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuCameraOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuSwitchCamera, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuFrontCameraOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuFrontCameraOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuBackCameraOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageCameraMenuBackCameraOff, image: UIImage(named: "Lightning"))

                //mic
                theme?.setImage(kHLImageMicOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageMicOff, image: UIImage(named: "Lightning"))

                //telestration
                theme?.setImage(kHLImageTelestrationMenuColorUnselected, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageTelestrationMenuColorSelected, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageTelestrationMenuArrowOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageTelestrationMenuArrowOff, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageTelestrationMenuPenOn, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageTelestrationMenuPenOff, image: UIImage(named: "Lightning"))

                //clear
                theme?.setImage(kHLImageTelestrationUndo, image: UIImage(named: "Lightning"))
                theme?.setImage(kHLImageTelestrationClearAll, image: UIImage(named: "Lightning"))

                //end call
                theme?.setImage(kHLImageEndCall, image: UIImage(named: "Lightning"))
            default:
                break
        }
        HLClientSwift.shared.setTheme(theme: theme);
    }

    func call(_ call: HLCall!, didEndWithReason reason: String!) {
        NSLog("The call has ended: %@", call.sessionId)
    }
    
    func call(_ call: HLCall!, didCaptureScreen image: UIImage!) {
        NSLog("screen captured.")
        self.imagePreview.image = image
    }
}
