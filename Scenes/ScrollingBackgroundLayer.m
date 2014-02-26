//
//  ScrollingBackgroundLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "ScrollingBackgroundLayer.h"
#import "GameManager.h"

@interface ScrollingBackgroundLayer ()
@end

@implementation ScrollingBackgroundLayer

- (id)init {
	if (self = [super initWithTextureAtlasNamed:@"Clouds"]) {
		srandom((int)time(NULL));
		for (int i = 0; i < 3; i++) {
			[self createCloud];
		}
		
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
	const CGSize screenSize = [CCDirector sharedDirector].winSize;
	
	const float xOffset = cloud.boundingBox.size.width / 2.0f;
	
	const int xPosition = screenSize.width + 1 + xOffset;
	
	const int yMin = (int)SCREEN_SIZE.height * 0.33f;
	const int yMax = (int)SCREEN_SIZE.height;
	const int yRange = yMax - yMin;
	const int yPosition = (random() % yRange) + yMin;
	
	cloud.position = ccp(xPosition, yPosition);
	
	static const int MaxCloudMoveDuration = 5;
	static const int MinCloudMoveDuration = 2;
	const int moveDuration = (random() % (MaxCloudMoveDuration - MinCloudMoveDuration)) + MinCloudMoveDuration;
	
	const float offscreenXPosition = (xOffset * -1) - 1;
	
	if ([GameManager sharedInstance].gameState != GameStateGameOver) {
		id moveAction = [CCMoveTo actionWithDuration:moveDuration position:ccp(offscreenXPosition, cloud.position.y)];
		id resetAction = [CCCallFuncN actionWithTarget:self selector:@selector(resetCloudWithNode:)];
		id sequenceAction = [CCSequence actions:moveAction,resetAction,nil];
		[cloud runAction:sequenceAction];
	}
	
	const int newZOrder = MaxCloudMoveDuration - moveDuration;
	[self.spriteBatchNode reorderChild:cloud z:newZOrder];
}

- (void)update:(ccTime)delta {
	if ([GameManager sharedInstance].gameState == GameStateGameOver) {
		for (id child in self.spriteBatchNode.children) {
			[child stopAllActions];
		}
	}
}

@end
