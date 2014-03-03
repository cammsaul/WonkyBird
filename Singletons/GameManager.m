//
//  GameManager.m
//  WonkyBird
//
//  Created by Cam Saul on 2/25/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import <Mixpanel/Mixpanel.h>

#import "GameManager.h"
#import "GameKitManager.h"
#import "TwitterManager.h"
#import "FacebookShare.h"

static NSString * const BestScore_Total_Key			= @"hscore_Total";
static NSString * const BestScore_Rasta_Key			= @"hscore_Rasta";
static NSString * const BestScore_Lucky_Key			= @"hscore_Lucky";
static NSString * const LifetimePoints_Total_Key	= @"lftm_pts_Total";
static NSString * const LifetimePoints_Rasta_Key	= @"lftm_pts_Rasta";
static NSString * const LifetimePoints_Lucky_Key	= @"lftm_pts_Lucky";
static NSString * const LifetimeRounds_Total_Key	= @"lftm_rnds_Total";
static NSString * const LifetimeRounds_Rasta_Key	= @"lftm_rnds_Rasta";
static NSString * const LifetimeRounds_Lucky_Key	= @"lftm_rnds_Lucky";

@interface GameManager ()
@property (nonatomic, strong, readonly) NSMutableDictionary *gameScores;

@property (nonatomic, readonly) NSString *scoreShareMessage;
@property (nonatomic, readonly) NSString *highScoreShareMessage;
@end

@implementation GameManager

- (instancetype)init {
	if (self = [super init]) {
		self.gameState = GStateMainMenu; // start in main menu
		_gameScores = [NSMutableDictionary dictionary];
		self.currentRoundScore = 0;
	}
	return self;
}

- (float)gameSpeed {
	return (GState() & (GStateActive|GStateGetReady)) ? ((1.0f + (ScorePipeXVelocityMultiplier * CurrentRoundScore())) * (self.reverse ? -1.0f : 1.0f)) : 0;
}

- (BOOL)reverse {
	return (self.currentRoundScore / CrazyBackwardsModeScore) % 2 != 0;
}

- (NSNumber *)objectForKeyedSubscript:(NSString *)key {
	return @([[NSUserDefaults standardUserDefaults] integerForKey:key]);
}

- (void)setObject:(NSNumber *)value forKeyedSubscript:(NSString *)key {
	[[NSUserDefaults standardUserDefaults] setInteger:value.intValue forKey:key];
	[[Mixpanel sharedInstance].people set:key to:value];
}

- (void)setGameState:(GameState)gameState {
	if (_gameState != gameState) {
		switch (gameState) {
			case GStateMainMenu: NSLog(@"GameState -> GStateMainMenu (round %ld)", self.gameRound + 1);	break;
			case GStateGetReady: NSLog(@"GameState -> GStateGetReady (round %ld)", self.gameRound + 1);	break;
			case GStateActive: {
				NSLog(@"GameState -> GStateActive (round %ld)", self.gameRound + 1);
				// set score for this round and all subsequent rounds to zero
				for (GameRound i = self.gameRound; i < countGameRound; i++) {
					[self setScore:0 forGameRound:i];
				}
			} break;
			case GStateGameOver: {

				NSLog(@"GameState -> GStateGameOver (round %ld)", self.gameRound + 1);
				if (self.gameRound == GameRound2) {
					const auto round1Score = [self scoreForGameRound:GameRound1];
					const auto round2Score = [self scoreForGameRound:GameRound2];
					
					// save the relevant scores
					if (round1Score > self[BestScore_Rasta_Key].intValue) {
						self[BestScore_Rasta_Key] = @(round1Score);
					}
					if (round2Score > self[BestScore_Lucky_Key].intValue) {
						self[BestScore_Lucky_Key] = @(round2Score);
					}
					self[LifetimePoints_Rasta_Key] = @(self[LifetimePoints_Rasta_Key].intValue + round1Score);
					self[LifetimePoints_Lucky_Key] = @(self[LifetimePoints_Lucky_Key].intValue + round2Score);
					self[LifetimePoints_Total_Key] = @(self[LifetimePoints_Total_Key].intValue + round1Score + round2Score);
					
					self[LifetimeRounds_Total_Key] = @(self[LifetimeRounds_Total_Key].intValue + 1);
					self[LifetimeRounds_Rasta_Key] = @(self[LifetimeRounds_Rasta_Key].intValue + 1);
					self[LifetimeRounds_Lucky_Key] = @(self[LifetimeRounds_Lucky_Key].intValue + 1);
					
					[[NSUserDefaults standardUserDefaults] synchronize];
					
					if ([GameKitManager sharedInstance].userIsAuthenticated) {
						[[GameKitManager sharedInstance] reportScoresForGameOver];
					}
					
					if ([GameManager sharedInstance].totalScore == [GameManager sharedInstance].bestTotalScore) {
						const BOOL enableShareToTwitter = [TwitterManager canShareToTwitter] && [TwitterManager sharedInstance].enableShareToTwitter;
						const BOOL enableShareToFB = [FacebookShare sharedInstance].isAuthenticated;
						
						[[Mixpanel sharedInstance].people set:@"enbl_twitter" to:@(enableShareToTwitter)];
						[[Mixpanel sharedInstance].people set:@"enbl_fb" to:@(enableShareToFB)];

						if (enableShareToTwitter) {
							[self shareHighScoreToTwitter];
						}
						if (enableShareToFB) {
							[self shareHighScoreToFB];
						}
					}
				}
			} break;
		}
	}
	_gameState = gameState;
}

