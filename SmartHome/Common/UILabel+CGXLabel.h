//
//  UILabel+CGXLabel.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/23.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CGXLabel)

+ (UILabel *)commonLabelWithFrame:(CGRect)frame
                             text:(NSString*)text
                            color:(UIColor*)color
                             font:(UIFont*)font
                          bgColor:(UIColor *)bgColor
                    textAlignment:(NSTextAlignment)textAlignment;

@end
