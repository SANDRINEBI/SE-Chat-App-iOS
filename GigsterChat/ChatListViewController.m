//
//  ViewController.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/14/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#define BLUE_COLOR [UIColor colorWithRed:39/255.0 green:128/255.0 blue:218/255.0 alpha:1.0];

#import "AppDelegate.h"
#import "API.h"
#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "ChatListCell.h"

#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <TOWebViewController/TOWebViewController.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ChatListViewController ()

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.table setEmptyDataSetDelegate:self];
    [self.table setEmptyDataSetSource:self];
    
    [self setupNavBar];
    [self setupPullToRefresh];
    
    self.chats = [NSMutableArray new];
/*    [self.chats addObject:@{@"name":@"Noah / SE Chat", @"unread": [NSNumber numberWithBool:YES], @"urgent": [NSNumber numberWithBool:NO], @"timestamp": [NSDate date], @"last_message": @"Cool! Well I can talk anytime outside that 3 - 4 window!", @"profile_url": @"https://graph.facebook.com/565956182/picture?width=120&height=120"}];
    [self.chats addObject:@{@"name":@"Hoan / Wardrobe iOS", @"unread": [NSNumber numberWithBool:YES], @"urgent": [NSNumber numberWithBool:YES], @"timestamp": [NSDate date], @"last_message": @"After UI tidy up", @"profile_url": @"https://graph.facebook.com/100009178679586/picture?width=120&height=120"}];
    [self.chats addObject:@{@"name":@"Erin / Project XY", @"unread": [NSNumber numberWithBool:NO], @"urgent": [NSNumber numberWithBool:NO], @"timestamp": [NSDate date], @"last_message": @"Oh OK - I take it all back", @"profile_url": @"https://graph.facebook.com/564664585/picture?width=120&height=120"}];*/
    
    [SVProgressHUD show];
    [self loadGigs];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app requestPushPermissions];
    
    self.firebase = [[Firebase alloc] initWithUrl:@"https://gigster-debo.firebaseio.com/messages/"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(markGigAsRead:) name:@"markGigAsRead" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveGigToTop:) name:@"moveGigToTop" object:nil];
}

- (void)markGigAsRead:(NSNotification*)notif {
    NSString *gigId = (NSString*)[notif object];
    
    NSLog(@"marking %@ as read", gigId);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id == '%@'", gigId];
    NSInteger index = [self.chats indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj[@"_id"] isEqualToString:gigId];
    }];
    
    NSLog(@"found at index %d", index);
    
    if(index != -1) {
        NSMutableDictionary *obj = [self.chats objectAtIndex:index];
        [obj setObject:[NSNumber numberWithBool:NO] forKey:@"unread"];
        
        [self.table reloadData];
    }
}

- (void)moveGigToTop:(NSNotification*)notif {
    NSString *gigId = (NSString*)[notif object];
    
    NSLog(@"moving %@ to top", gigId);
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"_id == '%@'", gigId];
    NSInteger index = [self.chats indexOfObjectPassingTest:^BOOL(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [obj[@"_id"] isEqualToString:gigId];
    }];
    
    NSLog(@"found at index %d", index);

    if(index != -1) {
        NSMutableDictionary *obj = [self.chats objectAtIndex:index];
        [self.chats removeObjectAtIndex:index];
        [self.chats insertObject:obj atIndex:0];
        
        [self.table reloadData];
    }
    
}

- (void)loadGigs {

    self.chats = [NSMutableArray new];
    [[API shared] getGigs:^(id gigsResponse, NSError *error) {
//        NSLog(@"gigs = %@", gigsResponse);
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
        
        [gigsResponse[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull gig, NSUInteger idx, BOOL * _Nonnull stop) {
            if(idx < 30) {
                id poster = gig[@"poster"];
                
                if(!poster || poster == [NSNull null]) {
                    NSLog(@"poster = nil");
                    return;
                }
                    
                    
                //    NSLog(@"gig = %@", gig);
                
                NSString *profileUrl = poster[@"img_url"];
                if(!profileUrl) profileUrl = @"https://app.gigster.com/media/sprites/generic-avatars/av1.png";
                
                id name = [NSNull null];
                if(gig[@"name"]) name = gig[@"name"];
                
                if(!gig[@"name"]) NSLog(@"no name");
                
                NSMutableDictionary *chat = [NSMutableDictionary new];
                [chat setObject:name forKey:@"name"];
                [chat setObject:gig[@"_id"] forKey:@"_id"];
                [chat setObject:profileUrl forKey:@"profile_url"];
                [chat setObject:[NSNull null] forKey:@"timestamp"];
                [chat setObject:@"" forKey:@"last_message"];
                [chat setObject:gig[@"poster"] forKey:@"poster"];
                [chat setObject:gig forKey:@"gig"];
                
                [self.chats addObject:chat];
            }
        }];
    
        [self.table reloadData];
        [self loadLastMessages];
        
    }];
}

