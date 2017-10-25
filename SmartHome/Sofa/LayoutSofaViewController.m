//
//  LayoutSofaViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/6/29.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "LayoutSofaViewController.h"

@interface LayoutSofaViewController (){

    LayoutSofaView *layoutsofa;//布局界面
    NSString *idStr;

    NSMutableArray *sofaArr;
    NSString *pos;
    
    BOOL isClick;//是否点击
    
    int currentPosIndex;
    NSMutableDictionary *currentDic;
    
    UIButton *btn_l;
    UIButton *btn_r;
    UIButton *btn_save;
    
    int indexNum;
    int moreNum;
    
    BOOL isCurrentBle;
    
    NSString *currentScreen;//当前的存储信息的位置
    
    NSMutableArray *scanTemp;
    
    BOOL isPowerOff;//是否断电
    
    NSMutableArray *saveBLEArr;
    
    BOOL isUnexpected;//是否意外
}

@end

@implementation LayoutSofaViewController
@synthesize scanSofaArr;

//返回上一层
-(void)popToPre{
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    isUnexpected = NO;
    //增加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnexpectedInterruptionNotice) name:@"UnexpectedInterruptionNotice" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //删除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UnexpectedInterruptionNotice" object:nil];

}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.hidesBackButton = YES;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    [[UIButton appearance] setExclusiveTouch:YES]; //一个视图上的多个控件同时点击同时响应的
    
   //背景图片
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];

    /*
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
    */
    
    
    //描述文字 -Finger touch control sofa movement
    [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake(15, 20, sWIDTH - 15*2, 20) text:@"Press and drag the sofa" color:kUIColorFromRGB(0x575757) font:[UIFont systemFontOfSize:14.0] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter]];
    //Finger touch into the spin mode
    [self.view addSubview:[UILabel commonLabelWithFrame:CGRectMake(15, 45, sWIDTH - 15*2, 20) text:@"Double-Click to spin the sofa" color:kUIColorFromRGB(0x575757) font:[UIFont systemFontOfSize:14.0] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter]];
    
    //画线1
    UILabel *line1 = [UILabel commonLabelWithFrame:CGRectMake(15, 75, sWIDTH - 15*2, 0.5) text:@"" color:[UIColor clearColor] font:[UIFont systemFontOfSize:0.0] bgColor:kUIColorFromRGB(0xd2d2d2) textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:line1];
    
    
    //布局界面
    layoutsofa = [[LayoutSofaView alloc] initWithFrame:CGRectMake(spaceWidth, line1.frame.origin.y+15+(ipad ? 75 :0), boxWidth *shu_box, boxWidth *heng_box)];
    layoutsofa.delegate = self;
    [self.view addSubview:layoutsofa];
    
    
    //底部测试视图
    [self.view addSubview:[self testOpView]];
    
    
    //获取蓝牙列表
    NSArray *listArr = [[NSArray alloc] initWithArray:[AppDelegate shareGlobal].bleListArr];
    
//    NSMutableArray *temp = [[NSMutableArray alloc] init];
//    [temp addObjectsFromArray:listArr];
//    [temp addObjectsFromArray:listArr];
    //拆分
    sofaArr = [[NSMutableArray alloc] initWithArray:[self getSofaArrByBLEArr:listArr]];
//    NSLog(@"sofaArr==%@",sofaArr);

    //[layoutsofa layoutSetDataToBox:sofaArr];

    //判断蓝牙是打开/关闭
    [[AppDelegate shareGlobal] manager].linkBlcok = ^(NSString *state){
    
//        NSLog(@"断开/连接==%@",state);
        [AppDelegate shareGlobal].link = state;
        if ([state isEqualToString:kCONNECTED_POWERD_ON]) {
            
            [btn_l setEnabled:YES];
            [btn_r setEnabled:YES];
            [btn_save setEnabled:YES];
            
//            isCurrentBle = YES;
            //蓝牙打开之后，搜索设备
//            [[[AppDelegate shareGlobal] manager] scanMgr];
            if (currentDic) {
                //搜索到蓝牙设备之后,并直接连接
                [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[currentDic objectForKey:@"serviceUUIDs"] identifier:[currentDic objectForKey:@"identifier"]];
                
                [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
                    //连接成功之后
//                    NSLog(@"到达这里了");
                    if ([state intValue] == 1) {
                        isClick = YES;
                    }
                };
            }
        }
        else{
            
            [self updateLog:@"Please open Bluetooth"];
            
            [btn_l setEnabled:NO];
            [btn_r setEnabled:NO];
            [btn_save setEnabled:NO];
        }
        
    };
    
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
        [self updateLog:@"Please open Bluetooth"];
        
        [btn_l setEnabled:NO];
        [btn_r setEnabled:NO];
        [btn_save setEnabled:NO];
        
        return ;
    }
    
