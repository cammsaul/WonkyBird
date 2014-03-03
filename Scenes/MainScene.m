//
//  MainScene.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import <CocosDenshion/CocosDenshion.h>
#import <CocosDenshion/SimpleAudioEngine.h>

#import "MainScene.h"
#import "StaticBackgroundLayer.h"
#import "ScrollingBackgroundLayer.h"
#import "GameplayLayer.h"
#import "HUDLayer.h"
#import "GameManager.h"
#import "Bird.h"
#import "GameKitManager.h"

@interface MainScene ()
@property (nonatomic, strong) StaticBackgroundLayer *staticBackgroundLayer;
@property (nonatomic, strong) ScrollingBackgroundLayer *scrollingBackgroundLayer;
@property (nonatomic, strong) GameplayLayer *gameplayLayer;
@property (nonatomic, strong) HUDLayer *hudLayer;
@end

static MainScene *__mainScene;

@implementation MainScene

+ (instancetype)mainScene {
	return __mainScene;
}

- (Box2DLayer *)box2DLayer {
	return self.gameplayLayer;
}

- (instancetype)init {
	if (self = [super init]) {
		__mainScene = self;
		
		self.gameplayLayer = [GameplayLayer node];
		[self addChild:self.gameplayLayer z:305];
		
		self.staticBackgroundLayer = [[StaticBackgroundLayer alloc] init];
		[self addChild:self.staticBackgroundLayer z:0];

		self.scrollingBackgroundLayer = [ScrollingBackgroundLayer node];
		[self addChild:self.scrollingBackgroundLayer z:100];
		
		self.hudLayer = [[HUDLayer alloc] init];
		[self addChild:self.hudLayer z:300];
		
		#if !TARGET_IPHONE_SIMULATOR
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
				[CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_HIGH];
				[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"Return_to_Earth.mp3"];
				[[SimpleAudioEngine sharedEngine] preloadEffect:@"Shaker_2.wav"];
				[[SimpleAudioEngine sharedEngine] preloadEffect:@"Perc_2.wav"];
				[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"Return_to_Earth.mp3"];
			});
		#endif
				
		[self scheduleUpdate];
	}
	return self;
}

- (void)update:(ccTime)delta {
	static GameState lastState = (GameState)-1;
	if (!GStateIsMainMenu()) {
		self.hudLayer.zOrder = 300;
		self.gameplayLayer.zOrder = 200;
	} else {
		// flip the zOrders when Bird's flies past the buttons
		static bool lockToggle = false; ///< disable further toggling until Bird is back to negative y velocity
		if (self.gameplayLayer.bird.y > 300 && !lockToggle) {
			lockToggle = true;
			auto temp = self.hudLayer.zOrder;
			self.hudLayer.zOrder = self.gameplayLayer.zOrder;
			self.gameplayLayer.zOrder = temp;
		} else if (self.gameplayLayer.bird.y < 150) {
			lockToggle = false;
		}
	}
	if (GState() != lastState) {
		if (GStateIsGameOver()) {
			[[SimpleAudioEngine sharedEngine] playEffect:@"Perc_2.wav"];
			[[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];
		} else if (lastState != GStateMainMenu && GStateIsGetReady()) {
			[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
		}
	}
	
	lastState = GState();
}
@end
