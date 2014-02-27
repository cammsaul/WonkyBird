//
//  HUDLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "HUDLayer.h"
#import "GameManager.h"

static NSString * const TitleLabelKey			= @"Title.png";
static NSString * const GetReadyLabelKey		= @"Get_Ready.png";
static NSString * const GameOverLabelKey		= @"Game_Over.png";
static NSString * const PlayButtonKey			= @"Button_Play.png";
static NSString * const RateButtonKey			= @"Button_Rate.png";
static NSString * const LeaderBoardButtonKey	= @"Button_Leader_Board.png";

@interface HUDSpriteInfo : NSObject
@property (nonatomic, readonly) GameState states;
@property (nonatomic, readonly) CGPoint position;
+ (HUDSpriteInfo *)states:(GameState)states position:(CGPoint)position;
@end

@implementation HUDSpriteInfo
+ (HUDSpriteInfo *)states:(GameState)states position:(CGPoint)position {
	HUDSpriteInfo *info = [[HUDSpriteInfo alloc] init];
	info->_states = states;
	info->_position = position;
	return info;
}
@end

@interface HUDLayer ()
@property (nonatomic, strong) CCSprite *getReadyLabel;
@property (nonatomic, strong) CCSprite *gameOverLabel;
@property (nonatomic, strong) CCSprite *titleLabel;

@property (nonatomic, strong) CCLabelBMFont *scoreLabel;

@property (nonatomic, strong, readonly) NSMutableDictionary *sprites;
@property (nonatomic, strong, readonly) NSDictionary *spriteInfo;
@end

@implementation HUDLayer

- (id)init {
	return [self initWithTextureAtlasNamed:@"HUD"];
}

- (instancetype)initWithTextureAtlasNamed:(NSString *)textureAtlasName {
	if (self = [super initWithTextureAtlasNamed:textureAtlasName]) {
		self.touchEnabled = YES;
		[self scheduleUpdate];
		
		const CGPoint labelPosition = ccp(ScreenWidth() / 2.0f, ScreenHeight() * 0.75f);
		static const GameState ButtonStates = (GameState)(GameStateMainMenu|GameStateGameOver);
		
		const float rateButtonY = ScreenHeight() * 0.45f;
		const float otherButtonsY = ScreenHeight() * 0.3f;
		
		// test the score font
		self.scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Font_Score_Large.fnt"];
		self.scoreLabel.position = labelPosition;
		[self addChild:self.scoreLabel];
		
		_sprites = @{}.mutableCopy;
		_spriteInfo = @{TitleLabelKey:			[HUDSpriteInfo states:GameStateMainMenu position:labelPosition],
						GetReadyLabelKey:		[HUDSpriteInfo states:GameStateGetReady position:labelPosition],
						GameOverLabelKey:		[HUDSpriteInfo states:GameStateGameOver position:labelPosition],
						PlayButtonKey:			[HUDSpriteInfo states:ButtonStates position:ccp(ScreenWidth() * 0.25f, otherButtonsY)],
						LeaderBoardButtonKey:	[HUDSpriteInfo states:ButtonStates position:ccp(ScreenWidth() * 0.75f, otherButtonsY)],
						RateButtonKey:			[HUDSpriteInfo states:ButtonStates position:ccp(ScreenWidth() * 0.5f, rateButtonY)]};
		
	}
	return self;
}

- (CCSprite *)objectForKeyedSubscript:(NSString *)spriteKey {
	return self.sprites[spriteKey];
}

- (void)setObject:(CCSprite *)sprite forKeyedSubscript:(NSString *)key {
	if (sprite) [self.sprites setObject:sprite forKey:key];
	else		[self.sprites removeObjectForKey:key];
}

- (void)registerWithTouchDispatcher {
	[[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)addSpriteWithKeyIfNeeded:(NSString *)spriteKey {
	if (self[spriteKey]) return;
	NSLog(@"add sprite: %@", spriteKey);
	
	CCSprite *sprite = [CCSprite spriteWithSpriteFrameName:spriteKey];
	sprite.position = [self.spriteInfo[spriteKey] position];
	[self.spriteBatchNode addChild:sprite];
	self[spriteKey] = sprite;
}

- (void)removeSpriteWithKeyIfNeeded:(NSString *)spriteKey {
	CCSprite *sprite = self[spriteKey];
	if (!sprite) return;
	
	static const float RemovalDuration = 0.5f;
	id action = [CCSequence actionOne:[CCSpawn actionOne:[CCScaleBy actionWithDuration:RemovalDuration scale:4.0]
													 two:[CCFadeOut actionWithDuration:RemovalDuration]]
								  two:[CCCallBlockN actionWithBlock:^(CCNode *node) {
		[node removeFromParentAndCleanup:YES];
	}]];
	[sprite runAction:action];
	
	self[spriteKey] = nil;
}

/// add sprite if needed if !(gameState & state), otherwise remove if needed if condition == false
- (void)addOrRemoveSpriteWithKey:(NSString *)spriteKey states:(GameState)states {
	const auto gameState = GState();
	if (gameState & states)	[self addSpriteWithKeyIfNeeded:spriteKey];
	else					[self removeSpriteWithKeyIfNeeded:spriteKey];
}

- (void)update:(ccTime)delta {
	[self.spriteInfo enumerateKeysAndObjectsUsingBlock:^(NSString *spriteKey, HUDSpriteInfo *info, BOOL *stop) {
		[self addOrRemoveSpriteWithKey:spriteKey states:info.states];
	}];

	self.scoreLabel.visible = GStateIsActive();
	self.scoreLabel.string = [NSString stringWithFormat:@"%d", [GameManager sharedInstance].gameScore];
	
	// TODO -> show copyright notice if needed
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
	if (GStateIsActive()) return NO;
	
	auto TouchedSprite = [&](NSString *spriteKey) -> CCSprite* {
		return CGRectContainsPoint([self.sprites[spriteKey] boundingBox], [self convertTouchToNodeSpace:touch]) ? self.sprites[spriteKey] : nil;
	};
	for (id spriteKey in @[PlayButtonKey, RateButtonKey, LeaderBoardButtonKey]) {
		if (auto sprite = TouchedSprite(spriteKey)) {
			sprite.scale = 0.9f;
		}
	}
	
	return YES;
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
	if (GStateIsActive()) return;
	
	auto TouchOnSprite = [=](NSString *spriteKey) -> bool {
		return CGRectContainsPoint([self.sprites[spriteKey] boundingBox], [self convertTouchToNodeSpace:touch]);
	};
	
	for (id spriteKey in @[PlayButtonKey, RateButtonKey, LeaderBoardButtonKey]) {
		if (CCSprite *sprite = self.sprites[spriteKey]) {
			sprite.scale = 1.0f;
		}
	}
	
	if (GState() & GameState(GameStateMainMenu|GameStateGameOver)) {
		// TODO -> move button back to appropriate location
		
		if (TouchOnSprite(PlayButtonKey)) {
			SetGState(GameStateGetReady);
		} else if (TouchOnSprite(RateButtonKey)) {
			SetGState(GameStateMainMenu);
		} else if (TouchOnSprite(LeaderBoardButtonKey)) {
		}
		return;
	}
	if (GStateIsGetReady()) {
		SetGState(GameStateActive);
	}
}

@end
