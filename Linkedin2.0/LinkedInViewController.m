//
//  LinkedInViewController.m
//  Linkedin2.0
//
//  Created by Florian Reiss on 28/10/2013.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "LinkedInViewController.h"

#define LK_API_URL (@"https://www.linkedin.com/uas/oauth2/")
#define LK_API_FORMER_URL (@"https://api.linkedin.com/v1/")

@interface LinkedInViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *LinkedInWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LinkedInActivityIndicator;
@property (strong, nonatomic) NSString* API_KEY;
@property (strong, nonatomic) NSString* API_SECRET;
@property (strong, nonatomic) NSString* API_STATE;
@property (strong, nonatomic) NSString* URL_REDIRECT;

@end

@implementation LinkedInViewController

- (id)initWithAPIKey:(NSString*)API_KEY APISecret:(NSString*)API_SECRET andAPIState:(NSString*)API_STATE
{
    self = [super init];
    if(self) {
        self.API_KEY = nil;
        self.API_STATE = nil;
        self.API_SECRET = nil;
    }
    return self;
}

- (id)initWithAPIKey:(NSString*)API_KEY APISecret:(NSString*)API_SECRET APIState:(NSString*)API_STATE andRedirect:(NSString*)URL_REDIRECT
{
    self = [self initWithAPIKey:API_KEY APISecret:API_SECRET andAPIState:API_STATE];
    
    if(self) {
        self.URL_REDIRECT = nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - Accessors

- (NSString*)API_KEY
{
    if(!_API_KEY)
        _API_KEY = @"API_KEY missing";
    return _API_KEY;
}

- (NSString *)API_SECRET
{
    if(!_API_SECRET)
        _API_SECRET = @"API_SECRET missing";
    return _API_SECRET;
}

- (NSString*)API_STATE
{
    if(!_API_STATE)
        _API_STATE = @"API_STATE missing";
    return _API_STATE;
    
}

- (NSString*)URL_REDIRECT
{
    if(!_URL_REDIRECT)
        _URL_REDIRECT = @"www.github.com/floflo67";
    return _URL_REDIRECT;
}

@end