//    [[AppDelegate shareGlobal] manager].listBlock = ^(NSMutableArray *array) {
////        NSLog(@"蓝牙列表入口==%@",array);
//  
//    };
    
    //判断蓝牙是连接成功/失败
    [[AppDelegate shareGlobal] manager].stateBlock = ^(int number,NSString *idFlag,int errCode) {
//        NSLog(@"状态=2=%d=2=err=2=%d=2=flag==%@",number,errCode,idFlag);
        //判断是断开蓝牙还是断开连接
        if (errCode != 0) {//断电的情况
            //判断当前断电的沙发
            if ([idFlag isEqualToString:[currentDic objectForKey:@"identifier"]]) {//判断当前点击的沙发
                
                isPowerOff = YES;
                
                if (number != 0) {
                    
                    //下方三个可以点击
                    [btn_l setEnabled:YES];
                    [btn_r setEnabled:YES];
                    [btn_save setEnabled:YES];
                    
                    //图标置为显示故障图标
                    [self connectOrDis:1];
                }
                else{
                    //下方三个可以点击
                    [btn_l setEnabled:YES];
                    [btn_r setEnabled:YES];
                    [btn_save setEnabled:YES];
                    
                    [self connectOrDis:0];
                }
            }
        }
        else{
            //判断当前通电
            if ([idFlag isEqualToString:[currentDic objectForKey:@"identifier"]]) {
                if (number == 0) {
                    isPowerOff = NO;
                    
                    [btn_l setEnabled:YES];
                    [btn_r setEnabled:YES];
                    [btn_save setEnabled:YES];
                    
                    [self connectOrDis:0];
                }
            }
        }
        
    };
    
    
    //无匹配蓝牙
    [[AppDelegate shareGlobal] manager].noPeripheralBlock = ^(NSString *state) {
//        NSLog(@"无匹配蓝牙状态状态==%@",state);
        if ([state intValue] == 1) {
            
            isPowerOff = YES;
            
//            [btn_l setEnabled:NO];
//            [btn_r setEnabled:NO];
//            [btn_save setEnabled:NO];
            
            [self connectOrDis:1];
        }
    };

    
    [self initDataView];
}


//意外中断通知
-(void)UnexpectedInterruptionNotice{
    NSLog(@"意外中断");
    [[VWProgressHUD shareInstance] dismiss];
    isUnexpected = YES;
    [btn_l setEnabled:YES];
    [btn_r setEnabled:YES];
    [btn_save setEnabled:YES];
    
}

//最大连接数量
-(void)maxConnectState:(BOOL)state
{
    [btn_l setEnabled:state];
    [btn_r setEnabled:state];
    [btn_save setEnabled:state];
    
    if (!state) {
        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
    }
    
    
}

-(void)initDataView{
    isClick = NO;
    //布局
    [layoutsofa layoutSetDataToBox:sofaArr  isMove:YES isBack:YES isTest:YES finishCallBack:^(NSDictionary *data, int currentIndex, int position) {
        
        currentPosIndex = currentIndex;
        //选中当前沙发
        currentDic = [[NSMutableDictionary alloc] initWithDictionary:data];
        
        if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
            
        }
        else{
            [self updateLog:@"Please open Bluetooth"];
            return ;
        }
        
        isClick = YES;
        
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"serviceUUIDs"] identifier:[data objectForKey:@"identifier"]];
        
        //判断是左边还是右边座位
        if (position == 0) {
            pos = @"01";
        }
        else{
            pos = @"02";
        }
        
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
//            NSLog(@"准备完成状态==%@",state);
            
            if ([state isEqualToString:@"1"]) {
                
                isPowerOff = NO;
                //注册命令
                [self writeData:[NSString stringWithFormat:@"%@%@01%@",msgHead,msgLength,msgCRC16]];
                //数据返回
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                    
//                    NSLog(@"注册==%@",[array componentsJoinedByString:@","]);
                    
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        [self maxConnectState:NO];
                        return ;
                    }
                    else{
                        [self maxConnectState:YES];
                    }
                    
            
                    NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
                    
                    for (int i=0; i<temp_arr.count; i++) {
                        //将sofadata中的某一个取出来
                        NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc]initWithDictionary:[temp_arr objectAtIndex:i]];
                        
                        if ([[self responseData:array] intValue] == 0) {
                            //                                 NSLog(@"成功");
                            if ([[array objectAtIndex:(array.count-6)] intValue] == 1 || [[array objectAtIndex:(array.count-5)] intValue] == 1 || [[array objectAtIndex:(array.count-4)] intValue] == 1) {
                                
                                 [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isLock"];
                            }
                            else{
                                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
                                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
                            }
                            
                        }
                        else if ([[self responseData:array] intValue] == 1 || [[array objectAtIndex:(array.count-6)] intValue] == 1 || [[array objectAtIndex:(array.count-5)] intValue] == 1 || [[array objectAtIndex:(array.count-4)] intValue] == 1){
                            //NSLog(@"锁定");
                            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isLock"];
                        }
                        else{
                            //NSLog(@"故障");
                            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
                        }
                        
                        [temp_arr removeObjectAtIndex:i];
                        [temp_arr insertObject:temp_dic atIndex:i];
                    }
                    
                    [currentDic setObject:temp_arr forKey:@"sofadata"];
                    //                         NSLog(@"currentDic==%@",currentDic);
                    
                    [sofaArr removeObjectAtIndex:currentPosIndex];
                    [sofaArr insertObject:currentDic atIndex:currentPosIndex];
                    
                    [layoutsofa layoutRefreshDataToBox:sofaArr];//刷新界面
                    
                };
            }
            else{
                isPowerOff = YES;
                
                //下方三个不可以点击
                [btn_l setEnabled:YES];
                [btn_r setEnabled:YES];
                [btn_save setEnabled:YES];
                
                //图标置为显示故障图标
                [self connectOrDis:1];
            }
            
        };
        
        
    }];
}


