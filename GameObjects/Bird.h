//
//  Bird.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameSprite.h"

static const float kBirdMenuHeight = 0.6f; ///< Bird is 60% way up screen when flapping in menu

typedef enum : unsigned {
	BirdStateDead,
	BirdStateFalling,
	BirdStateFlapping,
} BirdState;

@interface Bird : GameSprite

@property (nonatomic) BirdState state;

@property (nonatomic, readonly) BOOL dead;
@property (nonatomic, readonly) BOOL falling;
@property (nonatomic, readonly) BOOL flapping;

- (void)applyTouch:(NSUInteger)numFrames;

- (void)flapAroundOnMainScreen:(NSArray *)otherBirds;

@end