- (NSUInteger)lifetimeTotalPoints {
	return self[LifetimePoints_Total_Key].intValue;
}

- (NSUInteger)lifetimePointsForRound:(GameRound)gameRound {
	return self[(gameRound == GameRound1  ? LifetimePoints_Rasta_Key : LifetimePoints_Lucky_Key)].intValue;
}

- (NSInteger)scoreForGameRound:(GameRound)gameRound {
	return [self.gameScores[@(gameRound)] intValue];
}

- (void)setScore:(NSInteger)score forGameRound:(GameRound)gameRound {
	self.gameScores[@(gameRound)] = @(score);
}

- (NSInteger)currentRoundScore {
	return [self scoreForGameRound:self.gameRound];
}

- (void)setCurrentRoundScore:(NSInteger)currentRoundScore {
	[self setScore:currentRoundScore forGameRound:self.gameRound];
}


- (NSInteger)totalScore {
	int total = 0;
	for (int i = 0; i < countGameRound; i++) {
		total += [self.gameScores[@(i)] intValue];
	}
	return total;
}

- (NSUInteger)bestTotalScore {
	static NSInteger bestScore = -1;
	if (bestScore == -1) bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:BestScore_Total_Key];
	if (bestScore < self.totalScore) {
		[[NSUserDefaults standardUserDefaults] setInteger:self.totalScore forKey:BestScore_Total_Key];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"Updated best score: %zd --> %zd", bestScore, self.totalScore);
		bestScore = self.totalScore;
	}
	return bestScore;
}


#pragma mark - Sharing

- (NSString *)scoreShareMessage {
	NSNumber *appID = [NSBundle mainBundle].infoDictionary[@"LBAppID"];
	return [NSString stringWithFormat:@"Just scored %zd on #wonkybird https://itunes.apple.com/us/app/id%@", self.totalScore, appID];
}

- (NSString *)highScoreShareMessage {
	NSNumber *appID = [NSBundle mainBundle].infoDictionary[@"LBAppID"];
	return [NSString stringWithFormat:@"New high score: %zd on #wonkybird https://itunes.apple.com/us/app/id%@", self.totalScore, appID];
}

- (void)postStatus:(NSString *)status toTwitterWithCompletion:(void(^)(BOOL))completion {
	auto share = ^(void(^shareCompletion)(BOOL)){
		[TwitterManager sharedInstance].enableShareToTwitter = YES;
		[TwitterManager postStatusUpdate:status completion:shareCompletion];
	};
	
	if ([TwitterManager canShareToTwitter] /* already logged in */) {
		share(completion);
	} else {
		[TwitterManager loginWithTwitterSuccess:^{
			share(completion);
			if (completion) completion(YES);
		} error:^(NSError *error) {
			NSLog(@"Error logging into Twitter: %@", error);
			if (completion) completion(NO);
		}];
	}
}

- (void)shareToTwitter:(void(^)(BOOL))completion {
	[[Mixpanel sharedInstance] track:@"share_twitter_score"];
	[self postStatus:[self scoreShareMessage] toTwitterWithCompletion:^(BOOL success) {
		[[Mixpanel sharedInstance] track:(success ? @"share_twitter_score_success" : @"share_twitter_score_fail")];
		if (completion) completion(success);
	}];
}

- (void)shareHighScoreToTwitter {
	[[Mixpanel sharedInstance] track:@"share_twitter_high_score"];
	[self postStatus:[self highScoreShareMessage] toTwitterWithCompletion:^(BOOL success) {
		[[Mixpanel sharedInstance] track:(success ? @"share_twitter_high_score_success" : @"share_twitter_high_score_fail")];
	}];
}

- (void)shareToFB:(void(^)(BOOL))completion {
	[[Mixpanel sharedInstance] track:@"share_fb_score"];
	[FacebookShare authWithGraphAPIAndPostStatusMessage:[self scoreShareMessage] completion:^(BOOL success){
	[[Mixpanel sharedInstance] track:(success ? @"share_fb_score_success" : @"share_fb_score_fail")];
		if (success) {
			[FacebookShare sharedInstance].enableShareToFB = YES;
			NSLog(@"FB Share (score) successful.");
		}
		if (completion) completion(success);
	}];
}

- (void)shareHighScoreToFB {
	[[Mixpanel sharedInstance] track:@"share_fb_high_score"];
	[FacebookShare authWithGraphAPIAndPostStatusMessage:[self highScoreShareMessage] completion:^(BOOL success){
		[[Mixpanel sharedInstance] track:(success ? @"share_fb_high_score_success" : @"share_fb_high_score_fail")];
		if (success) {
			[FacebookShare sharedInstance].enableShareToFB = YES;
			NSLog(@"FB Share (high score) successful.");
		}
	}];
}

@end

#pragma mark - C Function Implementations

NSUInteger CurrentRoundScore() { return [GameManager sharedInstance].currentRoundScore; }
GameState GState() { return [[GameManager sharedInstance] gameState]; }
void SetGState(GameState gState) { [GameManager sharedInstance].gameState = gState; }
