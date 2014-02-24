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

static const int GroundHeight = 60;

@interface GameplayLayer ()
@property (nonatomic, strong) Toucan *toucan;
@property (nonatomic, strong) BasicSprite *ground;
@property (nonatomic, strong) BasicSprite *roof;
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
		
		[self.toucan addToWorld:self.world];
		
		// add the ground
		self.ground = [[BasicSprite alloc] init];
		self.ground.bodyDef->type = b2_staticBody;
		self.ground.position = CGPointMake(160, GroundHeight / 2);
		self.ground.contentSizeInPoints = CGSizeMake(320, GroundHeight);
		self.ground.fixtureDef->density = 0.0f;
		[self.ground addToWorld:self.world];
		
		// add the "roof"
		self.roof = [[BasicSprite alloc] init];
		self.roof.bodyDef->type = b2_staticBody;
		self.roof.position = CGPointMake(160, (SCREEN_SIZE.height / 2) - 2);
		self.roof.contentSizeInPoints = CGSizeMake(320, 4);
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
	
	CCArray *gameObjects = self.children; // TODO - this should be iterated in a thread safe manner ?
	for (GameSprite *sprite in gameObjects) {
		[sprite updateStateWithDeltaTime:delta andListOfGameObjects:gameObjects];
	}
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (self.toucan.state != ToucanStateDead) {
		self.toucan.body->SetAwake(true);
		// toucan force is 100  / distance from ground
//		static const float ToucanConstForceBase = 80.0f; ///< minimum amount of force to apply to the toucan
//		static const float ToucanVariableForceBase = 40.0f; ///< amount of extra force to apply to toucan when it is on the ground
//		const float toucanMaxHeight = SCREEN_SIZE.height;
//		const float toucanRange = toucanMaxHeight - GroundHeight;
//		NSLog(@"self.toucan.position.y: %.1f", self.toucan.position.y);
//		const float toucanYAmount = ((self.toucan.position.y / CC_CONTENT_SCALE_FACTOR()) - GroundHeight) / toucanRange; ///< 1.0 is top of screen, 0 is ground
//		const float toucanForceMultiplier = 1.0 - toucanYAmount;
//		if (toucanForceMultiplier > 0) {
//			const float toucanForce = (ToucanVariableForceBase * toucanForceMultiplier) + ToucanConstForceBase;
////			NSLog(@"toucanForceMultiplier: %.1f", toucanForceMultiplier);
//			self.toucan.body->ApplyForceToCenter({0.0f, toucanForce}, true);
//		}
		self.toucan.body->ApplyForceToCenter({0.0f, 100}, true);
	}
	return YES;
}

@end
