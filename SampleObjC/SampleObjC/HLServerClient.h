/* -*- Mode:objc; c-basic-offset: 4; indent-tabs-mode: nil; -*- */
/*
 **
 ** Copyright (c) 2020 VIPAAR, LLC all rights reserved.
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
//  HLServerClient.h
//  SampleObjC
//
//  Created by Hale Xie on 2020/1/19.
//Copyright © 2020 Helplightning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLPromises.h"

@interface HLServerClient : NSObject
@property (nonatomic) NSURL* serverURL;
+ (instancetype) sharedInstance;

- (FBLPromise*) authenticateWithEmail:(NSString *)email;

- (FBLPromise*) createCallWithAuthToken:(NSString*)authToken contactEmail:(NSString*)contactEmail;

- (FBLPromise*) retreiveCallWithAuthToken:(NSString*)authToken pin:(NSString*)pin;

@end
