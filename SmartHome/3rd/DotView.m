//
//  DotView.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/5/8.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "DotView.h"

@implementation DotView
@synthesize row;
@synthesize col;
@synthesize width;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    for (int i = 0 ; i<row+1; i++) {
        //for (int j = 0 ; j<col; j++) {
            
            // Drawing code
            CGContextRef context =UIGraphicsGetCurrentContext();
            // 设置线条的样式
            CGContextSetLineCap(context, kCGLineCapRound);
            // 绘制线的宽度
            CGContextSetLineWidth(context, 1);
            // 线的颜色  [UIColor clearColor].CGColor
            CGContextSetStrokeColorWithColor(context, kUIColorFromRGB(0xb1b9bd).CGColor);
            // 开始绘制
            CGContextBeginPath(context);
            // 设置虚线绘制起点
            CGContextMoveToPoint(context, 5.0, width*i);
            // lengths的值｛10,10｝表示先绘制10个点，再跳过10个点，如此反复
            CGFloat lengths[] = {5,5};
            // 虚线的起始点
            CGContextSetLineDash(context, 0, lengths,2);
            // 绘制虚线的终点
            CGContextAddLineToPoint(context, sWIDTH,width*i);
            // 绘制
            CGContextStrokePath(context);
            // 关闭图像
            //CGContextClosePath(context);

        //}
    }
  
    for (int j = 0 ; j<col+1; j++) {
        // Drawing code
        CGContextRef context =UIGraphicsGetCurrentContext();
        // 设置线条的样式
        CGContextSetLineCap(context, kCGLineCapRound);
        // 绘制线的宽度
        CGContextSetLineWidth(context, 1);
        // 线的颜色
        CGContextSetStrokeColorWithColor(context,kUIColorFromRGB(0xb1b9bd).CGColor);
        // 开始绘制
        CGContextBeginPath(context);
        // 设置虚线绘制起点
        CGContextMoveToPoint(context, width*j, 5.0);
        // lengths的值｛10,10｝表示先绘制10个点，再跳过10个点，如此反复
        CGFloat lengths[] = {5,5};
        // 虚线的起始点
        CGContextSetLineDash(context, 0, lengths,2);
        // 绘制虚线的终点
        CGContextAddLineToPoint(context,width*j, sWIDTH);
        // 绘制
        CGContextStrokePath(context);
        // 关闭图像
//        CGContextClosePath(context);

    }

}

@end
