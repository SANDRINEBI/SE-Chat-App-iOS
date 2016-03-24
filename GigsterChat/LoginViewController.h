//
//  LoginViewController.h
//  GigsterChat
//
//  Created by Hoan Ton-That on 3/16/16.
//  Copyright © 2016 Hoan Ton-That. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, retain) IBOutlet UITextField *emailField, *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton, *forgotButton;
@property (nonatomic, retain) IBOutlet UIImageView *logo;

- (IBAction)onLogin:(id)sender;

@end
