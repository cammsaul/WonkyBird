//
//  Box2DLayer.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#include <memory>

#import <Foundation/Foundation.h>
#import <Box2D/Box2D.h>
#import "GameLayer.h"
#import "GLES-Render.h"

@interface Box2DLayer : GameLayer

@property (nonatomic, readonly) std::shared_ptr<b2World> world;
@property (nonatomic, readonly) std::shared_ptr<GLESDebugDraw> debugDraw;

@end
