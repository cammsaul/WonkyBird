//
//  BasicSprite.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "BasicSprite.h"

@implementation BasicSprite

- (void)setup {
	[super setup];
	self.shape = make_shared<b2PolygonShape>();
	[self updateShape];
	self.fixtureDef = make_shared<b2FixtureDef>();
	self.fixtureDef->shape = self.shape.get();
}

- (void)addToWorld:(shared_ptr<b2World>)world {
	[super addToWorld:world];
	
	self.body->CreateFixture(self.fixtureDef.get());
}

- (void)updateShape {	
	if (self.shape) self.shape->SetAsBox(self.contentSizeForBox2D.x / 2, self.contentSizeForBox2D.y / 2, self.positionForBox2D, 0);
}

- (void)setContentSize:(CGSize)contentSize {
	[super setContentSize:contentSize];
	[self updateShape];
}

@end