-(void)connectOrDis:(int)err{
    
    NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];

    //图标置为显示故障图标
    for (int i=0; i<temp_arr.count; i++) {
        //将sofadata中的某一个取出来
        NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc]initWithDictionary:[temp_arr objectAtIndex:i]];
        // NSLog(@"故障");
        [temp_dic setObject:[NSNumber numberWithInt:err] forKey:@"isError"];
//        [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isCurrent"];
        [temp_arr removeObjectAtIndex:i];
        [temp_arr insertObject:temp_dic atIndex:i];
    }
    
    [currentDic setObject:temp_arr forKey:@"sofadata"];
    //                         NSLog(@"currentDic==%@",currentDic);
    
    [sofaArr removeObjectAtIndex:currentPosIndex];
    [sofaArr insertObject:currentDic atIndex:currentPosIndex];
    
//    NSLog(@"sofaArr==%@",sofaArr);
    [layoutsofa layoutRefreshDataToBox:sofaArr];//刷新界面
}


//刷新界面数据
-(void)RefreshLayoutData:(NSArray *)data position:(int)position{
    //数据重置5
    sofaArr = [[NSMutableArray alloc] initWithArray:data];
    //选中当前沙发
    currentDic = [[NSMutableDictionary alloc] initWithDictionary:[sofaArr objectAtIndex:currentPosIndex]];
    
//    NSLog(@"sofaArr==%@",sofaArr);
    
//  [layoutsofa layoutRefreshDataToBox:sofaArr];//刷新界面
    
}

