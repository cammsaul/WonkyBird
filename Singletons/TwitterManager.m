//
//  TwitterManager.m
//  GeoTip
//
//  Created by Cameron Saul on 10/31/13.
//  Copyright (c) 2013 GeoTip Technologies, Inc. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Social/Social.h>

extern "C" {
	#import <OAuthCore.h>
	#import "XLogging.h"
	#import "XGCDUtilites.h"
}
#import "NSString+Expa.h"

#import "TwitterManager.h"

typedef NSString * const Credential;
static Credential TwitterConsumerKey				= @"17k7SkRQ1Uh3eExgEk4CQ";							///< token for @geotip -> GeoTip Twitter app
static Credential TwitterConsumerSecret				= @"emBc0Br6zUCNa11AZ21VOYWMB2OOYVgPklGjkTN1n8";	///< token for @geotip -> GeoTip Twitter app

static ACAccountStore *__accountStore; // you must keep this around as long as you need the account access info
static TwitterManager *__twitterManager;

static NSString * const UserDefaultsOAuthTokenKey		= @"com.luckybird.wonkybird.OAuthTokenKey";
static NSString * const UserDefaultsOAuthTokenSecretKey = @"com.luckybird.wonkybird.OAuthTokenSecretKey";

@interface TwitterManager () <UIActionSheetDelegate>
@property (nonatomic, strong, readwrite) NSArray *accounts;
@property (nonatomic, strong, readwrite) NSDictionary *twitterCredentials;
@property (nonatomic, copy, readwrite) void(^successBlock)();
@property (nonatomic, copy, readwrite) TwitterLoginErrorBlock errorBlock;

+ (TwitterManager *)sharedInstance;
@end

@implementation TwitterManager

+ (void)loginWithTwitterSuccess:(void(^)())successBlock error:(TwitterLoginErrorBlock)errorBlock {
	__accountStore = [[ACAccountStore alloc] init];
	
	BOOL userHasAccessToTwitter = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
	if (!userHasAccessToTwitter) {
		__accountStore = nil;
		NSError *error = [[NSError alloc] initWithDomain:NSStringFromClass(self) code:0 userInfo:@{NSLocalizedDescriptionKey: @"Please log in to your Twitter account in iOS Settings to log in to WonkyBird with Twitter." }];
		XLog(self, LogFlagError, @"User not logged into Twitter: %@", error);
		errorBlock(error);
		return;
	}
	
	ACAccountType *twitterAccountType = [__accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	[__accountStore requestAccessToAccountsWithType:twitterAccountType options:nil completion:^(BOOL granted, NSError *error) {
		if (!granted || error) {
			__accountStore = nil;
			if (!error) error = [[NSError alloc] initWithDomain:NSStringFromClass(self) code:0 userInfo:@{NSLocalizedDescriptionKey: @"You must grant access to WonkyBird to access your Twitter account to log in with Twitter." }];
			XLog(self, LogFlagError, @"Error getting Twitter account access: %@", error);
			errorBlock(error);
			return;
		}
		
		// Step 2: create a request
		
		[self sharedInstance].accounts = [__accountStore accountsWithAccountType:twitterAccountType];
		[self sharedInstance].successBlock = ^{
			if (successBlock) successBlock();
		};
		[self sharedInstance].errorBlock = ^(NSError *error2){
			if (errorBlock) errorBlock(error2);
		};
		
		dispatch_async_main(^{
			UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Select Account" delegate:[self sharedInstance] cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:nil];
			for (ACAccount *account in [self sharedInstance].accounts) [actionSheet addButtonWithTitle:account.username];
			[actionSheet showInView:[CCDirector sharedDirector].view];
		});
		return;
	}];
}

+ (void)loginWithTwitterAccount:(ACAccount *)twitterAccount {
	XLog(self, LogFlagInfo, @"Twitter account: %@", twitterAccount);
	
	void(^successBlock)() = [self sharedInstance].successBlock;
	[self sharedInstance].successBlock = nil;
	TwitterLoginErrorBlock errorBlock = [self sharedInstance].errorBlock;
	[self sharedInstance].errorBlock = nil;
	[self sharedInstance].accounts = nil;
	
	if (!twitterAccount) {
		errorBlock([NSError errorWithDomain:NSStringFromClass([TwitterManager class]) code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Please select a twitter account."}]);
		return;
	}
	
	// Get a request token so we can make the request
	NSURLRequest *request = [self signedRequestWithTwitterEndpoint:@"oauth/request_token" httpPOST:YES accountOAuthToken:nil accountOAuthSecret:nil params:@{@"x_auth_mode": @"reverse_auth"}];
	[NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		NSString *authenticationHeader = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
		if (connectionError) {
			__accountStore = nil;
			XLog(self, LogFlagError, @"Error making Step 2 Request Token Request: %@", authenticationHeader);
			NSError *error = [[NSError alloc] initWithDomain:NSStringFromClass([TwitterManager class]) code:2 userInfo:@{NSLocalizedDescriptionKey: authenticationHeader}];
			errorBlock(error);
			return;
		}
		
		XLog(self, LogFlagInfo, @"got authentication header: %@", authenticationHeader);
		
		// Step 3: Obtain the Access Token
		NSURL *accessTokenURL = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
		SLRequest *accessTokenRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:accessTokenURL parameters:@{@"x_reverse_auth_target":		TwitterConsumerKey,
																																								@"x_reverse_auth_parameters":	authenticationHeader}];
		[accessTokenRequest setAccount:twitterAccount];
		[accessTokenRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
			__accountStore = nil;
			if (error) {
				NSString *twitterErrorStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
				XLog(self, LogFlagError, @"Error making Step 3 Access Token Request: %@", twitterErrorStr);
				NSError *nsError = [[NSError alloc] initWithDomain:NSStringFromClass([TwitterManager class]) code:3 userInfo:@{NSLocalizedDescriptionKey: @"Couldn't log into Twitter. Go to Settings and making sure your passwords for all of your Twitter accounts are entered correctly. They may have been reset if you updated or restored your phone recently."}];
				errorBlock(nsError);
				return;
			}
			
			NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
			NSMutableDictionary *credentials = [NSMutableDictionary dictionary];
			for (NSString *part in parts) {
				NSArray *keyAndValue = [part componentsSeparatedByString:@"="];
				credentials[keyAndValue[0]] = keyAndValue[1];
			}
			XLog(self, LogFlagInfo, @"Got credentials: %@", credentials);
			if (!credentials[@"oauth_token"]) {
				XLog(self, LogFlagInfo, @"Invalid response for Step 3: %@", responseStr);
				NSError *nsError = [[NSError alloc] initWithDomain:NSStringFromClass([TwitterManager class]) code:3 userInfo:@{NSLocalizedDescriptionKey: responseStr}];
				errorBlock(nsError);
				return;
			}
			
			// stash oauth_token and oauth_token_secret for the posting of twitter statuses as needed
			[[NSUserDefaults standardUserDefaults] setObject:credentials[@"oauth_token"] forKey:UserDefaultsOAuthTokenKey];
			[[NSUserDefaults standardUserDefaults] setObject:credentials[@"oauth_token_secret"] forKey:UserDefaultsOAuthTokenSecretKey];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			successBlock();
			[self sharedInstance].successBlock = nil;
			[self sharedInstance].errorBlock = nil;
		}];
	}];
}


