//
//  LightViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/24.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "LightViewController.h"

@interface LightViewController (){
    
    UIImageView *mainImg;
    
    BOOL isSwitch;
    UIButton *switchBtn;
    
    UIButton *cupBtn;
    BOOL isCup;
    
    UIButton *readBtn;
    BOOL isRead;
   
    UIButton *lightBtn;
    BOOL isLight;

    UISlider *timerSlider;
    UISlider *brightSlider;
    UISlider *colorSlider;
    
    int colorInt;
    int brightInt;
    int timeInt;
    
    
    int readBrightInt;
    int readTimeInt;
    
    BOOL isColor; //灯杯是否是彩色
    BOOL isLightColor; //等待是否是彩色
    
    BOOL isHasCup;//是否有杯灯
    BOOL isHasRead;//是否有阅读灯
    BOOL isHasLight;//是否有等待
    
    UIImageView *colorImg;
    
    int oldBright;
    
    BOOL isFree;
    
    BOOL isCurrentBle;
}

@end

@implementation LightViewController
@synthesize lightStr;
@synthesize data;

//返回上一层
-(void)popToPre{
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)layoutControlView{
    //去除
    for (UIView *sub in self.view.subviews) {
        if (sub.tag < 1000) {
            [sub removeFromSuperview];
        }
    }
    
    //提示图片
    mainImg = [UIImageView new];
    if (isCup) {
        //杯灯
        if (isColor) {
             mainImg.image = [UIImage imageNamed:@"bg_caidengbei_h1"];
        }
        else{
             mainImg.image = [UIImage imageNamed:@"bg_beideng"];
        }
       
    }
    else if(isRead){
        //阅读灯
        mainImg.image = [UIImage imageNamed:@"bg_yuedudeng"];
    }
    else{
        //灯带
        if (isLightColor) {
            
            mainImg.image = [UIImage imageNamed:@"bg_caidaideng_h1"];
        }
        else{
            
            mainImg.image = [UIImage imageNamed:@"bg_caidaideng_h"];
        }
        
    }
    [self.view addSubview:mainImg];
    [mainImg mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            
            make.top.mas_equalTo(50);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(300, 160));
        }
        else{
            make.top.mas_equalTo(0);
            make.centerX.mas_equalTo(self.view.mas_centerX);
            make.size.mas_equalTo(CGSizeMake(250, 135));
        }
        
    }];
    
    
    //timer
    [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake(15, 150+(ipad ? 100 :0), sWIDTH - 15*2, 20) text:@"Timer" color:kUIColorFromRGB(0x444444) font:[UIFont systemFontOfSize:(ipad ? 18.0 : 12.0)] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter]];
    
    //创建滑动条对象
    timerSlider = [[UISlider alloc]init];
    //位置设置，高度不可变更，40写的不起作用，系统默认
    if (ipad) {
        timerSlider.frame =CGRectMake((sWIDTH - 300)/2, 280, 300, 30);
    }
    else{
        timerSlider.frame =CGRectMake((sWIDTH - 250)/2, 170, 250, 30);
    }
    
    //设置滑动条最大值
    timerSlider.maximumValue=60;
    //设置滑动条的最小值，可以为负值
    timerSlider.minimumValue=15;
    timerSlider.value=timeInt;
    //设置滑动条的滑块位置float值
    timerSlider.continuous = NO ;
    //左侧滑条背景颜色
    timerSlider.minimumTrackTintColor=[UIColor redColor];
//    UIImage *image = [[UIImage imageNamed:@"bt_red"] resizableImageWithCapInsets:UIEdgeInsetsZero];//图片模式，不设置的话会被压缩
//    [timerSlider setMinimumTrackImage:image forState:UIControlStateNormal];
    
    //右侧滑条背景颜色
    timerSlider.maximumTrackTintColor=[UIColor lightGrayColor];
//    [timerSlider setMaximumTrackImage:[UIImage imageNamed:@"commonbg"] forState:UIControlStateNormal];
    //设置滑块的颜色
