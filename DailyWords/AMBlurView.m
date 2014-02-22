//
//  AMBlurView.m
//  blur
//
//  Created by Cesar Pinto Castillo on 7/1/13.
//  Copyright (c) 2013 Arctic Minds Inc. All rights reserved.
//

#import "AMBlurView.h"
#import <QuartzCore/QuartzCore.h>

@interface AMBlurView ()

@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation AMBlurView
@synthesize blurTintColor = _blurTintColor;
@synthesize translucencyAlpha = _translucencyAlpha;
@synthesize translucent = _translucent;

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (AMBlurView*)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // If we don't clip to bounds the toolbar draws a thin shadow on top
    [self setClipsToBounds:YES];
    
    if (![self toolbar]) {
        [self setToolbar:[[UIToolbar alloc] initWithFrame:[self bounds]]];
        [self setTranslucent:YES];
        [self setTranslucencyAlpha:1];
        [self.layer insertSublayer:[self.toolbar layer] atIndex:0];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self.toolbar setFrame:self.bounds];
}

- (void)setTranslucencyAlpha:(CGFloat)translucencyAlpha
{
    _translucencyAlpha = translucencyAlpha;
    [self.toolbar setAlpha:translucencyAlpha];
}

- (void)setTranslucent:(BOOL)translucent
{
    _translucent = translucent;
    [self.toolbar setTranslucent:translucent];
}

- (void) setBlurTintColor:(UIColor *)blurTintColor {
    _blurTintColor = blurTintColor;
    [self.toolbar setBarTintColor:blurTintColor];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.toolbar setFrame:[self bounds]];
}

@end
