//
//  GameplayLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#include <random>

#import "GameplayLayer.h"
#import "GameSprite.h"
#import "Toucan.h"
#import "Pipe.h"
#import "GameManager.h"

static const float PipeXVelocity = -1.4f; ///< base x velocity for pipe movement
static const float ScorePipeXVelocityMultiplier = 0.01f; ///< Amount each point should increase pipe velocity. e.g. if ScorePipeXVelocityMultiplier = 0.01f, 100 points means pipes move at double speed

static const float kToucanMenuRandVelocity = 10.0f; ///< Apply +/- this amount to toucan's x velocity in main menu
static auto Rand = std::bind (std::uniform_real_distribution<float>(0.0f, 1.0f), std::default_random_engine()); // nice random number between 0.0f and 1.0f

static float __lastTotalPipeSize = 0; // don't be too aggressive with adding new pipes if this is pretty big

static const int MinPipeSize = 2;
static const int MaxPipeSize = 8;
static const int MaxTotalSize = MaxPipeSize + MinPipeSize;
float RandomPipeSize() {
	static const int SizeRange = MaxPipeSize - MinPipeSize;
	return (random() % SizeRange) + MinPipeSize;
//	return MaxTotalSize - lastPipeSize;
}

static const int GroundHeight = 130;
static const int kMaxNumPipes = 12;

static const int ToucanTouchYVelocityBase = 100; ///< amount to add to toucan's Y velocity when screen is tapped
static const int ToucanTouchYVelocityRandom = 20; ///< random amount to add to toucan's y velocity when screen is tapped

@interface GameplayLayer ()
@property (nonatomic, strong) Toucan *toucan;
@property (nonatomic, strong) GameSprite *ground;
@property (nonatomic, strong) NSMutableArray *walls;
@property (nonatomic, strong) NSMutableArray *pipes;
@end

@implementation GameplayLayer

- (instancetype)init {
	if (self = [super initWithTextureAtlasNamed:@"Textures"]) {
		srandom((int)time(NULL));
		
		self.toucan = [[Toucan alloc] init];
		self.toucan.position = ccp(ScreenHalfWidth(), ScreenHeight() * kToucanMenuHeight);
		[self.spriteBatchNode addChild:self.toucan];
		[self.toucan.item addToWorld:self.world];
		
		// add the ground
		self.ground = [[GameSprite alloc] init];
		self.ground.item.bodyDef->type = b2_staticBody;
		self.ground.position = CGPointMake(ScreenHalfWidth(), GroundHeight / 2);
		self.ground.contentSize = CGSizeMake(ScreenWidth() * 2 /* extend out past edges a bit */, GroundHeight);
		self.ground.item.fixtureDef->density = 0.0f;
		[self.ground.item addToWorld:self.world];
		
		// add the "walls"
		self.walls = [NSMutableArray array];
		
		auto makeWall = [&](float x, float y, float width, float height) {
			GameSprite *wall = [[GameSprite alloc] init];
			wall.item.bodyDef->type = b2_staticBody;
			wall.position = CGPointMake(x, y);
			wall.contentSize = CGSizeMake(width, height);
			wall.item.fixtureDef->density = 0.0f;
			wall.item.fixtureDef->restitution = 0.4f;
			[wall.item addToWorld:self.world];
			[self.walls addObject:wall];
		};
		makeWall(ScreenHalfWidth(), ScreenHeight() + 2, ScreenWidth() * 2, 4); // roof
//		makeWall(-70 /* enough to move pipe offscreen */, ScreenHeight() / 2, 4, ScreenHeight()); // left wall
//		makeWall(ScreenWidth() + 2, ScreenHeight() / 2, 4, ScreenHeight()); // right wall
								
		self.pipes = [NSMutableArray array];
		
		self.touchEnabled = YES;
	}
	return self;
}

