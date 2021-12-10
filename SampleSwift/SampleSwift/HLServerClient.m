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
//  HLServerClient.m
//  SampleObjC
//
//  Created by Hale Xie on 2020/1/19.
//Copyright © 2020 Helplightning. All rights reserved.
//

#import "HLServerClient.h"

NSString* const kHLAPIKey = @"[YOUR_HL_API_KEY]";

NSErrorDomain const kSampleErrorDomain = @"SampleObjC";
NSString* const kHTTPMethodGet = @"GET";
NSString* const kHTTPMethodPost = @"POST";
NSString* const kHTTPMethodDelete = @"DELETE";
NSString* const kHTTPMethodPut = @"PUT";
NSTimeInterval const kHTTRequestTimeout = 30.0;

@interface  HLServerClient()
@property (nonatomic) NSURLSession* session;
@property (nonatomic) NSOperationQueue* queue;
@end


@implementation HLServerClient

+ (instancetype) sharedInstance {
    static HLServerClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init {
    self = [super init];
    if (self) {
        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 1;
        
        NSURLSessionConfiguration* sc = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sc.allowsCellularAccess = YES;
        sc.networkServiceType = NSURLNetworkServiceTypeDefault;
        NSDictionary* headers = @{
            @"x-helplightning-api-key": kHLAPIKey,
            @"content-type": @"application/json"
        };
        sc.HTTPAdditionalHeaders = headers;
        _session = [NSURLSession sessionWithConfiguration:sc delegate:nil delegateQueue:_queue];
    }
    return self;
}

- (FBLPromise*) authenticateWithEmail:(NSString *)email {
    if (!email) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-1 userInfo:nil]];
    }
    
    NSDictionary* params = @{@"email" : email};
    return [self _sendRequestToEndPoint:@"/auth" withParams:params HTTPMethod:kHTTPMethodGet headers:nil body:nil].then(^id(id result) {
        if (result && [result isKindOfClass:NSDictionary.class]) {
            return result[@"token"];
        }
        return [NSError errorWithDomain:kSampleErrorDomain code:-2 userInfo:nil];
    });
}

- (FBLPromise*) createCallWithAuthToken:(NSString*)authToken contactEmail:(NSString*)contactEmail {
    if (!authToken) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-1 userInfo:nil]];
    }
    
    if (!contactEmail) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-2 userInfo:nil]];
    }
    NSDictionary* headers = @{@"authorization" : authToken};
    NSDictionary* body = @{@"contact_email" : contactEmail};
    return [self _sendRequestToEndPoint:@"/session" withParams:nil HTTPMethod:kHTTPMethodPost headers:headers body:body];
}

- (FBLPromise*) retreiveCallWithAuthToken:(NSString*)authToken pin:(NSString*)pin {
    if (!authToken) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-1 userInfo:nil]];
    }
    
    if (!pin) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-2 userInfo:nil]];
    }
    NSDictionary* headers = @{@"authorization" : authToken};
    NSDictionary* params = @{@"sid" : pin};
    return [self _sendRequestToEndPoint:@"/session" withParams:params HTTPMethod:kHTTPMethodGet headers:headers body:nil];
}

- (FBLPromise*) _sendRequestToEndPoint:(NSString*)endPoint
                            withParams:(NSDictionary<NSString*, NSString*>*)params
                            HTTPMethod:(NSString*)httpMethod
                               headers:(NSDictionary<NSString*, NSString*>*)headers
                                  body:(id)body {
    NSURLSession* session = self.session;
    NSURL* serverURL = self.serverURL;
    
    if (!session) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-1 userInfo:nil]];
    }
    
    if (!serverURL) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-2 userInfo:nil]];
    }
    
    NSURLComponents* comps = [NSURLComponents componentsWithURL:serverURL resolvingAgainstBaseURL:YES];
    comps.path = endPoint;
    if (params) {
        NSMutableArray<NSURLQueryItem*>* queryItems = [NSMutableArray arrayWithCapacity:params.count];
        [params enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL* stop) {
            NSURLQueryItem* item = [NSURLQueryItem queryItemWithName:key value:value];
            [queryItems addObject:item];
        }];
        comps.queryItems = queryItems;
    }
    // https://developer.apple.com/documentation/foundation/nsurlcomponents/1407752-queryitems?language=objc
    // NSURLQueryItem will NOT encode '+'
    // Let's encode '+' in the query parameters
    NSCharacterSet* plusSet = [[NSCharacterSet characterSetWithCharactersInString:@"+"] invertedSet];
    NSString* queryString = comps.percentEncodedQuery;
    comps.percentEncodedQuery = [queryString stringByAddingPercentEncodingWithAllowedCharacters:plusSet];
    
    NSURL* url = comps.URL;
    if (!url) {
        return [FBLPromise resolvedWith:[NSError errorWithDomain:kSampleErrorDomain code:-3 userInfo:nil]];
    }
    
    FBLPromise* promise = [FBLPromise pendingPromise];
    
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url
                                                                cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                            timeoutInterval:kHTTRequestTimeout];
    httpMethod = httpMethod ? httpMethod : kHTTPMethodGet;
    request.HTTPMethod = httpMethod;
    if (headers) {
        [headers enumerateKeysAndObjectsUsingBlock:^(NSString* key, NSString* value, BOOL* stop) {
            [request setValue:value forHTTPHeaderField:key];
        }];
    }
    
    if (body) {
        NSError* jsonError = nil;
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&jsonError];
        if (jsonError) {
            [promise reject:jsonError];
            return promise;
        }
        
    }
   
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData* data, NSURLResponse* response, NSError* error) {
        if (error) {
            [promise reject:error];
        } else {
            if ([self _isSuccessfulResponse:response]) {
                NSError* jsonError = nil;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                if (jsonError) {
                    [promise reject:jsonError];
                } else {
                    [promise fulfill:json];
                }
            } else {
                [promise reject:[NSError errorWithDomain:kSampleErrorDomain code:-3 userInfo:nil]];
            }
        }
    }];
    [task resume];
    
    return promise;
}

- (BOOL) _isSuccessfulResponse:(NSURLResponse*)response {
    //See https://developer.mozilla.org/en-US/docs/Web/HTTP/Status#Successful_responses
    if ([response isKindOfClass:NSHTTPURLResponse.class]) {
        NSHTTPURLResponse* r = (NSHTTPURLResponse*)response;
        return (r.statusCode >= 200 && r.statusCode < 300);
    }
    return YES;
}
@end
