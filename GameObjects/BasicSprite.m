//
//  BasicSprite.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "BasicSprite.h"

@implementation BasicSprite

+ (instancetype)alloc {
	BasicSprite *item = nil;
	if ((item = [super alloc])) {
		item.shape = make_shared<b2PolygonShape>();
		item.fixtureDef = make_shared<b2FixtureDef>();
		item.fixtureDef->shape = item.shape.get();
	}
	return item;
}

- (void)addToWorld:(shared_ptr<b2World>)world {
	[self updateShape];
	[super addToWorld:world];
	self.body->CreateFixture(self.fixtureDef.get());
}

- (void)updateShape {	
	self.shape->SetAsBox(self.contentSizeForBox2D.x / 2, self.contentSizeForBox2D.y / 2);
}

@end
