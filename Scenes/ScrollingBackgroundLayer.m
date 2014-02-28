//
//  ScrollingBackgroundLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "ScrollingBackgroundLayer.h"
#import "GameManager.h"
#import "Box2DItem.h"
#import "MainScene.h"
#import "Box2DLayer.h"

@interface CCTMXTiledMapWithBox2D : CCTMXTiledMap  <Box2DItemOwner>
@property (nonatomic, strong) Box2DItem *item;
@end
@implementation CCTMXTiledMapWithBox2D
@end

@interface ScrollingBackgroundLayer ()
@property (nonatomic, strong) CCTMXTiledMapWithBox2D *grass;
@end

static const int MaxNumClouds = 6;

@implementation ScrollingBackgroundLayer

- (id)init {
	if (self = [super initWithTextureAtlasNamed:@"Clouds"]) {
		srandom((int)time(NULL));
		for (int i = 0; i < MaxNumClouds; i++) {
			[self createCloud];
		}
		
		self.grass = [CCTMXTiledMapWithBox2D tiledMapWithTMXFile:@"Grass.tmx"];
		[self addChild:self.grass];
		self.grass.position = ccp(0, GroundHeight - 16.0f);
		
		self.grass.item = [[Box2DItem alloc] initWithOwner:self.grass];
		self.grass.item.bodyDef->type = b2_dynamicBody;
//		self.grass.item.fixtureDef->isSensor = true;
		self.grass.item.fixtureDef->filter.categoryBits = 0;
		self.grass.item.bodyDef->gravityScale = 0;
		self.contentSize = self.grass.contentSize;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			[self.grass.item addToWorld:[MainScene mainScene].box2DLayer.world];
		});
		
		[self scheduleUpdate];
	}
	return self;
}

- (void)createCloud {
	const int cloudToDraw = random() % 2; ///< which of the 6 cloud assets to draw
	NSString * const cloudFilename = [NSString stringWithFormat:@"Cloud_%d.png", cloudToDraw + 1];
	CCSprite *cloudSprite = [CCSprite spriteWithSpriteFrameName:cloudFilename];
	
	[self.spriteBatchNode addChild:cloudSprite];
	[self resetCloudWithNode:cloudSprite];
}

- (void)resetCloudWithNode:(CCNode *)cloud {
	const float cloudHalfWidth = cloud.boundingBox.size.width / 2.0f;
	
	const int xPosition = [GameManager sharedInstance].reverse ? -cloudHalfWidth : (ScreenWidth() + cloudHalfWidth);
	
	const int yMin = (int)ScreenHeight() * 0.33f;
	const int yMax = (int)ScreenHeight();
	const int yRange = yMax - yMin;
	const int yPosition = (random() % yRange) + yMin;
	
	cloud.position = ccp(xPosition, yPosition);
	
	const int MaxCloudMoveDuration = GStateIsActive() ? 8 : 40;
	const int MinCloudMoveDuration = GStateIsActive() ? 2 : 20;
	const int moveDuration = (random() % (MaxCloudMoveDuration - MinCloudMoveDuration)) + MinCloudMoveDuration;
	
	const float offscreenXPosition = [GameManager sharedInstance].reverse ? (ScreenWidth() + cloudHalfWidth) : -cloudHalfWidth;
	
	id moveAction = [CCMoveTo actionWithDuration:moveDuration position:ccp(offscreenXPosition, cloud.position.y)];
	id resetAction = [CCCallFuncN actionWithTarget:self selector:@selector(resetCloudWithNode:)];
	id sequenceAction = [CCSequence actions:moveAction,resetAction,nil];
	[cloud runAction:sequenceAction];
	
	const int newZOrder = MaxCloudMoveDuration - moveDuration;
	cloud.scale = (((MaxCloudMoveDuration - moveDuration) / (float)MaxCloudMoveDuration) * 0.5f) + 0.5f;
	[self.spriteBatchNode reorderChild:cloud z:newZOrder];
}

- (void)update:(ccTime)delta {
	static GameState lastState;
	
	if (GState() != lastState) {
		
		for (id child in self.spriteBatchNode.children) {
			if (GStateIsGameOver()) {
				[child stopAllActions];
			} else {
				[self resetCloudWithNode:child];
			}
		}
	}
	lastState = GState();
	
	auto pos = self.grass.position;
	if (pos.x < - 80.0f) {
		pos.x += 80.0f;
		self.grass.position = pos;
		[self.grass.item moveToNewPosition];
	} else if (pos.x > 0.0f) {
		pos.x -= 80.0f;
		self.grass.position = pos;
		[self.grass.item moveToNewPosition];
	}
	
	self.grass.item.body->SetLinearVelocity({PipeXVelocity * [GameManager sharedInstance].gameSpeed, 0});
}

@end