//    timerSlider.thumbTintColor=[UIColor darkGrayColor];
    [timerSlider setThumbImage:[UIImage imageNamed:@"humbImage"] forState:UIControlStateNormal];
    [timerSlider setThumbImage:[UIImage imageNamed:@"humbImage"] forState:UIControlStateHighlighted];
    //对滑动条添加事件函数
    [timerSlider addTarget:self action:@selector(timerSlider) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:timerSlider];
    
    
    for (int i =0; i<4; i++) {
        //        if (i > 0 && i<3) {
        //            [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake((sWIDTH - 250)/2+250/3*i, 190, 1, 3) text:@"" color:kUIColorFromRGB(0x444444)  font:[UIFont systemFontOfSize:12.0] bgColor:kUIColorFromRGB(0x444444) textAlignment:NSTextAlignmentLeft]];
        //        }
        
        if (ipad) {
            [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake((sWIDTH - 300)/2+300/3*i-20, 305, 300/4, 20) text:[NSString stringWithFormat:@"%dMIN",15+15*i] color:kUIColorFromRGB(0x444444) font:[UIFont systemFontOfSize:14.0] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft]];
        }
        else{
            [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake((sWIDTH - 250)/2+250/3*i-20, 200, 250/4, 20) text:[NSString stringWithFormat:@"%dMIN",15+15*i] color:kUIColorFromRGB(0x444444) font:[UIFont systemFontOfSize:12.0] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft]];
        }
        
    }
    
    
    
    //Brightness--亮度
    [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake(15, 200+20 +(ipad ? 150 : 0), sWIDTH - 15*2, 20) text:@"Brightness" color:kUIColorFromRGB(0x444444) font:[UIFont systemFontOfSize:(ipad ? 18.0 : 12.0)] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter]];
    
    //创建滑动条对象
    brightSlider = [[UISlider alloc]init];
    //位置设置，高度不可变更，40写的不起作用，系统默认
    if (ipad) {
        brightSlider.frame =CGRectMake((sWIDTH - 300)/2, 220+20+(ipad ? 160 : 0), 300, 30);
    }
    else{
        brightSlider.frame =CGRectMake((sWIDTH - 250)/2, 220+20, 250, 30);
    }
    
    //设置滑动条最大值
    brightSlider.maximumValue=100;
    //设置滑动条的最小值，可以为负值
    brightSlider.minimumValue=1;
    //设置滑动条的滑块位置float值
    brightSlider.value=brightInt;
    brightSlider.continuous = YES ;
//    UIImage *image2 = [[UIImage imageNamed:@"bt_blue"] resizableImageWithCapInsets:UIEdgeInsetsZero];//图片模式，不设置的话会被压缩
//    [slider setMinimumTrackImage:image forState:UIControlStateNormal];//设置图片
    //左侧滑条背景颜色
    brightSlider.minimumTrackTintColor=[UIColor blueColor];
//    [brightSlider setMinimumTrackImage:image2 forState:UIControlStateNormal];
    //右侧滑条背景颜色
    brightSlider.maximumTrackTintColor=[UIColor lightGrayColor];
//    UIImage *image22 = [[UIImage imageNamed:@"commonbg"] resizableImageWithCapInsets:UIEdgeInsetsZero];
//    [brightSlider setMaximumTrackImage:image22 forState:UIControlStateNormal];
    //设置滑块的颜色
//    brightSlider.thumbTintColor=[UIColor darkGrayColor];
    [brightSlider setThumbImage:[UIImage imageNamed:@"humbImage"] forState:UIControlStateNormal];
    [brightSlider setThumbImage:[UIImage imageNamed:@"humbImage"] forState:UIControlStateHighlighted];
    //对滑动条添加事件函数
    [brightSlider addTarget:self action:@selector(brightSlider) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:brightSlider];
    
    
    //减按钮
    UIButton *reduceBtn= [UIButton new];
    [reduceBtn setEnabled:false];
    [reduceBtn setImage:[UIImage imageNamed:@"ic_jian"] forState:UIControlStateNormal];
    [reduceBtn setBackgroundImage:[UIImage imageNamed:@"ic_jian"] forState:UIControlStateNormal];
    //    [reduceBtn addTarget:self action:@selector(switchBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reduceBtn];
    [reduceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.mas_equalTo(brightSlider.mas_left).offset(-10);
        make.centerY.mas_equalTo(brightSlider);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    
    //加按钮
    UIButton *addBtn= [UIButton new];
    [addBtn setEnabled:false];
    [addBtn setImage:[UIImage imageNamed:@"ic_jia"] forState:UIControlStateNormal];
    [addBtn setBackgroundImage:[UIImage imageNamed:@"ic_jia"] forState:UIControlStateNormal];
    //    [reduceBtn addTarget:self action:@selector(switchBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.mas_equalTo(brightSlider.mas_right).offset(10);
        make.centerY.mas_equalTo(brightSlider);
        make.size.mas_equalTo(CGSizeMake(15, 15));
    }];
    

    if ((isCup && isColor) || (isLightColor && isLight)) {
        //Colorful--彩色
        [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake(15, 270+(ipad ? 200 : 0), sWIDTH - 15*2, 20) text:@"Colorful" color:kUIColorFromRGB(0x444444) font:[UIFont systemFontOfSize:(ipad ? 18.0 : 12.0)] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter]];
        
        //创建滑动条对象
        colorSlider = [[UISlider alloc]init];
        //位置设置，高度不可变更，40写的不起作用，系统默认
        if (ipad) {
            colorSlider.frame =CGRectMake((sWIDTH - 300)/2, 270+20+(ipad ? 210 : 0), 300, 30);
        }
        else{
            colorSlider.frame =CGRectMake((sWIDTH - 250)/2, 270+20, 250, 30);
        }
        
        //设置滑动条最大值
        colorSlider.maximumValue=7;
        //设置滑动条的最小值，可以为负值
        colorSlider.minimumValue=1;
        //设置滑动条的滑块位置float值
