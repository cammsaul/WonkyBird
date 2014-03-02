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
@property (nonatomic, strong) CCSprite *currentBackground;
@property (nonatomic, strong) CCSprite *dayBackground;
@property (nonatomic, strong) CCSprite *nightBackground;
@property (nonatomic, strong) CCSprite *toucanBackground;
@property (nonatomic) BOOL isDay;
@end

@implementation StaticBackgroundLayer

- (instancetype)init {
	if (self = [super init]) {
		_isDay = YES;
		self.currentBackground = self.dayBackground;
		[self.currentBackground stopAllActions];
		self.currentBackground.opacity = 255;
		[self scheduleUpdate];
	}
	return self;
}

- (CCSprite *)addBackgroundNamed:(NSString *)name {
	CCSprite *background = [CCSprite spriteWithFile:name];
	background.position = ccp(ScreenHalfWidth(), ScreenHalfHeight() + (IsIphone5() ? 0 : 44)); // cut off the top part of the sky on iPhone 4
	background.opacity = 0;
	[self addChild:background];
	return background;
}

- (CCSprite *)dayBackground {
	if (!_dayBackground) {
		_dayBackground = [self addBackgroundNamed:@"Background.png"];
		_dayBackground.zOrder = 2;
	}
	return _dayBackground;
}

- (CCSprite *)nightBackground {
	if (!_nightBackground) {
		_nightBackground = [self addBackgroundNamed:@"Background_Night.png"];
		_nightBackground.zOrder = 1;
	}
	return _nightBackground;
}

- (CCSprite *)toucanBackground {
	if (!_toucanBackground) {
		_toucanBackground = [self addBackgroundNamed:@"Background_Toucan.png"];
		_toucanBackground.zOrder = 0;
	}
	return _toucanBackground;
}

- (void)setIsDay:(BOOL)isDay {
	_isDay = isDay;
	
	self.currentBackground = isDay ? self.dayBackground : self.nightBackground;
}

- (void)setCurrentBackground:(CCSprite *)currentBackground {
	[_currentBackground runAction:[CCFadeOut actionWithDuration:10.0f]];
	_currentBackground = currentBackground;
	[currentBackground runAction:[CCFadeIn actionWithDuration:10.0f]];
}

- (void)update:(ccTime)delta {
	static NSUInteger gameScore = 0;
	if (CurrentRoundScore() != gameScore) {
		gameScore = CurrentRoundScore();
		
		if (gameScore != 0 && gameScore % CrazySwitchBackgroundsScore == 0) { // flip day / night
			self.isDay = !self.isDay;
		}
		
		if (gameScore > CrazyBackgroundSkewScore) {
			[self.dayBackground runAction:[CCSkewBy actionWithDuration:1.0f skewX:gameScore skewY:0]];
		}
		
		if ((random() % 1000) == 0) {
			[self setCurrentBackground:[self toucanBackground]];
		}
	}
}

@end
