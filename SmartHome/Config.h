//
//  Config.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#ifndef Config_h
#define Config_h


//判断是否iphon4的尺寸
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

//判断是否iphon5的尺寸
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

//判断是否iphon6的尺寸
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)

//判断是否iphon6+的尺寸
#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

//判断是否ipadmini的尺寸
#define ipad ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(768, 1024), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(2048, 2732), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1536, 2048), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(768, 1024), [[UIScreen mainScreen] currentMode].size)) : NO)


#define heng_box 5     //排
#define shu_box 6      //列

//判断是pad还是iphone
#define spaceWidth  (ipad ? 150 :15)

#define boxWidth ((sWIDTH-spaceWidth*2)/shu_box) //盒子的尺寸

#define boxContentWidth (boxWidth-8) //盒子中的东西尺寸
#define boxContentHeight (boxWidth-15) //盒子中的东西尺寸

#define btnWidth 50


//使用rgb
#define kUIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define sWIDTH    ([UIScreen mainScreen].bounds.size.width)
#define sHEIGHT ([UIScreen mainScreen].bounds.size.height)

#define WeakSelf __weak typeof(self) weakSelf = self;

//蓝牙连接状态的定义
#define kCONNECTED_UNKNOWN_STATE @"未知蓝牙状态"
#define kCONNECTED_RESET         @"蓝牙重置"
#define kCONNECTED_UNSUPPORTED   @"该设备不支持蓝牙"
#define kCONNECTED_UNAUTHORIZED  @"未授权蓝牙权限"
#define kCONNECTED_POWERED_OFF   @"蓝牙已关闭"
#define kCONNECTED_POWERD_ON     @"蓝牙已打开"
#define kCONNECTED_ERROR         @"未知的蓝牙错误"

/*
#ifdef DEBUG
#define kDLOG(FORMAT, ...) fprintf(stderr,"%s: %d\t  %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String])

#define NSLog(...)  NSLog(@"\n%s \n %d行\n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else

#define kDLOG(...)
#define NSLog(...)
#endif
*/


/**
 设备名称
 */
#define PMServiceName @"MulinDev"

/**
 设备服务UUID
 */
#define PMServiceUUID @"FFF0"

/**
 主机写入UUID
 */
#define PMCharacteristicUUID_Write @"FFF3"


/**
 主机读取UUID
 */
#define PMCharacteristicUUID_Read @"FFF4"


//定义本地保存数据名称
#define SMARTMULIN @"SMARTMULIN"


/**
 命令拆分
 */
#define msgHead    @"5555" //帧头

#define msgLength  @"00" //桢长度

#define msgType    @"00"   //命令类型

#define msgCRC16   @"0000" //防错校验

//kCBAdvDataManufacturerData

//定义扫描次数
#define scanTimes 1

#define buttonTime 0.8

#define delayTime 100

#define repeatTime 10

#define addLength 0

#define maxPer 4
#define maxNumber 4

#endif /* Config_h */
