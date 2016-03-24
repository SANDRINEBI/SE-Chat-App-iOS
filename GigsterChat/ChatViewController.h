//
//  ChatViewController.h
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/16/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JSQMessagesViewController/JSQMessagesViewController.h>


@class ChatViewController;

@protocol ChatViewControllerDelegate <NSObject>

- (void)didDismissChatViewController:(ChatViewController *)vc;

@end

@interface ChatViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (weak, nonatomic) id<ChatViewControllerDelegate> delegateModal;

@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSDictionary *info;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;
- (void)closePressed:(UIBarButtonItem *)sender;
- (void)setChatInfo:(NSDictionary*)info;

@end
