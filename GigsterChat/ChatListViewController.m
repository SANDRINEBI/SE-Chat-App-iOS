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
    [self.chats addObject:@{@"name":@"Noah / SE Chat", @"unread": [NSNumber numberWithBool:YES], @"urgent": [NSNumber numberWithBool:NO], @"timestamp": [NSDate date], @"last_message": @"Cool! Well I can talk anytime outside that 3 - 4 window!", @"profile_url": @"https://graph.facebook.com/565956182/picture?width=120&height=120"}];
    [self.chats addObject:@{@"name":@"Hoan / Wardrobe iOS", @"unread": [NSNumber numberWithBool:YES], @"urgent": [NSNumber numberWithBool:YES], @"timestamp": [NSDate date], @"last_message": @"After UI tidy up", @"profile_url": @"https://graph.facebook.com/100009178679586/picture?width=120&height=120"}];
    [self.chats addObject:@{@"name":@"Erin / Project XY", @"unread": [NSNumber numberWithBool:NO], @"urgent": [NSNumber numberWithBool:NO], @"timestamp": [NSDate date], @"last_message": @"Oh OK - I take it all back", @"profile_url": @"https://graph.facebook.com/564664585/picture?width=120&height=120"}];
    
    [SVProgressHUD show];
    [self loadGigs];
    
    AppDelegate *app = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [app requestPushPermissions];
    
    self.firebase = [[Firebase alloc] initWithUrl:@"https://gigster-debo.firebaseio.com/messages/"];
}

- (void)loadGigs {

    self.chats = [NSMutableArray new];
    [[API shared] getGigs:^(id gigsResponse, NSError *error) {
//        NSLog(@"gigs = %@", gigsResponse);
        [SVProgressHUD dismiss];
        [self.refreshControl endRefreshing];
        
        [gigsResponse[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull gig, NSUInteger idx, BOOL * _Nonnull stop) {
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
        }];
    
        [self.table reloadData];
//        [self loadLastMessages];
        
    }];
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
            
            [self.table reloadData];
        }];

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
    [UIActionSheet showInView:self.view withTitle:[[API shared] currentUser][@"name"] cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Gigster Website", @"Notification Settings", @"Logout"] tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        NSLog(@"hi");
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gigster Website"]) {
            TOWebViewController *vc = [[TOWebViewController alloc] initWithURLString:@"https://app.gigster.com"];
            [self.navigationController pushViewController:vc animated:YES];
        } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
            [UIAlertView showWithTitle:@"Logout?" message:@"Are you sure you want to logout?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Logout"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
                    [[API shared] logout];
                    [self performSegueWithIdentifier:@"ChatListToLogin" sender:nil];
                }
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
    
    NSDictionary *info = self.chats[indexPath.row];
    [cell setChatInfo:info];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *info = self.chats[indexPath.row];
//    [self performSegueWithIdentifier:@"ChatListToChat" sender:info];
    
    NSLog(@"cinfo = %@", info);
    
    ChatViewController *vc = [[ChatViewController alloc] init];
    [vc setChatInfo:info];
    
    [self.navigationController pushViewController:vc animated:YES];

}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *chat = self.chats[indexPath.row];
    
    NSString *actionTitle = [chat[@"unread"] boolValue] ? @"Mark as read" : @"Mark as unread";
    
    UITableViewRowAction *markAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:actionTitle handler:^(UITableViewRowAction *action, NSIndexPath *indexPath){
        //insert your editAction here
            
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