//        colorSlider.value=colorInt;
        if (colorInt == 1) {
            [colorSlider setValue:1.3 animated:NO];
        }
        else  if (colorInt == 2){
            [colorSlider setValue:2.2 animated:NO];
        }
        else if (colorInt == 3){
            [colorSlider setValue:3.1 animated:NO];
        }
        else if (colorInt == 4){
            [colorSlider setValue:4 animated:NO];
        }
        else if (colorInt == 5){
            [colorSlider setValue:4.9 animated:NO];
        }
        else if (colorInt == 6){
            [colorSlider setValue:5.8 animated:NO];
        }
        else if (colorInt == 7){
            [colorSlider setValue:6.7 animated:NO];
        }

        colorSlider.continuous = NO ;
        [colorSlider setThumbImage:[UIImage imageNamed:@"humbImage"] forState:UIControlStateNormal];
        [colorSlider setThumbImage:[UIImage imageNamed:@"humbImage"] forState:UIControlStateHighlighted];
        //左侧滑条背景颜色
//        [colorSlider setMinimumTrackImage:[UIImage imageNamed:@"color_slider"] forState:UIControlStateNormal];
        colorSlider.minimumTrackTintColor=[UIColor clearColor];
        
        //右侧滑条背景颜色
        colorSlider.maximumTrackTintColor=[UIColor clearColor];
        //        [colorSlider setMaximumTrackImage:nil forState:UIControlStateNormal];
        //设置滑块的颜色
//        colorSlider.thumbTintColor=[UIColor darkGrayColor];
        //对滑动条添加事件函数
        [colorSlider addTarget:self action:@selector(colorSlider) forControlEvents:UIControlEventValueChanged];
        [self.view addSubview:colorSlider];
        
        colorImg = [UIImageView new];
        colorImg.image = [UIImage imageNamed:@"color_slider"];
        [self.view insertSubview:colorImg belowSubview:colorSlider];
