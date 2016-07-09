//
//  RISignupViewController.m
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/30/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import "RISignupViewController.h"

@interface RISignupViewController ()

@end

@implementation RISignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
}

- (IBAction)signupAction:(id)sender {
    if([[self.username_text text] isEqualToString:@""] || [[self.password_text text] isEqualToString:@""]){
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"One of the fields is empty." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [error show];
    }else{
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        NSURL* url = [NSURL URLWithString:@"http://localhost:3000/api/register"];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"POST"];
        NSString* params = [NSString stringWithFormat:@"%@=%@&%@=%@", @"username", [self.username_text text], @"password", [self.password_text text]];
        
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLSessionTask* dataTask = [session dataTaskWithRequest:request];
        
        [dataTask resume];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    NSLog(@"Response:%@\n", response);
    //Converts json response to a dictionary
    //NSError* error;
    //NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSHTTPURLResponse* resp = (NSHTTPURLResponse*)response;
    NSLog(@"Response code %d", [resp statusCode]);
    if([resp statusCode] == 201){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"signup_success" sender:self];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* fail = [[UIAlertView alloc] initWithTitle:@"Registration Failed" message:@"Could not complete the registration" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [fail show];
        });
    }
}

- (IBAction)returnToScreen:(id)sender {
    [self.view endEditing:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
@end
