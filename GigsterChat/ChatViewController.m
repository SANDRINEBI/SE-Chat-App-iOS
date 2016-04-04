//
//  ChatViewController.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/16/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import "ChatViewController.h"
#import "API.h"

#import <JSQMessagesViewController/JSQMessagesViewController.h>
#import <JSQMessagesViewController/JSQMessage.h>
#import <JSQMessagesViewController/JSQMessagesBubbleImageFactory.h>
#import <JSQMessagesViewController/JSQMessagesAvatarImageFactory.h>
#import <NSStringEmojize/NSString+Emojize.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <FrameAccessor/FrameAccessor.h>
#import <Firebase/Firebase.h>

@interface ChatViewController ()

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.messages = [NSMutableArray new];
    
/*    NSString *senderId = [[API shared] currentUser][@"_id"];
    NSString *senderName = [[API shared] currentUser][@"name"];
    
    [self.messages addObject:[JSQMessage messageWithSenderId:@"2" displayName:@"Erin" text:@"Hey Catherine - Can you please creat the proposal for this? Want to get it kicked off ASAP. Here's the spec. ht tp://docs.google.com/somefreakingurl"]];
    [self.messages addObject:[JSQMessage messageWithSenderId:senderId displayName:senderName text:@"Wonderful, thanks for sharing and I'll get started on this proposal. I'll ping you when its read"]];
    [self.messages addObject:[JSQMessage messageWithSenderId:senderId displayName:senderName text:@"We're ready to go! Take a look at the proposal"]];
    [self.messages addObject:[JSQMessage messageWithSenderId:@"2" displayName:@"Erin" text:@"How'd you do that so fast? You're miracle workers!"]];*/
    
//    self.senderId = @"1";
//    self.senderDisplayName = @"Hoan";

    UIImage *phoneImage = [[UIImage imageNamed:@"phone-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *phoneButton = [[UIButton alloc] init];
    [phoneButton setImage:phoneImage forState:UIControlStateNormal];
    phoneButton.tintColor = [UIColor lightGrayColor];
    
    self.inputToolbar.contentView.leftBarButtonItem = phoneButton;
    self.showLoadEarlierMessagesHeader = NO;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-gear"] style:UIBarButtonItemStylePlain target:self action:@selector(onSettings:)];

    UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
    [button addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(onInfo:)];

    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
//                                                                              style:UIBarButtonItemStyleBordered
//                                                                             target:self
//                                                                             action:@selector(receiveMessagePressed:)];
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
//    [UIMenuController sharedMenuController].menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action"
//                                                                                      action:@selector(customAction:)] ];
//    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    [self loadFromFirebase];
}


- (void)loadFromFirebase {
//    NSString *chatUrl = [NSString stringWithFormat:@"https://gigster-dev.firebaseio.com/messages/%@", self.info[@"_id"]]; // TEST
    NSString *chatUrl = [NSString stringWithFormat:@"https://gigster-debo.firebaseio.com/messages/%@", self.info[@"_id"]]; // PROD
    NSLog(@"fburl = %@", chatUrl);
    Firebase *ref = [[Firebase alloc] initWithUrl:chatUrl];
    [ref observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        id obj = snapshot.value;
        
        if([obj[@"type"] isEqualToString:@"text"]) {
            NSLog(@"text child added, %@", obj);
            
            NSString *text = [obj[@"text"] emojizedString];
            NSString *displayName = obj[@"firstName"];
            NSString *toClient = [obj[@"toClient"] boolValue] ? @"1" : @"0";
            if(!displayName || displayName == [NSNull null]) displayName=@" ";
            
            NSLog(@"text = %@", text);
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([obj[@"timestamp"] doubleValue]/1000.0f)];
            
//            JSQMessage *message = [JSQMessage messageWithSenderId:toClient displayName:displayName text:text];
            JSQMessage *message = [[JSQMessage alloc] initWithSenderId:toClient senderDisplayName:displayName date:date text:text];

            [self.messages addObject:message];
            [self.collectionView reloadData];
            [self scrollToBottomAnimated:YES];
        } else if([obj[@"type"] isEqualToString:@"wireframe"]) {
            NSLog(@"NEW wireframe %@", obj);
        } else if([obj[@"type"] isEqualToString:@"phonecall"]) {
            NSLog(@"NEW phonecall %@", obj);
        } else {
            NSLog(@"skipping, %@", obj[@"type"]);
        }
    }];
}

