/*
 **
 ** Copyright (c) 2024 VIPAAR, LLC all rights reserved.
 **
 ** Any commercial use of this software is subject to license
 ** agreement. Disclosure of the information contained herein to any
 ** third parties is prohibited without prior written consent. This
 ** software is subject to US export control regulations.
 **
 ** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 ** ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 ** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 ** FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 ** AUTHORS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 ** INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 ** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 ** SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 ** INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 ** WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 ** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 ** THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 **
 */
//
//  HLClientWrapper.swift
//  SampleSwift
//
//  Created by Hale Xie on 2024/7/15.
//  Copyright © 2024 Helplightning. All rights reserved.
//
import UIKit
import HLSDK
import HLSDKCommon
import Promises

public class HLClientWrapper: NSObject {
    public static let shared = HLClientWrapper()
    
    public weak var delegate : HLClientDelegate? {
        get {
            return HLClient.sharedInstance.delegate
        }
        set {
            HLClient.sharedInstance.delegate = newValue;
        }
    }
    
    private override init() {
        
    }

    public func startCall(call : HLCall, viewController : UIViewController, dataCenterId: HLDataCenterID) -> Promise<AnyObject> {
        return Promise(HLClient.sharedInstance.start(call, withPresenting: viewController, dataCenter:dataCenterId));
    }
    
    public func startCall(call : HLCall, viewController : UIViewController) -> Promise<AnyObject> {
        return Promise(HLClient.sharedInstance.start(call, withPresenting: viewController));
    }
    
    public func stopCurrentCall() -> Promise<AnyObject> {
        return Promise(HLClient.sharedInstance.stopCurrentCall());
    }
    
    public func setTheme(theme: HLTheme?) {
        HLClient.sharedInstance.setTheme(theme);
    }
    
    public func clearTheme() {
        HLClient.sharedInstance.clearTheme();
    }
 }
