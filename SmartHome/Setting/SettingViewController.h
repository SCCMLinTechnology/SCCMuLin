//
//  SettingViewController.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/6/29.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "BaseViewController.h"
#import "LayoutSofaViewController.h"

#import "DrawImageViewController.h"

#import "OPAPViewController.h"

@interface SettingViewController : BaseViewController<UIAlertViewDelegate>{
    

}

@property(nonatomic,assign)BOOL isNeedDel;//是否需要显示删除按钮

@end


/*
 //操作测试按钮
 UIButton *opBtn= [UIButton new];
 [opBtn setBackgroundImage:[UIImage imageNamed:@"Download-button-base"] forState:UIControlStateNormal];
 [opBtn setTitle:@"CUSTOM SCENE" forState:UIControlStateNormal];
 [opBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 opBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
 [opBtn addTarget:self action:@selector(openter) forControlEvents:UIControlEventTouchUpInside];
 [btnView addSubview:opBtn];
 [opBtn mas_makeConstraints:^(MASConstraintMaker *make) {
 
 make.right.mas_equalTo(btnView.mas_centerX).offset(-30);
 make.centerY.mas_equalTo(btnView.mas_centerY);
 make.size.mas_equalTo(CGSizeMake(115, 40));
 }];
 
 
 UIButton *opBtn1= [UIButton new];
 [opBtn1 setBackgroundImage:[UIImage imageNamed:@"Download-button-base"] forState:UIControlStateNormal];
 [opBtn1 setTitle:@"DELETE All" forState:UIControlStateNormal];
 [opBtn1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
 opBtn1.titleLabel.font = [UIFont systemFontOfSize:13.0];
 [opBtn1 addTarget:self action:@selector(opdelall) forControlEvents:UIControlEventTouchUpInside];
 [btnView addSubview:opBtn1];
 [opBtn1 mas_makeConstraints:^(MASConstraintMaker *make) {
 make.left.mas_equalTo(btnView.mas_centerX).offset(30);
 make.centerY.mas_equalTo(btnView.mas_centerY);
 make.size.mas_equalTo(CGSizeMake(115, 40));
 }];
 */


/*
 //扫描布局
 -(void)scan_temp{
 
 if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
 
 }
 else{
 [[VWProgressHUD shareInstance] dismiss];
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
 if ([[self responseData:array] intValue] == 0) {
 int  position_d = (int)(strtoul([[array objectAtIndex:5+addLength] UTF8String],0,16));
 
 if (position_d > 0) {
 //转换成二进制
 NSString *screen1=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5+addLength] uppercaseString]];
 NSString *currentScreen1 = [screen1 substringFromIndex:3] ;
 [scanTemp addObject:currentScreen1];
 
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
 
 NSLog(@"scanTemp==%@",scanTemp);
 if (scanTemp.count > 0) {
 //获取场景位置信息
 currentScreen = [self allPosition:scanTemp];
 NSLog(@"currentScreen==%@",currentScreen);
 [self startScanScreen];
 }
 else{
 
 [[VWProgressHUD shareInstance] dismiss];
 NSLog(@"无法获取场景信息");
 [self updateLog:@"无场景信息"];
 }
 
 }
 
 }
 */


/*
 //连接
 NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:indexNum];
 //1.连接蓝牙
 [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
 
 //2.判断状态
 [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
 //连接成功之后
 if ([state isEqualToString:@"1"]) {
 
 //获取保存坐标，方向信息
 //发06指令,用来获取当前哪些位置已经存储过,只从当前链接的蓝牙设备中获取
 [self writeData:[NSString stringWithFormat:@"%@%@06%@%@",msgHead,msgLength,screenNum,msgCRC16]];
 [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
 NSLog(@"数据返回：read%@",array);
 if ([[self responseData:array] intValue] == 2 || [[self responseData:array] intValue] == 6) {
 //通讯故障 | 布局指令写入错误
 ++indexNum;
 [self screenData:screenNum];//屏幕显示
 }
 else{
 //组合数据
 int  position_d = (int)(strtoul([[array objectAtIndex:5+addLength] UTF8String],0,16));
 NSLog(@"position_d==%d",position_d);
 if (position_d == 0) {
 ++indexNum;
 [self screenData:screenNum];//屏幕显示
 
 return ;
 }
 
 //获取当前沙发位置信息
 NSMutableDictionary *sofaDic = [[NSMutableDictionary alloc] initWithDictionary:[self getBleArrByDic:bleDic num:indexNum]];
 
 int x = (position_d - 1)%shu_box;
 int y = (position_d - 1)/shu_box;
 
 [sofaDic setObject:[NSNumber numberWithInt:x] forKey:@"x"];
 [sofaDic setObject:[NSNumber numberWithInt:y] forKey:@"y"];
 
 
 NSString *directad = [array objectAtIndex:6+addLength];
 int directInt = 0;//方向值
 if ([directad isEqualToString:@"00"]) {
 directInt = 1;//向下
 }
 else if ([directad isEqualToString:@"01"]){
 directInt = 3;//向上
 }
 else if ([directad isEqualToString:@"10"]){
 directInt = 2;//向左
 }
 else if ([directad isEqualToString:@"11"]){
 directInt = 4;//向右
 }
 [sofaDic setObject:[NSNumber numberWithInt:directInt] forKey:@"sofaDirect"];//沙发方向,默认为1,面向上
 
 
 //每一个布局重新生成一次
 [sofasetArr addObject:sofaDic];
 
 //                        [sofasetArr removeObjectAtIndex:currentIndex];
 //                        [sofasetArr insertObject:sofaDic atIndex:currentIndex];
 
 //                        NSLog(@"sofasetArr==%@",sofasetArr);
 
 ++indexNum;
 [self screenData:screenNum];//屏幕显示
 }
 
 };
 
 }
 else{
 
 NSLog(@"cc==超时");
 ++indexNum;
 [self screenData:screenNum];//屏幕显示
 }
 };
 */


/*
 //8个字节的设备信息
 
 NSString *perInfo=@"";
 
 [self writeData:[NSString stringWithFormat:@"%@%@05%@%@%@%@",msgHead,msgLength,msgType,@"01",perInfo,msgCRC16]];
 [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
 
 NSLog(@"数据返回：read=02=%@",array);
 if ([[[array objectAtIndex:0] uppercaseString] isEqualToString:@"AA"] && [[[array objectAtIndex:1] uppercaseString] isEqualToString:@"AA"] && [[[array objectAtIndex:4] uppercaseString] isEqualToString:@"04"]) {
 
 
 
 }
 };
 */


/*
 //连接
 NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:p];
 //1.连接蓝牙
 [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
 
 //2.判断状态
 [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
 //连接成功之后
 if ([state isEqualToString:@"1"]) {
 
 [self writeData:[NSString stringWithFormat:@"%@%@05%@%@%@",msgHead,msgLength,[orderArr objectAtIndex:p],@"0000",msgCRC16]];
 [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
 
 //        NSLog(@"数据最终返回=%@",array);
 if ([[self responseData:array] intValue] == 0) {
 [self updateLog:@"删除成功"];
 [orderArr removeObjectAtIndex:p];
 [orderArr insertObject:@"" atIndex:p];
 //将数据保存
 [sofaDataArr removeObjectAtIndex:p];
 [sofaDataArr insertObject:@"" atIndex:p];
 
 //将图片保存
 [sofaImageArr removeObjectAtIndex:p];
 [sofaImageArr insertObject:@"" atIndex:p];
 
 [collection reloadData];
 }
 };
 
 }
 };
 
 */
