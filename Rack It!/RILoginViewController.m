//
//  RIViewController.m
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/29/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import "RILoginViewController.h"

@interface RILoginViewController ()

@end

@implementation RILoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.activityIndicator.hidesWhenStopped = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)loginAction:(id)sender {
    if([[self.username_text text] isEqualToString:@""] || [[self.password_text text] isEqualToString:@""]){
        UIAlertView* error = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"One of the fields is empty." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [error show];
    }else{
        NSURLSessionConfiguration* configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        //NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSession* session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
        NSURL* url = [NSURL URLWithString:@"http://localhost:3000/api/login"];
        
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
        
        [request setHTTPMethod:@"POST"];
        [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
        NSString* params = [NSString stringWithFormat:@"%@=%@&%@=%@", @"username", [self.username_text text], @"password", [self.password_text text]];
        
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        NSURLSessionTask* dataTask = [session dataTaskWithRequest:request];
        
        [dataTask resume];
    }
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    
    completionHandler(NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data{
    
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
    NSHTTPURLResponse* resp = (NSHTTPURLResponse*)dataTask.response;
    NSLog(@"Response code %d", [resp statusCode]);
    if([resp statusCode] == 200){
        [self.activityIndicator stopAnimating];
        
        currentUser = [RIUser alloc];
        
        NSArray* results = [json objectForKey:@"data"];
        
        NSDictionary* responseData = [results objectAtIndex:0];
        
        currentUser._id = [responseData objectForKey:@"_id"];
        currentUser.username = [responseData objectForKey:@"username"];
        
        NSLog(@"Username: %@", currentUser.username);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self performSegueWithIdentifier:@"login_success" sender:self];
        });
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* fail = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:@"Username or password invalid." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [fail show];
            [self.activityIndicator stopAnimating];
        });
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend{
    [self.activityIndicator startAnimating];
}

- (IBAction)returnToScreen:(id)sender {
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier] isEqualToString:@"login_success"]){
        UITabBarController* tabBar = segue.destinationViewController;
        RIClosetViewController* destinationController = [tabBar.viewControllers objectAtIndex:0];
        [destinationController setUser:currentUser];
    }
}
@end
