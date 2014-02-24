//
//  GameplayLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameplayLayer.h"
#import "SquareSprite.h"

@implementation GameplayLayer

- (instancetype)init {
	if (self = [super init]) {
		const CGSize screenSize = [CCDirector sharedDirector].winSize;
		SquareSprite *s = [[SquareSprite alloc] initWithFile:@"Icon-72.png"];
		s.scale = 2.0f;
		s.position = ccp(screenSize.width / 2.0f, screenSize.height / 2.0f);
		[self addChild:s];
		
		self.world->SetGravity({0.0f, -1.0f});
		
		[s addToWorld:self.world];
		
	}
	return self;
}

- (void)update:(ccTime)delta {
	[super update:delta];
	
	CCArray *gameObjects = self.children; // TODO - this should be iterated in a thread safe manner ?
	for (GameSprite *sprite in gameObjects) {
		// do something with sprite
	}
}

@end
