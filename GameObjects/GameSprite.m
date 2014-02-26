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

- (float)x { return self.position.x; }
- (float)y { return self.position.y; }
- (void)setX:(float)x { self.position = ccp(x, self.y); }
- (void)setY:(float)y { self.position = ccp(self.x, y); }

- (b2Vec2)velocity { return self.item.body->GetLinearVelocity(); }
- (float)xVelocity { return self.velocity.x; }
- (float)yVelocity { return self.velocity.y; }

- (void)setVelocity:(b2Vec2)velocity  { self.item.body->SetLinearVelocity(velocity); }
- (void)setXVelocity:(float)xVelocity {	self.velocity = b2Vec2 {xVelocity, self.yVelocity}; }
- (void)setYVelocity:(float)yVelocity { self.velocity = b2Vec2 {self.xVelocity, yVelocity}; }

- (void)updateStateWithDeltaTime:(ccTime)deltaTime andListOfGameObjects:(CCArray *)listOfGameObjects {}

@end
