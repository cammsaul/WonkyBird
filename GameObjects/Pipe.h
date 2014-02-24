//
//  Pipe.h
//  WonkyBird
//
//  Created by Cam Saul on 2/24/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Box2DItem.h"

@interface Pipe : NSObject <Box2DItemOwner>

@property (nonatomic, strong) CCTMXLayer *layer;

+ (instancetype)pipeOfSize:(NSUInteger)pipeHeight; ///< return a new pipe a certain number of tiles high.

@property (nonatomic, readonly) Box2DItem *item;

@end
