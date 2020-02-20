//
//  ViewController.swift
//  SampleSwift
//
//  Created by Hale Xie on 2019/11/18.
//  Copyright © 2019 Helplightning. All rights reserved.
//

import UIKit
import HLSDK
import HLSDKSwift

let HL_SESSION_ID       = ("c6d553ed-1feb-4e1c-b1a7-e85a5de04c31")
let HL_SESSION_TOKEN    = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdHRyaWJ1dGVzIjpbIm9yZ2FuaXplciJdLCJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDYxODY3NTgsImlhdCI6MTU3NDY1MDc1OCwiaXNzIjoiR2hhemFsIiwianRpIjoiYTYwMDlmODQtODg5NS00OWY2LWFlZjktNDJmNTRkNjMwZTVmIiwibWV0YSI6e30sIm5iZiI6MTU3NDY1MDc1Nywib3JpZ2luYXRvciI6MTYsInBlbSI6eyJzZXNzaW9uIjoyNTU5fSwicmVjb3JkaW5nX3BvbGljeSI6ImFsd2F5c19vbiIsInN1YiI6IlNlc3Npb246YzZkNTUzZWQtMWZlYi00ZTFjLWIxYTctZTg1YTVkZTA0YzMxIiwidHlwIjoiYWNjZXNzIiwidmVyIjoiMTAwIn0.u5ziXTqbTAMBCgx9MZ8JkMcgCvxhKDdN3wsSW4camPw")
let HL_GSS_URL          = ("gss+ssl://containers-asia.helplightning.net:32773")

let HL_USER1_TOKEN      = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDYxODY2NDUsImlhdCI6MTU3NDY1MDY0NSwiaXNzIjoiR2hhemFsIiwianRpIjoiNDNhNzYzNTAtZjUxYi00ZDIwLTlmMDItMGQ1Yjc1OGIyMzNjIiwibWV0YSI6e30sIm5iZiI6MTU3NDY1MDY0NCwicGVtIjp7InVzZXIiOjEwOTg2NTI3MDA0ODU1OH0sInN1YiI6IlVzZXI6MTUiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.PVskE0v8fYMYR62ixhJnkK93I5piP1WCtk2I3ZpkwQM")
let HL_USER1_NAME       = ("Small User12")
let HL_USER1_AVATAR     = ("")

let HL_USER2_TOKEN      = ("eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJHaGF6YWwiLCJleHAiOjE2MDYxODY2NzcsImlhdCI6MTU3NDY1MDY3NywiaXNzIjoiR2hhemFsIiwianRpIjoiNmRmYWExYWYtMDk5Yy00YjYzLWJjMGEtOTkyOGM3NGFlMGQ2IiwibWV0YSI6e30sIm5iZiI6MTU3NDY1MDY3NiwicGVtIjp7InVzZXIiOjEwOTg2NTI3MDA0ODU1OH0sInN1YiI6IlVzZXI6MTYiLCJ0eXAiOiJhY2Nlc3MiLCJ2ZXIiOiIxMDAifQ.MA8ODeG-0UXKJ0XJW6lNnKhqlaSTPfuAt2ExASPhl9E")
let HL_USER2_NAME       = ("Small User13")

let HL_USER2_AVATAR     = ("")

class ViewController: UIViewController, UITabBarDelegate, HLClientDelegate {
    @IBOutlet weak var sessionId: UITextView?
    @IBOutlet weak var sessionToken: UITextView?
    @IBOutlet weak var userToken: UITextView?
    @IBOutlet weak var userName: UITextView?
    @IBOutlet weak var gssURL: UITextView?
    @IBOutlet weak var userAvatar: UITextView?
    @IBOutlet weak var userTab: UITabBar?
    @IBOutlet weak var joinIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sessionId?.text = HL_SESSION_ID;
        self.sessionToken?.text = HL_SESSION_TOKEN;
        self.userToken?.text = HL_USER1_TOKEN;
        self.userName?.text = HL_USER1_NAME;
        self.userAvatar?.text = HL_USER1_AVATAR;
        self.gssURL?.text = HL_GSS_URL;
        self.userTab?.selectedItem = self.userTab?.items?.first;
        HLClientSwift.shared.delegate = self;
    }
    
    @IBAction func cancelCall(_ sender: Any) {
        let promise = HLClientSwift.shared.stopCurrentCall()
        promise.then { (bool) in
            NSLog("The call has been stopped")
        }
        promise.catch { (error) in
            self.joinIndicator.stopAnimating()
            NSLog("Cannot stop the call:%@", error.localizedDescription);
        }
        
    }
    
    @IBAction func joinCall(_ sender: Any) {
        guard let call = HLCall(sessionId:self.sessionId!.text,
                                sessionToken: self.sessionToken!.text,
                                userToken: self.userToken!.text,
                                gssUrl:  self.gssURL!.text,
                                helplightningAPIKey: "",
                                localUserDisplayName: self.userName?.text,
                                localUserAvatarUrl: self.userAvatar?.text) else { return; }
        self.joinIndicator.startAnimating()
        
        let promise = HLClientSwift.shared.startCall(call: call, viewController: self)
        promise.then { (bool) in
            NSLog("The call has started")
        }
        promise.catch { (error) in
            self.joinIndicator.stopAnimating()
            NSLog("Cannot start the call:%@", error.localizedDescription);
        }
        
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.firstIndex(of: item) {
            if (index == 1) {
                self.userToken?.text = HL_USER2_TOKEN
                self.userName?.text = HL_USER2_NAME
                self.userAvatar?.text = HL_USER2_AVATAR
            } else {
                self.userToken?.text = HL_USER1_TOKEN
                self.userName?.text = HL_USER1_NAME
                self.userAvatar?.text = HL_USER1_AVATAR
            }
        }
    }
    
    func call(_ call: HLCall!, didEndWithReason reason: String!) {
        self.joinIndicator.stopAnimating()
        NSLog("The call has ended: %@", call.sessionId)
    }
    
    func call(_ call: HLCall!, didCaptureScreen image: UIImage!) {
        NSLog("screen captured")
    }
}