- (void)moveChatToTop:(NSString*)gigId {
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"propertyName == %@", gigId];

}

- (void)loadLastMessages {
    [self.chats enumerateObjectsUsingBlock:^(NSMutableDictionary *chat, NSUInteger idx, BOOL * _Nonnull stop) {
        Firebase *ref = [self.firebase childByAppendingPath:chat[@"_id"]];
//        [[[ref queryEqualToValue:@"text" childKey:@"type"] queryLimitedToLast:1]  observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        [[[ref queryOrderedByChild:@"timestamp"] queryLimitedToLast:1] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
            NSLog(@"OMGGG : %@ %@", snapshot.key, snapshot.value);
            
            if([snapshot.value[@"type"] isEqualToString:@"typing"]) {
                [chat setObject:@"" forKey:@"last_message"];
            } else if([snapshot.value[@"type"] isEqualToString:@"text"]) {
                [chat setObject:snapshot.value[@"text"] forKey:@"last_message"];
            } else {
                [chat setObject:@"Attachment" forKey:@"last_message"];
            }
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:([snapshot.value[@"timestamp"] doubleValue]/1000.0f)];
            [chat setObject:date forKey:@"timestamp"];
            
            NSLog(@"value = %@", snapshot.value);
            
            NSArray *read = snapshot.value[@"read"];
            BOOL isUnread = NO;
            if(read) {
                NSString *currentUserId = [[API shared] currentUser][@"_id"];
                __block BOOL inArray = NO;
                [read enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if([obj[@"id"] isEqualToString:currentUserId]) {
                        inArray = YES;
                        *stop = YES;
                    }
                }];
                
                if(inArray) {
                    NSLog(@"in read array - not unread");
                    isUnread = NO;
                } else {
                    NSLog(@"not in array - unread");
                    isUnread = YES;
                }
            } else {
                NSLog(@"no read array - so unread");
                isUnread = YES;
            }
            
            if([snapshot.value[@"toClient"] boolValue]) {
                isUnread = NO;
            }
            
            if(isUnread) {
                // If greater than 5h then it is URGENT
                NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:date];
                NSLog(@"interval = %d", (int)interval);
                
                if(interval > 5*60*60) {
                    [chat setObject:[NSNumber numberWithBool:YES] forKey:@"urgent"];
                }
                
                [chat setObject:[NSNumber numberWithBool:YES] forKey:@"unread"];
            } else {
                [chat setObject:[NSNumber numberWithBool:NO] forKey:@"unread"];
            }
            
            // reorder
            [self reorderChats];
            [self.table reloadData];
        }];

    }];
}

- (void)reorderChats {
    [self.chats sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSDate *d1 = obj1[@"timestamp"];
        NSDate *d2 = obj2[@"timestamp"];
        
        return [d1 compare:d2];
    }];
}

- (void)setupPullToRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor blackColor];
    [self.refreshControl addTarget:self
                            action:@selector(onRefresh:)
                  forControlEvents:UIControlEventValueChanged];
    [self.table addSubview:self.refreshControl];
}

- (void)setupNavBar {
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self.navigationController setNavigationBarHidden:NO];

//    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.backgroundColor = BLUE_COLOR;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    
    UIImage *image = [UIImage imageNamed:@"logo-titlebar.png"];
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:image];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"button-gear"]]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"button-gear"] style:UIBarButtonItemStylePlain target:self action:@selector(onSettings:)];
}

- (void)onRefresh:(id)sender {
    [self loadGigs];
}

