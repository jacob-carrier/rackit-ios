//
//  RIMainMenuViewController.m
//  Rack It!
//
//  Created by Jacob Lemelin-Carrier on 1/30/2014.
//  Copyright (c) 2014 Jacob Lemelin-Carrier. All rights reserved.
//

#import "RIMainMenuViewController.h"

@interface RIMainMenuViewController ()

@end

@implementation RIMainMenuViewController

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
	// Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
