//
//  GameLayer.h
//  WonkyBird
//
//  Created by Cam Saul on 2/23/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import <cocos2d.h>

@interface GameLayer : CCLayer

@property (nonatomic, strong, readonly) CCSpriteBatchNode *spriteBatchNode;

- (instancetype)initWithTextureAtlasNamed:(NSString *)textureAtlasName; ///< designated initializer

@end