- (void)addPipeOfSize:(int)pipeSize upsideDown:(BOOL)upsideDown {
	NSParameterAssert(pipeSize >= MinPipeSize);
	NSParameterAssert(pipeSize <= MaxPipeSize);
	
	Pipe *p = [Pipe pipeOfSize:pipeSize upsideDown:upsideDown];
	const float pipeHalfHeight = p.contentSize.height / 2;
	p.position = CGPointMake(ScreenWidth(), (upsideDown ? (ScreenHeight() - pipeHalfHeight) : (pipeHalfHeight + GroundHeight)));
	[self addChild:p.layer];
	[p.item addToWorld:self.world];
	[self.pipes addObject:p];
	
	p.item.body->SetLinearVelocity({PipeXVelocity, -kGravityVelocity});
	p.item.body->SetGravityScale(0.0f); // pipes unaffected by gravity !
	
	// call self recursively to add upside-down pipe if needed
	if (!upsideDown) {
		const auto newPipeSize = MaxTotalSize - pipeSize;
		__lastTotalPipeSize = pipeSize + newPipeSize;
		[self addPipeOfSize:newPipeSize upsideDown:YES];
	}
}

- (void)removeOldPipes {
	Pipe *p = self.pipes.firstObject;
	if (p.position.x < -p.contentSize.width / 2) {
		[self.pipes removeObject:p];
		[self removeChild:p.layer cleanup:YES];
		[self removeOldPipes];
	}
}