//底部测试界面
-(UIView *)testOpView{
    
    UIView *testOpView =[[UIView alloc] initWithFrame:CGRectMake(0,  15+layoutsofa.frame.origin.y+layoutsofa.frame.size.height+(ipad ? 75 :0), sWIDTH, sHEIGHT-(layoutsofa.frame.origin.y+layoutsofa.frame.size.height))];
    
    //画线2
    UILabel *line2 = [UILabel commonLabelWithFrame:CGRectMake(15, 0, sWIDTH - 15*2, 0.5) text:@"" color:[UIColor clearColor] font:[UIFont systemFontOfSize:0.0] bgColor:kUIColorFromRGB(0xd2d2d2) textAlignment:NSTextAlignmentCenter];
    [testOpView addSubview:line2];
    
    //左侧向上按钮
    btn_l = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_l.tag = 10;
    if (ipad) {
        btn_l.frame = CGRectMake(sWIDTH/2 - 200 - 40, (96-70)/2, 200, 70);
    }
    else{
       btn_l.frame = CGRectMake(sWIDTH/2 - 110 - 40, (96-56)/2, 110, 56);
    }
    
    [btn_l setImage:[UIImage imageNamed:@"bt_text_up"] forState:UIControlStateNormal];
    [btn_l addTarget:self action:@selector(opTestStart:) forControlEvents:UIControlEventTouchDown];
//    [btn_l addTarget:self action:@selector(opTestStart:) forControlEvents:UIControlEventPrimaryActionTriggered];
    [btn_l addTarget:self action:@selector(opTestEnd:) forControlEvents:UIControlEventTouchUpInside];
//    [btn_l addTarget:self action:@selector(opTestEnd:) forControlEvents:UIControlEventTouchDragOutside];
    [btn_l addTarget:self action:@selector(opTestEnd:) forControlEvents: UIControlEventTouchDragExit];
    [testOpView addSubview:btn_l];

    
     //右侧向下按钮
    btn_r = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_r.tag = 11;
    if (ipad) {
        btn_r.frame = CGRectMake(sWIDTH/2 + 40, (96-70)/2, 200, 70);
    }
    else{
        btn_r.frame = CGRectMake(sWIDTH/2 + 40, (96-56)/2, 110, 56);
    }
    
    [btn_r setImage:[UIImage imageNamed:@"bt_text_down"] forState:UIControlStateNormal];
    [btn_r addTarget:self action:@selector(opTestStart:) forControlEvents:UIControlEventTouchDown];
    [btn_r addTarget:self action:@selector(opTestEnd:) forControlEvents:UIControlEventTouchUpInside];
//    [btn_r addTarget:self action:@selector(opTestEnd:) forControlEvents:UIControlEventTouchDragOutside];
    [btn_r addTarget:self action:@selector(opTestEnd:) forControlEvents: UIControlEventTouchDragExit];
    [testOpView addSubview:btn_r];
   
    //画线3
    UILabel *line3 = [UILabel commonLabelWithFrame:CGRectMake(15, line2.frame.origin.y+line2.frame.size.height+96, sWIDTH - 15*2, 0.5) text:@"" color:[UIColor clearColor] font:[UIFont systemFontOfSize:0.0] bgColor:kUIColorFromRGB(0xd2d2d2) textAlignment:NSTextAlignmentCenter];
    [testOpView addSubview:line3];
    
    //保存
    btn_save = [UIButton buttonWithType:UIButtonTypeCustom];
    if (ipad) {
         btn_save.frame = CGRectMake((sWIDTH-200)/2, line3.frame.origin.y+line3.frame.size.height+ (iPhone5 ? 0 : 30), 200, 70);
    }
    else{
         btn_save.frame = CGRectMake((sWIDTH-160)/2, line3.frame.origin.y+line3.frame.size.height+ (iPhone5 ? 0 : 30), 160, 55);
    }
    [btn_save setImage:[UIImage imageNamed:@"bt_save"] forState:UIControlStateNormal];
//    [btn_save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchDown];
    [btn_save addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    btn_save.mm_acceptEventInterval = 0.5;
    [testOpView addSubview:btn_save];
    
    
    return testOpView;
    
}

-(void)buttonOK
{
    [btn_l setEnabled:YES];
    [btn_r setEnabled:YES];
    [btn_save setEnabled:YES];
}


//根据返回结果布局
-(void)reponseArr:(NSArray *)array{
    
    NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
    for (int i=0; i<temp_arr.count; i++) {
        //将sofadata中的某一个取出来
        NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc]initWithDictionary:[temp_arr objectAtIndex:i]];
        
        if ([[self responseData:array] intValue] == 0) {
            
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
            
            [currentDic setObject:[NSNumber numberWithInt:1] forKey:@"isTest"];
        }
        else if ([[self responseData:array] intValue] == 1){
            //                                 NSLog(@"锁定");
            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isLock"];
        }
        else{
            //                                 NSLog(@"故障");
            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
        }
        
        [temp_arr removeObjectAtIndex:i];
        [temp_arr insertObject:temp_dic atIndex:i];
    }
    
    [currentDic setObject:temp_arr forKey:@"sofadata"];
    //                                 NSLog(@"成功");
    
    [sofaArr removeObjectAtIndex:currentPosIndex];
    [sofaArr insertObject:currentDic atIndex:currentPosIndex];
    
    [layoutsofa layoutRefreshDataToBox:sofaArr];//刷新界面
}

//按下事件
-(void)opTestStart:(UIButton *)sender{
    
    if (isClick == NO) {
        [self updateLog:@"Please select one sofa"];
        return ;
    }
    
    if (isPowerOff) {
        return;
    }
    
    if (sender.tag==11) {
        [btn_l setEnabled:NO];
    }
    else{
        [btn_r setEnabled:NO];
    }

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(opTestStart_copy:) object:sender];
    [self performSelector:@selector(opTestStart_copy:) withObject:sender afterDelay:0.1];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(opTestEnd_copy:) object:sender];
  
}

