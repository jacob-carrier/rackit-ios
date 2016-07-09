//
//  RISignupViewController.h
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/30/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RISignupViewController : UIViewController <UITextFieldDelegate, NSURLSessionDataDelegate>
@property (weak, nonatomic) IBOutlet UITextField *username_text;
@property (weak, nonatomic) IBOutlet UITextField *password_text;
- (IBAction)signupAction:(id)sender;
- (IBAction)returnToScreen:(id)sender;

@end
