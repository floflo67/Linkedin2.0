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
    NSString *urlRequest = [NSString stringWithFormat:@"%@authorization?response_type=code&client_id=%@&state=%@&redirect_uri=%@", LK_API_URL, LK_API_KEY, LK_API_STATE, LK_API_REDIRECT];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    [self.webView loadRequest:request];
}

#pragma mark - WebView delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = request.URL;
	NSString *urlString = url.absoluteString;
    BOOL requestForCallbackURL = ([urlString rangeOfString:[NSString stringWithFormat:@"%@?", LK_API_REDIRECT]].location != NSNotFound); // YES if success
    BOOL userSubmit = ([urlString rangeOfString:@"submit"].location != NSNotFound); // YES if success
    if (requestForCallbackURL && !userSubmit) {
        BOOL userAllowedAccess = ([urlString rangeOfString:@"error"].location == NSNotFound); // YES if success
        BOOL correctState = [urlString rangeOfString:LK_API_STATE].location != NSNotFound; // YES if success
        
        if (userAllowedAccess && correctState) {
            NSString *authorizationCode = [self getAuthorizationCodeWithRequestString:urlString];
            if(authorizationCode && ![authorizationCode isEqualToString:@""]) {
                if([self requestAccesWithCode:authorizationCode]) {
                    [self.webView stopLoading];
                }
            }
        }
        else {
            NSLog(@"false");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"loginViewDidFinish" object:self userInfo:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    
    return YES;
}

- (NSString*)getAuthorizationCodeWithRequestString:(NSString*)urlString
{
    NSString *parameters = [urlString substringFromIndex:[LK_API_REDIRECT length] + 1];
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

- (BOOL)requestAccesWithCode:(NSString*)authorizationCode
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@", LK_API_URL, authorizationCode,LK_API_REDIRECT, LK_API_KEY, LK_API_SECRET];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    
    NSURLResponse *response;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    [self settingUpData:data andResponse:response];
    
    return YES;
}

- (void)settingUpData:(NSData*)data andResponse:(NSURLResponse*)response
{    
    NSInteger statusCode = [(NSHTTPURLResponse*)response statusCode];
    
    if(statusCode == 200) {
        NSMutableDictionary *jsonDict = [NSMutableDictionary dictionaryWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
        NSLog(@"%@", [jsonDict objectForKey:@"access_token"]);
    }
    else {
        NSString* error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", error);
    }
}

@end
