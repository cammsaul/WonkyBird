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

static const float kGravityVelocity = -(kPTMRatio / 10.0f);

static inline CGSize ScreenSize()		{ return [CCDirector sharedDirector].winSize; }
static inline float ScreenWidth()		{ return ScreenSize().width; }
static inline float ScreenHalfWidth()	{ return ScreenWidth() / 2.0f; }
static inline float ScreenHeight()		{ return ScreenSize().height; }
static inline float ScreenHalfHeight()	{ return ScreenHeight() / 2.0f; }
static inline bool IsIphone5()			{ return ScreenHeight() > 480.0f; }

typedef enum : NSInteger {
	GStateMainMenu	= 0b0001,
	GStateGetReady	= 0b0010,
	GStateActive	= 0b0100,
	GStateGameOver	= 0b1000,
} GameState;

GameState GState();
void SetGState(GameState gState);
static inline bool GStateIsActive()		{ return GState() == GStateActive; }
static inline bool GStateIsGetReady()	{ return GState() == GStateGetReady; }
static inline bool GStateIsMainMenu()	{ return GState() == GStateMainMenu; }
static inline bool GStateIsGameOver()	{ return GState() == GStateGameOver; }

NSUInteger CurrentRoundScore(); ///< Returns the score for the current game round.

static auto Rand = std::bind (std::uniform_real_distribution<float>(0.0f, 1.0f), std::default_random_engine()); // nice random number between 0.0f and 1.0f


static const float PipeXVelocity = -1.1f; ///< base x velocity for pipe movement
static const float ScorePipeXVelocityMultiplier = 0.01f; ///< Amount each point should increase pipe velocity. e.g. if ScorePipeXVelocityMultiplier = 0.01f, 100 points means pipes move at double speed

static const float NextPipeDistance = 0.25f; ///< position on screen pipes must get to before adding new ones, e.g. 0.25 is 25% from the left. Lower numbers means waiting longer before adding new pipes.

static const float kBirdMenuRandVelocity = 10.0f; ///< Apply +/- this amount to Bird's x velocity in main menu

static const float BirdGetReadyHeight = 0.6f; ///< How far up (percent of screen height) bird should flap at during the "Get Ready" stage
static const float BirdXVelocityDeathThreshold = 0.2f; ///< During gameplay, if absolute value of bird's x velocity >= this amount, bird is dead. This allows for a some sliding and slight bumping of pipes without causing death

static const int MinPipeSize = 2;
static const int InitialMaxSize = 6;
static const int MaxMaxSize = 9;
static const int MaxPipeSize = MaxMaxSize - MinPipeSize;

static const int GroundHeight = 130;
static const int kMaxNumPipes = 12;

static const int CrazyBackwardsModeScore = 50;		///< game reverse when you pass this many points
static const int CrazySwitchBackgroundsScore = 10;	///< switch background every time we pass 10
static const int CrazyBackgroundSkewScore = 25;		///< apply skew transforms to BG every point after this
static const int CrazyBackgroundToucanChance = 1000; ///< approx every 1000 points we will switch the BG to toucan for a lil bit
#endif
