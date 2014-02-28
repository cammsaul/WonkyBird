//
//  MainScene.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "MainScene.h"
#import "StaticBackgroundLayer.h"
#import "ScrollingBackgroundLayer.h"
#import "GameplayLayer.h"
#import "HUDLayer.h"
#import "GameManager.h"
#import "Bird.h"

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
		
		self.staticBackgroundLayer = [[StaticBackgroundLayer alloc] init];
		[self addChild:self.staticBackgroundLayer z:0];

		self.scrollingBackgroundLayer = [ScrollingBackgroundLayer node];
		[self addChild:self.scrollingBackgroundLayer z:100];
		
		self.gameplayLayer = [GameplayLayer node];
		[self addChild:self.gameplayLayer z:305];
		
		self.hudLayer = [[HUDLayer alloc] init];
		[self addChild:self.hudLayer z:300];
		
		[self scheduleUpdate];
	}
	return self;
}

- (void)update:(ccTime)delta {
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
}
@end
