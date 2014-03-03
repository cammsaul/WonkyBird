//
//  GameManager.m
//  WonkyBird
//
//  Created by Cam Saul on 2/25/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameManager.h"

@interface GameManager ()
@property (nonatomic, strong, readonly) NSMutableDictionary *gameScores;
@end

@implementation GameManager

+ (id)alloc {
	@synchronized(self) {
		static GameManager *__sharedInstance = nil;
		NSAssert(!__sharedInstance, @"Attempt to allocate a second instance of singleton class GameManager!");
		__sharedInstance = [super alloc];
		return __sharedInstance;
	}
}

+ (GameManager *)sharedInstance {
	@synchronized(self) {
		static GameManager *__sharedInstance;
		if (!__sharedInstance) {
			__sharedInstance = [[GameManager alloc] init];
		}
		return __sharedInstance;
	}
}

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

- (void)setGameState:(GameState)gameState {
	if (_gameState != gameState) {
		switch (gameState) {
			case GStateMainMenu: NSLog(@"GameState -> GStateMainMenu");	break;
			case GStateGetReady: NSLog(@"GameState -> GStateGetReady");	break;
			case GStateActive: {
				NSLog(@"GameState -> GStateActive");
				// set score for this round and all subsequent rounds to zero
				for (GameRound i = self.gameRound; i < countGameRound; i++) {
					[self setScore:0 forGameRound:i];
				}
			} break;
			case GStateGameOver: NSLog(@"GameState -> GStateGameOver");	break;
		}
	}
	_gameState = gameState;
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
	static NSString * const BestScoreKey = @"BestTotalScore";
	static NSInteger bestScore = -1;
	if (bestScore == -1) bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:BestScoreKey];
	if (bestScore < self.totalScore) {
		[[NSUserDefaults standardUserDefaults] setInteger:self.totalScore forKey:BestScoreKey];
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
