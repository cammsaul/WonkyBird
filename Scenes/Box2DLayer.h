//
//  Box2DLayer.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameLayer.h"

@interface Box2DLayer : GameLayer

@property (nonatomic, readonly) shared_ptr<b2World> world;
@property (nonatomic, readonly) shared_ptr<GLESDebugDraw> debugDraw;

@end
