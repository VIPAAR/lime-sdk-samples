//
//  DocumentManager.h
//  SampleObjC
//
//  Created by xiaowei chang on 2023/8/28.
//  Copyright © 2023 Helplightning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SharedDocTaskBlock)(NSURL*);
typedef void (^SharedDocCompletionBlock)(id);
extern NSInteger const kSharedDocManagerErrorUserCancel;
extern NSInteger const kSharedDocManagerErrorGeneric;
extern NSInteger const kSharedDocManagerErrorUserCancel;

@interface DocumentManager : NSObject
@property (nonatomic) UIUserInterfaceStyle userInterfaceStyle;
@property (nonatomic, readonly) NSURL* importDocURL;

+ (NSArray<UTType*>*) supportedPDFType;
+ (NSArray<UTType*>*) supportedShareKnowledgeTypes;
+ (NSArray<UTType*>*) supportedKnowledgeOverlayTypes;
    
- (instancetype) initWithViewController:(UIViewController*)presentingController;

- (void) selectDocumentWithType:(NSArray<UTType *>*)allowedUTIs readBlock:(SharedDocTaskBlock)readBlock
                completionBlock:(SharedDocCompletionBlock)completionBlock;
- (void) selectShareKnowledgeWithReadBlock:(SharedDocTaskBlock)readBlock
                     completionBlock:(SharedDocCompletionBlock)completionBlock;
- (void) selectKnowledgeOverlayWithReadBlock:(SharedDocTaskBlock)readBlock
                             completionBlock:(SharedDocCompletionBlock)completionBlock;

- (void) tearDown;

@end