//        [self.view addSubview:colorImg];
        [colorImg mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(colorSlider.mas_left);
            make.right.mas_equalTo(colorSlider.mas_right);
            make.centerY.mas_equalTo(colorSlider);
            make.height.mas_equalTo(5);
//            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
//        [colorImg bringSubviewToFront:colorSlider];
        
        /*
        //减按钮
        UIButton *reduceBtn= [UIButton new];
        [reduceBtn setEnabled:false];
        [reduceBtn setImage:[UIImage imageNamed:@"ic_jian"] forState:UIControlStateNormal];
        [reduceBtn setBackgroundImage:[UIImage imageNamed:@"ic_jian"] forState:UIControlStateNormal];
        //    [reduceBtn addTarget:self action:@selector(switchBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:reduceBtn];
        [reduceBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.right.mas_equalTo(colorSlider.mas_left).offset(-10);
            make.centerY.mas_equalTo(colorSlider);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
        
        //加按钮
        UIButton *addBtn= [UIButton new];
        [addBtn setEnabled:false];
        [addBtn setImage:[UIImage imageNamed:@"ic_jia"] forState:UIControlStateNormal];
        [addBtn setBackgroundImage:[UIImage imageNamed:@"ic_jia"] forState:UIControlStateNormal];
        //    [reduceBtn addTarget:self action:@selector(switchBtn) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:addBtn];
        [addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.left.mas_equalTo(colorSlider.mas_right).offset(10);
            make.centerY.mas_equalTo(colorSlider);
            make.size.mas_equalTo(CGSizeMake(15, 15));
        }];
         */
        
        
    }
    
    
    
    //开关按钮
    switchBtn= [UIButton new];
    if (isSwitch) {
        [switchBtn setImage:[UIImage imageNamed:@"bt_on"] forState:UIControlStateNormal];
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"bt_on"] forState:UIControlStateNormal];
    }
    else{
        [switchBtn setImage:[UIImage imageNamed:@"bt_off"] forState:UIControlStateNormal];
        [switchBtn setBackgroundImage:[UIImage imageNamed:@"bt_off"] forState:UIControlStateNormal];
    }
   
    [switchBtn addTarget:self action:@selector(switchBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchBtn];
    [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (ipad) {
            make.top.mas_equalTo(600);
            make.centerX.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(90, 40));
        }
        else{
            if ((isCup && isColor) || (isLight && isLightColor)) {
                make.top.mas_equalTo(330);
            }
            else{
                make.top.mas_equalTo(300);
            }
            
            make.centerX.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(90, 40));
        }
       
    }];
    
    //杯子按钮
    cupBtn= [UIButton new];
    if (isCup) {
        if (isColor) {
            [cupBtn setImage:[UIImage imageNamed:@"bt_caidengbei_h1"] forState:UIControlStateNormal];
            [cupBtn setBackgroundImage:[UIImage imageNamed:@"bt_caidengbei_h1"] forState:UIControlStateNormal];
            
        }
        else{
            [cupBtn setImage:[UIImage imageNamed:@"bt_beideng_open"] forState:UIControlStateNormal];
            [cupBtn setBackgroundImage:[UIImage imageNamed:@"bt_beideng_open"] forState:UIControlStateNormal];
        }
    }
    else{
        [cupBtn setImage:[UIImage imageNamed:@"bt_beideng_off"] forState:UIControlStateNormal];
        [cupBtn setBackgroundImage:[UIImage imageNamed:@"bt_beideng_off"] forState:UIControlStateNormal];
    }
    [cupBtn addTarget:self action:@selector(cupBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cupBtn];
    [cupBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (ipad) {
            make.top.mas_equalTo(switchBtn.mas_bottom).offset(30);
            make.centerX.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(110, 57));
        }
        else{
            
            make.top.mas_equalTo(switchBtn.mas_bottom).offset(20+(iPhone5?-10:0));
            make.centerX.mas_equalTo(self.view);
            if (iPhone5) {
                make.size.mas_equalTo(CGSizeMake(90, 45));
            }
            else{
                make.size.mas_equalTo(CGSizeMake(110, 57));
            }
        }
        
    }];
    
    //阅读
    readBtn= [UIButton new];
    if (isRead) {
        [readBtn setImage:[UIImage imageNamed:@"bt_kanshu_open"] forState:UIControlStateNormal];
        [readBtn setBackgroundImage:[UIImage imageNamed:@"bt_kanshu_open"] forState:UIControlStateNormal];
    }
    else{
        [readBtn setImage:[UIImage imageNamed:@"bt_kanshu_off"] forState:UIControlStateNormal];
        [readBtn setBackgroundImage:[UIImage imageNamed:@"bt_kanshu_off"] forState:UIControlStateNormal];
    }
    
    [readBtn addTarget:self action:@selector(readBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:readBtn];
    [readBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (ipad) {
            make.top.mas_equalTo(cupBtn.mas_bottom).offset(30);
            make.centerX.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(110, 57));
        }
        else{
            if (isHasCup) {
                make.top.mas_equalTo(cupBtn.mas_bottom).offset(20+(iPhone5?-10:0));
            }
            else{
                make.top.mas_equalTo(switchBtn.mas_bottom).offset(20+(iPhone5?-10:0));
            }
            
            if (iPhone5) {
                if (isHasCup) {
                    if (isHasRead) {
                        if (isHasLight) {
                            make.centerX.mas_equalTo(self.view).offset(-60);
                        }
                        else{
                            make.centerX.mas_equalTo(self.view);
                        }
                    }
                    else{
                        make.centerX.mas_equalTo(self.view);
                    }
                }
                else{
                    make.centerX.mas_equalTo(self.view);
                }
                make.size.mas_equalTo(CGSizeMake(90, 45));
            }
            else{
                make.centerX.mas_equalTo(self.view);
                make.size.mas_equalTo(CGSizeMake(110, 57));
            }

        }
        
    }];
    
    
    //灯带
    lightBtn= [UIButton new];
    if (isLight) {
        if (isLightColor) {
            
            [lightBtn setImage:[UIImage imageNamed:@"bt_dengdai_open"] forState:UIControlStateNormal];
            [lightBtn setBackgroundImage:[UIImage imageNamed:@"bt_dengdai_open"] forState:UIControlStateNormal];
            
        }
        else{
            [lightBtn setImage:[UIImage imageNamed:@"bt_dansedengdai_h1"] forState:UIControlStateNormal];
            [lightBtn setBackgroundImage:[UIImage imageNamed:@"bt_dansedengdai_h1"] forState:UIControlStateNormal];
           
        }
    }
    else{
        [lightBtn setImage:[UIImage imageNamed:@"bt_dengdai_off"] forState:UIControlStateNormal];
        [lightBtn setBackgroundImage:[UIImage imageNamed:@"bt_dengdai_off"] forState:UIControlStateNormal];
    }
    
    [lightBtn addTarget:self action:@selector(lightBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lightBtn];
    [lightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (ipad) {
            make.top.mas_equalTo(readBtn.mas_bottom).offset(30);
            make.centerX.mas_equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(110, 57));
        }
        else{
            if (isHasCup) {
                if (isHasRead) {
                    if (iPhone5) {
                        make.top.mas_equalTo(cupBtn.mas_bottom).offset(20+(iPhone5?-10:0));
                    }
                    else{
                        make.top.mas_equalTo(readBtn.mas_bottom).offset(20+(iPhone5?-10:0));
                    }
                }
                else{
                    make.top.mas_equalTo(cupBtn.mas_bottom).offset(20+(iPhone5?-10:0));
                }
            }
            else{
                if (isHasRead) {
                    make.top.mas_equalTo(readBtn.mas_bottom).offset(20+(iPhone5?-10:0));
                }
                else{
                    make.top.mas_equalTo(switchBtn.mas_bottom).offset(20+(iPhone5?-10:0));
                }
            }
            
            if (iPhone5) {
                if (isHasCup) {
                    if (isHasRead) {
                        if (isHasLight) {
                            make.centerX.mas_equalTo(self.view).offset(60);
                        }
                        else{
                            make.centerX.mas_equalTo(self.view);
                        }
                    }
                    else{
                        make.centerX.mas_equalTo(self.view);
                    }
                }
                else{
                    make.centerX.mas_equalTo(self.view);
                }
                
                make.size.mas_equalTo(CGSizeMake(90, 45));
            }
            else{
                //            make.top.mas_equalTo(cupBtn.mas_bottom).offset(20+(iPhone5?-10:0));
                make.centerX.mas_equalTo(self.view);
                make.size.mas_equalTo(CGSizeMake(110, 57));
            }

        }
    }];
    
    //判断是否有杯灯
    if (isHasCup) {
        [cupBtn setHidden:NO];
    }
    else{
        [cupBtn setHidden:YES];
    }
    //判断是否有阅读灯
    if (isHasRead) {
        [readBtn setHidden:NO];
    }
    else{
        [readBtn setHidden:YES];
    }
    //判断是否有灯带
    if (isHasLight) {
        [lightBtn setHidden:NO];
    }
    else{
        [lightBtn setHidden:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    lightStr = @"11111";
//    NSLog(@"light==%@",lightStr);
    
    //导航栏背景图片
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    
    
    //返回按钮
    UIView *customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,50,40)];
    customView.backgroundColor=[UIColor clearColor];
    UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, (40-24)/2, 34,24)];
    img.image=[UIImage imageNamed:@"bt_back"];
    [customView addSubview:img];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=customView.bounds;
    [btn addTarget:self action:@selector(popToPre) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.leftBarButtonItem = backItem;
    
    
    //背景图片
    UIImageView *bgImg = [UIImageView new];
    bgImg.tag = 1000;
    bgImg.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    
    isFree = YES;//默认亮度的滑块
    
    
    //判断是否有灯桶
    if ([[[lightStr substringFromIndex:2] substringToIndex:1] intValue] == 1) {
        isHasCup = YES;
    }
    else{
        isHasCup = NO;
    }
    
    //是否彩色灯桶
    if ([[[lightStr substringFromIndex:1] substringToIndex:1] intValue] == 1) {
        isColor = YES;
    }
    else{
        isColor = NO;
    }
    
    //判断是否有阅读灯
    if ([[[lightStr substringFromIndex:0] substringToIndex:1] intValue] == 1) {
        isHasRead = YES;
    }
    else{
        isHasRead = NO;
    }
    
    
    //判断是否有灯带
    if ([[[lightStr substringFromIndex:4] substringToIndex:1] intValue] == 1) {
        isHasLight = YES;
    }
    else{
        isHasLight = NO;
    }
    
    //是否彩色灯带
    if ([[[lightStr substringFromIndex:3] substringToIndex:1] intValue] == 1) {
        isLightColor = YES;
    }
    else{
        isLightColor = NO;
    }
    
    if (isHasCup) {
        isCup = YES;
        isRead = NO;
        isLight = NO;
    }
    else if(isHasRead){
        isCup = NO;
        isRead = YES;
        isLight = NO;
    }
    else{
        isCup = NO;
        isRead = NO;
        isLight = YES;
    }
    
//    [[NSUserDefaults standardUserDefaults] setBool:isCup forKey:@"isCup"];
//    [[NSUserDefaults standardUserDefaults] setBool:isRead forKey:@"isRead"];
    
    colorInt = 0;//彩色值
    brightInt = 0;//亮度值
    
    [self layoutControlView];//布局
    
    if (isCup) {
        [self requestCupControlState];//获取灯杯状态
    }
    else if(isRead){
        [self requestReadControlState];//获取阅读灯状态
    }
    else{
        [self requestLightControlState];//获取灯带状态
    }
    
    
    //判断蓝牙是打开／关闭
    [[AppDelegate shareGlobal] manager].linkBlcok = ^(NSString *state){
        [AppDelegate shareGlobal].link = state;
        if ([state isEqualToString:kCONNECTED_POWERD_ON]) {
            
            [cupBtn setEnabled:YES];
            [readBtn setEnabled:YES];
            [switchBtn setEnabled:YES];
            [lightBtn setEnabled:YES];
            
//            isCurrentBle = YES;
//            [[[AppDelegate shareGlobal] manager] scanMgr];
            
            //直接连接
            [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"serviceUUIDs"] identifier:[data objectForKey:@"identifier"]];
           
        }
        else{
            [self updateLog:@"Please open Bluetooth"];
            [AppDelegate shareGlobal].globalBleDis  = YES;
            
            [cupBtn setEnabled:NO];
            [readBtn setEnabled:NO];
            [lightBtn setEnabled:NO];
            [switchBtn setEnabled:NO];
        }
        
    };
    
    
    /*
    //获取搜索蓝牙设备列表
    [[AppDelegate shareGlobal] manager].listBlock = ^(NSMutableArray *array) {
//        NSLog(@"蓝牙列表==%@",array);
        if (data && isCurrentBle) {
            for (int i=0; i<array.count; i++) {
                if ([[data objectForKey:@"identifier"] isEqualToString: [[array objectAtIndex:i] objectForKey:@"identifier"] ]) {
                    
                    isCurrentBle = NO;
                    //搜索到蓝牙设备之后,并直接连接
                    [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"serviceUUIDs"] identifier:[data objectForKey:@"identifier"]];
                    
                    break;
                }
            }
        }
        
    };
     */
    
    
    /*
    //判断蓝牙是连接成功/失败
    [[AppDelegate shareGlobal] manager].stateBlock = ^(int number) {
        NSLog(@"状态==%d",number);
        if (number != 0) {
            [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"serviceUUIDs"] identifier:[data objectForKey:@"identifier"]];
        }
    };

    */
    
    //判断蓝牙是连接成功/失败
    [[AppDelegate shareGlobal] manager].stateBlock = ^(int number,NSString *idFlag,int errCode) {
        NSLog(@"状态==%d===%d",number,errCode);
        
//        [self updateLog:[NSString stringWithFormat:@"num==%d,err==%d",number,errCode]];
        //判断是断开蓝牙还是断开连接
        if (errCode != 0) {//断电的情况
            //判断当前断电的沙发
            if ([idFlag isEqualToString:[data objectForKey:@"identifier"]]) {
                if (number != 0) {
                    [AppDelegate shareGlobal].globalPowerOff = YES;
                    
                    [cupBtn setEnabled:NO];
                    [readBtn setEnabled:NO];
                    [lightBtn setEnabled:NO];
                    [switchBtn setEnabled:NO];
                }
                else{
                    //表示蓝牙断开,解锁
                    [cupBtn setEnabled:YES];
                    [readBtn setEnabled:YES];
                    [switchBtn setEnabled:YES];
                    [lightBtn setEnabled:YES];
                }
                
            }
        }
        else{
            //判断当前断电的沙发
            if ([idFlag isEqualToString:[data objectForKey:@"identifier"]]) {
                if (number == 0) {
                    //连接
                    [cupBtn setEnabled:YES];
                    [readBtn setEnabled:YES];
                    [lightBtn setEnabled:YES];
                    [switchBtn setEnabled:YES];
                    
                }
            }
        }
    };
    
    
    [[AppDelegate shareGlobal] manager].noPeripheralBlock = ^(NSString *state) {
//        NSLog(@"无匹配蓝牙状态状态==%@",state);
        if ([state intValue] == 1) {
        }
    };
    

}


