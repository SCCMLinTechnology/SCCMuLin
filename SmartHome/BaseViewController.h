//
//  BaseViewController.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Config.h"
#import "Masonry.h"

#import "BLEModel.h"
#import "BLEIToll.h"

#import "AppDelegate.h"

#import "CRC.h"

#import "VWProgressHUD.h"


@interface BaseViewController : UIViewController{
    
    
}


-(void)updateLog:(NSString *)msg;

//写入数据
-(void)writeData:(NSString *)data;

//网格布局
-(UIView *)layoutbox_bg:(UIView *)selffView;
//根据返回状态判断
-(NSString *)responseData:(NSArray *)array;

//根据蓝牙获取设备分配沙发
-(NSArray *)getSofaArrByBLEArr:(NSArray *)listArr;

//所有设备的位置情况
-(NSString *)allPosition:(NSArray *)storePositionArr;

-(NSDictionary *)getBleArrByDic:(NSDictionary *)dataDic num:(int)num;

@end
