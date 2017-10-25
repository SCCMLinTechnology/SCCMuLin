//
//  OPFunctionView.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/8/24.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "OPFunctionView.h"

@implementation OPFunctionView

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        saveTag = 0;
        [[UIButton appearance] setExclusiveTouch:YES]; //一个视图上的多个控件同时点击同时响应的
        [self initView];//初始化view
    }
    return self;
}


-(void)initView{
    //背景图
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"op_functionbg"];
    bgImg.tag = 100000;
    [self addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            make.left.mas_offset(70);
            make.right.mas_offset(-70);
            make.top.bottom.mas_offset(0);
        }
        else{
             make.left.right.top.bottom.mas_equalTo(0);
        }
       
    }];
    
}


//根据配置项目布局
-(void)opFunctionLayout:(BOOL)isLock isError:(BOOL)isError isLight:(BOOL)isLight isHome:(BOOL)isHome  position:(int)position{
    
    //删除以前布局，只保留一层
    for (UIView *sub in self.subviews) {
        if (sub.tag < 100000) {
             [sub removeFromSuperview];
        }
    }
    
    //底部--复位
    UIButton *rBtn = nil;
    rBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (isHome) {
        
        [rBtn setBackgroundImage:[UIImage imageNamed:@"bt_h_n"] forState:UIControlStateNormal];
        [rBtn addTarget:self action:@selector(startResertHome) forControlEvents:UIControlEventTouchDown];
        [rBtn addTarget:self action:@selector(stopResertHome) forControlEvents:UIControlEventTouchUpInside];
        [rBtn addTarget:self action:@selector(stopResertHome) forControlEvents:UIControlEventTouchDragExit |UIControlEventTouchDragOutside];
    }
    else{
        [rBtn setBackgroundImage:[UIImage imageNamed:@"r"] forState:UIControlStateNormal];
        [rBtn addTarget:self action:@selector(resert) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [self addSubview:rBtn];
    [rBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            make.bottom.mas_equalTo(-60);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(100, 60));
        }
        else{
            make.bottom.mas_equalTo(-30);
            make.centerX.mas_equalTo(self);
            make.size.mas_equalTo(CGSizeMake(75, 47));
        }
    }];

    
    posIndex = position;
    //锁
    lock = isLock;
    
