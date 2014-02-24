//
//  GameplayLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameplayLayer.h"
#import "BasicSprite.h"

@interface GameplayLayer ()
@property (nonatomic, strong) BasicSprite *ground;
@end

@implementation GameplayLayer

- (instancetype)init {
	if (self = [super init]) {
		const CGSize screenSize = [CCDirector sharedDirector].winSize;
		BasicSprite *s = [[BasicSprite alloc] initWithFile:@"Icon-Small-50.png"];
		s.scale = 2.0f;
		s.position = ccp(screenSize.width / 2.0f, screenSize.height / 2.0f);
		[self addChild:s];
		
		self.world->SetGravity({0.0f, -1.0f});
		
		[s addToWorld:self.world];
		
		// add the ground
		static const int GroundHeight = 60;
		self.ground = [[BasicSprite alloc] init];
		self.ground.bodyDef->type = b2_staticBody;
		self.ground.position = CGPointMake(160, GroundHeight / 2);
		self.ground.contentSize = CGSizeMake(320, GroundHeight);
		self.ground.fixtureDef->density = 0.0f;
		self.ground.fixtureDef->restitution = 0.5;
		[self.ground addToWorld:self.world];
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
