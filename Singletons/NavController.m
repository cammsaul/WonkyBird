//
//  NavController.m
//  WonkyBird
//
//  Created by Cam Saul on 2/28/14.
//  Copyright (c) 2014 LuckyBird, Inc. All rights reserved.
//

#import <iAd/iAd.h>


#import "NavController.h"
#import "MainScene.h"

@implementation NavController
-(NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return NO;
}
- (void)directorDidReshapeProjection:(CCDirector*)director
{
	if(director.runningScene == nil) {
		// Add the first scene to the stack. The director will draw it immediately into the framebuffer. (Animation is started automatically when the view is displayed.)
		// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
		[director runWithScene: [MainScene node]];
		
		// add an iad view
		auto adBanner = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
		adBanner.backgroundColor = [UIColor clearColor];
		adBanner.translatesAutoresizingMaskIntoConstraints = NO;
		[self.view addSubview:adBanner];
		
		NSMutableArray *constraints = [NSMutableArray array];
		[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"|[adBanner]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(adBanner)]];
		[constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[adBanner(50)]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(adBanner)]];
		for (NSLayoutConstraint *c in constraints) {
			c.priority = UILayoutPriorityRequired;
		}
		[self.view addConstraints:constraints];
	}
}

@end