//
//  Toucan.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameSprite.h"

static const float kToucanMenuHeight = 0.6f; ///< toucan is 60% way up screen when flapping in menu

typedef enum : unsigned {
	ToucanStateIdle,
	ToucanStateDead,
	ToucanStateFalling,
	ToucanStateFlapping,
} ToucanState;

@interface Toucan : GameSprite

@property (nonatomic) ToucanState state;

@property (nonatomic, readonly) BOOL idle;
@property (nonatomic, readonly) BOOL dead;
@property (nonatomic, readonly) BOOL falling;
@property (nonatomic, readonly) BOOL flapping;

@end