//开关
-(void)switchBtn{
    
    isSwitch = !isSwitch;
    
    if (isSwitch) {
        if (brightInt == 0) {
            brightInt = 50;
        }
        
//        isCup = [[NSUserDefaults standardUserDefaults] objectForKey:@"isCup"];
//        isRead = [[NSUserDefaults standardUserDefaults] objectForKey:@"isRead"];
    }
    else{
        brightInt = 0;
    }
    
    [self control];
    [self layoutControlView];
}


//杯子
-(void)cupBtn{

    isCup = YES;
    isRead = NO;
    isLight = NO;
    
    if (isColor) {
        isColor = YES;
    }
    else{
        isColor = NO;
    }
   
    if (isLightColor) {
        isLightColor = YES;
    }
    else{
        isLightColor = NO;
    }
//    [[NSUserDefaults standardUserDefaults] setBool:isCup forKey:@"isCup"];
//    [[NSUserDefaults standardUserDefaults] setBool:isRead forKey:@"isRead"];
    
    [self requestCupControlState];
}

//阅读
-(void)readBtn{

    isRead = YES;
    isCup = NO;
    isLight = NO;
    
    if (isColor) {
        isColor = YES;
    }
    else{
        isColor = NO;
    }
    
    if (isLightColor) {
        isLightColor = YES;
    }
    else{
        isLightColor = NO;
    }
    
//    [[NSUserDefaults standardUserDefaults] setBool:isCup forKey:@"isCup"];
//    [[NSUserDefaults standardUserDefaults] setBool:isRead forKey:@"isRead"];
    
    [self requestReadControlState];
}

