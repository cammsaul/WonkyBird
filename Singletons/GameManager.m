//
//  GameManager.m
//  WonkyBird
//
//  Created by Cam Saul on 2/25/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameManager.h"

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
	}
	return self;
}

- (float)gameSpeed {
	return (GState() & (GStateActive|GStateGetReady)) ? ((1.0f + (ScorePipeXVelocityMultiplier * GameScore())) * (GameScore() > CrazyBackwardsModeScore ? -1.0f : 1.0f)) : 0;
}

- (BOOL)reverse {
	return [self gameSpeed] < 0.0f;
}

- (void)setGameState:(GameState)gameState {
	if (_gameState != gameState) {
		switch (gameState) {
			case GStateMainMenu: NSLog(@"GameState -> GStateMainMenu");	break;
			case GStateGetReady: NSLog(@"GameState -> GStateGetReady");	break;
			case GStateActive: {
				NSLog(@"GameState -> GStateActive");
				self.gameScore = 0;
			} break;
			case GStateGameOver: NSLog(@"GameState -> GStateGameOver");	break;
		}
	}
	_gameState = gameState;
}

- (NSUInteger)bestScore {
	static NSString * const BestScoreKey = @"BestScore";
	static NSInteger bestScore = -1;
	if (bestScore == -1) bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:BestScoreKey];
	if (bestScore < self.gameScore) {
		[[NSUserDefaults standardUserDefaults] setInteger:self.gameScore forKey:BestScoreKey];
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"Updated best score: %zd --> %zd", bestScore, self.gameScore);
		bestScore = self.gameScore;
	}
	return bestScore;
}

@end

NSUInteger GameScore() { return [GameManager sharedInstance].gameScore; }
GameState GState() { return [[GameManager sharedInstance] gameState]; }
void SetGState(GameState gState) { [GameManager sharedInstance].gameState = gState; }
