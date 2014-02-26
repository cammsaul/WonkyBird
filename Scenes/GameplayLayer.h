//
//  GameplayLayer.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Box2DLayer.h"

@class Toucan;

@interface GameplayLayer : Box2DLayer

@property (nonatomic, strong, readonly) Toucan *toucan;

@end
