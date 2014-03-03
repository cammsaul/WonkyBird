//
//  HUDLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "HUDLayer.h"
#import "GameManager.h"
#import "GameKitManager.h"

static NSString * const TitleLabelKey			= @"Title.png";
static NSString * const GetReadyLabelKey		= @"Get_Ready.png";
static NSString * const GameOverLabelKey		= @"Game_Over.png";
static NSString * const PlayButtonKey			= @"Button_Play.png";
static NSString * const RateButtonKey			= @"Button_Rate.png";
static NSString * const LeaderBoardButtonKey	= @"Button_Leader_Board.png";
static NSString * const ScoreBackgroundKey		= @"Score_Background.png";
static NSString * const CopyrightLabelKey		= @"LuckyBird_2014.png";
static NSString * const TapLeftKey				= @"Button_Tap_Left.png";
static NSString * const TapRightKey				= @"Button_Tap_Right.png";
static NSString * const TapFingerKey			= @"Finger.png";

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
@property (nonatomic, strong) CCLabelBMFont *scoreLabel;
@property (nonatomic, strong) CCLabelBMFont *scoreBoardScoreLabel;
@property (nonatomic, strong) CCLabelBMFont *scoreBoardBestLabel;

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
		
		const float labelYPosition = ScreenHeight() * 0.75f;
		const float rateButtonY = ScreenHeight() * 0.45f;
		const float otherButtonsY = ScreenHeight() * 0.3f;
		const float scoreboardYPosition = (labelYPosition + rateButtonY) / 2.0f;
		const float scoreboardScoreYPosition = scoreboardYPosition + 12.0f;
		const float scoreboardBestYPosition = scoreboardYPosition - 28.0f;
		
		const CGPoint labelPosition = ccp(ScreenHalfWidth(), labelYPosition);
		static const GameState ButtonStates = (GameState)(GStateMainMenu|GStateGameOver);
		
		self.scoreLabel = [CCLabelBMFont labelWithString:@"" fntFile:@"Font_Score_Large.fnt"];
		self.scoreLabel.position = ccp(ScreenHalfWidth(), ScreenHeight() * 0.9f);
		[self addChild:self.scoreLabel z:0];
					
		self.scoreBoardScoreLabel = [CCLabelBMFont labelWithString:@"10" fntFile:@"Font_Score_Small.fnt"];
		self.scoreBoardScoreLabel.position = ccp(ScreenHalfWidth(), scoreboardScoreYPosition);
		[self addChild:self.scoreBoardScoreLabel z:1];
		
		self.scoreBoardBestLabel = [CCLabelBMFont labelWithString:@"100" fntFile:@"Font_Score_Small.fnt"];
		self.scoreBoardBestLabel.position = ccp(ScreenHalfWidth(), scoreboardBestYPosition);
		[self addChild:self.scoreBoardBestLabel z:1];
		
		_sprites = @{}.mutableCopy;
		_spriteInfo = @{TitleLabelKey:			[HUDSpriteInfo states:GStateMainMenu position:labelPosition],
						GetReadyLabelKey:		[HUDSpriteInfo states:GStateGetReady position:labelPosition],
						GameOverLabelKey:		[HUDSpriteInfo states:GStateGameOver position:labelPosition],
						CopyrightLabelKey:		[HUDSpriteInfo states:GStateMainMenu position:ccp(ScreenHalfWidth(), ScreenHeight() * 0.15f)],
						ScoreBackgroundKey:		[HUDSpriteInfo states:GStateGameOver position:ccp(ScreenHalfWidth(), scoreboardYPosition)],
						PlayButtonKey:			[HUDSpriteInfo states:ButtonStates position:ccp(ScreenWidth() * 0.25f, otherButtonsY)],
						LeaderBoardButtonKey:	[HUDSpriteInfo states:ButtonStates position:ccp(ScreenWidth() * 0.75f, otherButtonsY)],
						RateButtonKey:			[HUDSpriteInfo states:ButtonStates position:ccp(ScreenWidth() * 0.5f, rateButtonY)],
						TapLeftKey:				[HUDSpriteInfo states:GStateGetReady position:ccp(ScreenWidth() * 0.3f, ScreenHeight() * BirdGetReadyHeight)],
						TapRightKey:			[HUDSpriteInfo states:GStateGetReady position:ccp(ScreenWidth() * 0.7f, ScreenHeight() * BirdGetReadyHeight)],
						TapFingerKey:			[HUDSpriteInfo states:GStateGetReady position:ccp(ScreenHalfWidth(), ScreenHeight() * (BirdGetReadyHeight - 0.08f))],
						};
		
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
	self.scoreBoardScoreLabel.visible = GStateIsGameOver();
	self.scoreBoardBestLabel.visible = GStateIsGameOver();
	
	if (GStateIsGetReady()) {
		static float timeSinceLastTap = 0;
		timeSinceLastTap += delta;
		if (timeSinceLastTap > 0.8f) {
			timeSinceLastTap = 0;
			CCSprite *tapSprite = self.sprites[TapFingerKey];
			tapSprite.scale = 0.8f;
			[tapSprite runAction:[CCScaleTo actionWithDuration:0.25f scale:1.0f]];
		}
	}
	if (GStateIsActive()) {
		self.scoreLabel.string = [NSString stringWithFormat:@"%zd", [GameManager sharedInstance].totalScore];
	} else if (GStateIsGameOver()) {
		self.scoreBoardScoreLabel.string = [NSString stringWithFormat:@"%zd", [GameManager sharedInstance].totalScore];
		self.scoreBoardBestLabel.string = [NSString stringWithFormat:@"%zd", [GameManager sharedInstance].bestTotalScore];
	}

	// TODO -> show copyright notice if needed (start screen)
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
	
	if (GState() & GameState(GStateMainMenu|GStateGameOver)) {
		// TODO -> move button back to appropriate location
		
		if (TouchOnSprite(PlayButtonKey)) {
			SetGState(GStateGetReady);
		} else if (TouchOnSprite(RateButtonKey)) {
			NSNumber *appID = [NSBundle mainBundle].infoDictionary[@"LBAppID"];
			NSAssert([appID intValue], @"Set the key 'LBAppID' in the app's info.plist!");
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appID]]];
		} else if (TouchOnSprite(LeaderBoardButtonKey)) {
			[[GameKitManager sharedInstance] showLeaderboard];
		}
		return;
	}
	if (GStateIsGetReady()) {
		SetGState(GStateActive);
	}
}

@end
