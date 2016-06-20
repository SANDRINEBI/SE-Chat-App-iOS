//
//  AppDelegate.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/14/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#define BLUE_COLOR [UIColor colorWithRed:39/255.0 green:128/255.0 blue:218/255.0 alpha:1.0]

#import "AppDelegate.h"
#import "API.h"

#import <Firebase/Firebase.h>
#import <NSStringEmojize/NSString+Emojize.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    [[UINavigationBar appearance] setBarTintColor:BLUE_COLOR];
    
    NSString *s1 = [@"test emojize :sunglasses:" emojizedString];
    NSString *s2 = [@"test unemojize 😎" unemojizedString];
    
    NSLog(@"%@", s1);
    NSLog(@"%@", s2);
    
    [Fabric with:@[[Crashlytics class]]];
    
    if([[API shared] currentUser]) {
        NSLog(@"Have user, login");
        
//        NSLog(@"current user = %@", [[API shared] currentUser]);
        
        UIStoryboard *storyboard = self.window.rootViewController.storyboard;
        UIViewController *rootViewController = [storyboard instantiateViewControllerWithIdentifier:@"ChatListViewController"];
        
        UINavigationController *navViewController = (UINavigationController*)self.window.rootViewController;
        [navViewController setViewControllers:@[rootViewController]];
    } else {
        NSLog(@"Not logged in");
    }
    
//    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://gigster-debo.firebaseio.com/messages/"];
//    [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
//        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
//    }];
    
    return YES;
}

- (void)requestPushPermissions {
    NSLog(@"requesting permissions...");

    // SETUP CATEGORIES
    NSSet *categories = nil;
    UIApplication *application = [UIApplication sharedApplication];
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound);
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:categories];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"save push token permissions...");
    
    // Store the deviceToken in the current Installation and save it to Parse
    NSLog(@"token = %@", deviceToken);
    
    NSString *realDeviceToken = [[[[deviceToken description]
                                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSLog(@"token = %@", realDeviceToken);

    [[API shared] saveDeviceToken:realDeviceToken callback:^(id response, NSError *error) {
        
//        [UIAlertView showWithTitle:@"Saved" message:realDeviceToken cancelButtonTitle:@"ok" otherButtonTitles:nil tapBlock:nil];
        
        NSLog(@"%@ - %@", response, error);
    }];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