//灯带
-(void)lightBtn{
    isCup = NO;
    isRead = NO;
    isLight = YES;
    
    if (isColor) {
        isColor = YES;
    }
    else{
        isColor = NO;
    }
    
    if (isLightColor) {
        isLightColor = YES;
    }
    else{
        isLightColor = NO;
    }
    
    //    [[NSUserDefaults standardUserDefaults] setBool:isCup forKey:@"isCup"];
    //    [[NSUserDefaults standardUserDefaults] setBool:isRead forKey:@"isRead"];
    
    [self requestLightControlState];
}
//定时
- (void)timerSlider{
    
    int n = (timerSlider.value + 6) / 15;
    timeInt = n * 15;
    //    NSLog(@"value=%d",timeInt);
    [timerSlider setValue:timeInt animated:NO];
    
    if (!isSwitch) {
        [self updateLog:@"Please switch on"];
        return ;
    }
    
    [self control];

}

//亮度
-(void)brightSlider{
    
    if (!isSwitch) {
        [self updateLog:@"Please switch on"];
        [brightSlider setValue:0 animated:NO];
        return ;
    }
    
    brightInt = (int)(brightSlider.value);
//    NSLog(@"value=%d",brightInt);
    if (isFree) {
         [self performSelector:@selector(control) withObject:nil afterDelay:0.2];
    }
}


