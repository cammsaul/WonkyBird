//
//  Pigeon.m
//  WonkyBird
//
//  Created by Cam Saul on 2/28/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Pigeon.h"
#import "Toucan.h"
#import "Constants.h"

@implementation Pigeon

- (void)applyTouch:(NSUInteger)numFrames {
	if (self.yVelocity < 0) {
		self.yVelocity = -kGravityVelocity * 0.6f;
		
		const float angle = self.item.body->GetAngle();
		self.item.body->ApplyTorque(-angle, true);
	}
}

- (void)flapAroundOnMainScreen:(NSArray *)birds {
	auto RandTimes10 = []{ return Rand() * kBirdMenuRandVelocity; };
	
	if (ABS(self.yVelocity) < 2) {
		const float BirdXDiff = (self.x - ScreenHalfWidth()) / ScreenHalfWidth(); /// < 1.0 = right edge, -1.0 = left
		
		const float newYVel = -kGravityVelocity * ((ScreenHeight() * kBirdMenuHeight) - self.y) * Rand() * Rand() * 0.1f;
		
		const float xVel = (Rand() > .5f) ? (RandTimes10() * -BirdXDiff) : ((RandTimes10() * 2) - kBirdMenuRandVelocity);
		self.item.body->ApplyForceToCenter({xVel, newYVel}, true);
		
		// move away from toucans
		for (Bird *b in birds) {
			if (b == self) continue;
			if ([b isKindOfClass:Toucan.class]) {
				self.item.body->ApplyForceToCenter({(self.box2DX - b.box2DX) / 10.0f, (self.box2DY - b.box2DY) * 2.0f}, true);
			}
		}
	}
}

- (void)createFixtures {
	[super createFixtures];
	self.item.body->SetGravityScale(1.4);
}
//
//- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
//	[super updateStateWithDeltaTime:deltaTime andListOfGameObjects:listOfGameObjects];
//	
//	self.fix
//	
//	if (self.yVelocity < 0) {
//		self.yVelocity *= 1.01;
//	}
//}
@end