-(void)opTestStart_copy:(UIButton *)sender{
    
    if (isClick == NO) {
        [self updateLog:@"Please select one sofa"];
        return ;
    }
    
    if (isPowerOff) {
        return;
    }
    //    [NSThread sleepForTimeInterval:0.3];//暂停300ms
    int num = [[[sofaArr objectAtIndex:currentPosIndex] objectForKey:@"num"] intValue];//沙发的个数
    
    if (sender.tag==11) {
        [btn_l setEnabled:NO];
        //后进0x12-左
        [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"12",[NSString stringWithFormat:@"%@010000",@"01"],msgCRC16]];
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
            
//            NSLog(@"数据返回：read==%@",array);
            
            if ([[array objectAtIndex:maxPer] intValue] > 4) {
                [self maxConnectState:NO];
                return ;
            }
            else{
                //                [self maxConnectState:YES];
            }
        
            if ([[self responseData:array] intValue] == 0) {
                
                if (num == 2) {
                    //后进0x12-右
                    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"12",[NSString stringWithFormat:@"%@010000",@"02"],msgCRC16]];
                    
                    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                        
                        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                            [self maxConnectState:NO];
                            return ;
                        }
                        else{
                            //                            [self maxConnectState:YES];
                        }
                        
//                        NSLog(@"数据返回：read==%@",array);
                        [self reponseArr:array];
                        
                    };
                }
                else{
                    [self reponseArr:array];
                }
            }
            else{
                [btn_l setEnabled:YES];
                [self reponseArr:array];
            }
            
        };
    }
    else{
        
        [btn_r setEnabled:NO];
        //前进0x11-左
        [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"11",[NSString stringWithFormat:@"%@010000",@"01"],msgCRC16]];
        
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
            //            NSLog(@"数据返回：read0x11==%@",array);
            if ([[array objectAtIndex:maxPer] intValue] > 4) {
                [self maxConnectState:NO];
                return ;
            }
            else{
                //                [self maxConnectState:YES];
            }
            
            if ([[self responseData:array] intValue] == 0) {
                if (num == 2) {
                    //前进0x11-右
                    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"11",[NSString stringWithFormat:@"%@010000",@"02"],msgCRC16]];
                    
                    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                        
//                        NSLog(@"数据返回：read0x==%@",array);
                        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                            [self maxConnectState:NO];
                            return ;
                        }
                        else{
                            //                            [self maxConnectState:YES];
                        }
                        
                        [self reponseArr:array];
                    };
                }
                else{
                    [self reponseArr:array];
                }
            }
            else{
                [btn_r setEnabled:YES];
                [self reponseArr:array];
            }
            
        };
    }

}


-(void)opTestEnd:(UIButton *)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(opTestStart_copy:) object:sender];
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(opTestEnd_copy:) object:sender];
    [self performSelector:@selector(opTestEnd_copy:) withObject:sender afterDelay:0.1];
}
//松开事件
-(void)opTestEnd_copy:(UIButton *)sender{
    
    if (isClick == NO) {
        [self updateLog:@"Please select one sofa"];
        return ;
    }
    
    if (isPowerOff) {
        return;
    }
    
    int num = [[[sofaArr objectAtIndex:currentPosIndex] objectForKey:@"num"] intValue];//沙发的个数
    //停止0x13-左
    [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"13",[NSString stringWithFormat:@"%@010000",@"01"],msgCRC16]];
    
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
//        NSLog(@"数据返回：read0x13==%@",array);
        if ([[array objectAtIndex:maxPer] intValue] > 4) {
            [self maxConnectState:NO];
            return ;
        }
        else{
            [self maxConnectState:YES];
        }

        if ([[self responseData:array] intValue] == 0) {
            
            if (num == 2) {
                //停止0x13-右
                [self writeData:[NSString stringWithFormat:@"%@%@10%@%@%@",msgHead,msgLength,@"13",[NSString stringWithFormat:@"%@010000",@"02"],msgCRC16]];
                
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                    
//                    NSLog(@"数据返回：==%@",array);
                    
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        [self maxConnectState:NO];
                        return ;
                    }
                    else{
                        [self maxConnectState:YES];
                    }
                    
                    [self reponseArr:array];
                };
            }
            else{
                [self reponseArr:array];
            }
        }
        else{
            [self reponseArr:array];
        }
        
        [btn_l setEnabled:YES];
        [btn_r setEnabled:YES];
    };
    
}


-(void)initData{
    
    for (int i = 0; i<sofaArr.count; i++) {
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:[sofaArr objectAtIndex:i]];
        
        NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[temp objectForKey:@"sofadata"]];
        
        for (int j =0; j<temp_arr.count; j++) {
            //沙发位的序号
            NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc] initWithDictionary:[temp_arr objectAtIndex:j]];
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
            
            [temp_arr removeObjectAtIndex:j];
            [temp_arr insertObject:temp_dic atIndex:j];
        }
        
        [temp setObject:temp_arr forKey:@"sofadata"];
        //        NSLog(@"currentDic==%@",currentDic);
        
        [sofaArr removeObjectAtIndex:i];//沙发的序号
        [sofaArr insertObject:temp atIndex:i];
    }
    
    //    NSLog(@"sofa_arr==%@",sofa_arr);
    
}


