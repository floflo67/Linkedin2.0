//
//  ViewController.m
//  Linkedin2.0
//
//  Created by Florian Reiss on 19/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

/*
 https://www.linkedin.com/uas/oauth2/authorization?response_type=code
 &client_id=YOUR_API_KEY
 &scope=SCOPE
 &state=STATE
 &redirect_uri=YOUR_REDIRECT_URI
 */
- (IBAction)buttonGetLinkedinTouchDown:(id)sender
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@&client_id=%@&state=%@&redirect_uri=%@", LK_API_URL, LK_API_KEY, LK_API_STATE, LK_API_REDIRECT];
    NSLog(@"%@", urlRequest);
}
@end