//    NSLog(@"isLockisLockisLock==%d",isLock);
    
    UIButton *lockBtn = nil;
    
    lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (isLock) {
        [lockBtn setBackgroundImage:[UIImage imageNamed:@"lock"] forState:UIControlStateNormal];
    }
    else{
        [lockBtn setBackgroundImage:[UIImage imageNamed:@"un_lock"] forState:UIControlStateNormal];
    }
    lockBtn.tag = 10001;
    [lockBtn addTarget:self action:@selector(clicklock:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:lockBtn];
    [lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (ipad) {
            make.top.mas_equalTo(50);
            if (isLight) {
                make.right.mas_equalTo(rBtn.mas_left).offset(-30);
            }
            else{
                make.centerX.mas_equalTo(self);
            }
            make.size.mas_equalTo(CGSizeMake(100, 60));
        }
        else{
            make.top.mas_equalTo(20);
            if (isLight) {
                make.right.mas_equalTo(rBtn.mas_left).offset(5);
            }
            else{
                make.centerX.mas_equalTo(self);
            }
            make.size.mas_equalTo(CGSizeMake(75, 47));
        }
        
    }];
    
    
    if (isLight) {
        //灯
        light = isLight;
        UIButton *lightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         [lightBtn setBackgroundImage:[UIImage imageNamed:@"bt_dengliang_h"] forState:UIControlStateNormal];
        /*
        if (isLight){
            
           
        }
        else{
            
            [lightBtn setBackgroundImage:[UIImage imageNamed:@"bt_dengguan_n"] forState:UIControlStateNormal];
        }
         */
        lightBtn.tag = 10002;
        [lightBtn addTarget:self action:@selector(clicklight:) forControlEvents:UIControlEventTouchUpInside];
//        [lightBtn addTarget:self action:@selector(clicklight:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:lightBtn];
        [lightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.top.mas_equalTo(lockBtn.mas_top);
//            make.left.mas_equalTo(lockBtn.mas_right).offset(15);
            if (ipad) {
                make.left.mas_equalTo(rBtn.mas_right).offset(30);
                make.size.mas_equalTo(CGSizeMake(100, 60));
            }
            else{
                make.left.mas_equalTo(rBtn.mas_right).offset(-5);
                make.size.mas_equalTo(CGSizeMake(75, 47));
            }
            
        }];
        lightBtn.mm_acceptEventInterval = 0.3;

    }
    
    //线
    UIImageView *lineImg = [UIImageView new];
    lineImg.image = [UIImage imageNamed:@"op_line"];
    [self addSubview:lineImg];
    [lineImg mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            make.left.mas_equalTo(71);
            make.right.mas_equalTo(-71);
            make.top.mas_equalTo(lockBtn.mas_bottom).offset(20);
            make.height.mas_equalTo(3);
        }
        else{
            make.left.mas_equalTo(1);
            make.right.mas_equalTo(-1);
            make.top.mas_equalTo(lockBtn.mas_bottom).offset(10);
            make.height.mas_equalTo(3);
        }
        
    }];
   
    
    
    
    //底部--p1
    UIButton *p1Btn = nil;
    p1Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [p1Btn setBackgroundImage:[UIImage imageNamed:@"p1"] forState:UIControlStateNormal];
    //恢复记忆
    [p1Btn addTarget:self action:@selector(recoveryMemery:) forControlEvents:UIControlEventTouchUpInside];
    [p1Btn addTarget:self action:@selector(buttonOK) forControlEvents:UIControlEventTouchDragOutside | UIControlEventTouchDragExit];
    p1Btn.tag = 1;
    [p1Btn addTarget:self action:@selector(changeState) forControlEvents:UIControlEventTouchDown];
    //保存记忆
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveMemery:)];
    longPress.minimumPressDuration = 1.0; //定义按的时间
    [p1Btn addGestureRecognizer:longPress];
    
    [self addSubview:p1Btn];
    [p1Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            //        make.bottom.mas_equalTo(rBtn.mas_bottom);
            make.centerY.mas_equalTo(rBtn.mas_centerY);
            make.right.mas_equalTo(rBtn.mas_left).offset(-50);
            make.size.mas_equalTo(CGSizeMake(70, 70));
        }
        else{
            //        make.bottom.mas_equalTo(rBtn.mas_bottom);
            make.centerY.mas_equalTo(rBtn.mas_centerY);
            make.right.mas_equalTo(rBtn.mas_left).offset(-20);
            make.size.mas_equalTo(CGSizeMake(62, 62));
        }

    }];
    
//    p1Btn.mm_acceptEventInterval = 0.5;
    
    //底部--p2
    UIButton *p2Btn = nil;
    p2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [p2Btn setBackgroundImage:[UIImage imageNamed:@"p2"] forState:UIControlStateNormal];
    //恢复记忆
    [p2Btn addTarget:self action:@selector(recoveryMemery:) forControlEvents:UIControlEventTouchUpInside];
    [p2Btn addTarget:self action:@selector(buttonOK) forControlEvents:UIControlEventTouchDragOutside | UIControlEventTouchDragExit];
//    p2Btn.mm_acceptEventInterval = 0.5;
    p2Btn.tag = 2;
    [p2Btn addTarget:self action:@selector(changeState) forControlEvents:UIControlEventTouchDown];
    //保存记忆
    UILongPressGestureRecognizer *longPress_ = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(saveMemery:)];
    longPress_.minimumPressDuration = 1.0; //定义按的时间
    [p2Btn addGestureRecognizer:longPress_];
    [self addSubview:p2Btn];
    [p2Btn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            //        make.bottom.mas_equalTo(rBtn.mas_bottom);
            make.centerY.mas_equalTo(rBtn.mas_centerY);
            make.left.mas_equalTo(rBtn.mas_right).offset(50);
            make.size.mas_equalTo(CGSizeMake(70, 70));
        }
        else{
            //        make.bottom.mas_equalTo(rBtn.mas_bottom);
            make.centerY.mas_equalTo(rBtn.mas_centerY);
            make.left.mas_equalTo(rBtn.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(62, 62));
        }

    }];
    
    
    //头部
    UIButton *headBtn_l = nil;
    headBtn_l = [UIButton buttonWithType:UIButtonTypeCustom];
    headBtn_l.tag = 1;
    [headBtn_l setBackgroundImage:[UIImage imageNamed:@"bt_tou_up"] forState:UIControlStateNormal];
    [headBtn_l addTarget:self action:@selector(startRotate:) forControlEvents:UIControlEventTouchDown];
    [headBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents:UIControlEventTouchUpInside];
