//
//  RootReplaceSegue.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/16/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import "RootReplaceSegue.h"

@implementation RootReplaceSegue

-(void)perform {
    NSLog(@"root me");
    UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    UINavigationController *navigationController = sourceViewController.navigationController;
    [navigationController setViewControllers:@[destinationController] animated:YES];
}

@end