//保存
-(void)save{
    
    BOOL testState = YES;
    for (int i = 0; i<sofaArr.count; i++) {
        int test = [[[sofaArr objectAtIndex:i] objectForKey:@"isTest"] intValue];
        int error = [[[[[sofaArr objectAtIndex:i] objectForKey:@"sofadata"] objectAtIndex:0]objectForKey:@"isError"] intValue];
        int lock = [[[[[sofaArr objectAtIndex:i] objectForKey:@"sofadata"] objectAtIndex:0]objectForKey:@"isLock"] intValue];
        if (test == 0 && error == 0 &&  lock == 0) {
            testState = NO;
            break;
        }
    }
    
    if (testState) {
        
       btn_save.enabled = NO;
       [self initData];//初始化,将isError、isLock置为0

        //保存到本地数据
       [[NSUserDefaults standardUserDefaults] setObject:sofaArr forKey:[NSString stringWithFormat:@"%@_%@", SMARTMULIN,@"sofa"]];
        
        //将沙发位置保存到控制盒中,控制盒最多保存5个场景。
       
        //获取控制盒当前保存了几个场景
        [self readSettingData];
        
        
//        OPAPViewController *op = [OPAPViewController new];
//        op.sofaArr = sofaArr;
//        [self.navigationController pushViewController:op animated:YES];
        
    }
    else{
        btn_save.enabled = YES;
        [self updateLog:@"Please check if any untested sofa existed"];
    }
}


//读取配置数据
-(void)readSettingData{
    //判断是否断开蓝牙
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
        //提示打开蓝牙
        [self updateLog:@"Please open Bluetooth"];
        btn_save.enabled = YES;
        return;
    }
    //开始读取保存信息
    [[VWProgressHUD shareInstance] showLoadingWithTip:@"Start saving"];
    
    indexNum = 0;
    scanTemp =[NSMutableArray new];
    saveBLEArr = [NSMutableArray new];//保存的蓝牙信息
    isUnexpected = NO;
    [self scan];//扫描设备位置信息

}