//    [headBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents:];
    [headBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents: UIControlEventTouchDragExit |UIControlEventTouchDragOutside];
    [self addSubview:headBtn_l];
    [headBtn_l mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            make.top.mas_equalTo(lineImg.mas_bottom).offset(80);
            make.right.mas_equalTo(rBtn.mas_left).offset(-30);
            make.size.mas_equalTo(CGSizeMake(100, 60));
        }
        else{
            make.top.mas_equalTo(lineImg.mas_bottom).offset(20);
            make.right.mas_equalTo(rBtn.mas_left).offset(10);
            make.size.mas_equalTo(CGSizeMake(98, 54));
        }
        
    }];
    

    UIButton *headBtn_r = nil;
    headBtn_r = [UIButton buttonWithType:UIButtonTypeCustom];
    headBtn_r.tag = 11;
    [headBtn_r setBackgroundImage:[UIImage imageNamed:@"bt_tou_down"] forState:UIControlStateNormal];
    [headBtn_r addTarget:self action:@selector(startRotate:) forControlEvents:UIControlEventTouchDown];
    [headBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents:UIControlEventTouchUpInside];
//    [headBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents:];
    [headBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents: UIControlEventTouchDragExit |UIControlEventTouchDragOutside];
    [self addSubview:headBtn_r];
    [headBtn_r mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
            make.top.mas_equalTo(headBtn_l.mas_top);
            make.left.mas_equalTo(rBtn.mas_right).offset(30);
            make.size.mas_equalTo(CGSizeMake(100, 60));
        }
        else{
            make.top.mas_equalTo(headBtn_l.mas_top);
            make.left.mas_equalTo(rBtn.mas_right).offset(-10);
            make.size.mas_equalTo(CGSizeMake(98, 54));
        }
        
    }];
    
  
    //脚部
    UIButton *footBtn_l = nil;
    footBtn_l = [UIButton buttonWithType:UIButtonTypeCustom];
    footBtn_l.tag = 2;
    [footBtn_l setBackgroundImage:[UIImage imageNamed:@"bt_tui_up"] forState:UIControlStateNormal];
    [footBtn_l addTarget:self action:@selector(startRotate:) forControlEvents:UIControlEventTouchDown];
    [footBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents:UIControlEventTouchUpInside];
//    [footBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents:];
    [footBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchDragOutside];
    [self addSubview:footBtn_l];
    [footBtn_l mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (ipad) {
            make.top.mas_equalTo(headBtn_l.mas_bottom).offset(80);
            make.right.mas_equalTo(rBtn.mas_left).offset(-20);
            make.size.mas_equalTo(CGSizeMake(120, 60));
        }
        else{
            make.top.mas_equalTo(headBtn_l.mas_bottom).offset(35);
            if (iPhone5) {
                make.right.mas_equalTo(rBtn.mas_left).offset(25);
            }
            else{
                make.right.mas_equalTo(rBtn.mas_left).offset(10);
            }
            
            make.size.mas_equalTo(CGSizeMake(120, 60));
        }
        
    }];
    
    
    UIButton *footBtn_r = nil;
    footBtn_r = [UIButton buttonWithType:UIButtonTypeCustom];
    footBtn_r.tag = 12;
    [footBtn_r setBackgroundImage:[UIImage imageNamed:@"bt_tui_down"] forState:UIControlStateNormal];
    [footBtn_r addTarget:self action:@selector(startRotate:) forControlEvents:UIControlEventTouchDown];
    [footBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents:UIControlEventTouchUpInside];
