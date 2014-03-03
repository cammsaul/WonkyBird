//
//  TwitterManager.h
//  GeoTip
//
//  Created by Cameron Saul on 10/31/13.
//  Copyright (c) 2013 GeoTip Technologies, Inc. All rights reserved.
//

#import "XSingleton.h"

typedef void(^TwitterLoginErrorBlock)(NSError *error);

@interface TwitterManager : XSingleton

+ (void)loginWithTwitterSuccess:(void(^)())successBlock error:(TwitterLoginErrorBlock)errorBlock;

/// YES if the User is logged in and their account is connected to Twitter, and we have the OAuth token stashed in NSUserDefaults.
/// Users of the app before Feb 18th 2014 will have to logout and log back in to have the app save OAuth info.
+ (BOOL)canShareToTwitter;

/// Posts status update to Twitter if the possible. Check [TwitterManager canShareToTwitter] to see if we can post a status update.
+ (void)postStatusUpdate:(NSString *)status;

@property (nonatomic) BOOL enableShareToTwitter; ///< user defaults-backed property to keep track of whether user WANTS to share to twitter

@end