//扫描布局
-(void)scan{
    
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
        [[VWProgressHUD shareInstance] dismiss];
        [self updateLog:@"Please open Bluetooth"];
        btn_save.enabled = YES;
        return;
    }
    
    if (isUnexpected) {
        return ;
    }
    //根据当前的设备进行扫描,有几个设备扫描几次
    if (indexNum < sofaArr.count) {
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[[sofaArr objectAtIndex:indexNum] objectForKey:@"serviceUUIDs"] identifier:[[sofaArr objectAtIndex:indexNum] objectForKey:@"identifier"]];
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
            //连接成功之后
            if ([state isEqualToString:@"1"]) {
                //获取沙发位置信息
                [self writeData:[NSString stringWithFormat:@"%@%@06%@",msgHead,msgLength,msgCRC16]];
                
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//                    NSLog(@"位置信息：read=%@",array);
                    
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        [self maxConnectState:NO];
                        btn_save.enabled = YES;
                        return ;
                    }
                    else{
                        [self maxConnectState:YES];
                    }
                    //如果沙发状态为正常或者锁定
                     if ([[self responseData:array] intValue] == 0 || [[self responseData:array] intValue] == 1 ) {
                         //用来组装信息的数组
                         NSMutableArray *temp_arr = [NSMutableArray new];
                         int  position_d = (int)(strtoul([[array objectAtIndex:5] UTF8String],0,16));
                         if (position_d > 0) {
                    
                             //转换成二进制,最多保存5个场景
                             NSString *screen1=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
                             NSMutableString *currentScreen1 = [[NSMutableString alloc] initWithString:[screen1 substringFromIndex:3]];
                            // [temp_arr addObject:currentScreen1];
                           
                             //位置及方向信息
                             NSArray *screenArr =[array subarrayWithRange:NSMakeRange(6, 10)];
//                             NSLog(@"screenArr==%@",screenArr);
                             for (int i=0; i<5; i++) {
                                 
//                                 [temp_arr addObject:[screenArr subarrayWithRange:NSMakeRange(2*i,2)]];
                                 //获取每一个的位置信息
                                 NSArray *positionArr = [screenArr subarrayWithRange:NSMakeRange(2*i,2)];
//                                 NSLog(@"sigleArr==%@",positionArr);
                                 //每一个位置信息的数组,第一个字节代表序号
                                 int  position = (int)(strtoul([[positionArr objectAtIndex:0] UTF8String],0,16));
                                 //每一个状态位对应一个字节
                                 NSString *currentStr = [[currentScreen1 substringFromIndex:4-i] substringToIndex:1];

                                 if (position > 0 && [currentStr intValue] == 1) {
                                     
                                     [temp_arr addObject:positionArr];
                                 }
                                 else{
                                     [currentScreen1 replaceCharactersInRange:NSMakeRange(4-i, 1) withString:@"0"];
                                     [temp_arr addObject:@[@"00",@"00"]];
                                 }
                             }
                             
                             [temp_arr insertObject:currentScreen1 atIndex:0];
                             [scanTemp addObject:temp_arr];
                         }
                         else{
                             [temp_arr addObject:@"00000"];//状态位信息
                             //保存的5个沙发信息
                             for (int j=0; j<5; j++) {
                                 [temp_arr addObject:@[@"00",@"00"]];
                             }
                             [scanTemp addObject:temp_arr];
                         }
                         
                        
                         //合格的蓝牙个数组装成数组
                         NSMutableDictionary *bleDic = [NSMutableDictionary new];
                         [bleDic setObject:[[sofaArr objectAtIndex:indexNum] objectForKey:@"serviceUUIDs"]  forKey:@"serviceUUIDs"];
                         [bleDic setObject:[[sofaArr objectAtIndex:indexNum] objectForKey:@"identifier"] forKey:@"identifier"];
                         
                         [saveBLEArr addObject:bleDic];
                         
                         ++indexNum;
                         [self scan];
                         
                     }
                     else if ([[self responseData:array] intValue] == 4){
                         
                         //忙碌
                         [NSThread sleepForTimeInterval:0.3];//暂停300ms
                         [self scan];
                         
                     }
                     else{
                         
                         ++indexNum;
                         [self scan];
                     }
                };
            }
            else{
                //超时
                ++indexNum;
                [self scan];
            }
        };
        
    }
    else{
        
//        NSLog(@"scanTemp==%@",scanTemp);
        indexNum = 0;
        NSString *screenNumber =@"";//获取当前需要存储的序号
             
        if (scanTemp.count == 0) {
            
            btn_save.enabled = YES;
            [[VWProgressHUD shareInstance] dismiss];
            
            //进入到操作界面
            OPAPViewController *op = [OPAPViewController new];
            op.sofaArr = sofaArr;
            [self.navigationController pushViewController:op animated:YES];
            
            return ;
        }
        
        //获取此次存储的位置信息
        currentScreen = [self allPosition:scanTemp];//将所有的位置信息相互或运算
//        NSLog(@"currentScreen==%@",currentScreen);
        //最多只有5幅场景
        BOOL isFlag = YES;
        for (int i = 0; i<currentScreen.length; i++) {
            //获取当前的字符
            NSString *currentStr = [[currentScreen substringFromIndex:4-i] substringToIndex:1];
            if ([currentStr isEqualToString:@"1"]) {
                
            }
            else{
                screenNumber = [NSString stringWithFormat:@"%02d",i+1];
                isFlag = NO;
                break;
            }
        }
        if (isFlag) {
            //如果全为1,则把最后一个冲掉
            screenNumber = @"05";
        }

//        [self updateLog:currentScreen];
        isUnexpected = NO;
//        NSLog(@"screenNumber==%@",screenNumber);
        [self settingSofa:screenNumber];//开始存储沙发
    }
    
}




