//
//  Pipe.h
//  WonkyBird
//
//  Created by Cam Saul on 2/24/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import "Box2DItem.h"

@interface Pipe : NSObject <Box2DItemOwner>

+ (instancetype)pipeOfSize:(NSUInteger)pipeHeight; ///< return a new pipe a certain number of tiles high.

@property (nonatomic, strong) CCTMXLayer *layer;

@property (nonatomic, readonly) Box2DItem *item;

@property (nonatomic, readonly) BOOL cleared; ///< whether the toucan has 'cleared' this pipe (right edge of pipe == half screen size).

- (void)updateStateWithDeltaTime:(ccTime)delta;

@end
