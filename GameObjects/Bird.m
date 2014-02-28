//
//  Bird.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Bird.h"
#import "GameManager.h"
#import "GB2ShapeCache.h"

@interface Bird ()
@property (nonatomic, strong) CCAnimation *flappingAnimation;
@property (nonatomic, strong) CCAnimation *fallingAnimation;
@end

@implementation Bird

+ (void)load {
	[[GB2ShapeCache sharedShapeCache] addShapesWithFile:@"ShapeDefs.plist"];
}

- (NSString *)spriteName:(NSString *)suffix {
	return [NSString stringWithFormat:@"%@_%@.png", NSStringFromClass([self class]), suffix];
}

- (id)init {
	if (self = [super initWithSpriteFrameName:[self spriteName:@"1"]]) {
		static const vector<unsigned> frameNums { 1, 2, 3, 2 };
		NSMutableArray *frames = [NSMutableArray arrayWithCapacity:frameNums.size()];
		for (auto frameNum : frameNums) {
			[frames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:[self spriteName:@"%d"], frameNum]]];
		}
		self.flappingAnimation = [CCAnimation animationWithSpriteFrames:frames delay:0.04f];
		
		static const vector<unsigned> frameNums2 { 1, 2 };
		NSMutableArray *frames2 = [NSMutableArray arrayWithCapacity:frameNums.size()];
		for (auto frameNum : frameNums2) {
			[frames2 addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[NSString stringWithFormat:[self spriteName:@"%d"], frameNum]]];
		}
		self.fallingAnimation = [CCAnimation animationWithSpriteFrames:frames2 delay:0.10f];
		
		self.state = BirdStateFlapping; // start out flapping on main menu
	}
	return self;
}

- (void)createFixtures {
	[[GB2ShapeCache sharedShapeCache] addFixturesToBody:self.item.body forShapeName:[NSString stringWithFormat:@"%@_1", NSStringFromClass([self class])]];
}

//- (BOOL)idle		{ return self.state == BirdStateIdle; }
- (BOOL)dead		{ return self.state == BirdStateDead; }
- (BOOL)falling		{ return self.state == BirdStateFalling; }
- (BOOL)flapping	{ return self.state == BirdStateFlapping; }


- (void)setState:(BirdState)state {
	if (_state == state) return;
	[self stopAllActions];
	
	_state = state;
	switch (state) {
		case BirdStateDead: {
			NSLog(@"Bird -> dead.");
			self.displayFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:[self spriteName:@"Dead"]];
		} break;
		case BirdStateFlapping: {
			[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.flappingAnimation]]];
		} break;
		case BirdStateFalling: {
			[self runAction:[CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:self.fallingAnimation]]];
		} break;
		default: NSAssert(NO, @"Unhandled state for Bird: %d", state);
	}
}

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
	[super updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];
	
	if (self.dead) return;

	// clamp to screen as needed
	if (GStateIsMainMenu() || GStateIsActive()) {
		const float minX = 0;
		const float maxX = ScreenWidth();
		if (self.x < minX) {
			self.x = minX;
			self.xVelocity = 1;
		} else if (self.x > maxX) {
			self.xVelocity = -1;
			self.x = maxX;
		}
		if		(self.y < 0)				self.yVelocity = 1;
		else if (self.y > ScreenHeight())	self.yVelocity = -1;
	}
	
	self.rotation = self.rotationBox2DDegrees * (self.flipX ? -1.0f : 1.0f);
	if (self.rotation > 90) self.rotation = 90;
	if (self.rotation < -90) self.rotation = -90;
	
	const BOOL lowYVelocity = ABS(self.yVelocity) < 0.1f;
//	if (lowYVelocity) {
//		self.rotation *= ABS(self.yVelocity) * 10;
//	}
	
//	self.item.body->SetAngularVelocity(self.yVelocity);
	self.item.body->ApplyTorque(-(self.rotationBox2D + self.angularVelocity) + (lowYVelocity ? 0 : self.yVelocity), true);
	
	if (GStateIsMainMenu()) {
		self.state = self.yVelocity < 0.2f ? BirdStateFalling : BirdStateFlapping;
		
		static const float MinXVelocityBeforeFlipping = 0.2f; ///< don't flipX until we're going at least this amount to prevent thrashing
		if		(self.xVelocity < -MinXVelocityBeforeFlipping /* -1 */)	self.flipX = YES;
		else if (self.xVelocity > MinXVelocityBeforeFlipping)			self.flipX = NO;
	}
	else if (GStateIsGetReady()) {
		self.flipX = NO;
		self.state = BirdStateFlapping;
	}
	else if (GStateIsActive()) {
		self.flipX = NO;
		
		if (self.isOffscreen || !self.item.body->IsAwake() || (self.yVelocity == 0 && self.falling)) {
			self.state = BirdStateDead;
		} else if (self.yVelocity <= 0.2f) {
			self.state = BirdStateFalling;
		} else {
			self.state = BirdStateFlapping;
		}
	}
}

- (void)applyTouch:(NSUInteger)numFrames {
	NSAssert(NO, @"subclasses should override this!");
}

- (void)flapAroundOnMainScreen:(NSArray *)birds {
	NSAssert(NO, @"subclasses should override this!");
}

@end
