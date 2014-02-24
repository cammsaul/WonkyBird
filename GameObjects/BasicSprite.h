//
//  BasicSprite.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "GameSprite.h"

/// A basic sprite whose Box2D body is a single shape.
@interface BasicSprite : GameSprite
@property (nonatomic) shared_ptr<b2PolygonShape> shape;		///< By default, just a box
@property (nonatomic) shared_ptr<b2FixtureDef> fixtureDef;
@end
