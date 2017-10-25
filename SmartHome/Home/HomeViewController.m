//
//  HomeViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController (){
    int peripheralNum;
    NSMutableArray *cyclePerArray;
    BOOL isFirstScan;
    
    int indexNum;
    NSMutableArray *scanTemp;
    
    BOOL isFirstScanBle;
}


@end

@implementation HomeViewController


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden: YES];
    //增加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnexpectedInterruptionNotice) name:@"UnexpectedInterruptionNotice" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden: NO];
    //删除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UnexpectedInterruptionNotice" object:nil];
}



//布局
-(void)layoutView{
    
    //背景
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"home_bg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(0);
    }];
    
    //公司logo，软件名称
    UIImageView *logoImg = [UIImageView new];
    logoImg.image = [UIImage imageNamed:@"logo"];
    [self.view addSubview:logoImg];
    [logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
//            make.top.mas_equalTo(200);
             make.top.mas_equalTo(100);
        }
        else{
            make.top.mas_equalTo(100+20);
        }
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(176, 59));
    }];
    
    //动画⭕️
    componyImg = [UIImageView new];
    componyImg.image = [UIImage imageNamed:@"circle_out"];
    [self.view addSubview:componyImg];
    [componyImg mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
//            make.top.mas_equalTo(logoImg.mas_bottom).offset(250);
            make.top.mas_equalTo(logoImg.mas_bottom).offset(150);
        }
        else{
            make.top.mas_equalTo(logoImg.mas_bottom).offset(150);
        }
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
    
      
    //按钮
    apBtn = [UIButton new];
    [apBtn setBackgroundImage:[UIImage imageNamed:@"circle_in"] forState:UIControlStateNormal];
    //[apBtn setBackgroundColor:kUIColorFromRGB(0x334455)];
    [apBtn addTarget:self action:@selector(connectAp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:apBtn];
    [apBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if (ipad) {
//            make.top.mas_equalTo(logoImg.mas_bottom).offset(250);
            make.top.mas_equalTo(logoImg.mas_bottom).offset(150);
        }
        else{
            make.top.mas_equalTo(logoImg.mas_bottom).offset(150);
        }
        
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(113, 113));
    }];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.title = @"首页";

    isFirstScanBle = YES;
    [self layoutView];
    
   
    /*
    //删除app重新安装可以获取，重启此值不变
    NSString *uuid = [[UIDevice currentDevice].identifierForVendor UUIDString];
    NSLog(@"uuid==%@",uuid);
    */
    
    //判断蓝牙是打开/关闭
    [[AppDelegate shareGlobal] manager].linkBlcok = ^(NSString *state){
        
//        NSLog(@"state==%@",state);
        [AppDelegate shareGlobal].link = state;
        if ([state isEqualToString:kCONNECTED_POWERD_ON]) {
            
//            [apBtn setEnabled:YES];
            isFirstScanBle = YES;
            [[[AppDelegate shareGlobal] manager] scanMgr];
        }
        else{
            
//          [self updateLog:@"请打开蓝牙"];
//            [apBtn setEnabled:NO];
        }
    };
    
    
    [[AppDelegate shareGlobal] manager].listBlock = ^(NSMutableArray *array) {
        NSLog(@"蓝牙列表入口只有这边一个==%@",array);
        if (isFirstScanBle) {
            [AppDelegate shareGlobal].bleListArr = array;
            isFirstScanBle = NO;
        }
        
    };
    
    
    //超时断网显示
    [[AppDelegate shareGlobal] manager].stateBlock = ^(int number,NSString *idFlag,int errCode) {
        NSLog(@"状态==%d==err==%d",number,errCode);
        if (errCode != 0) {//断电的情况å
//            [apBtn setEnabled:YES];
//            [componyImg.layer removeAllAnimations];
   
//            [[VWProgressHUD shareInstance] dismiss];
            
            ++indexNum;
            [self scan];
        }
    };

    
}


