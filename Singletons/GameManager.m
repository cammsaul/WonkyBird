//
//  GameManager.m
//  WonkyBird
//
//  Created by Cam Saul on 2/25/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameManager.h"
#import "GameKitManager.h"

static NSString * const BestScore_Total_Key			= @"BestScore_Total";
static NSString * const BestScore_Rasta_Key			= @"BestScore_Rasta";
static NSString * const BestScore_Lucky_Key			= @"BestScore_Lucky";
static NSString * const LifetimePoints_Total_Key	= @"LifetimePoints_Total";
static NSString * const LifetimePoints_Rasta_Key	= @"LifetimePoints_Rasta";
static NSString * const LifetimePoints_Lucky_Key	= @"LifetimePoints_Lucky";


@interface GameManager ()
@property (nonatomic, strong, readonly) NSMutableDictionary *gameScores;
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
					self[LifetimePoints_Rasta_Key] = @([self[LifetimePoints_Rasta_Key] intValue] + round1Score);
					self[LifetimePoints_Lucky_Key] = @([self[LifetimePoints_Lucky_Key] intValue] + round2Score);
					self[LifetimePoints_Total_Key] = @([self[LifetimePoints_Total_Key] intValue] + round1Score + round2Score);
					[[NSUserDefaults standardUserDefaults] synchronize];
					
					[[GameKitManager sharedInstance] reportScoresForGameOver];
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

@end

NSUInteger CurrentRoundScore() { return [GameManager sharedInstance].currentRoundScore; }
GameState GState() { return [[GameManager sharedInstance] gameState]; }
void SetGState(GameState gState) { [GameManager sharedInstance].gameState = gState; }
