//
//  GameKitManager.m
//  WonkyBird
//
//  Created by Cam Saul on 3/2/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import <GameKit/GameKit.h>
extern "C" {
	#import <XGCDUtilites.h>
}

#import "GameManager.h"
#import "GameKitManager.h"

@interface GameKitManager () <GKGameCenterControllerDelegate>
@property (nonatomic, copy) void(^authenticationCompletionBlock)(BOOL);
- (void)authenticateUser:(void(^)(BOOL success))completion; ///< call this method to authenticate the current user, usually on app launch
@end

@implementation GameKitManager

- (instancetype)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameKitAuthenticationChanged:) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
	}
	return self;
}

- (BOOL)userIsAuthenticated {
	return [GKLocalPlayer localPlayer].isAuthenticated;
}

- (void)authenticateUser:(void(^)(BOOL success))completion {
	if (self.userIsAuthenticated) {
		if (completion) completion(YES);
		return;
	}
	
	auto completionOnMain = ^(BOOL success){
		dispatch_async_main(^{
			if (completion) completion(success);
		});
	};
	
	dispatch_async_default_priority(^{
		static NSError *__authenticationError = nil;
		if (__authenticationError) {
			NSLog(@"GameKit authentication Error: %@", __authenticationError);
			completionOnMain(NO);
			return;
		}
		
		self.authenticationCompletionBlock = completionOnMain;
		[[GKLocalPlayer localPlayer] setAuthenticateHandler:^(UIViewController *viewController, NSError *error) {
			if (error) {
				__authenticationError = error;
				NSLog(@"GameKit authentication Error: %@", error);
				if (self.authenticationCompletionBlock) self.authenticationCompletionBlock(NO);
				self.authenticationCompletionBlock = nil;
			} else {
				if (viewController) {
					[[CCDirector sharedDirector] presentViewController:viewController animated:YES completion:nil];
				} else {
					if (self.authenticationCompletionBlock) self.authenticationCompletionBlock(NO);
					self.authenticationCompletionBlock = nil;
				}
			}
		}];
	});
}

- (void)showLeaderboard {
	[self authenticateUser:^(BOOL success) {
		if (success) {
			dispatch_async_background_priority(^{
				GKGameCenterViewController *gameCenterVC = [[GKGameCenterViewController alloc] init];
				dispatch_async_main(^{
					if (gameCenterVC) {
						[[CCDirector sharedDirector] presentViewController:gameCenterVC animated:YES completion:nil];
						gameCenterVC.gameCenterDelegate = self;
					}

				});
			});
		}
	}];
}

- (void)reportScoresForGameOver {
	[self authenticateUser:^(BOOL success) {
		[self reportAchievements];
		[self reportScores];
	}];
}

- (GKScore *)scoreWithName:(NSString *)scoreName {
	return [[GKScore alloc] initWithLeaderboardIdentifier:[NSString stringWithFormat:@"%@.score.%@", [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"], scoreName]];
}

- (void)reportScores {
	NSMutableArray *scores = [NSMutableArray array];
	[@{@"total": @([GameManager sharedInstance].totalScore),
	   @"Rasta": @([[GameManager sharedInstance] scoreForGameRound:GameRound1]),
	   @"Lucky": @([[GameManager sharedInstance] scoreForGameRound:GameRound2]),
	   } enumerateKeysAndObjectsUsingBlock:^(id key, NSNumber *value, BOOL *stop) {
		   GKScore *score = [self scoreWithName:key];
		   score.value = value.intValue;
		   [scores addObject:score];
	   }];
	
	if (scores.count) {
		[GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
			if (error) {
				NSLog(@"Error reporting scores: %@", error);
			} else {
				NSLog(@"Reported scores: %@", scores);
			}
		}];
	}
}

- (GKAchievement *)achievementWithName:(NSString *)name {
	return [[GKAchievement alloc] initWithIdentifier:[NSString stringWithFormat:@"%@.%@", [NSBundle mainBundle].infoDictionary[@"CFBundleIdentifier"], name]];
}

- (void)reportAchievements {
	const auto totalScore = [GameManager sharedInstance].totalScore;
	const auto round1Score = [[GameManager sharedInstance] scoreForGameRound:GameRound1];
	const auto round2Score = [[GameManager sharedInstance] scoreForGameRound:GameRound2];
	const auto lifetimePoints = [GameManager sharedInstance].lifetimeTotalPoints;
	const auto lifetimeRastaPoints = [[GameManager sharedInstance] lifetimePointsForRound:GameRound1];
	const auto lifetimeLuckyPoints = [[GameManager sharedInstance] lifetimePointsForRound:GameRound2];
	
	NSLog(@"Lifetime points: %lu + %lu = %lu", lifetimeRastaPoints, lifetimeLuckyPoints, lifetimePoints);
	
	__block NSMutableArray *achievements = [NSMutableArray array];
	
	auto setAchievement = ^(NSString *name, float percentComplete) {
		auto achievement = [self achievementWithName:name];
		achievement.percentComplete = percentComplete;
		[achievements addObject:achievement];
	};
	auto completeAchievement = ^(NSString *name) {
		setAchievement(name, 100.0f);
	};
	
	if (totalScore > 10)	completeAchievement(@"10Points");
	if (totalScore > 100)	completeAchievement(@"BirdMaster");
	if (round1Score > 10)	completeAchievement(@"ToucanTamer");
	if (round1Score > 50)	completeAchievement(@"ToucanMaster");
	if (round2Score > 10)	completeAchievement(@"PigeonTamer");
	if (round1Score > 50)	completeAchievement(@"PigeonMaster");
	
	setAchievement(@"PigeonLover", lifetimeLuckyPoints/10.0f);
	setAchievement(@"ToucanLover", lifetimeRastaPoints/10.0f);
	setAchievement(@"BirdLover", lifetimePoints/10.0f);
	
	if (achievements.count) {
		[GKAchievement reportAchievements:achievements withCompletionHandler:^(NSError *error) {
			if (error) {
				NSLog(@"Error reporting acheivement complete: %@", error);
			} else {
				NSLog(@"Reported achievements: %@", achievements);
			}
		}];
	}
}

- (void)setAuthenticationCompletionBlock:(void (^)(BOOL))authenticationCompletionBlock {
	if (authenticationCompletionBlock) {
		NSLog(@"Uh oh: Attempt to set duplicate authentication completion block!!!!");
	}
	
	_authenticationCompletionBlock = [authenticationCompletionBlock copy];
}

#pragma mark -  Notifications

- (void)gameKitAuthenticationChanged:(NSNotification *)notification {
	NSLog(@"GameKit Authenticated? %d", self.userIsAuthenticated);
	if (self.authenticationCompletionBlock) self.authenticationCompletionBlock(self.userIsAuthenticated);
	self.authenticationCompletionBlock = nil;
}


#pragma mark - GKGameCenterControllerDelegate

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController {
	[[CCDirector sharedDirector] dismissViewControllerAnimated:YES completion:nil];
}

@end
