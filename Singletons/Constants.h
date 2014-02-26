//
//  Constants.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#ifndef WonkyBird_Constants_h
#define WonkyBird_Constants_h

static const float kPTMRatio = 100.0f;

static const float kGravityVelocity = -10.0f;

static inline CGSize ScreenSize() { return [CCDirector sharedDirector].winSize; }
static inline float ScreenWidth() { return ScreenSize().width; }
static inline float ScreenHeight() { return ScreenSize().height; }
static inline bool IsIphone5() { return ScreenHeight() > 480.0f; }

typedef enum : NSInteger {
	GameStateMainMenu	= 0b0001,
	GameStateGetReady	= 0b0010,
	GameStateActive		= 0b0100,
	GameStateGameOver	= 0b1000
} GameState;

GameState GState();
void SetGState(GameState gState);
static inline bool GStateIsActive()		{ return GState() == GameStateActive; }
static inline bool GStateIsGetReady()	{ return GState() == GameStateGetReady; }
static inline bool GStateIsMainMenu()	{ return GState() == GameStateMainMenu; }
static inline bool GStateIsGameOver()	{ return GState() == GameStateGameOver; }

#endif
