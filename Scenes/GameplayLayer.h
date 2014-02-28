//
//  GameplayLayer.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Box2DLayer.h"

@class Bird;

@interface GameplayLayer : Box2DLayer

@property (nonatomic, strong, readonly) Bird *bird;

@end
