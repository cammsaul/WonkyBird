//
//  StaticBackgroundLayer.m
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "StaticBackgroundLayer.h"
#import "Constants.h"
#import "GameManager.h"

@interface StaticBackgroundLayer ()
@property (nonatomic, strong) CCSprite *dayBackground;
@property (nonatomic, strong) CCSprite *nightBackground;
@property (nonatomic) BOOL isDay;
@end

@implementation StaticBackgroundLayer

- (instancetype)init {
	if (self = [super init]) {
		auto day = self.dayBackground; // force lazy load
		day = day;
		[self scheduleUpdate];
	}
	return self;
}

- (CCSprite *)addBackgroundNamed:(NSString *)name {
	CCSprite *background = [CCSprite spriteWithFile:name];
	background.position = ccp(ScreenHalfWidth(), ScreenHalfHeight() + (IsIphone5() ? 0 : 44)); // cut off the top part of the sky on iPhone 4
	[self addChild:background];
	return background;
}

- (CCSprite *)dayBackground {
	if (!_dayBackground) {
		_dayBackground = [self addBackgroundNamed:@"Background.png"];
		_dayBackground.zOrder = 1;
	}
	return _dayBackground;
}

- (CCSprite *)nightBackground {
	if (!_nightBackground) {
		_nightBackground = [self addBackgroundNamed:@"Background_Night.png"];
		_dayBackground.zOrder = 0;
		_nightBackground.opacity = 0;
	}
	return _nightBackground;
}

- (void)setIsDay:(BOOL)isDay {
	_isDay = isDay;
	auto bgToFadeOut = isDay ? self.nightBackground : self.dayBackground;
	auto bgToFadeIn = isDay ? self.dayBackground : self.nightBackground;
	
	[bgToFadeOut runAction:[CCFadeOut actionWithDuration:1200.0f]];
	[bgToFadeIn runAction:[CCFadeIn actionWithDuration:1200.0f]];
}

- (void)update:(ccTime)delta {
	static NSUInteger gameScore = 0;
	if ([GameManager sharedInstance].gameScore != gameScore) {
		gameScore = [GameManager sharedInstance].gameScore;
		
		if (gameScore != 0 && gameScore % 5 == 0) { // flip day / night
			self.isDay = !self.isDay;
		}
	}
}

@end