- (void)addRandomPipeIfNeeded {
	[self removeOldPipes];
	
	if (self.pipes.count >= kMaxNumPipes) return;
	static float nextPipeDistance = 0.3f;
	
	// how far was the most recent pipe?
	Pipe *lastPipe = self.pipes.lastObject;
	
	if (lastPipe.layer.position.x > ScreenWidth() * nextPipeDistance) return; // too soon
	
//	const float totalPipeSizeModifier = (MaxTotalSize - __lastTotalPipeSize) * 0.1f; // 8 --> 0 : 0.8f --> (worst) 0 (best)
//	static const float Aggression = 0.0f; // how aggresively we add new pipes
//	static const float Range = 0.1f; // how much agression can differ, in terms of size of screen
//	const float MinNextPipeDistance = Aggression + totalPipeSizeModifier; ///< LATEST point (lowest x) at which to add another pipe
//	const float MaxNextPipeDistance = Aggression + Range + totalPipeSizeModifier; ///< EARLIEST point (highest x) at which to add another pipe
//	const float NextPipeDistRange = MaxNextPipeDistance - MinNextPipeDistance;
	
//	NSLog(@"modifier: %.2f, min: %.2f, max: %.2f", totalPipeSizeModifier, MinNextPipeDistance, MaxNextPipeDistance);
	
	[self addPipeOfSize:RandomPipeSize() upsideDown:NO];
//	nextPipeDistance = 0.8f;
//	nextPipeDistance = ((random() % (int)(NextPipeDistRange * 1000)) / 1000.0f) + MinNextPipeDistance;
//	const float nextPipeDist = 0.8f;
}

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)update:(ccTime)delta {
	static GameState lastState = GameStateMainMenu;
	
	if (GStateIsMainMenu()) {
		auto RandTimes10 = []{ return Rand() * kToucanMenuRandVelocity; };
		
		if (ABS(self.toucan.yVelocity) < 2) {
			const float toucanXDiff = (self.toucan.x - ScreenHalfWidth()) / ScreenHalfWidth(); /// < 1.0 = right edge, -1.0 = left
			
			static const float MinAntiGravityAmount = 0.0f;
			static const float MaxAntiGravityAmount = 0.7f;
			static const float AntiGravityRange = MaxAntiGravityAmount - MinAntiGravityAmount;
			static const int NumAntiGravityTurnsBeforeChanging = 200;
			static int NumAntiGravityTurns = NumAntiGravityTurnsBeforeChanging;
			static float AntiGravityAmount = MinAntiGravityAmount; // amount of gravity to apply on home screen will be random
			if (NumAntiGravityTurns > NumAntiGravityTurnsBeforeChanging) {
				AntiGravityAmount = (Rand() / (1.0/AntiGravityRange)) + MinAntiGravityAmount;
				NSLog(@"Today's random anti-gravity amount = %.02f", AntiGravityAmount);
				NumAntiGravityTurns = 0;
			}
			NumAntiGravityTurns++;
			
			const float heightCorrectionVel = ((ScreenHeight() * kToucanMenuHeight) - self.toucan.y) * Rand() * AntiGravityAmount * 0.1f; ///< add neccessary velocity to keep toucan around the right y spot during flapping
			
			const float newYVel = (-kGravityVelocity * AntiGravityAmount) + heightCorrectionVel + RandTimes10();
		
			const float xVel = (Rand() > .5f) ? (RandTimes10() * -toucanXDiff) : ((RandTimes10() * 2) - kToucanMenuRandVelocity);
			self.toucan.item.body->ApplyForceToCenter({xVel, newYVel}, true);
		}
	}
	else if (GStateIsGetReady())
	{
		self.toucan.state = ToucanStateFlapping;
		const float toucanYDiff = (self.toucan.y - (ScreenHeight() * 0.60f)) / kPTMRatio;
		const float toucanXDiff = (self.toucan.x - ScreenHalfWidth()) / kPTMRatio;
		self.toucan.velocity =  b2Vec2{-toucanXDiff, -toucanYDiff};
		
		for (Pipe *p in self.pipes) {
			[self removeChild:p.layer cleanup:YES];
		}
		[self.pipes removeAllObjects];
	}
	else if (GStateIsActive())
	{
		if (lastState != GameStateActive) {
			self.toucan.x = ScreenHalfWidth();
			self.toucan.xVelocity = 0.0f;
		}
		
		if (ABS(self.toucan.xVelocity) >= 0.2f) {
			NSLog(@"Toucan x: %.2f", self.toucan.xVelocity);
			self.toucan.state = ToucanStateDead;
		}

		if (self.toucan.dead) {
			SetGState(GameStateGameOver);
		} else {
			[self addRandomPipeIfNeeded];
		}
		
		for (Pipe *p in self.pipes) {
			const float pipeXVelocity = PipeXVelocity * (1.0f + ([GameManager sharedInstance].gameScore * ScorePipeXVelocityMultiplier));
			p.item.body->SetLinearVelocity({pipeXVelocity, 0});
			[p updateStateWithDeltaTime:delta];
		}
	}
	else if (GStateIsGameOver()) {
		for (Pipe *p in self.pipes) {
			p.item.body->SetGravityScale(1.0f);
			p.item.body->SetLinearVelocity({0.0f, kGravityVelocity});
			[p updateStateWithDeltaTime:delta];
		}
	}
	
	[super update:delta];
	
	CCArray *gameObjects = self.spriteBatchNode.children; // TODO - this should be iterated in a thread safe manner ?
	for (GameSprite *sprite in gameObjects) {
		[sprite updateStateWithDeltaTime:delta andListOfGameObjects:gameObjects];
	}
	
	lastState = GState();
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (!GStateIsActive()) {
		return NO;
	}
	
	if (self.toucan.state != ToucanStateDead && self.toucan.yVelocity <= 1.0f) {
		self.toucan.item.body->SetAwake(true);
				
//		self.toucan.yVelocity = 20;
		
		// move toucan towards horizontal center of screen if needed
		auto linearVelocity = self.toucan.item.body->GetLinearVelocity();
//		linearVelocity.x = (ScreenHalfWidth() / kPTMRatio) - self.toucan.item.positionForBox2D.x;
		linearVelocity.y = -kGravityVelocity * 0.5f;
		self.toucan.item.body->SetLinearVelocity(linearVelocity);
	}
	return YES;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {
	self.toucan.item.body->ApplyForceToCenter({0, 10}, true);
}

@end