-(void)colorSlider{
    
    colorInt = (int)colorSlider.value;
//    NSLog(@"color:::===%d",colorInt);
    if (colorInt == 1) {
        [colorSlider setValue:1.3 animated:NO];
    }
    else  if (colorInt == 2){
        [colorSlider setValue:2.2 animated:NO];
    }
    else if (colorInt == 3){
        [colorSlider setValue:3.1 animated:NO];
    }
    else if (colorInt == 4){
        [colorSlider setValue:4 animated:NO];
    }
    else if (colorInt == 5){
        [colorSlider setValue:4.9 animated:NO];
    }
    else if (colorInt == 6){
        [colorSlider setValue:5.8 animated:NO];
    }
    else if (colorInt == 7){
        [colorSlider setValue:6.7 animated:NO];
    }
    
    if (!isSwitch) {
        [self updateLog:@"Please switch on"];
        return ;
    }
    
    [self control];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)maxConnectState:(BOOL)state{
    
    [cupBtn setEnabled:state];
    [readBtn setEnabled:state];
    [lightBtn setEnabled:state];
    [switchBtn setEnabled:state];
    
    if (!state) {
         [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
    }
}


-(void)control{
    
//    [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"serviceUUIDs"] identifier:[data objectForKey:@"identifier"]];
    
    if (isCup) {
        //灯杯
        isFree = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(control) object:nil];
        [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"26",[NSString stringWithFormat:@"00%02d%02x%02x",colorInt,brightInt,timeInt],msgCRC16]];
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//            NSLog(@"数据返回：灯==%@",array);
            if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                [self maxConnectState:NO];
                return ;
            }
            else{
                [self maxConnectState:YES];
            }
            
            if ([[self responseData:array] intValue] == 0) {
                
                isFree = YES;
                if (brightInt == 0) {
                    [self layoutControlView];
                }
            }
            else{
//                [self updateLog:[self responseData:array]];
            }
        };
    }
    else if(isRead) {
        //判断阅读
        if (isRead) {
            isFree = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(control) object:nil];
            [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"27",[NSString stringWithFormat:@"0000%02x%02x",brightInt,timeInt],msgCRC16]];
            [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//                NSLog(@"数据返回：阅读==%@",array);
                if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                    [self maxConnectState:NO];
                    return ;
                }
                else{
                    [self maxConnectState:YES];
                }
                
                if ([[self responseData:array] intValue] == 0) {
                    isFree = YES;
                    if (brightInt == 0) {
                        [self layoutControlView];
                    }
                }
                else{
//                    [self updateLog:[self responseData:array]];
                }
            };
        }
    }
    else{
        //判断灯带
        if (isLight) {
            isFree = NO;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(control) object:nil];
            [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"25",[NSString stringWithFormat:@"00%02d%02x%02x",colorInt,brightInt,timeInt],msgCRC16]];
            [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                //                NSLog(@"数据返回：阅读==%@",array);
                if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                    [self maxConnectState:NO];
                    return ;
                }
                else{
                    [self maxConnectState:YES];
                }
                
                if ([[self responseData:array] intValue] == 0) {
                    isFree = YES;
                    if (brightInt == 0) {
                        [self layoutControlView];
                    }
                }
                else{
                    //                    [self updateLog:[self responseData:array]];
                }
            };
        }

    }
   
}



