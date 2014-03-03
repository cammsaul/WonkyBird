//
//  FacebookShare.m
//  GeoTip
//
//  Created by Justin Ho on 2/12/14.
//  Copyright (c) 2014 GeoTip Technologies, Inc. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import "GameManager.h"
#import "FacebookShare.h"

@interface FacebookShare ()
@property (nonatomic) BOOL isAuthenticated;
@property (nonatomic, strong) NSString *fbUserID;
@end

@implementation FacebookShare

- (BOOL)isAuthenticated {
	return [FBSession openActiveSessionWithAllowLoginUI:NO];
}

// --------------- DEPRECATE -----------------
+ (void)authWithGraphAPIAndPostStatusMessage:(NSString *)statusMessage completion:(void(^)(BOOL success))completionBlock {
    if ([[FBSession activeSession] isOpen]) {
        [self publishStatusMessage:statusMessage completion:completionBlock];
    }
    else {
        [self authenticateSessionOnCompletion:^(BOOL success){
			if (success)	[self publishStatusMessage:statusMessage completion:completionBlock];
			else			if (completionBlock) completionBlock(NO);
         }];
    }
}

+ (void)publishStatusMessage:(NSString *)statusMessage completion:(void(^)(BOOL))completionBlock {
    [self requestPublishPermissionOnCompletion:^(BOOL success) {
		if (success)	[self postStatusMessage:statusMessage completion:completionBlock];
		else			if (completionBlock) completionBlock(NO);
     }];
}

+ (void)authenticateSessionOnCompletion:(void(^)(BOOL))completionBlock {
	[FBSession openActiveSessionWithReadPermissions:@[@"basic_info"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
		if (error || status != FBSessionStateOpen) {
			NSLog(@"Error logging into facebook: %@", error.localizedDescription);
			if (completionBlock) completionBlock(NO);
			return;
		}
		[FBSession openActiveSessionWithPublishPermissions:[NSArray arrayWithObject:@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
			if (!error && status == FBSessionStateOpen) {
				if (completionBlock) completionBlock(YES);
			} else {
				[[FBSession activeSession] closeAndClearTokenInformation];
				NSLog(@"error logging in to Facebook: %@", error.localizedDescription);
				if (completionBlock) completionBlock(NO);
			}
		}];
	}];
}

+ (void)requestPublishPermissionOnCompletion:(void (^)(BOOL))completionBlock {
	NSParameterAssert([[FBSession activeSession] isOpen]);
	
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"] defaultAudience:FBSessionDefaultAudienceFriends completionHandler:^(FBSession *session, NSError *error)  {
			if (!error) { if (completionBlock) completionBlock(YES); }
			else {
				NSLog(@"Error requesting permission: %@", error.localizedDescription);
				if (completionBlock) completionBlock(NO);
			}}];
    }
    else if (completionBlock) completionBlock(YES);
}

+ (void)fetchUserID:(void(^)(BOOL))completion {
	if ([FacebookShare sharedInstance].fbUserID) {
		if (completion) completion(YES);
		return;
	}
	
	[FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
		if (error) {
			NSDictionary *errorDict = [[error userInfo] valueForKey:FBErrorParsedJSONResponseKey];
			NSString *errorMessage = [errorDict valueForKeyPath:@"body.error.message"];
			NSLog(@"Error posting to FB: an unknown error has occured: %@", errorMessage);
			if (completion) completion(NO);
		} else if (result[@"id"]) {
			[FacebookShare sharedInstance].fbUserID = result[@"id"];
			if (completion) completion(YES);
		} else {
			NSLog(@"Error fetching facebook userID: missing!");
			if (completion) completion(NO);
		}
	}];
}

+ (void)postStatusMessage:(NSString *)message completion:(void(^)(BOOL))completionBlock {
	[self fetchUserID:^(BOOL success) {
		if (!success) {
			if (completionBlock) completionBlock(NO);
			return;
		}
		
		[FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/scores", [FacebookShare sharedInstance].fbUserID]
									 parameters:@{@"score": @([GameManager sharedInstance].totalScore).description}
									 HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
			if (!result || error) {
				NSDictionary *errorDict = [[error userInfo] valueForKey:FBErrorParsedJSONResponseKey];
				NSString *errorMessage = [errorDict valueForKeyPath:@"body.error.message"];
				NSLog(@"Error posting to FB: an unknown error has occured: %@", errorMessage);
				if (completionBlock) completionBlock(NO);
			} else {
				NSLog(@"Posted score. success: %@", [result valueForKey:@"FACEBOOK_NON_JSON_RESULT"]);
				if (completionBlock) completionBlock(YES);
			}
		}];
	}];
	
    [FBRequestConnection startForPostStatusUpdate:message completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (error) {
             NSDictionary *errorDict = [[error userInfo] valueForKey:FBErrorParsedJSONResponseKey];
             NSString *errorMessage = [errorDict valueForKeyPath:@"body.error.message"];
			 NSLog(@"Error posting to FB: an unknown error has occured: %@", errorMessage);
			 if (completionBlock) completionBlock(NO);
         }
         else if ([result valueForKey:@"id"]) {
             if (completionBlock) completionBlock(YES);
         }
         else {
			 NSLog(@"Error posting to FB: an unknown error has occured.");
			 if (completionBlock) completionBlock(NO);
         }
     }];
}

static NSString * const EnableShareToFBKey = @"EnableShareToFB";
static NSString * const FBUserIDKey = @"FBUserID";

- (BOOL)enableShareToFB {
	return [[NSUserDefaults standardUserDefaults] boolForKey:EnableShareToFBKey];
}

- (NSString *)fbUserID {
	return [[NSUserDefaults standardUserDefaults] stringForKey:FBUserIDKey];
}

- (void)setFbUserID:(NSString *)fbUserID {
	[[NSUserDefaults standardUserDefaults] setValue:fbUserID forKey:FBUserIDKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setEnableShareToFB:(BOOL)enableShareToFB {
	[[NSUserDefaults standardUserDefaults] setBool:enableShareToFB forKey:EnableShareToFBKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
