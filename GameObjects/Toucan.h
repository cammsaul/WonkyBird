//
//  Toucan.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameSprite.h"

typedef enum : unsigned {
	ToucanStateIdle,
	ToucanStateDead,
	ToucanStateFalling,
	ToucanStateFlapping,
} ToucanState;

@interface Toucan : GameSprite

@property (nonatomic) ToucanState state;

@end