//    [footBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents:];
    [footBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchDragOutside];
    [self addSubview:footBtn_r];
    [footBtn_r mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if (ipad) {
            make.top.mas_equalTo(footBtn_l.mas_top);
            make.left.mas_equalTo(rBtn.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(120, 60));
        }
        else{
            make.top.mas_equalTo(footBtn_l.mas_top);
            if (iPhone5) {
                make.left.mas_equalTo(rBtn.mas_right).offset(-25);
            }
            else{
                make.left.mas_equalTo(rBtn.mas_right).offset(-10);
            }
            
            make.size.mas_equalTo(CGSizeMake(120, 60));
        }
        
    }];

    
     if (position > 1) {
         [headBtn_l setHidden:NO];
         [headBtn_r setHidden:NO];
     }
     else{
         [headBtn_l setHidden:YES];
         [headBtn_r setHidden:YES];
     }
    
    
    //腰部
    if (position > 2) {
        
        UIButton *backBtn_l = nil;
        backBtn_l = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn_l.tag = 3;
        [backBtn_l setBackgroundImage:[UIImage imageNamed:@"bt_bei_up"] forState:UIControlStateNormal];
        [backBtn_l addTarget:self action:@selector(startRotate:) forControlEvents:UIControlEventTouchDown];
        [backBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents:UIControlEventTouchUpInside];
//        [backBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents:];
        [backBtn_l addTarget:self action:@selector(stopRotate:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchDragOutside];
        [self addSubview:backBtn_l];
        [backBtn_l mas_makeConstraints:^(MASConstraintMaker *make) {
            if (ipad) {
                make.top.mas_equalTo(footBtn_l.mas_bottom).offset(80);
                make.right.mas_equalTo(rBtn.mas_left).offset(-30);
                make.size.mas_equalTo(CGSizeMake(100, 60));
            }
            else{
                make.top.mas_equalTo(footBtn_l.mas_bottom).offset(35);
                make.right.mas_equalTo(rBtn.mas_left).offset(10);
                make.size.mas_equalTo(CGSizeMake(98, 54));
            }
            
        }];
        
        
        UIButton *backBtn_r = nil;
        backBtn_r = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn_r.tag = 13;
        [backBtn_r setBackgroundImage:[UIImage imageNamed:@"bt_bei_down"] forState:UIControlStateNormal];
        [backBtn_r addTarget:self action:@selector(startRotate:) forControlEvents:UIControlEventTouchDown];
        [backBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents:UIControlEventTouchUpInside];
//        [backBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents:];
        [backBtn_r addTarget:self action:@selector(stopRotate:) forControlEvents: UIControlEventTouchDragExit | UIControlEventTouchDragOutside];
        [self addSubview:backBtn_r];
        [backBtn_r mas_makeConstraints:^(MASConstraintMaker *make) {
            if (ipad) {
                make.top.mas_equalTo(backBtn_l.mas_top);
                make.left.mas_equalTo(rBtn.mas_right).offset(30);
                make.size.mas_equalTo(CGSizeMake(100, 60));
            }
            else{
                make.top.mas_equalTo(backBtn_l.mas_top);
                make.left.mas_equalTo(rBtn.mas_right).offset(-10);
                make.size.mas_equalTo(CGSizeMake(98, 54));
            }
            
        }];
    }
   
    
    if (isLock) {
        
        /*
        UIView *lockView =[UIView new];
        lockView.backgroundColor = [UIColor blackColor];
        lockView.alpha = 0.3;
        [self addSubview:lockView];
        [lockView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(100);
            make.left.right.bottom.mas_equalTo(0);
        }];
        
        UIImageView *lockImg = [UIImageView new];
        lockImg.image = [UIImage imageNamed:@"ic_suo"];
        [lockView addSubview:lockImg];
        [lockImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(lockView);
            make.size.mas_equalTo(CGSizeMake(23, 27));
        }];
         */
        [self buttonLockFailue];
        
    }
    else{
        [self buttonLockOK];
        
        if (isError) {
            [self buttonFailue];
        }
        else{
            [self buttonOK];
        }
    }
}