-(void)connectAp{

     if ([[AppDelegate shareGlobal].link  isEqualToString: kCONNECTED_POWERD_ON]) {
         if ([AppDelegate shareGlobal].linkState == 0) {
             NSArray *temp_sofa = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@", SMARTMULIN,@"sofa"]];
//             NSLog(@"temp_sofa==%@",temp_sofa);
             if (temp_sofa) {
                 if ([[AppDelegate shareGlobal].bleListArr count] > 0) {
                     //直接进入操作界面
                     OPAPViewController *op = [OPAPViewController new];
                     op.sofaArr = temp_sofa;
                     [self.navigationController pushViewController:op animated:YES];
                 }
                 else{
                     [self updateLog:@"No sofas searched"];
                 }
                 
             }
             else{
                 
//                 NSLog(@"本地无缓存");
                 /*
                 if ([[AppDelegate shareGlobal].bleListArr count] > 0) {
                     //进入沙发布局界面
                     LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
                     [self.navigationController pushViewController:vc animated:YES];
                 }
                 else{
//                     [self updateLog:@"No sofas searched"];
                     //将连接按钮置为不可点击
                     [apBtn setEnabled:NO];
                     angle = 0.0;
                     [self startAnimation];//开始动画
                     
                     [[[AppDelegate shareGlobal] manager] scanMgr];
                     [self performSelector:@selector(searchMgr) withObject:nil afterDelay:2.0];
                 }
                  */
                 //将connect按钮置为不可点击
                 [apBtn setEnabled:NO];
                 angle = 0.0;
                 [self startAnimation];//开始动画
                 
                 isFirstScanBle = YES;
                 indexNum = 0;
                 //扫描蓝牙设备
                 [[[AppDelegate shareGlobal] manager] startScan];//scanMgr
                 //1.5s显示搜索结果
                 [self performSelector:@selector(searchMgr) withObject:nil afterDelay:1.5];
                 
             }
         }
         else{
             [self updateLog:@"Bluetooth disconnected"];
         }
     }
     else{
         //[self updateLog:@"Please check if Bluetooth was on"];
         UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Turn On Bluetooth to Allow \"MuLin\" to Connect to Accessories" message:nil delegate:self cancelButtonTitle:@"Settings" otherButtonTitles: @"OK", nil];
         alert.tag = 10;
         [alert show];
     }
}


//意外中断通知
-(void)UnexpectedInterruptionNotice{
    NSLog(@"意外中断");
    
    [apBtn setEnabled:YES];
    [componyImg.layer removeAllAnimations];
    indexNum = 100;
    
}

-(void)startAnimation
{
    
    CGAffineTransform endAngle = CGAffineTransformMakeRotation(angle * (M_PI /180.0f));
    
    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        
        componyImg.transform = endAngle;
        
        
    } completion:^(BOOL finished) {
        if (finished) {//必须写上，@selector(endAnimation)中的方法才有用
            angle += 15;
            [self startAnimation];
        }
        
    }];
}

//搜索设备
-(void)searchMgr{
    
   
//    NSLog(@"===%@",[AppDelegate shareGlobal].bleListArr);
    if ([[AppDelegate shareGlobal].bleListArr count] > 0) {
        /*
        //进入沙发布局界面
        LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
         */
        if (indexNum == 100) {
            return;
        }
        scanTemp =[NSMutableArray new];
        indexNum = 0;
        [self scan];//扫描布局
    }
    else{
        
        //停止扫描
        [apBtn setEnabled:YES];
        [componyImg.layer removeAllAnimations];
        
        [self updateLog:@"No sofas searched"];
    }
}

