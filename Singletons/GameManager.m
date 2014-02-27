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
		self.gameState = GameStateMainMenu; // start in main menu
	}
	return self;
}

- (void)setGameState:(GameState)gameState {
	if (_gameState != gameState) {
		switch (gameState) {
			case GameStateMainMenu: NSLog(@"GameState -> GameStateMainMenu");	break;
			case GameStateGetReady: NSLog(@"GameState -> GameStateGetReady");	break;
			case GameStateActive: {
				NSLog(@"GameState -> GameStateActive");
				self.gameScore = 0;
			} break;
			case GameStateGameOver: NSLog(@"GameState -> GameStateGameOver");	break;
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

GameState GState() { return [[GameManager sharedInstance] gameState]; }
void SetGState(GameState gState) { [GameManager sharedInstance].gameState = gState; }
