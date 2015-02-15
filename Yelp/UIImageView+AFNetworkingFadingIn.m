//
//  UIImageView+AFNetworkingFadingIn.m
//  RottenTomatoes
//
//  Created by Baeksan Oh on 2/8/15.
//  Copyright (c) 2015 cp. All rights reserved.
//

#import "UIImageView+AFNetworkingFadingIn.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImageView (AFNetworkingFadingIn)

- (void) setImageWithURL:(NSString*)urlString fadingInDuration:(float)duration {
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    
    __weak UIImageView *weakImageView = self;
    [self setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        UIImageView *strongImageView = weakImageView;
        [UIView transitionWithView:strongImageView
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            strongImageView.image = image;
                        }
                        completion:nil];
    } failure:nil];
}

@end