- (void)onInfo:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://app.gigster.com"]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
}


#pragma mark - Actions
- (void)closePressed:(UIBarButtonItem *)sender {
    [self.delegateModal didDismissChatViewController:self];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    NSString *realText = [text unemojizedString];
    NSLog(@"sending: %@", realText);
//    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
//                                             senderDisplayName:senderDisplayName
//                                                          date:date
//                                                          text:text];
//    
//    [self.messages addObject:message];
    
    NSDictionary *params = @{@"type": @"text", @"toClient": @"1", @"text": realText, @"isWireframe": @"0", @"showAuto": @"0", @"isProposalReady": @"0"};
    
    [[API shared] sendMessage:params toGig:self.info[@"_id"] callback:^(id response, NSError *error) {
        NSLog(@"%@ %@", response, error);
    }];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:nil
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Send photo", @"Send location", @"Send video", nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.messages[indexPath.row];
}

- (NSInteger)collectionView:(JSQMessagesCollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.messages count];
}

- (NSString *)senderDisplayName {
    return [[API shared] currentUser][@"name"];
}

- (NSString *)senderId {
    return @"1";// toClient=1 then we sent it
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath {
    return;
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor colorWithRed:97/255.0 green:175/255.0 blue:255/255.0 alpha:1.0]];
    }
    
    return [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:231/255.0 green:230/255.0 blue:236/255.0 alpha:1.0]];;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage new] diameter:1];
    return nil;
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor whiteColor];
        }
        else {
            cell.textView.textColor = [UIColor blackColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}


//- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
//                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    /**
//     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
//     */
//    
//    /**
//     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
//     *  The other label height delegate methods should follow similarly
//     *
//     *  Show a timestamp for every 3rd message
//     */
//    if (indexPath.item % 3 == 0) {
//        return kJSQMessagesCollectionViewCellLabelHeightDefault;
//    }
//    
//    return 0.0f;
//}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.messages objectAtIndex:indexPath.item];
//    if ([[currentMessage senderDisplayName] isEqualToString:self.senderDisplayName]) {
//        return 0.0f;
//    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderDisplayName] isEqualToString:[currentMessage senderDisplayName]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}


- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
//    if ([message.senderDisplayName isEqualToString:self.senderDisplayName]) {
//        return nil;
//    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderDisplayName] isEqualToString:message.senderDisplayName]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}




- (void)setChatInfo:(NSDictionary*)info {
    _info = info;
    
    self.navigationItem.title = info[@"name"];
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar
       didPressLeftBarButton:(UIButton *)sender {
    NSLog(@"mofofof");
    [self onPhone:nil];
}

- (void)onPhone:(id)sender {
//    [UIAlertView show]
    NSLog(@"phone pressed");
    
    if(self.info[@"poster"][@"phone"] && self.info[@"poster"][@"phone"] != [NSNull null] && ![self.info[@"poster"][@"phone"] isEqualToString:@""]) {
        NSLog(@"phone %@", self.info[@"poster"][@"phone"]);
        NSString *realPhone = [NSString stringWithFormat:@"+%@",self.info[@"poster"][@"phone"]];
        NSString *message   = [NSString stringWithFormat:@"Do you want to call %@?", realPhone];
        NSString *phoneUrl  = [NSString stringWithFormat:@"tel://%@", realPhone];
        
        [UIAlertView showWithTitle:@"Call?" message:message cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Call"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
            if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Call"]) {
                NSLog(@"call");
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneUrl]];
            }
        }];
        
    } else {
        NSLog(@"no phone");
        [UIAlertView showWithTitle:@"No phone number" message:@"The customer hasn't inputted a phone number" cancelButtonTitle:@"Ok" otherButtonTitles:@[] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        }];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
