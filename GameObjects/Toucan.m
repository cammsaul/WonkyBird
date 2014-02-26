//
//  Toucan.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Toucan.h"
#import "GameManager.h"

@interface Toucan ()
@property (nonatomic, strong) CCAnimation *flappingAnimation;
@property (nonatomic, strong) CCAnimation *fallingAnimation;
@end

@implementation Toucan

- (id)init {
	if (self = [super initWithSpriteFrameName:@"Toucan_1.png"]) {
		static const vector<unsigned> frameNums { 1, 2, 3, 2 };
		NSMutableArray *frames = [NSMutableArray arrayWithCapacity:frameNums.size()];
		for (auto frameNum : frameNums) {
			[frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Toucan_%d.png", frameNum]]];
		}
		self.flappingAnimation = [CCAnimation animationWithSpriteFrames:frames delay:0.04f];
		
		static const vector<unsigned> frameNums2 { 1, 2 };
		NSMutableArray *frames2 = [NSMutableArray arrayWithCapacity:frameNums.size()];
		for (auto frameNum : frameNums2) {
			[frames2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:@"Toucan_%d.png", frameNum]]];
		}
		self.fallingAnimation = [CCAnimation animationWithSpriteFrames:frames2 delay:0.10f];
		
		self.state = ToucanStateFlapping; // start out flapping on main menu
	}
	return self;
}

- (BOOL)idle		{ return self.state == ToucanStateIdle; }
- (BOOL)dead		{ return self.state == ToucanStateDead; }
- (BOOL)falling		{ return self.state == ToucanStateFalling; }
- (BOOL)flapping	{ return self.state == ToucanStateFlapping; }


- (void)setState:(ToucanState)state {
	const ToucanState lastState = _state;
	if (lastState == ToucanStateDead) {
		return; // already dead
	}
	
//	[self runAction:[CCRotateTo actionWithDuration:0.1f angle:(self.body->GetLinearVelocity().y * -50.0)]];
	
	if (lastState == state) return;
	[self stopAllActions];
	
	_state = state;
	switch (state) {
		case ToucanStateIdle: {
//			NSLog(@"Toucan -> idle");
			self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Toucan_Dead.png"];
		} break;
		case ToucanStateDead: {
//			NSLog(@"Toucan -> dead.");
			self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"Toucan_Dead.png"];
		} break;
		case ToucanStateFlapping: {
//			NSLog(@"Toucan -> flapping");
			[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.flappingAnimation]]];
		} break;
		case ToucanStateFalling: {
//			NSLog(@"Toucan -> falling");
			[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.fallingAnimation]]];
		} break;
		default: NSAssert(NO, @"Unhandled state for toucan: %d", state);
	}
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
	[super updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];
	
//	if (GStateIsActive() && self.isOffscreen) {
//		GState() = GameStateGameOver;
//	}
	
	// clamp to screen as needed
	const float minX = 0;
	const float maxX = ScreenWidth();
	if (self.x < minX) {
		self.xVelocity = 1;
	} else if (self.x > maxX) {
		self.xVelocity = -1;
	}
	if		(self.y < 0)				self.yVelocity = 1;
	else if (self.y > ScreenHeight())	self.yVelocity = -1;
	
	if (GState() == GameStateMainMenu) {
		self.state = self.yVelocity < 0 ? ToucanStateFalling : ToucanStateFlapping;
	}
	
	static const float MinXVelocityBeforeFlipping = 0.2f; ///< don't flipX until we're going at least this amount to prevent thrashing
	if		(self.xVelocity < -MinXVelocityBeforeFlipping /* -1 */)	self.flipX = YES;
	else if (self.xVelocity > MinXVelocityBeforeFlipping)			self.flipX = NO;
	
	float    rotation = self.yVelocity * 20;
	if		(rotation > 90.0f)  rotation =  90.0f;
	else if (rotation < -90.0f) rotation = -90.0f;
	self.rotation = rotation * (self.flipX ? 1.0f : -1.0f);
	
//	NSLog(@"y: %.3f", self.body->GetLinearVelocity().y);
	if (!self.item.body->IsAwake() || (self.yVelocity == 0 && self.falling)) {
		self.state = ToucanStateIdle;
	} else if (self.yVelocity <= 0) {
		self.state = ToucanStateFalling;
	} else {
		self.state = ToucanStateFlapping;
	}
}

@end
