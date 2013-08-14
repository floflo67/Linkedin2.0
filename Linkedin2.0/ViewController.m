//
//  ViewController.m
//  Linkedin2.0
//
//  Created by Florian Reiss on 19/07/13.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *buttonUpdate;
@property (nonatomic, weak) IBOutlet UIButton *buttonGetLinkedin;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSString *access_token;

@property (nonatomic) NSInteger expires;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.activityIndicator stopAnimating];
    [self.webView setHidden:YES];
    [self.buttonUpdate setHidden:YES];
}

#pragma mark - button events

/*
 https://www.linkedin.com/uas/oauth2/authorization?response_type=code
 &client_id=YOUR_API_KEY
 &scope=SCOPE
 &state=STATE
 &redirect_uri=YOUR_REDIRECT_URI
 */
- (IBAction)buttonGetLinkedinTouchDown:(id)sender
{
    [self.webView setHidden:NO];
    NSString *urlRequest = [NSString stringWithFormat:@"%@authorization?response_type=code&client_id=%@&state=%@&redirect_uri=%@", LK_API_URL, LK_API_KEY, LK_API_STATE, LK_API_REDIRECT];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    [self.webView loadRequest:request];
}

/*
 http://api.linkedin.com/v1/people/~/shares?oauth2_access_token=ACCESS_TOKEN
 */
- (IBAction)buttonPostTouchDown:(UIButton *)sender
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@people/~/shares?oauth2_access_token=%@", LK_API_FORMER_URL, self.access_token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
    NSData *body = [self settingUpParameters];
    [request setHTTPBody:body];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields: @{@"x-li-format":@"json"}];
    [request setHTTPMethod: @"POST"];
    
    NSURLResponse *urlResponse;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:nil];
    NSString* response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", response);
}

- (NSData*)settingUpParameters
{
    NSData *requestData;
    
    NSString *postTitle = @"postTitle";
    NSString *postDescription = @"postDescription";
    NSString *postURL = @"www.google.com";
    NSString *postImageURL = @"https:////www.google.com//images//srpr//logo4w.png";
    NSString *postComment = @"postComment";
    
    NSMutableDictionary *visibility = [[NSMutableDictionary alloc] init];
    [visibility setValue:@"anyone" forKey:@"code"];
    
    NSMutableDictionary *content = [[NSMutableDictionary alloc] init];
    [content setValue:postTitle forKey:@"title"];
    [content setValue:postDescription forKey:@"description"];
    [content setValue:postURL forKey:@"submitted-url"];
    [content setValue:postImageURL forKey:@"submitted-image-url"];
    
    NSDictionary *update = [[NSDictionary alloc] initWithObjectsAndKeys:visibility, @"visibility", content, @"content", postComment, @"comment", nil];
    
    requestData = [NSJSONSerialization dataWithJSONObject:update options:0 error:nil];
    
    return requestData;
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
                    self.buttonUpdate.hidden = NO;
                    self.buttonGetLinkedin.hidden = YES;
                    [self.webView stopLoading];
                    [self.webView removeFromSuperview];
                    self.webView = nil;
                }
            }
        }
        else if(!userAllowedAccess) {
            NSLog(@"User cancelled");
            [self.webView setHidden:YES];
            return NO;
        }
        else {
            NSLog(@"Error");
        }
    }
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.activityIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

# pragma mark - Request delegate

- (BOOL)requestAccesWithCode:(NSString*)authorizationCode
{
    NSString *urlRequest = [NSString stringWithFormat:@"%@accessToken?grant_type=authorization_code&code=%@&redirect_uri=%@&client_id=%@&client_secret=%@", LK_API_URL, authorizationCode,LK_API_REDIRECT, LK_API_KEY, LK_API_SECRET];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlRequest]];
    
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField: @"Content-Type"];
    
    NSURLResponse *response;
    
    [self.activityIndicator startAnimating];
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    
    [self settingUpData:data andResponse:response];
    [self.activityIndicator stopAnimating];
    
    return YES;
}

#pragma mark - Custom functions

- (NSString*)getAuthorizationCodeWithRequestString:(NSString*)urlString
{
    int lenght = [LK_API_REDIRECT length];
    if([LK_API_REDIRECT hasSuffix:@"/"])
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
        self.access_token = [jsonDict objectForKey:@"access_token"];
        self.expires = [[jsonDict objectForKey:@"expires_in"] intValue];
    }
    else {
        NSString* error = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@", error);
    }
}

@end