#pragma mark - Helper Methods

+ (NSURLRequest *)signedRequestWithTwitterEndpoint:(NSString *)endpoint httpPOST:(BOOL)methodIsPost accountOAuthToken:(NSString *)accountTokenOrNil accountOAuthSecret:(NSString *)secretOrNil params:(NSDictionary *)params {
	NSString *method = methodIsPost ? @"POST" : @"GET";
	
	NSURL *url = [NSURL URLWithString:[@"https://api.twitter.com/" stringByAppendingString:endpoint]];
	XLog(self, LogFlagInfo, @"generating signed twitter request for URL: %@ (%@)", url, method);

    //  Build our parameter string
    NSMutableString *paramsAsString = [[NSMutableString alloc] init];
    [params enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         [paramsAsString appendFormat:@"%@=%@&", key, obj];
     }];
	
    //  Create the authorization header and attach to our request
    NSData *bodyData = [paramsAsString dataUsingEncoding:NSUTF8StringEncoding];
	XLog(self, LogFlagInfo, @"Body data: %@", paramsAsString);
	
	NSString *authorizationHeader = OAuthorizationHeader(url, method, bodyData, TwitterConsumerKey, TwitterConsumerSecret, accountTokenOrNil, secretOrNil);
	XLog(self, LogFlagInfo, @"Authorization header: %@", authorizationHeader);
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:10.f];
    [request setHTTPMethod:method];
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    if (methodIsPost) [request setHTTPBody:bodyData];
	
    return request;
}


#pragma mark - UIActionSheetDelegate 

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == actionSheet.cancelButtonIndex) {
		[TwitterManager loginWithTwitterAccount:nil];
	} else {
		[TwitterManager loginWithTwitterAccount:self.accounts[buttonIndex - 1]];
	}
}


#pragma mark - Sharing

+ (BOOL)canShareToTwitter {
	NSString *oauthToken		= [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsOAuthTokenKey];
	NSString *oauthTokenSecret	= [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsOAuthTokenSecretKey];
	return oauthToken.length && oauthTokenSecret.length;
}

+ (void)postStatusUpdate:(NSString *)status {
	if (![self canShareToTwitter]) {
		XLog(self, LogFlagError, @"Error posting status update: user is not logged in.");
		return;
	}
	
	NSString *oauthToken		= [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsOAuthTokenKey];
	NSString *oauthTokenSecret	= [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsOAuthTokenSecretKey];

	NSDictionary *params = @{@"status": [status urlEncodeUsingEncoding:NSUTF8StringEncoding]};
	auto request = [self signedRequestWithTwitterEndpoint:@"1.1/statuses/update.json" httpPOST:YES accountOAuthToken:oauthToken accountOAuthSecret:oauthTokenSecret params:params];
	[NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
		NSError *jsonError = nil;
		NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
		if (jsonError) {
			XLog(self, LogFlagError, @"Error parsing JSON: %@", jsonError);
			return;
		}
		XLog(self, LogFlagInfo, @"Posted a tweet: %@", jsonDict);
	}];
}

static NSString * const EnableShareToTwitterKey = @"EnableShareToTwitter";

- (BOOL)enableShareToTwitter {
	return [[NSUserDefaults standardUserDefaults] boolForKey:EnableShareToTwitterKey];
}

- (void)setEnableShareToTwitter:(BOOL)enableShareToTwitter {
	[[NSUserDefaults standardUserDefaults] setBool:enableShareToTwitter forKey:EnableShareToTwitterKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