//锁功能
-(void)clicklock:(UIButton *)sender{
    
//    lock = !lock;
    
//    [self opFunctionLayout:lock isLight:light position:posIndex];
    
    [_delegate isLockFunc:lock];
    
}


//灯功能
-(void)clicklight:(UIButton *)sender{
    
//    light = !light;
//    [self opFunctionLayout:lock isLight:light position:posIndex];
    [_delegate isLightFunc:light];
}

//复位
-(void)resert{
    
    [self buttonFailue];
    [_delegate resertFunc];
}

-(void)changeState{
    
    [self buttonFailue];
    [_delegate changeStateFunc];
}
//保存记忆
-(void)saveMemery:(UILongPressGestureRecognizer *)gestureRecognizer{
//    NSLog(@"gestureRecognizer==%@",gestureRecognizer);
    UIView *view = gestureRecognizer.view;
    
//    NSLog(@"view==%@",view);
    NSString *memery;
    ++saveTag;
    if (saveTag >=2) {
        return;
    }
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        
        if (view.tag == 1) {
            //M1长按事件
            memery=@"1";
        }
        else{
            //M2长按事件
            memery=@"2";
        }
        
        [self buttonFailue];
        [_delegate saveMemeryFunc:memery];
    }
}


-(void)setSaveNum
{
//    NSLog(@"这里");
    saveTag = 0;
}
//恢复记忆
-(void)recoveryMemery:(UIButton *)sender{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(recoveryMemery:) object:nil];
    //左边与右边 p1与p2
    NSString *memery;
    if (sender.tag == 1) {
         memery= @"1";
    }
    else{
         memery=@"2";
    }

    [self buttonFailue];
    
    [_delegate recoveryMemeryFunc:memery];
}

//开始旋转
-(void)startRotate:(UIButton *)sender{

    NSString *positon;
    if (sender.tag < 10) {
        positon = @"L";//代表左边
    }
    else{
        positon = @"R";//代表右边
    }
    
    //判断选择的是哪一个
    NSString *seatPoisiton;
    if (sender.tag == 1 || sender.tag == 11) {
        //头部 02
        seatPoisiton = @"02";
    }
    else if (sender.tag == 2 || sender.tag == 12){
        //脚部 01
        seatPoisiton = @"01";
    }
    else if (sender.tag == 3 || sender.tag == 13){
        //背部 03
        seatPoisiton = @"03";
    }
    
    
    [self buttonFailue];
    
    [_delegate startRotateFunc:positon indexNum:seatPoisiton];
    
}

//停止旋转
-(void)stopRotate:(UIButton *)sender{
    
    [self buttonOK];
    [_delegate stopRotateFunc];
    
}


//开始Home
-(void)startResertHome{
    
    [self buttonFailue];
    [_delegate startResertHomeFunc];
}


//停止Home
-(void)stopResertHome{
   
    [self buttonOK];
    [_delegate stopResertHomeFunc];
//    [self buttonFailue];
}

//按钮禁止
-(void)buttonLockFailue{
    
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            if (sub.tag < 10000) {
                UIButton *btn =(UIButton *)sub;
                [btn setEnabled:NO];
            }
        }
    }
}


-(void)buttonLockOK{
    for (UIView *sub in self.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            if (sub.tag < 10000) {
                UIButton *btn =(UIButton *)sub;
                [btn setEnabled:YES];
            }
        }
    }
}
 //按钮恢复
 -(void)buttonOK{
 
     for (UIView *sub in self.subviews) {
         if ([sub isKindOfClass:[UIButton class]]) {
             UIButton *btn =(UIButton *)sub;
             [btn setEnabled:YES];
             [_delegate changeStateOKFunc];
         }
     }
 }
 
 //按钮禁止
 -(void)buttonFailue{
 
     for (UIView *sub in self.subviews) {
         if ([sub isKindOfClass:[UIButton class]]) {
             UIButton *btn =(UIButton *)sub;
             [btn setEnabled:NO];
         }
     }
 }

@end
