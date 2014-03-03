//
//  GameSprite.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameSprite.h"

@implementation GameSprite

+ (instancetype)alloc {
	GameSprite *gameSprite = nil;
	if ((gameSprite = [super alloc])) {
		NSLog(@"init %@", NSStringFromClass(self));
		gameSprite->_item = [[Box2DItem alloc] initWithOwner:gameSprite];
	}
	return gameSprite;
}

- (BOOL)isOffscreen {
	return self.x < -(self.contentSize.width / 2);
}

- (float)rotationBox2DDegrees { return self.rotationBox2D * (-90.0f / M_PI_2); }
- (float)rotationBox2D { return self.item.body->GetAngle(); }

- (float)angularVelocity { return self.item.body->GetAngularVelocity(); }
- (void)setAngularVelocity:(float)angularVelocity { self.item.body->SetAngularVelocity(angularVelocity); }

- (float)x { return self.position.x; }
- (float)y { return self.position.y; }
- (float)box2DX { return self.item.positionForBox2D.x; }
- (float)box2DY { return self.item.positionForBox2D.y; }
- (void)setX:(float)x { self.position = CGPointMake(x, self.y); }
- (void)setY:(float)y { self.position = CGPointMake(self.x, y); }

- (b2Vec2)velocity { return self.item.body->GetLinearVelocity(); }
- (float)xVelocity { return self.velocity.x; }
- (float)yVelocity { return self.velocity.y; }

- (void)setVelocity:(b2Vec2)velocity  { self.item.body->SetLinearVelocity(velocity); }
- (void)setXVelocity:(float)xVelocity {	self.velocity = b2Vec2 {xVelocity, self.yVelocity}; }
- (void)setYVelocity:(float)yVelocity { self.velocity = b2Vec2 {self.xVelocity, yVelocity}; }

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {
//	self.item.body->SetTransform(self.item.positionForBox2D, self.rotation / M_PI_2);
}

@end
