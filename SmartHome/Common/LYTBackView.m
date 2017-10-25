//
//  LYTBackView.m
//  addProject
//
//  Created by 云盛科技 on 2017/7/25.
//  Copyright © 2017年 神廷. All rights reserved.
//

#import "LYTBackView.h"
#import "Config.h"
static UIView *dissView;
static LYTBackView *_instance;
UITapGestureRecognizer *tapGesture;

@implementation LYTBackView

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    // 由于alloc方法内部会调用allocWithZone: 所以我们只需要保证在该方法只创建一个对象即可
    dispatch_once(&onceToken,^{
        // 只执行1次的代码(这里面默认是线程安全的)
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}
+ (instancetype)shareSingle
{
    if (iPhone5) {
        return [[self alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    }
    else if (iPhone6)
    {
        return [[self alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    }
    else if (iPhone6plus){
        return [[self alloc] initWithFrame:CGRectMake(0, 0, 540, 960)];
    }
    else if (ipad){
        return [[self alloc] initWithFrame:CGRectMake(0, 0, 2048, 2732)];
    }
    else{
        return [[self alloc] initWithFrame:CGRectMake(0, 0, 375, 667)];
    }
    
}

+(void)showWithView:(UIView *)topView isFirst:(BOOL)isFirst{
    LYTBackView *view = [self shareSingle];
    view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.7];
    UIWindow *window = [[[UIApplication sharedApplication]delegate]window];
    [window addSubview:view];
    
    if (dissView) {
        [dissView removeFromSuperview];
    }
    dissView = [[UIView alloc]initWithFrame:topView.frame];
    dissView.alpha = 0.0;
    view.alpha = 0.0;
    [window addSubview:dissView];
    [dissView addSubview:topView];
    topView.frame = CGRectMake(0, 0, dissView.frame.size.width, dissView.frame.size.height);
    [UIView animateWithDuration:0.5 animations:^{
        dissView.alpha = 1.0;
        view.alpha = 1.0;
    }];
    
    if (tapGesture) {
        [view removeGestureRecognizer:tapGesture];
    }
    
    if (!isFirst) {
        tapGesture= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissMiss)];
        [view addGestureRecognizer:tapGesture];
    }
    else{
        if (tapGesture) {
            [view removeGestureRecognizer:tapGesture];
        }
    }
  
    
}


+(void)dissMiss{
    LYTBackView *view = [self shareSingle];
    [UIView animateWithDuration:0.5 animations:^{
        dissView.alpha = 0.0;
        view.alpha =0.0;
    } completion:^(BOOL finished) {
//        [view removeFromSuperview];
//        [dissView removeFromSuperview];
    }];
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
