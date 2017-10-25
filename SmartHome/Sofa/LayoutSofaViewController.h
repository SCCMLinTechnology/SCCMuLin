//
//  LayoutSofaViewController.h
//  SmartHome
//
//  Created by 晁广喜 on 2017/6/29.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "BaseViewController.h"
#import "LayoutSofaView.h"
#import "UILabel+CGXLabel.h"
#import "OPAPViewController.h"

@interface LayoutSofaViewController : BaseViewController<RefreshLayoutDelegate>


@property(nonatomic,retain)NSArray *scanSofaArr;//接收扫描到的沙发信息数组

@end


/*
 //发06指令,用来获取当前哪些位置已经存储过,只从当前链接的蓝牙设备中获取
 [self writeData:[NSString stringWithFormat:@"%@%@06%@%@",msgHead,msgLength,@"00",msgCRC16]];
 [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
 NSLog(@"数据返回：read%@",array);
 if ([[self responseData:array] intValue] == 0) {
 //选择是的场景位置。01、02、03、04、05
 indexNum = 0;//每一个网格的序号从左向右,1,2,3,4,........
 
 //转换成二进制
 NSString *screen=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
 NSLog(@"sccc==%@",screen);
 currentScreen = [screen substringFromIndex:3];//获取最多5张图的标识
 NSLog(@"currentScreen==%@",currentScreen);
 
 NSString *screenNumber =@"";//获取当先存储的序号
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
 
 if (isFlag == NO) {
 [self settingSofa:screenNumber];//开始存储沙发
 }
 else{
 //已经满足5个的需求
 [[VWProgressHUD shareInstance] dismiss];
 [self updateLog:@"已经存满5张图"];
 
 //进入到操作界面
 OPAPViewController *op = [OPAPViewController new];
 op.sofaArr = sofaArr;
 [self.navigationController pushViewController:op animated:YES];
 }
 
 }
 };
 */


/*
 if ([[self responseData:array] intValue] == 0) {
 
 int  position_d = (int)(strtoul([[array objectAtIndex:5] UTF8String],0,16));
 
 if (position_d > 0) {
 
 //转换成二进制
 NSString *screen1=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
 NSString *currentScreen1 = [screen1 substringFromIndex:3];
 [temp_arr addObject:currentScreen1];
 
 //位置及方向信息
 NSArray *screenArr =[array subarrayWithRange:NSMakeRange(6, 10)];
 NSLog(@"screenArr==%@",screenArr);
 for (int i=0; i<5; i++) {
 
 [temp_arr addObject:[screenArr subarrayWithRange:NSMakeRange(2*i,2)]];
 }
 
 [scanTemp addObject:temp_arr];
 
 ++indexNum;
 [self scan];
 }
 else{
 
 [temp_arr addObject:@"00000"];
 
 for (int j=0; j<5; j++) {
 
 [temp_arr addObject:@[@"00",@"00"]];
 }
 [scanTemp addObject:temp_arr];
 
 ++indexNum;
 [self scan];
 }
 }
 else{
 //返回不为0时。直接
 
 [temp_arr addObject:@"00000"];
 
 for (int j=0; j<5; j++) {
 
 [temp_arr addObject:@[@"00",@"00"]];
 }
 [scanTemp addObject:temp_arr];
 
 ++indexNum;
 [self scan];
 }
 */

/*
 if (scanTemp.count == 0) {
 screenNumber = @"01";
 
 for (int i = 0; i<[AppDelegate shareGlobal].bleListArr.count; i++) {
 currentScreen = @"00000";
 
 NSMutableArray *temp_arr = [NSMutableArray new];
 [temp_arr addObject:currentScreen];
 
 for (int j=0; j<5; j++) {
 
 [temp_arr addObject:@[@"00",@"00"]];
 }
 [scanTemp addObject:temp_arr];
 }
 }
 else{
 currentScreen = [self allPosition:scanTemp];
 
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
 
 }
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
 int  position_d = (int)(strtoul([[array objectAtIndex:5] UTF8String],0,16));
 if (position_d > 0) {
 //转换成二进制
 NSString *screen1=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
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
 //从上个界面界面返回的结果,每一个设备中存储的位置结果，
 indexNum = 0;
 NSString *screenNumber =@"";//获取当先存储的序号
 if (scanTemp.count == 0) {
 currentScreen = @"00000";
 screenNumber = @"01";
 }
 else{
 currentScreen = [self allPosition:scanTemp];
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
 }
 
 [self settingSofa:screenNumber];//开始存储沙发
 }
 
 }
 
 */

/*
 -(void)writeSuccess:(NSString  *)screenNum{
 
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
 
 NSLog(@"tempStr==%@",tempStr);
 NSLog(@"hex===%@",[PZMessageUtils getHexByBinary:tempStr]);
 if (isFlag) {
 tempStr = [[NSMutableString alloc] initWithString:currentScreen];
 }
 //将当前位置置为1
 [self writeData:[NSString stringWithFormat:@"%@%@05%@%@%@%@",msgHead,msgLength,@"00",[PZMessageUtils getHexByBinary:tempStr],@"00",msgCRC16]];
 
 [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
 
 NSLog(@"写入设备位置结果=%@",array);
 ++indexNum;//横向开始，1，2，3....网格开始
 [self settingSofa];//开始存储沙发
 };
 
 }
 */
