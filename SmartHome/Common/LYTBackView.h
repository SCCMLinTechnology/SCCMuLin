//
//  LYTBackView.h
//  addProject
//
//  Created by 云盛科技 on 2017/7/25.
//  Copyright © 2017年 神廷. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYTBackView : UIView
//添加蒙板,并在蒙板上添加视图,topView为自己创建的蒙板上的视图
//+(void)showWithView:(id)topView;
//视图和蒙板同时消失
+(void)dissMiss;

+(void)showWithView:(UIView *)topView isFirst:(BOOL)isFirst;
//+(void)dissMiss:(BOOL)isdiss;

@end
