//
//  SquareSprite.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "SquareSprite.h"

@implementation SquareSprite

- (void)addToWorld:(shared_ptr<b2World>)world {
	[super addToWorld:world];
	
	// just create a box fixture for time being
	b2PolygonShape shape;
	shape.SetAsBox(self.contentSizeForBox2D.x, self.contentSizeForBox2D.y);
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &shape;
	self.body->CreateFixture(&fixtureDef);
}

@end
