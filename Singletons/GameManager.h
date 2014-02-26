//
//  GameManager.h
//  WonkyBird
//
//  Created by Cam Saul on 2/25/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

typedef enum : NSInteger {
	GameStateMainMenu	= 0b0001,
	GameStateGetReady	= 0b0010,
	GameStateActive		= 0b0100,
	GameStateGameOver	= 0b1000
} GameState;

@interface GameManager : NSObject

+ (GameManager *)sharedInstance;

@property (nonatomic) GameState gameState;

@end
