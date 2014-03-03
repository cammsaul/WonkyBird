//
//  FacebookShare.h
//  GeoTip
//
//  Created by Justin Ho on 2/12/14.
//  Copyright (c) 2014 GeoTip Technologies, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ExpaPlatform/Components/XSingleton.h>

@interface FacebookShare : XSingleton

+ (void)authWithGraphAPIAndPostStatusMessage:(NSString *)statusMessage completion:(void(^)(BOOL success))completionBlock;

@property (nonatomic, readonly) BOOL isAuthenticated;

@property (nonatomic) BOOL enableShareToFB; ///< user defaults-backed property to keep track of whether user WANTS to share to facebook

@end
