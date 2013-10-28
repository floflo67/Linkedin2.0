//
//  LinkedInViewController.h
//  Linkedin2.0
//
//  Created by Florian Reiss on 28/10/2013.
//  Copyright (c) 2013 Florian Reiss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkedInViewController : UIViewController

-initWithAPIKey:(NSString*)API_KEY APIState:(NSString*)API_STATE;
-initWithAPIKey:(NSString*)API_KEY APIState:(NSString*)API_STATE andRedirect:(NSString*)URL_REDIRECT;

@end
