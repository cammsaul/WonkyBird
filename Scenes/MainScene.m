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

@interface MainScene ()
@property (nonatomic, strong) StaticBackgroundLayer *staticBackgroundLayer;
@property (nonatomic, strong) ScrollingBackgroundLayer *scrollingBackgroundLayer;
@property (nonatomic, strong) GameplayLayer *gameplayLayer;
@property (nonatomic, strong) HUDLayer *hudLayer;
@end

@implementation MainScene

- (instancetype)init {
	if (self = [super init]) {
//		self.staticBackgroundLayer = [[StaticBackgroundLayer alloc] init];
//		[self addChild:self.staticBackgroundLayer z:0];
//		
//		self.scrollingBackgroundLayer = [ScrollingBackgroundLayer node];
//		[self addChild:self.scrollingBackgroundLayer z:100];
		
		self.gameplayLayer = [GameplayLayer node];
		[self addChild:self.gameplayLayer z:200];
		
//		self.hudLayer = [HUDLayer node];
//		[self addChild:self.hudLayer z:300];
	}
	return self;
}
@end
