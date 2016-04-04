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
    
//    self.emailField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);
//    self.passwordField.layer.sublayerTransform = CATransform3DMakeTranslation(10, 0, 0);

//    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.emailField.height)];
//    self.emailField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.emailField.height)];
//    self.emailField.leftViewMode = UITextFieldViewModeAlways;
//    self.emailField.rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, self.emailField.height)];
//    self.emailField.rightViewMode = UITextFieldViewModeAlways;
    
    UIView *spacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.emailField setLeftViewMode:UITextFieldViewModeAlways];
    [self.emailField setLeftView:spacerView];

    UIView *spacerView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self.passwordField setLeftViewMode:UITextFieldViewModeAlways];
    [self.passwordField setLeftView:spacerView2];

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
        if(error) {
            NSString *errorMessage;
            if(response && response[@"message"]) {
                errorMessage = response[@"message"];
            } else {
                errorMessage = @"There was an error connecting to the gigster servers";
            }
            
            [UIAlertView showWithTitle:@"Login error" message:errorMessage cancelButtonTitle:@"Ok" otherButtonTitles:@[] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
                
            }];
        } else {
            NSLog(@"success login");
            
            [self performSegueWithIdentifier:@"LoginToChatList" sender:nil];
        }

    }];
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