//扫描布局
-(void)scan{
    
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
        //停止扫描
        [apBtn setEnabled:YES];
        [componyImg.layer removeAllAnimations];
        
        [self updateLog:@"Please open Bluetooth"];
        return;
    }
    
    
    if (indexNum < [AppDelegate shareGlobal].bleListArr.count) {
        
        NSLog(@"开始扫描布局");
        NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:indexNum];
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
            
            if (indexNum >= [AppDelegate shareGlobal].bleListArr.count) {
                return ;
            }
            //连接成功之后
            if ([state isEqualToString:@"1"]) {
                
                [self writeData:[NSString stringWithFormat:@"%@%@06%@",msgHead,msgLength,msgCRC16]];
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
//                    NSLog(@"位置信息：read=%@",array);
//                    [self updateLog:[array componentsJoinedByString:@","]];
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        
                        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
                        
                        [apBtn setEnabled:YES];
                        [componyImg.layer removeAllAnimations];
                        
                        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
                        
                        return ;
                    }

                    
                    if ([[self responseData:array] intValue] == 0 || [[self responseData:array] intValue] == 1) {
                        
                        //获取的存储位置信息
                        int  screen_d = (int)(strtoul([[array objectAtIndex:5] UTF8String],0,16));
                        
//                        NSLog(@"screen_d==%d",screen_d);
                        if (screen_d > 0) {
                            
//                            NSMutableArray *temp_arr = [NSMutableArray new];
                            //转换成二进制
                            NSString *screen=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
                            NSString *currentScreen = [screen substringFromIndex:3] ;
//                            currentScreen = @"01000";
//                            NSLog(@"currentScreen==%@",currentScreen);
                            
                            /*
                            [temp_arr addObject:currentScreen];
                        
                            //位置及方向信息
                            NSArray *screenArr =[array subarrayWithRange:NSMakeRange(6, 10)];
                            NSLog(@"screenArr==%@",screenArr);
                            for (int i=0; i<5; i++) {
                                [temp_arr addObject:[screenArr subarrayWithRange:NSMakeRange(2*i,2)]];
                            }

                            [scanTemp addObject:temp_arr];
                            */
                            
                            
                            NSArray *screenArr =[array subarrayWithRange:NSMakeRange(6, 10)];
//                            screenArr = @[@"00",@"00",@"07",@"00",@"07",@"00",@"00",@"00",@"00",@"00"];
//                            NSLog(@"screenArr==%@",screenArr);
                            for (int i=0; i<5; i++) {
                                NSArray *sigleArr = [screenArr subarrayWithRange:NSMakeRange(2*i,2)];
//                                NSLog(@"sigleArr==%@",sigleArr);
                                //组合数据
                                int  position_d = (int)(strtoul([[sigleArr objectAtIndex:0] UTF8String],0,16));
                                
                                NSString *currentStr = [[currentScreen substringFromIndex:4-i] substringToIndex:1];
//                                NSLog(@"position_d==%d",position_d);
                                if (position_d > 0 && [currentStr intValue] == 1) {
                                    [scanTemp addObject:currentScreen];
                                    break;
                                }
                            }
                            
                            ++indexNum;
                            [self scan];
                        }
                        else{
                            ++indexNum;
                            [self scan];
                        }
                        
                    }
                    else{
                        //返回不为0时。直接
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
        //获取列表
        [apBtn setEnabled:YES];
        [componyImg.layer removeAllAnimations];
        
       NSLog(@"scanTemp==%@",scanTemp);
        
        if (indexNum != 100) {
            [AppDelegate shareGlobal].globalBleDis = NO;
            [AppDelegate shareGlobal].globalPowerOff = NO;
            
            if (scanTemp.count > 0) {
                //进入场景界面
                SettingViewController *setting = [SettingViewController new];
                setting.isNeedDel = NO;
                [self.navigationController pushViewController:setting animated:YES];
            }
            else{
                //进入沙发布局界面
                LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }

        }
        
    }

    
}






