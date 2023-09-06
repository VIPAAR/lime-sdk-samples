//
//  DocumentManager.m
//  SampleObjC
//
//  Created by xiaowei chang on 2023/8/28.
//  Copyright © 2023 Helplightning. All rights reserved.
//

#import "DocumentManager.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

NSErrorDomain const kSharedDocManagerErrorDomain = @"kSharedDocManagerErrorDomain";
NSInteger const kSharedDocManagerErrorGeneric = 1;
NSInteger const kSharedDocManagerErrorUserCancel = 2;

@interface DocumentManager () <UIDocumentPickerDelegate>
@property (nonatomic, readwrite) NSURL* importDocURL;
@property (nonatomic, readwrite) NSURL* exportDocURL;
@property (nonatomic, weak) UIViewController* presentingViewController;
@property (nonatomic, copy) SharedDocCompletionBlock completionBlock;
@property (nonatomic, copy) SharedDocTaskBlock taskBlock;
@end

@implementation DocumentManager
- (instancetype) initWithViewController:(UIViewController*)presentingController {
    self = [super init];
    if (self) {
        self.presentingViewController = presentingController;
        self.userInterfaceStyle = UIUserInterfaceStyleUnspecified;
    }
    return self;
}

- (void) dealloc {
    [self tearDown];
}

- (void) tearDown {
    self.completionBlock = nil;
    self.taskBlock = nil;
    self.presentingViewController = nil;
    NSFileManager* fm = NSFileManager.defaultManager;
    if (self.importDocURL) {
        [fm removeItemAtURL:self.importDocURL error:nil];
        self.importDocURL = nil;
    }
}

- (void) selectShareKnowledgeWithReadBlock:(SharedDocTaskBlock)readBlock
                     completionBlock:(SharedDocCompletionBlock)completionBlock {
    NSArray<UTType*>* utTypes = [self.class supportedShareKnowledgeTypes];
    [self selectDocumentWithType:utTypes readBlock:readBlock completionBlock:completionBlock];
}

- (void) selectKnowledgeOverlayWithReadBlock:(SharedDocTaskBlock)readBlock
                             completionBlock:(SharedDocCompletionBlock)completionBlock {
    NSArray<UTType*>* utTypes = [self.class supportedKnowledgeOverlayTypes];
    [self selectDocumentWithType:utTypes readBlock:readBlock completionBlock:completionBlock];
}

- (void) selectPDFWithReadBlock:(SharedDocTaskBlock)readBlock
                     completionBlock:(SharedDocCompletionBlock)completionBlock {
    NSArray<UTType*>* utTypes = [self.class supportedPDFType];
    [self selectDocumentWithType:utTypes readBlock:readBlock completionBlock:completionBlock];
}

- (void) selectDocumentWithType:(NSArray <UTType *>*)allowedUTIs readBlock:(SharedDocTaskBlock)readBlock
                     completionBlock:(SharedDocCompletionBlock)completionBlock {
    if (!self.presentingViewController) {
        NSLog(@"No presentingViewController");
        if (completionBlock) {
            completionBlock([NSError errorWithDomain:kSharedDocManagerErrorDomain
                                                code:kSharedDocManagerErrorGeneric
                                            userInfo:@{ NSLocalizedDescriptionKey : @"No presentingViewController" }]);
        }
        return;
    }
    
    UIDocumentPickerViewController* dpvc = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:allowedUTIs asCopy:YES];
    dpvc.overrideUserInterfaceStyle = self.userInterfaceStyle;
    self.completionBlock = completionBlock;
    self.taskBlock = readBlock;
    dpvc.allowsMultipleSelection = NO;

    dpvc.delegate = self;
    dpvc.editing = NO;
    dpvc.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    if (self.presentingViewController.presentedViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self.presentingViewController presentViewController:dpvc animated:YES completion:nil];
        }];
    } else {
        [self.presentingViewController presentViewController:dpvc animated:YES completion:nil];
    }
}

#pragma mark UIDocumentPickerDelegate

- (void) documentPicker:(UIDocumentPickerViewController*)controller didPickDocumentsAtURLs:(NSArray<NSURL *>*)urls {
    [self _processImportedDoc:urls.firstObject];
    SharedDocCompletionBlock completionBlock = self.completionBlock;
    if (completionBlock) {
        completionBlock(urls.firstObject);
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    SharedDocCompletionBlock completionBlock = self.completionBlock;
    if (completionBlock) {
        completionBlock([NSError errorWithDomain:kSharedDocManagerErrorDomain
                                            code:kSharedDocManagerErrorUserCancel
                                        userInfo:@{ NSLocalizedDescriptionKey :@"User cancel document picking" }]);
    }
}

- (void)_processImportedDoc:(NSURL*)url {
    if (!url) {
        NSLog(@"No url");
        return;
    }
    
    self.importDocURL = url;
    SharedDocTaskBlock taskBlock = self.taskBlock;
    if (taskBlock) {
        taskBlock(url);
    }
}

#pragma mark - Static Methods
+ (NSArray<UTType*>*) supportedPDFType {
    NSArray<UTType*>* utTypes = @[UTTypePDF];
    return utTypes;
}

+ (NSArray<UTType*>*) supportedShareKnowledgeTypes {
    NSArray<UTType*>* utTypes = @[UTTypePDF, UTTypeImage];
    return utTypes;
}

+ (NSArray<UTType*>*) supportedKnowledgeOverlayTypes {
    NSArray<UTType*>* utTypes = @[UTTypeImage];
    return utTypes;
}
@end
