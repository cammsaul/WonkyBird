//
//  Toucan.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Toucan.h"

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
	}
	return self;
}

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
			[self runAction:[CCRotateTo actionWithDuration:0.1f angle:-15.0f]];
		} break;
		case ToucanStateFalling: {
//			NSLog(@"Toucan -> falling");
			[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.fallingAnimation]]];
			[self runAction:[CCRotateTo actionWithDuration:1.1f angle:45.0f]];
		} break;
		default: NSAssert(NO, @"Unhandled state for toucan: %d", state);
	}
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
	[super updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];
	
//	NSLog(@"y: %.3f", self.body->GetLinearVelocity().y);
	if (!self.item.body->IsAwake() || (self.item.body->GetLinearVelocity().y == 0 && self.state == ToucanStateFalling)) {
		self.state = ToucanStateIdle;
	} else if (self.item.body->GetLinearVelocity().y <= 0) {
		self.state = ToucanStateFalling;
	} else {
		self.state = ToucanStateFlapping;
	}
}

@end
