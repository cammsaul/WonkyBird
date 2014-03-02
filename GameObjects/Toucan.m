//
//  Toucan.m
//  WonkyBird
//
//  Created by Cam Saul on 2/28/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Toucan.h"
#import "Pigeon.h"
#import "Constants.h"

@implementation Toucan

#define NOAH_PHYSICS 0
#define CAM_PHYSICS 0
#define COMPROMISE_PHYSICS 1

- (void)applyTouch:(NSUInteger)numFrames {
	#if NOAH_PHYSICS
		self.yVelocity = -kGravityVelocity * (.1f + (.05f * numFrames));
	#elif CAM_PHYSICS
		self.yVelocity = -kGravityVelocity * (.0f + (.1f * numFrames));
	#elif COMPROMISE_PHYSICS
		self.yVelocity = -kGravityVelocity * (.05f + (.075f * numFrames));
	#endif
}

- (void)flapAroundOnMainScreen:(NSArray *)birds {
	auto RandTimes10 = []{ return Rand() * kBirdMenuRandVelocity; };
	
	if (ABS(self.yVelocity) < 2) {
		const float BirdXDiff = (self.x - ScreenHalfWidth()) / ScreenHalfWidth(); /// < 1.0 = right edge, -1.0 = left
		
		static const float MinAntiGravityAmount = 0.0f;
		static const float MaxAntiGravityAmount = 0.7f;
		static const float AntiGravityRange = MaxAntiGravityAmount - MinAntiGravityAmount;
		static const int NumAntiGravityTurnsBeforeChanging = 200;
		static int NumAntiGravityTurns = NumAntiGravityTurnsBeforeChanging;
		static float AntiGravityAmount = MinAntiGravityAmount; // amount of gravity to apply on home screen will be random
		if (NumAntiGravityTurns > NumAntiGravityTurnsBeforeChanging) {
			AntiGravityAmount = (Rand() / (1.0/AntiGravityRange)) + MinAntiGravityAmount;
			NumAntiGravityTurns = 0;
		}
		NumAntiGravityTurns++;
		
		const float heightCorrectionVel = ((ScreenHeight() * kBirdMenuHeight) - self.y) * Rand() * AntiGravityAmount * 0.1f; ///< add neccessary velocity to keep Bird around the right y spot during flapping
		
		const float newYVel = (-kGravityVelocity * AntiGravityAmount) + heightCorrectionVel + RandTimes10();
		
		const float xVel = (Rand() > .5f) ? (RandTimes10() * -BirdXDiff) : ((RandTimes10() * 2) - kBirdMenuRandVelocity);
		self.item.body->ApplyForceToCenter({xVel, newYVel}, true);
		
		// move towards pigeons
		for (Bird *b in birds) {
			if (b == self) continue;
			if ([b isKindOfClass:Pigeon.class]) {
				self.item.body->ApplyForceToCenter({(b.box2DX - self.box2DX) * 0.5f, (b.box2DY - self.box2DY) * 0.5f}, true);
			}
		}
		
		if (ABS(self.yVelocity) < 2.0f) {
			self.item.body->ApplyTorque(-self.rotationBox2D, true);
		}
	}
}

- (void)createFixtures {
	[super createFixtures];
	self.item.body->SetGravityScale(1.2);
}

@end