//设置沙发
-(void)settingSofa:(NSString *)screenNumber{
    
    //判断是否断开蓝牙
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
        
        [[VWProgressHUD shareInstance] dismiss];
        //提示打开蓝牙
        [self updateLog:@"Please open Bluetooth"];
        btn_save.enabled = YES;
        return;
    }
    
    
    if (isUnexpected) {
        
        return ;
    }
    
    //轮询每一个有用的设备
    if (indexNum < saveBLEArr.count) {

        NSDictionary *bleDic = [saveBLEArr objectAtIndex:indexNum];
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
        
        //获取序号
        int index = 0;
        for (int i = 0; i<sofaArr.count; i++) {
            if ([[bleDic objectForKey:@"identifier"] isEqualToString:[[sofaArr objectAtIndex:i] objectForKey:@"identifier"]]) {
                index = i;
                break;
            }
        }
        
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
            //连接成功之后 保存坐标，方向信息
            if ([state isEqualToString:@"1"]) {
                //位置
                int x = [[[sofaArr objectAtIndex:index] objectForKey:@"x"] intValue];
                int y = [[[sofaArr objectAtIndex:index] objectForKey:@"y"] intValue];
                
                //方向,默认为1,朝向为下
                int direct = [[[sofaArr objectAtIndex:index] objectForKey:@"sofaDirect"] intValue];//方向
                NSString *directStr = @"";
                if (direct == 1) {
                    //向下
                    directStr = @"00";
                }
                else if (direct == 2){
                    //向左
                    directStr = @"01";
                }
                else if (direct == 3){
                    //向上
                    directStr = @"02";
                }
                else{
                    //向右
                    directStr = @"03";
                }

                /*
                //存储完毕之后，写入位置号
                NSMutableString *tempStr = nil;
                BOOL isFlag = YES;
                //最多只有5幅场景
                for (int i = 0; i<currentScreen.length; i++) {
                    //获取当前的字符
                    NSString *currentStr = [[currentScreen substringFromIndex:4-i] substringToIndex:1];
                    if ([currentStr isEqualToString:@"1"]) {
                        
                    }
                    else{
                        isFlag = NO;
                        tempStr = [[NSMutableString alloc] initWithString:currentScreen];
                        [tempStr replaceCharactersInRange:NSMakeRange(4-i, 1) withString:@"1"];
                        break;
                    }
                }
                if (isFlag) {
                    tempStr = [[NSMutableString alloc] initWithString:currentScreen];
                }
                */
                
                //将每组的该位置的状态置为1
                NSMutableArray *currentSaveArr =[[NSMutableArray alloc] initWithArray:[scanTemp objectAtIndex:indexNum]];
                NSMutableString *tempStr = [[NSMutableString alloc] initWithString: [currentSaveArr objectAtIndex:0] ];
                
                int del = [screenNumber intValue]-1;
//                NSLog(@"===%d",del);
                [tempStr replaceCharactersInRange:NSMakeRange(4-del, 1) withString:@"1"];
//                NSLog(@"当前存储的位状态===%@",tempStr);
                
                
                //合成当前位置信息
                NSArray *currentSavePosition = @[[NSString stringWithFormat:@"%02x",shu_box*y+x+1],[NSString stringWithFormat:@"%@",directStr]];
//                NSLog(@"currentSavePosition==%@",currentSavePosition);
                //将相应的序号替换成需要的序号
                [currentSaveArr removeObjectAtIndex:[screenNumber intValue]];
                [currentSaveArr insertObject:currentSavePosition atIndex:[screenNumber intValue]];
                
                [currentSaveArr removeObjectAtIndex:0];//删除第一个位置信息
                
//                NSLog(@"currentSaveArr==%@",currentSaveArr);
                //将最终的合成字符串
                NSMutableArray *addArr = [NSMutableArray new];
                for (int i = 0; i<currentSaveArr.count; i++) {
                    [addArr addObjectsFromArray:[currentSaveArr objectAtIndex:i]];
                }
//                NSLog(@"======%@",[addArr componentsJoinedByString:@""]);
                

                //设置保存命令
                [self writeData:[NSString stringWithFormat:@"%@%@05%@%@%@",msgHead,msgLength,[PZMessageUtils getHexByBinary:tempStr],[addArr componentsJoinedByString:@""],msgCRC16]];
                //数据返回
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//                    NSLog(@"保存位置信息结果==%@",array);
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        [self maxConnectState:NO];
                        return ;
                    }
                    else{
                        [self maxConnectState:YES];
                    }
                    
                    if ([[self responseData:array] intValue] == 2 || [[self responseData:array] intValue] == 3 || [[self responseData:array] intValue] == 6) {
//                        [self updateLog:@"故障"];
                        //通讯故障或者
                        ++indexNum;//横向开始，1，2，3....网格开始
                        [self settingSofa:screenNumber];//开始存储沙发
                        
                    }
                    else if ([[self responseData:array] intValue] == 4){
//                        [self updateLog:@"忙碌"];
                        //忙碌
                        [NSThread sleepForTimeInterval:0.3];//暂停300ms
                        [self settingSofa:screenNumber];//开始存储沙发
                        
                    }
                    else{
                        ++indexNum;//横向开始，1，2，3....网格开始
                        [self settingSofa:screenNumber];//开始存储沙发
//                        [self writeSuccess:screenNum];//写入成功
                    }
                };
            }
            else{
                //端开连接
//                [self updateLog:@"跳过"];
                ++indexNum;//横向开始，1，2，3....网格开始
                [self settingSofa:screenNumber];//开始存储沙发
            }
        };
    }
    else{
        
        [[VWProgressHUD shareInstance] dismiss];
//        btn_save.enabled = YES;
//        [self updateLog:@"结束"];
        //进入到操作界面
        OPAPViewController *op = [OPAPViewController new];
        op.sofaArr = sofaArr;
        [self.navigationController pushViewController:op animated:YES];
    }  
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
