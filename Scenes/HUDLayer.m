//
//  HUDLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "HUDLayer.h"
#import "GameManager.h"

@interface HUDLayer ()
@property (nonatomic, strong) CCSprite *getReadyLabel;
@property (nonatomic, strong) CCSprite *gameOverLabel;
@property (nonatomic, strong) CCSprite *titleLabel;

@property (nonatomic, strong, readonly) NSDictionary *labelSpriteFrameNames;
@property (nonatomic, strong, readonly) NSDictionary *labelStates;
@end

@implementation HUDLayer

- (id)init {
	return [self initWithTextureAtlasNamed:@"HUD"];
}

- (instancetype)initWithTextureAtlasNamed:(NSString *)textureAtlasName {
	if (self = [super initWithTextureAtlasNamed:textureAtlasName]) {
		self.touchEnabled = YES;
		[self scheduleUpdate];
		
		_labelSpriteFrameNames = @{@"getReadyLabel": @"Get_Ready.png",
								   @"titleLabel": @"Title.png",
								   @"gameOverLabel": @"Game_Over.png"};
		
		_labelStates = @{@"titleLabel": @(GameStateMainMenu),
						 @"getReadyLabel": @(GameStateGetReady),
						 @"gameOverLabel": @(GameStateGetReady)};
	}
	return self;
}

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)addLabelIfNeeded:(NSString *)labelName {
	if ([self valueForKey:labelName]) return;
	
	CCSprite *label = [CCSprite spriteWithSpriteFrameName:[self labelSpriteFrameNames][labelName]];
	label.position = ccp(SCREEN_SIZE.width / 2.0f, SCREEN_SIZE.height * 0.75f);
	[self.sceneSpriteBatchNode addChild:label];
	[self setValue:label forKey:labelName];
}

- (void)removeLabelInNeeded:(NSString *)labelName {
	CCSprite *label = [self valueForKey:labelName];
	if (!label) return;
	
	id action = [CCSequence actionOne:[CCSpawn actionOne:[CCScaleBy actionWithDuration:2.0f scale:4.0]
													 two:[CCFadeOut actionWithDuration:2.0f]]
								  two:[CCCallBlockN actionWithBlock:^(CCNode *node) {
		[node removeFromParentAndCleanup:YES];
	}]];
	[label runAction:action];
	
	[self setValue:nil forKey:labelName];
}

/// add label if needed if condition == true, otherwise remove if needed if condition == false
- (void)addOrRemoveLabelNamed:(NSString *)labelName state:(GameState)state {
	const auto gameState = [GameManager sharedInstance].gameState;
	if (gameState == state)	[self addLabelIfNeeded:labelName];
	else					[self removeLabelInNeeded:labelName];
}

- (void)update:(ccTime)delta {
	[self.labelStates enumerateKeysAndObjectsUsingBlock:^(NSString *labelName, NSNumber *labelState, BOOL *stop) {
		[self addOrRemoveLabelNamed:labelName state:(GameState)labelState.integerValue];
	}];
	
	// TODO -> show menu buttons if needed
	
	// TODO -> show score if needed
	
	// TODO -> show counter if needed
	
	// TODO -> show copyright notice if needed
	
	// TODO -> show get ready if needed
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if ([GameManager sharedInstance].gameState == GameStateActive) {
		return NO;
	}
	
	if ([GameManager sharedInstance].gameState == GameStateGetReady) {
		[GameManager sharedInstance].gameState = GameStateActive;
		return YES;
	}
	
	// TODO -> Handle menu button taps (?)
	
	
	return YES;
}

@end
