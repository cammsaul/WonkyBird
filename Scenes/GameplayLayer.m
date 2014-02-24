//
//  GameplayLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameplayLayer.h"
#import "BasicSprite.h"
#import "Toucan.h"

@interface GameplayLayer ()
@property (nonatomic, strong) Toucan *toucan;
@property (nonatomic, strong) BasicSprite *ground;
@property (nonatomic, strong) CCSpriteBatchNode *sceneSpriteBatchNode;
@end

@implementation GameplayLayer

- (instancetype)init {
	if (self = [super init]) {
		self.sceneSpriteBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"Textures.png"];
		[[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"Textures.plist" texture:self.sceneSpriteBatchNode.texture];
		
		self.toucan = [[Toucan alloc] init];
		self.toucan.position = ccp(SCREEN_SIZE.width / 2.0f, SCREEN_SIZE.height / 2.0f);
		[self addChild:self.toucan];
		
		self.world->SetGravity({0.0f, -1.0f});
		
		[self.toucan addToWorld:self.world];
		
		// add the ground
		static const int GroundHeight = 60;
		self.ground = [[BasicSprite alloc] init];
		self.ground.bodyDef->type = b2_staticBody;
		self.ground.position = CGPointMake(160, GroundHeight / 2);
		self.ground.contentSizeInPoints = CGSizeMake(320, GroundHeight);
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
