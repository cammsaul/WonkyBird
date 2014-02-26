//
//  GameLayer.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "CCLayer.h"

@interface GameLayer : CCLayer

@property (nonatomic, strong, readonly) CCSpriteBatchNode *spriteBatchNode;

- (instancetype)initWithTextureAtlasNamed:(NSString *)textureAtlasName; ///< designated initializer

@end