//获取灯桶状态
-(void)requestCupControlState{
    //获取灯桶
    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"41",@"00000000",msgCRC16]];
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//        NSLog(@"数据返回：灯桶==%@",array);
        
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            [self maxConnectState:NO];
            return ;
        }
        else{
            [self maxConnectState:YES];
        }
        
        if ([[self responseData:array] intValue] == 0) {
            if ([[array objectAtIndex:4+1] intValue] == 41) {
                if (isColor) {
                    //彩灯
                    colorInt = [[array objectAtIndex:6+1] intValue];
                    if (colorInt == 0) {
                        colorInt = 1;
                    }
                }
                
                //亮度--当亮度为0时,开关为：关，其他为：开
                NSString *temp_light = [NSString stringWithFormat:@"%lu",strtoul([[array objectAtIndex:7+1] UTF8String],0,16)];
                brightInt = [temp_light intValue];

                //定时
                NSString *temp_timer = [NSString stringWithFormat:@"%lu",strtoul([[array objectAtIndex:8+1] UTF8String],0,16)];
                timeInt = [temp_timer intValue];
//                NSLog(@"timeInttimeInt==%d",timeInt);
                if (timeInt == 0) {
                    timeInt = 15;
                }
                
                if (brightInt == 0) {
                    isSwitch = NO;
                }
                else{
                    isSwitch = YES;
                }
                [self layoutControlView];//重新布局
            }
        }
        else{
//            [self updateLog:[self responseData:array]];
        }
        
    };
}


//获取控制状态
-(void)requestReadControlState{
    
    //获取阅读灯
    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"42",@"00000000",msgCRC16]];
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
//        NSLog(@"数据返回：阅读灯==%@",array);
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            [self maxConnectState:NO];
            return ;
        }
        else{
            [self maxConnectState:YES];
        }
        
        if ([[self responseData:array] intValue] == 0) {
            //亮度
            NSString *temp_bright = [NSString stringWithFormat:@"%lu",strtoul([[array objectAtIndex:7+1] UTF8String],0,16)];
            brightInt = [temp_bright intValue];
            
            if (brightInt == 0) {
                isSwitch = NO;
            }
            else{
                isSwitch = YES;
            }
            
            NSString *temp_timer = [NSString stringWithFormat:@"%lu",strtoul([[array objectAtIndex:8+1] UTF8String],0,16)];
            //定时
            timeInt = [temp_timer intValue];
            if (timeInt == 0) {
                timeInt = 15;
            }
            
            [self layoutControlView];//重新布局

        }
        else{
//            [self updateLog:[self responseData:array]];
        }
    };
}


//获取灯带控制状态
-(void)requestLightControlState{
    
    //获取灯带
    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"40",@"00000000",msgCRC16]];
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
//        NSLog(@"数据返回：灯带==%@",array);
        
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            [self maxConnectState:NO];
            return ;
        }
        else{
            [self maxConnectState:YES];
        }
        
        if ([[self responseData:array] intValue] == 0) {
            
            if (isLightColor) {
                //彩灯
                colorInt = [[array objectAtIndex:6+1] intValue];
                if (colorInt == 0) {
                    colorInt = 1;
                }
            }
            
            //亮度
            NSString *temp_bright = [NSString stringWithFormat:@"%lu",strtoul([[array objectAtIndex:7+1] UTF8String],0,16)];
            brightInt = [temp_bright intValue];
            
            if (brightInt == 0) {
                isSwitch = NO;
            }
            else{
                isSwitch = YES;
            }
            
            NSString *temp_timer = [NSString stringWithFormat:@"%lu",strtoul([[array objectAtIndex:8+1] UTF8String],0,16)];
            //定时
            timeInt = [temp_timer intValue];
            if (timeInt == 0) {
                timeInt = 15;
            }
            
            [self layoutControlView];//重新布局
            
        }
        else{
            //            [self updateLog:[self responseData:array]];
        }
    };
}

@end
