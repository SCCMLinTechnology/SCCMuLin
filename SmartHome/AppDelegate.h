//
//  AppDelegate.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BLEModel.h"
#import "BLEIToll.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>{


}



@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) BLEModel *manager;//主控制器
@property (nonatomic,assign) int linkState;//蓝牙连接状态
@property (nonatomic,retain) NSString *link;//蓝牙是否打开
@property (nonatomic,retain) NSArray *bleListArr;//扫描蓝牙列表
@property(nonatomic,retain) NSString *readyState;
@property(nonatomic,assign) BOOL isPowerOff;//是否电源断电

@property(nonatomic,assign) BOOL globalPowerOff;//是否电源断电
@property(nonatomic,assign) BOOL globalBleDis;//是否蓝牙断开

@property(nonatomic,retain) NSMutableArray *globalSofaArr;
@property(nonatomic,retain) NSDictionary *globalSofaDic;

+(AppDelegate*)shareGlobal;//设置全局参数

@end

