//
//  AppDelegate.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
@synthesize manager;
@synthesize linkState;
@synthesize link;
@synthesize bleListArr;
@synthesize readyState;
@synthesize isPowerOff;

@synthesize globalPowerOff;
@synthesize globalBleDis;

@synthesize globalSofaArr;
@synthesize globalSofaDic;

+(AppDelegate*)shareGlobal
{
    return (AppDelegate*)[[UIApplication sharedApplication]delegate];
}



- (void)BluetoothConnection{
    
    WeakSelf;
    /**
     BLEModel 对象通过init方法创建 ,在init方法中就已经将蓝牙操作对象进行初始化,遵循代理,在控制器中无需遵循任何的蓝牙代理,引入蓝牙库
     */
    manager = [[BLEModel alloc]init];
    
    
    /**
     BLEModel 中的 BLELinkBlock 是将蓝牙当前状态进行回调,方便在项目中对蓝牙处于什么状态进行操作,检测蓝牙是打开还是关闭
     */
    manager.linkBlcok = ^(NSString *state){
        
//        NSLog(@"蓝牙开关状态222222%@",state);
        link = state;
        
    };
    
    //监控连接状态,连接成功还是失败
    manager.stateBlock = ^(int number,NSString *idFlag,int errCode){
//        NSLog(@"连接状态====%d",number);
        linkState = number;
//        [weakSelf BLEStateInt:number];

    };
    
    //获取蓝牙列表
    manager.listBlock = ^(NSMutableArray *array) {
//        NSLog(@"蓝牙列表==%@",array);
        bleListArr = array;
    };
    
    //获取是否准备状态
    manager.readyBlock = ^(NSString *state) {
//        NSLog(@"准备完成状态==%@",state);
        readyState = state;
    };
    
    /**
     BLEModel 中的BLEDataBlock 是外设返回数据到手机
     外设返回的数据一般为十六进制数据,在BLEModel 内部中已经将十六进制数据进行一次处理,把拿到的数据已字符串的类型添加到array中,所以可以直接使用对array进行操作,无需再做处理
     */
    manager.dataBlock = ^(NSMutableArray *array){
        
//        NSLog(@"ble返回数据：%@",array);
    };
    
    //无匹配蓝牙
    manager.noPeripheralBlock = ^(NSString *state) {
//        NSLog(@"无匹配蓝牙状态状态==%@",state);
    };
    //判断是否主动断开连接
    manager.autoPeripheralBlock = ^(NSString *state) {
        
        NSLog(@"主动断开连接成功");
    };
}

- (void)BLEStateInt:(int) state{
    
    NSString *stateStr=@"";
    switch (state) {
        case BLEState_Successful:
        {
            //连接成功
//            NSLog(@"已连接");
            stateStr=@"蓝牙连接成功";
            
        }
            break;
        case BLEState_Disconnect:
        {
            //外设断开连接
//            NSLog(@"未连接");
            stateStr=@"蓝牙断开连接";
        }
            break;
            
        default:
            break;
    }
    
    /*
    //提示弹出框
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:stateStr message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    
    [alert show];
     */
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    [self BluetoothConnection];//蓝牙初始化及配置
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    NSLog(@"应用程序将要进入非活动状态，即将进入后台");
    
    //当电话来临时。触发事件
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UnexpectedInterruptionNotice" object:nil];
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