/*

//扫描布局
-(void)scan_temp{

    NSLog(@"为什么到这里");
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
        //停止扫描
        [apBtn setEnabled:YES];
        [componyImg.layer removeAllAnimations];
        
        [self updateLog:@"Please open Bluetooth"];
        return;
    }
    
    if (indexNum < [AppDelegate shareGlobal].bleListArr.count) {
        //连接
        NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:indexNum];
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
        
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
            //连接成功之后
            if ([state isEqualToString:@"1"]) {
                
                [self writeData:[NSString stringWithFormat:@"%@%@06%@%@",msgHead,msgLength,@"00",msgCRC16]];
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                    NSLog(@"位置信息：read=%@",array);
                    
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        
                        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
                        
                        [apBtn setEnabled:YES];
                        [componyImg.layer removeAllAnimations];
                        
                        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
                        
                        return ;
                    }

                    
                    if ([[self responseData:array] intValue] == 0 || [[self responseData:array] intValue] == 1) {
                        
                        int  position = (int)(strtoul([[array objectAtIndex:5] UTF8String],0,16));
                        
                        if (position >0) {
                            
                            //转换成二进制
                            NSString *screen=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
                            NSString *currentScreen = [screen substringFromIndex:3] ;
                            NSLog(@"currentScreen==%@",currentScreen);
                            
                            //位置及方向信息
                            NSArray *screenArr =[array subarrayWithRange:NSMakeRange(6, 10)];
                            NSLog(@"screenArr==%@",screenArr);
                            for (int i=0; i<5; i++) {
                                NSArray *sigleArr = [screenArr subarrayWithRange:NSMakeRange(2*i,2)];
                                NSLog(@"sigleArr==%@",sigleArr);
                                //组合数据
                                int  position_d = (int)(strtoul([[sigleArr objectAtIndex:0] UTF8String],0,16));
                                NSLog(@"position_d==%d",position_d);
                                if (position_d > 0) {
                                    [scanTemp addObject:currentScreen];
                                    break;
                                }
                            }
                            
                            ++indexNum;
                            [self scan];
                        }
                        else{
                            ++indexNum;
                            [self scan];
                        }
                        
                    }
                    else{
                        //返回不为0时。直接
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
        //获取列表
        [apBtn setEnabled:YES];
        [componyImg.layer removeAllAnimations];
        
        NSLog(@"scanTemp==%@",scanTemp);
        
 
        if (scanTemp.count > 0) {
            //进入场景界面
            SettingViewController *setting = [SettingViewController new];
            setting.isNeedDel = NO;
            [self.navigationController pushViewController:setting animated:YES];
        }
        else{
            //进入沙发布局界面
            LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
            [self.navigationController pushViewController:vc animated:YES];
        }
 

    }
    */

    /*
    //连接
    NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:0];
    //1.连接蓝牙
    [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
    
    //2.判断状态
    [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
        //连接成功之后
        if ([state isEqualToString:@"1"]) {
            
            [self writeData:[NSString stringWithFormat:@"%@%@06%@%@",msgHead,msgLength,@"00",msgCRC16]];
            [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                
                NSLog(@"数据返回：read=%@",array);
                BOOL isEnter = NO;
                if ([[self responseData:array] intValue] == 0) {
                    //转换成二进制
                    NSString *screen=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
                    NSLog(@"sccc==%@",screen);
                    NSString *currentScreen = [screen substringFromIndex:3] ;
                    NSLog(@"currentScreen==%@",currentScreen);
                    
                    
                    for (int i = 0; i<currentScreen.length; i++) {
                        //获取当前的字符
                        NSString *currentStr = [[currentScreen substringFromIndex:4-i] substringToIndex:1];
                        if ([currentStr isEqualToString:@"1"]) {
                            isEnter = YES;
                            break;
                        }
                    }
                }
                
                //获取列表
                [apBtn setEnabled:YES];
                [componyImg.layer removeAllAnimations];
                
                if (isEnter) {
                    
                    SettingViewController *setting = [SettingViewController new];
                    [self.navigationController pushViewController:setting animated:YES];
                }
                else{
                    //进入沙发布局界面
                    LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            };

        }
        else{
            
            //获取列表
            [apBtn setEnabled:YES];
            [componyImg.layer removeAllAnimations];
            
            //进入沙发布局界面
            LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
     
    
  
}
     
     */

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//     NSLog(@"buttonIndex==%ld",(long)buttonIndex);
    if (alertView.tag == 10) {
        if (buttonIndex == 0) {
        
            NSString *version = [UIDevice currentDevice].systemVersion;
        
            NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
            if (version.doubleValue < 10.0) { // iOS系统版本 < 10
                url = [NSURL URLWithString:@"prefs:root=Bluetooth"];
            }

            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
