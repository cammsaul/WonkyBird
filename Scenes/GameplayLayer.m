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

static const int GroundHeight = 90;

@interface GameplayLayer ()
@property (nonatomic, strong) Toucan *toucan;
@property (nonatomic, strong) BasicSprite *ground;
@property (nonatomic, strong) BasicSprite *roof;
@end

@implementation GameplayLayer

- (instancetype)init {
	if (self = [super initWithTextureAtlasNamed:@"Textures"]) {
		self.toucan = [[Toucan alloc] init];
		self.toucan.position = ccp(SCREEN_SIZE.width / 2.0f, SCREEN_SIZE.height / 2.0f);
		[self.sceneSpriteBatchNode addChild:self.toucan];
		[self.toucan addToWorld:self.world];
		
		// add the ground
		self.ground = [[BasicSprite alloc] init];
		self.ground.bodyDef->type = b2_staticBody;
		self.ground.position = CGPointMake(SCREEN_SIZE.width / 2.0f, GroundHeight / 2);
		self.ground.contentSize = CGSizeMake(SCREEN_SIZE.width, GroundHeight);
		self.ground.fixtureDef->density = 0.0f;
		[self.ground addToWorld:self.world];
		
		// add the "roof"
		self.roof = [[BasicSprite alloc] init];
		self.roof.bodyDef->type = b2_staticBody;
		self.roof.position = CGPointMake(160, SCREEN_SIZE.height - 2);
		self.roof.contentSize = CGSizeMake(320, 4);
		self.roof.fixtureDef->density = 0.0f;
		self.roof.fixtureDef->restitution = 0;
		[self.roof addToWorld:self.world];
		
		self.touchEnabled = YES;
	}
	return self;
}

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)update:(ccTime)delta {
	[super update:delta];
	
	CCArray *gameObjects = self.sceneSpriteBatchNode.children; // TODO - this should be iterated in a thread safe manner ?
	for (GameSprite *sprite in gameObjects) {
		[sprite updateStateWithDeltaTime:delta andListOfGameObjects:gameObjects];
	}
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (self.toucan.state != ToucanStateDead) {
		self.toucan.body->SetAwake(true);
		self.toucan.body->ApplyForceToCenter({10.0f, 200}, true);
	}
	return YES;
}

@end
