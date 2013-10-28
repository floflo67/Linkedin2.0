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

@interface LinkedInViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *LinkedInWebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *LinkedInActivityIndicator;

@property (strong, nonatomic) NSString* API_KEY;
@property (strong, nonatomic) NSString* API_SECRET;
@property (strong, nonatomic) NSString* API_STATE;
@property (strong, nonatomic) NSString* URL_REDIRECT;

@property (strong, nonatomic) NSString* accessToken;
@property (nonatomic) NSInteger expires;

@end

@implementation LinkedInViewController

#pragma mark - init

- (id)initWithAPIKey:(NSString*)API_KEY APISecret:(NSString*)API_SECRET andAPIState:(NSString*)API_STATE
{
    self = [super init];
    if(self) {
        self.API_KEY = nil;
        self.API_STATE = nil;
        self.API_SECRET = nil;
        
        if(!API_KEY || !API_SECRET || !API_STATE)
        {
            NSMutableString *errorMessage = [[NSMutableString alloc] init];
            
            [errorMessage appendString:@"Error with:/n"];
            
            if(!API_KEY)
                [errorMessage appendString:self.API_KEY];
            if(!API_SECRET)
                [errorMessage appendString:self.API_SECRET];
            if(!API_STATE)
                [errorMessage appendString:self.API_STATE];
            
            NSLog(@"%@", errorMessage);
            
            self = nil;
            return self;
        }
        
        self.LinkedInWebView.delegate = self;
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

#pragma mark - view life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

#pragma mark - WebView delegate

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
    BOOL requestForCallbackURL = ([urlString rangeOfString:[NSString stringWithFormat:@"%@?", self.URL_REDIRECT]].location != NSNotFound); // YES if success
    BOOL userSubmit = ([urlString rangeOfString:@"submit"].location != NSNotFound); // YES if success
    if (requestForCallbackURL && !userSubmit) {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"error"].location == NSNotFound); // YES if success
        BOOL correctState = [urlString rangeOfString:self.API_STATE].location != NSNotFound; // YES if success
        
        if (userAllowedAccess && correctState) {
            NSString *authorizationCode = [self getAuthorizationCodeWithRequestString:urlString];
            if(authorizationCode && ![authorizationCode isEqualToString:@""]) {
                if([self requestAccesWithCode:authorizationCode]) {
                    [self.LinkedInWebView stopLoading];
                    [self.LinkedInWebView removeFromSuperview];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    self.LinkedInWebView = nil;
                }
            }
        }
        else if(!userAllowedAccess) {
            NSLog(@"User cancelled");
            [self.LinkedInWebView setHidden:YES];
            return NO;
        }
        else {
            NSLog(@"Error");
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView*)webView
{
    [self.LinkedInActivityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView*)webView
{
    [self.LinkedInActivityIndicator stopAnimating];
}

# pragma mark - Request delegate

- (BOOL)requestAccesWithCode:(NSString*)authorizationCode
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@", LK_API_URL, authorizationCode, self.URL_REDIRECT, self.API_KEY, self.API_SECRET];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    
    NSURLResponse *response;
    
    [self.LinkedInActivityIndicator startAnimating];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    [self settingUpData:data andResponse:response];
    [self.LinkedInActivityIndicator stopAnimating];
    
    return YES;
}

#pragma mark - Custom functions

- (NSString*)getAuthorizationCodeWithRequestString:(NSString*)urlString
{
    int lenght = [self.URL_REDIRECT length];
    if([self.URL_REDIRECT hasSuffix:@"/"])
        lenght++;
    NSString *parameters = [urlString substringFromIndex:lenght];
    NSArray *pairs = [parameters componentsSeparatedByString:@"&"];
    NSString *auth = @"";
    
	for (NSString *pair in pairs)
    {
        NSArray *elements = [pair componentsSeparatedByString:@"="];
        if ([[elements objectAtIndex:0] isEqualToString:@"code"])
        {
            auth = [elements objectAtIndex:1];
        }
    }
    return auth;
}

- (void)settingUpData:(NSData*)data andResponse:(NSURLResponse*)response
{
    NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
    
    if(statusCode == 200) {
        NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        self.accessToken = [jsonDict objectForKey:@"access_token"];
        self.expires = [[jsonDict objectForKey:@"expires_in"] intValue];
    }
    else {
        NSString* error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", error);
    }
}

- (void)setViewSizeHeight:(float)height andWidth:(float)width
{
    self.view.frame = CGRectMake(0, 0, height, width);
    self.LinkedInWebView.frame = self.view.frame;
}

#pragma mark - Accessors

- (NSString*)API_KEY
{
    if(!_API_KEY)
        _API_KEY = @"API_KEY missing";
    return _API_KEY;
}

- (NSString*)API_SECRET
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
