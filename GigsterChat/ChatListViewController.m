//
//  ViewController.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/14/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#define BLUE_COLOR [UIColor colorWithRed:39/255.0 green:128/255.0 blue:218/255.0 alpha:1.0];

#import "API.h"
#import "ChatListViewController.h"
#import "ChatViewController.h"
#import "ChatListCell.h"

#import <UIActionSheet+Blocks/UIActionSheet+Blocks.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@interface ChatListViewController ()

@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupNavBar];
    [self setupPullToRefresh];
    
    self.chats = [NSMutableArray new];
    [self.chats addObject:@{@"name":@"Noah / SE Chat", @"unread": [NSNumber numberWithBool:YES], @"urgent": [NSNumber numberWithBool:NO], @"timestamp": [NSDate date], @"last_message": @"Cool! Well I can talk anytime outside that 3 - 4 window!", @"profile_url": @"https://graph.facebook.com/565956182/picture?width=120&height=120"}];
    [self.chats addObject:@{@"name":@"Hoan / Wardrobe iOS", @"unread": [NSNumber numberWithBool:YES], @"urgent": [NSNumber numberWithBool:YES], @"timestamp": [NSDate date], @"last_message": @"After UI tidy up", @"profile_url": @"https://graph.facebook.com/100009178679586/picture?width=120&height=120"}];
    [self.chats addObject:@{@"name":@"Erin / Project XY", @"unread": [NSNumber numberWithBool:NO], @"urgent": [NSNumber numberWithBool:NO], @"timestamp": [NSDate date], @"last_message": @"Oh OK - I take it all back", @"profile_url": @"https://graph.facebook.com/564664585/picture?width=120&height=120"}];
    
    [self loadGigs];
}

- (void)loadGigs {
    self.chats = [NSMutableArray new];
    [[API shared] getGigs:^(id response, NSError *error) {
        NSLog(@"gigs = %@", response);
        
        [response[@"data"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSMutableDictionary *chat = [NSMutableDictionary new];
            [chat setObject:obj[@"name"] forKey:@"name"];
            [chat setObject:@"https://graph.facebook.com/564664585/picture?width=120&height=120" forKey:@"profile_url"];
            [chat setObject:[NSDate date] forKey:@"timestamp"];
            [chat setObject:@"last_message" forKey:@"last_message"];
            
            [self.chats addObject:chat];
        }];
        [self.table reloadData];
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
    [self.refreshControl endRefreshing];
    [self.table reloadData];
}

- (void)onSettings:(id)sender {
    [UIActionSheet showInView:self.view withTitle:[[API shared] currentUser][@"name"] cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@[@"Gigster Website", @"Notification Settings", @"Logout"] tapBlock:^(UIActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        NSLog(@"hi");
        if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Gigster Website"]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://app.gigster.com"]];
        } else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
            [UIAlertView showWithTitle:@"Logout?" message:@"Are you sure you want to logout?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Logout"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Logout"]) {
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
