//
//  RIViewController.h
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/29/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RIUser.h"
#import "RIClosetViewController.h"

@interface RILoginViewController : UIViewController <UITextFieldDelegate, NSURLSessionDataDelegate>
{
    RIUser* currentUser;
}
@property (weak, nonatomic) IBOutlet UITextField *username_text;
@property (weak, nonatomic) IBOutlet UITextField *password_text;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


- (IBAction)loginAction:(id)sender;

- (IBAction)returnToScreen:(id)sender;

@end