- (void)onSettings:(id)sender {
    BOOL notifOn = [[[[API shared] currentUser] objectForKey:@"pushNotifications"] boolValue];
    BOOL availOn = [[[[API shared] currentUser] objectForKey:@"available"] boolValue];
    
    NSString *notificationsText = notifOn ? @"Turn OFF notifications" : @"Turn ON notifications";
    NSString *availabilityText  = availOn ? @"Turn OFF availability"  : @"Turn ON availability";
    
    [UIActionSheet showInView:self.view withTitle:[[API shared] currentUser][@"name"] cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Gigster Website", notificationsText, availabilityText, @"Logout"] tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        NSLog(@"hi");
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gigster Website"]) {
            TOWebViewController *vc = [[TOWebViewController alloc] initWithURLString:@"https://app.gigster.com"];
            [self.navigationController pushViewController:vc animated:YES];
        } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
            [UIAlertView showWithTitle:@"Logout?" message:@"Are you sure you want to logout?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Logout"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
                    
                    [[API shared] saveDeviceToken:@"null" callback:^(id response, NSError *error) {
                        NSLog(@"device token should be NUKED");
                    }];
                    
                    [[API shared] logout];
                    
                    [self performSegueWithIdentifier:@"ChatListToLogin" sender:nil];
                }
            }];
        } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:notificationsText]) {
            [[API shared] updateMe:@{@"pushNotifications": notifOn ? @"false" : @"true"} callback:^(id response, NSError *error) {
                NSLog(@"resp %@", response);
            }];
        } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:availabilityText]) {
            [[API shared] updateMe:@{@"available": availOn ? @"false" : @"true"} callback:^(id response, NSError *error) {
                NSLog(@"resp %@", response);
            }];
        }
    }];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if([[segue identifier] isEqualToString:@"ChatListToChat"]) {
//        ChatViewController *vc = (ChatViewController*)segue.destinationViewController;
//        [vc setChatInfo:sender];
//    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chats count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatListCell *cell = (ChatListCell*)[tableView dequeueReusableCellWithIdentifier:@"ChatListCell"];
    
    NSMutableDictionary *info = self.chats[indexPath.row];
    [cell setChatInfo:info];
    
    // Do firebase query here
/*    Firebase *ref = [self.firebase childByAppendingPath:info[@"_id"]];
    //        [[[ref queryEqualToValue:@"text" childKey:@"type"] queryLimitedToLast:1]  observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
    [[[ref queryOrderedByChild:@"timestamp"] queryLimitedToLast:1] observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"OMGGG : %@ %@", snapshot.key, snapshot.value);
        
        if([snapshot.value[@"type"] isEqualToString:@"typing"]) {
            [info setObject:@"" forKey:@"last_message"];
        } else if([snapshot.value[@"type"] isEqualToString:@"text"]) {
            [info setObject:snapshot.value[@"text"] forKey:@"last_message"];
        } else {
            [info setObject:@"Attachment" forKey:@"last_message"];
        }
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:([snapshot.value[@"timestamp"] doubleValue]/1000.0f)];
        [info setObject:date forKey:@"timestamp"];
        
        [self.table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }];*/

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSMutableDictionary *info = self.chats[indexPath.row];
//    [self performSegueWithIdentifier:@"ChatListToChat" sender:info];
    
    NSLog(@"cinfo = %@", info);
    
    // Mark as read here
    [info setObject:[NSNumber numberWithBool:NO] forKey:@"unread"];
    [info setObject:[NSNumber numberWithBool:NO] forKey:@"urgent"];
    
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    ChatViewController *vc = [[ChatViewController alloc] init];
    [vc setChatInfo:info];
    
    [self.navigationController pushViewController:vc animated:YES];

}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableDictionary *chat = self.chats[indexPath.row];
    
    NSString *actionTitle = @"Mark as Read";//[chat[@"unread"] boolValue] ? @"Mark as read" : @"Mark as unread";
    
    UITableViewRowAction *markAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:actionTitle handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        NSLog(@"hiii");
        
        [chat setObject:[NSNumber numberWithBool:NO] forKey:@"unread"];
        
        [self.table reloadData];
    }];
    markAction.backgroundColor = [UIColor grayColor];
    
    return @[markAction];
}

// empty
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return nil;
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath: @"transform"];
    
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
    
    animation.duration = 0.25;
    animation.cumulative = YES;
    animation.repeatCount = MAXFLOAT;
    
    return animation;
}

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"No chats";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor blackColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"You don't have any chats for any current projects";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:@"Reload" attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
    [SVProgressHUD show];
    [self loadGigs];
}

- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    [self.refreshControl beginRefreshing];
    [self loadGigs];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
