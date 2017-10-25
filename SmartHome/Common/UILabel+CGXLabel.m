//
//  UILabel+CGXLabel.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/23.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "UILabel+CGXLabel.h"

@implementation UILabel (CGXLabel)


+ (UILabel *)commonLabelWithFrame:(CGRect)frame
                             text:(NSString*)text
                            color:(UIColor*)color
                             font:(UIFont*)font
                          bgColor:(UIColor *)bgColor
                    textAlignment:(NSTextAlignment)textAlignment
{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = text;
    label.textColor = color;
    label.font = font;
    label.textAlignment = textAlignment;
    label.backgroundColor = bgColor;
    
    return label;
}


@end
