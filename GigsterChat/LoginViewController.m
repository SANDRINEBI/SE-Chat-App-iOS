//
//  LoginViewController.m
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/16/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import "LoginViewController.h"
#import "API.h"

#import <UIAlertView+Blocks/UIAlertView+Blocks.h>
#import <FrameAccessor/FrameAccessor.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupNavBar];
    [self.emailField becomeFirstResponder];
    
    self.emailField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
    self.passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);

//    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.emailField.height)];
//    self.emailField.leftView = paddingView;
//    self.emailField.leftViewMode = UITextFieldViewModeAlways;
    
//    [self.emailField  setContentInset:UIEdgeInsetsMake(7, 7, 0, 0)];
//    [self.passwordField  setContentInset:UIEdgeInsetsMake(7, 7, 0, 0)];

    
    self.logo.centerX = self.view.width/2;
}

- (void)setupNavBar {
    [self.navigationController setNavigationBarHidden:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)textFieldShouldReturn:(UITextField*)tf {
    if(tf == self.emailField) {
        [self.passwordField becomeFirstResponder];
    } else if(tf == self.passwordField) {
        [self onLogin:nil];
    }

    return YES;
}


- (IBAction)onLogin:(id)sender {
    [[API shared] login:self.emailField.text withPassword:self.passwordField.text callback:^(id response, NSError *error) {
        NSLog(@"success login");

        [[API shared] getGigs:^(id response, NSError *error) {
            NSLog(@"gigs = %@", response);
        }];

        [self performSegueWithIdentifier:@"LoginToChatList" sender:nil];

    }];

//    if([self.passwordField.text isEqualToString:@"gigster"]) {
        // Success
        
//        [self performSegueWithIdentifier:@"LoginToChatList" sender:nil];
//    } else {
//        [UIAlertView showWithTitle:@"Can't login" message:@"[SERVER MESSAGE GOES HERE]" cancelButtonTitle:@"Ok" otherButtonTitles:nil tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
//            
//        }];
//    }
}

- (IBAction)onForgot:(id)sender {
    [UIAlertView showWithTitle:@"Forgot Password?" message:@"Would you like to open the Gigster Website to reset your password?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Reset"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Reset"]) {
            // FIXME: figure out the way to get to the forgot form
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://app.gigster.com/login#forgot"]];
        }
    }];
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
