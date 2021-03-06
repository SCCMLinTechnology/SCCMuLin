//
//  VWBaseContentView.m
//  VWProgressHUD
//
//  Created by Vaith on 16/7/19.
//  Copyright © 2016年 Vaith. All rights reserved.
//

#import "VWBaseContentView.h"
#import "UIView+VWAutolayout.h"
#import "VWConfig.h"

@interface VWBaseContentView()
@end

@implementation VWBaseContentView

- (instancetype)init
{
    if (self = [super init])
    {
        [self setBackgroundColor:VWHEXCOLOR(kVWDminantColor)];
        [self.layer setCornerRadius:5.f];
        [self.layer setShadowOffset:CGSizeMake(0, 0)];
        [self.layer setShadowOpacity:0.2f];
        [self setAlpha:0];
        
        UILabel *mainLabel = [UILabel new];
        [mainLabel setTextAlignment:NSTextAlignmentCenter];
        [mainLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [mainLabel setTextColor:VWHEXCOLOR(kVWTextColor)];
        [mainLabel setFont:[UIFont systemFontOfSize:kVWDefaultTipFontSize]];
        [self addSubview:mainLabel];
        [mainLabel setPreferredMaxLayoutWidth:kVWMaxTextWidth];
        [mainLabel setNumberOfLines:0];
        self.mainLabel = mainLabel;
        
        UILabel *subLabel = [UILabel new];
        [subLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [subLabel setTextAlignment:NSTextAlignmentCenter];
        [subLabel setTextColor:VWHEXCOLOR(kVWTextColor)];
        [subLabel setFont:[UIFont systemFontOfSize:kVWDefaultSubFontSize]];
        [self addSubview:subLabel];
        [subLabel setPreferredMaxLayoutWidth:kVWMaxTextWidth];
        [subLabel setNumberOfLines:0];
        self.subLabel = subLabel;
    }
    return self;
}

- (void)resetConstraint
{
    [self setConstraint];
    [UIView animateWithDuration:kVWDefaultAnimationTime animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)setConstraint
{
    [self removeAllAutoLayout];
    
    if (self.topView)
    {
        if (self.mainLabel.text.length == 0 && self.subLabel.text.length == 0)
        {
            [self.topView addConstraint:NSLayoutAttributeCenterY equalTo:self offset:0];
        }
        else
        {
            [self.topView addConstraint:NSLayoutAttributeTop equalTo:self offset:self.type==VWContentViewTypeLoading?kVWPadding*2:kVWPadding];
        }
        [self.topView addConstraint:NSLayoutAttributeCenterX equalTo:self offset:0];
        
    }
    
    if (self.mainLabel)
    {
        [self.mainLabel addConstraint:NSLayoutAttributeTop equalTo:self.topView fromConstraint:NSLayoutAttributeBottom offset:kVWPadding];
        [self.mainLabel addConstraint:NSLayoutAttributeLeft equalTo:self offset:kVWPadding];
        [self.mainLabel addConstraint:NSLayoutAttributeRight equalTo:self offset:-kVWPadding];
    }
    
    if (self.subLabel)
    {
        [self.subLabel addConstraint:NSLayoutAttributeTop equalTo:self.mainLabel fromConstraint:NSLayoutAttributeBottom offset:kVWPadding/2];
        [self.subLabel addConstraint:NSLayoutAttributeLeft equalTo:self offset:kVWPadding];
        [self.subLabel addConstraint:NSLayoutAttributeRight equalTo:self offset:-kVWPadding];
        
    }
    
    [self addConstraint:NSLayoutAttributeWidth greatOrLess:NSLayoutRelationGreaterThanOrEqual value:kVWContentMinWidth];
    [self addConstraint:NSLayoutAttributeWidth greatOrLess:NSLayoutRelationLessThanOrEqual value:kVWContentMaxWidth];
    [self addConstraint:NSLayoutAttributeHeight greatOrLess:NSLayoutRelationGreaterThanOrEqual value:kVWContentMinWidth];
    
    UIView *lastView = self.topView;
    lastView = self.mainLabel.text.length>0?self.mainLabel:lastView;
    lastView = self.subLabel.text.length>0?self.subLabel:lastView;
    
    if (lastView != self.topView)
    {
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:lastView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:kVWPadding]];
    }
    
}

- (void)didMoveToSuperview
{
    if (self.superview)
    {
        [self addConstraint:NSLayoutAttributeCenterX equalTo:self.superview offset:0];
        [self addConstraint:NSLayoutAttributeCenterY equalTo:self.superview offset:0];
        
        
        [UIView animateWithDuration:kVWDefaultAnimationTime animations:^{
            [self setAlpha:kVWDefaultAlpha];
        }];
    }
}

#pragma mark dismiss
- (void)dismiss
{
    __weak VWBaseContentView *weakself = self;
    [UIView animateWithDuration:kVWDefaultAnimationTime animations:^{
        [weakself setAlpha:0];
    } completion:^(BOOL finished) {
        [weakself removeFromSuperview];
        [[NSNotificationCenter defaultCenter] postNotificationName:kVWDismissNotification object:nil];
    }];
}

@end
