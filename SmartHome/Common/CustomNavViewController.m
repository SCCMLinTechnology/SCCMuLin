//
//  CustomNavViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "CustomNavViewController.h"

@interface CustomNavViewController ()

@end

@implementation CustomNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)])
    {
        self.navigationBar.barStyle = UIBarStyleDefault;
//        设置背景图片
        [self.navigationBar setBackgroundImage:[UIImage imageNamed:@"nav"] forBarMetrics:UIBarMetricsDefault];
        //
        //去处navigationbar下面的那条黑线
        [[UINavigationBar appearance] setTitleVerticalPositionAdjustment: 0.0f forBarMetrics: UIBarMetricsDefault];
        [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
        
//        self.navigationBar.barTintColor=[UIColor blackColor];
        
        //导航栏上的文字定义颜色、大小
//        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:kUIColorFromRGB(NavBarTitleColor), NSForegroundColorAttributeName,(is_IOS_9?[UIFont fontWithName:@"Helvetica" size:20.0]:[UIFont fontWithName:@"Helvetica-BoldOblique" size:18.0] ), NSFontAttributeName,nil]];//title的颜色
        
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//重写push方法
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [super pushViewController:viewController animated:animated];
//    NSLog(@"111111=====%lu",(unsigned long)[self.viewControllers count]);
    if (viewController.navigationItem.leftBarButtonItem == nil && [self.viewControllers count] >= 1 )
    {
//        NSLog(@"222222");
        viewController.navigationItem.leftBarButtonItem =[self customLeftBackButton];//重新定义左按钮
    }
    
}

-(UIBarButtonItem *)customLeftBackButton
{
    UIView *customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,50,40)];
    customView.backgroundColor=[UIColor clearColor];
    
    UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, (40-24)/2, 34,24)];
    img.image=[UIImage imageNamed:@"bt_back"];
    [customView addSubview:img];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=customView.bounds;
    [btn addTarget:self action:@selector(popself) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    
    return backItem;
}

-(void)popself
{
    [self popViewControllerAnimated:YES];
    
}

@end
