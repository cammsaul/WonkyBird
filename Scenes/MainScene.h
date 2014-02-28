//
//  MainScene.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "CCScene.h"

@class Box2DLayer;

@interface MainScene : CCScene

@property (nonatomic, strong, readonly) Box2DLayer *box2DLayer;

+ (instancetype)mainScene;

@end
