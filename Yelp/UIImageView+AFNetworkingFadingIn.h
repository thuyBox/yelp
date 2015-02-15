//
//  UIImageView+AFNetworkingFadingIn.h
//  RottenTomatoes
//
//  Created by Baeksan Oh on 2/8/15.
//  Copyright (c) 2015 cp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AFNetworkingFadingIn)
- (void) setImageWithURL:(NSString*)urlString fadingInDuration:(float)duration;
@end
