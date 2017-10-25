//
//  BLEModel.h
//  BLEDemo
//
//  Created by Longma on 17/5/11.
//  Copyright © 2017年 ZhangK. All rights reserved.
//

#import <Foundation/Foundation.h>
//BLIE4.0 蓝牙库
#import <CoreBluetooth/CoreBluetooth.h>
#import "PZMessageUtils.h"

/**
 
 蓝牙链接状态

 @param state 状态
 */
typedef void (^BLELinkBlock)(NSString *state);

/**
 蓝牙返回数据

 @param array 返回数据
 */
typedef void (^BLEDataBlock)(NSMutableArray *array);

/**
 蓝牙列表返回数据
 
 @param array 返回数据
 */
typedef void (^BLEListBlock)(NSMutableArray *array);



/**
 返回蓝牙准备状态
 */
typedef void (^BLEReadySuccessBlock)(NSString *state);


/**
 返回查找无此设备返回
 */
typedef void (^FindNOPeripheralBlock)(NSString *state);


typedef enum BLEState_NOW{
    
    BLEState_Successful = 0,//连接成功
    BLEState_Disconnect = 1, // 失败
    BLEState_Normal,         // 未知
    
}BLEState_NOW;


/**
 蓝牙连接成功 或者断开

 */
typedef void(^BLEStateBlcok)(int number,NSString *idFlag,int errCode);


/**
 主动断开连接状态判断
 */
typedef void (^AutoDisconnectPeripheralBlock)(NSString *state);

@interface BLEModel : NSObject

@property (nonatomic,copy) NSString *connectState;//蓝牙连接状态
@property (nonatomic,copy) BLELinkBlock linkBlcok;
@property (nonatomic,copy) BLEDataBlock dataBlock;
@property (nonatomic,copy) BLEStateBlcok stateBlock;
@property (nonatomic,copy) BLEListBlock listBlock;
@property (nonatomic,copy) BLEReadySuccessBlock readyBlock;
@property (nonatomic,copy) FindNOPeripheralBlock noPeripheralBlock;
@property (nonatomic,copy) AutoDisconnectPeripheralBlock autoPeripheralBlock;
/**
 *  开始扫描
 */
-(void)startScan;


-(void)scanMgr;

/**
 主动断开链接
 */
-(void)cancelPeripheralConnection;

/**
 发送命令
 */
- (void)sendData:(NSData *)data;


//点击连接蓝牙设备
//-(void)connectBlePeripheral:(CBPeripheral *)peripheral identifier:(NSString *)identifier;

-(void)connectBlePeripheral:(NSString *)serviceUUIDs identifier:(NSString *)identifier;

//点击连接蓝牙设备
//-(void)connectBlePeripheral:(CBPeripheral *)peripheral;

-(void)disAllBle;
@end
