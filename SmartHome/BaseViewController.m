//
//  BaseViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/4/17.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "BaseViewController.h"
#import "DotView.h"


@interface BaseViewController (){
    
    int num1;
    int num2;
    int num3;
}

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kUIColorFromRGB(0xeaeaea);
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [[UIButton appearance] setExclusiveTouch:YES]; //一个视图上的多个控件同时点击同时响应的

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//弹出框
-(void)updateLog:(NSString *)msg{
//    NSLog(@"%@",msg);
    //提示弹出框
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    
    [alert show];
    
}


//写入数据
-(void)writeData:(NSString *)data{
    
    /*
     设备给蓝牙传输数据 必须以十六进制数据传给蓝牙 蓝牙设备才会执行
     因为iOS 蓝牙库中方法 传输书记是以NSData形式
     因此封装 stringToByte 方法的作用字符串 ---> 十六进制数据 ---> NSData数据
     */
    
    /*
    unsigned char test[8];
    test[0]=0x55;
    test[1]=0x55;
    test[2]=0x00;
    test[3]=0x08;
    test[4]=0x01;
    test[5]=0x00;
    
    //            test[6]=0x00;
    //            test[7]=0x00;
    
    NSLog(@"sizeof(test)::%d",sizeof(test));
    unsigned char c = CheckCRC(test, sizeof(test));
    NSLog(@"ccc====%x===%s",c,&test);
            for (int i = 0; i <sizeof(test); i++) {
                NSLog(@"%c", test[i]);
                NSString *string = [NSString stringWithFormat:@"%02lx", test[i]];
                NSLog(@"string::%@",string);
                //                NSLog(@"%@",[PZMessageUtils asciiToHex:string]);
            }
    */
    
    
    if ([AppDelegate shareGlobal].linkState == BLEState_Successful) {
        
        NSData *wdata = [[BLEIToll alloc] stringToByte:data];
        
        NSMutableData *rawdata = [wdata mutableCopy];//备份数据
        //计算长度
        NSInteger dataLen = wdata.length;
        NSString *hexStr = [NSString stringWithFormat:@"%02lx",(long)dataLen];
        NSData *msgLen = [PZMessageUtils hexToBytes:hexStr];
        
        [rawdata replaceBytesInRange:NSMakeRange(2, 1) withBytes:[msgLen bytes] length:1];
        NSLog(@"rawdata==%@",rawdata);
        if (rawdata != nil) {
             [[[AppDelegate shareGlobal] manager] sendData:rawdata];
        }
       
    }
    else{
        
        //提示弹出框
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Bluetooth disconnected" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        
        [alert show];
    }
}




-(UIView *)layoutbox_bg:(UIView *)selffView {
    
    //上半部分布局图
    UIView * layoutView = [UIView new];
    layoutView.backgroundColor = [UIColor clearColor];
    [selffView addSubview:layoutView];
    [layoutView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(boxWidth * (heng_box));
    }];
    
    //背景图
    UIView *bgView = [UIView new];
    bgView.backgroundColor = kUIColorFromRGB(0x9aa3aa);
    bgView.layer.borderWidth = 1;
    bgView.layer.borderColor = kUIColorFromRGB(0xb1b9bd).CGColor;
    bgView.layer.shadowOpacity = 0.5;// 阴影透明度
    bgView.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色
    bgView.layer.shadowRadius = 3;// 阴影扩散的范围控制
    bgView.layer.shadowOffset  = CGSizeMake(3, 3);// 阴影的范围
    [layoutView addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(5);
        make.right.mas_equalTo(-5);
        make.height.mas_equalTo(boxWidth * heng_box + 10);
    }];
    
    //画网格
    DotView * containerView = [DotView new];
    containerView.backgroundColor = kUIColorFromRGB(0x9aa3aa);
    containerView.layer.borderColor = kUIColorFromRGB(0xb1b9bd).CGColor;
    containerView.layer.borderWidth = 1;
    [layoutView addSubview:containerView];
    containerView.row = heng_box;//行
    containerView.col = shu_box;//列
    containerView.width = boxWidth;
    containerView.layer.shadowOpacity = 0.5;// 阴影透明度
    containerView.layer.shadowColor = [UIColor blackColor].CGColor;// 阴影的颜色
    containerView.layer.shadowRadius = 3;// 阴影扩散的范围控制
    containerView.layer.shadowOffset  = CGSizeMake(3, 3);// 阴影的范围
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(layoutView.mas_centerX);
        make.top.mas_equalTo(5*2);
        make.width.mas_equalTo(boxWidth * shu_box);
        make.height.mas_equalTo(boxWidth * heng_box);
    }];
    
    [containerView setNeedsDisplay];//调用

    
    return layoutView;
}



-(NSString *)responseData:(NSArray *)array{
    
    NSString *state = @"";
    if ([[[array objectAtIndex:0] uppercaseString] isEqualToString:@"AA"] && [[[array objectAtIndex:1] uppercaseString] isEqualToString:@"AA"]) {
       
        NSString *sts =[[array objectAtIndex:(array.count-3)] uppercaseString];
//        NSLog(@"state==%@",sts);
        if ([sts isEqualToString:@"00"]) {
            //NSLog(@"成功");
            state = @"00";
        }
        else if([sts isEqualToString:@"01"]){
            //NSLog(@"设备锁定");
            state = @"01";
        }
        else if([sts isEqualToString:@"02"]){
            //NSLog(@"通讯故障");
            state = @"02";
        }
        else if([sts isEqualToString:@"03"]){
            //NSLog(@"控制器故障");
            state = @"03";
        }
        else if([sts isEqualToString:@"04"]){
            //NSLog(@"设备忙碌");
            state = @"04";
        }
        else if([sts isEqualToString:@"05"]){
            //NSLog(@"指令错误");
            state = @"05";
        }
        else if([sts isEqualToString:@"06"]){
            //NSLog(@"写入布局失败");
            state = @"06";
        }
        else{
            //NSLog(@"无此设备");
        }
        
        
    }
    
    return state;
}

//根据蓝牙获取设备分配沙发
-(NSArray *)getSofaArrByBLEArr:(NSArray *)listArr{
    
    //测试用于组装数据,3个单人位,2个双人位
    NSMutableArray *sofaArr_temp = [NSMutableArray new];//初始化数组
    
    num1 = 0;//代表单人沙发位的数量
    num2 = 0;//代表双人沙发位的数量
    num3 = 0;//代表三人沙发位的数量
    
    //组装数据
    for(int i = 0;i<listArr.count;i++){
        
        [sofaArr_temp addObject: [self getBleArrByDic:[listArr objectAtIndex:i] num:i]];
    }

    return sofaArr_temp;
}



-(NSDictionary *)getBleArrByDic:(NSDictionary *)dataDic num:(int)num{
    
    if (num == 0) {
        num1 = 0;//代表单人沙发位的数量
        num2 = 0;//代表双人沙发位的数量
        num3 = 0;//代表三人沙发位的数量
    }
    
    NSMutableDictionary *sofaDic = [NSMutableDictionary new];
    //随机产生电机个数
    int powerNum = [[[[dataDic objectForKey:@"uuids"] substringFromIndex:4] substringToIndex:2] intValue];
    int k = 0;
    if (powerNum == 1) {
        k= 1;
    }
    else if(powerNum == 3){
        k = 2;
    }
    else if(powerNum == 7){
        k = 3;
    }
    
    [sofaDic setObject:[NSNumber numberWithInt:k] forKey:@"powerNum"];//电机的个数
    //沙发个数
    int sofaNum=[[[[dataDic objectForKey:@"uuids"] substringFromIndex:2] substringToIndex:2] intValue];
    [sofaDic setObject:[NSNumber numberWithInt:sofaNum]  forKey:@"num"];//沙发的个数
    [sofaDic setObject:@"sofa" forKey:@"sofaName"];//电机的名称
    [sofaDic setObject:[NSNumber numberWithInt:0] forKey:@"isTest"];//是否测试过
    [sofaDic setObject:[NSNumber numberWithInt:0] forKey:@"isCurrent"];//是否选中当前沙发
    [sofaDic setObject:[NSNumber numberWithInt:10+num]  forKey:@"tag"];//沙发的tag值
    [sofaDic setObject:[NSNumber numberWithInt:0]  forKey:@"isPowerOff"];//当前沙发是否断电
    [sofaDic setObject:[dataDic objectForKey:@"identifier"]   forKey:@"identifier"];//唯一标识码
    [sofaDic setObject:[dataDic objectForKey:@"serviceUUIDs"]   forKey:@"serviceUUIDs"];//serviceUUID
    //        [sofaDic setObject:[[listArr objectAtIndex:i] objectForKey:@"peripheral"]  forKey:@"peripheral"];//设备的唯一标识码
    //布局是home/r
    int home_r = [[[[dataDic objectForKey:@"uuids"] substringFromIndex:6] substringToIndex:2] intValue];
    NSString *layoutState = @"R";
    if (home_r == 1) {
        layoutState = @"Home";
    }
    else{
        layoutState = @"R";
    }
    [sofaDic setObject:layoutState forKey:@"controlLayout"];//布局是home/r
    
    //组合灯的布局
    NSString * lightStr = [[[dataDic objectForKey:@"uuids"] substringFromIndex:8] substringToIndex:2];
    NSString *lightBin =  [PZMessageUtils getBinaryByHex:lightStr];
    //        NSLog(@"lightBin==%@",lightBin);
    if ([lightBin containsString:@"1"]) {
        [sofaDic setObject:[lightBin substringFromIndex:3] forKey:@"light"];//灯组合
    }
    else{
        [sofaDic setObject:@"NO" forKey:@"light"];//灯组合
    }
    
    //[sofaDic setObject:[[scanSofaArr objectAtIndex:i] componentsJoinedByString:@""]  forKey:@"id"];//沙发id
    //        [sofaDic setObject:@"020304050607"  forKey:@"id"];
    [sofaDic setObject:[NSNumber numberWithInt:0] forKey:@"isOP"];//是否在操作
    
    //位置
    if (sofaNum == 1) {
        [sofaDic setObject:[NSNumber numberWithInt:num1] forKey:@"x"];
        num1++;
        [sofaDic setObject:[NSNumber numberWithInt:sofaNum *100 +num1] forKey:@"tag"];//将tag值保存
        [sofaDic setObject:[NSNumber numberWithInt:0] forKey:@"y"];
    }
    else if (sofaNum == 2){
        [sofaDic setObject:[NSNumber numberWithInt:num2] forKey:@"x"];
        num2=num2+2;
        [sofaDic setObject:[NSNumber numberWithInt:sofaNum *100+num2] forKey:@"tag"];//将tag值保存
        if (num2 > 6) {
//            sofaNum++;
//            num2 = 0;
            [sofaDic setObject:[NSNumber numberWithInt:num2-8] forKey:@"x"];
//            num2 = num2+2;
        }
        [sofaDic setObject:[NSNumber numberWithInt:(num2/8+1)] forKey:@"y"];
    }
    else if (sofaNum == 3){
        [sofaDic setObject:[NSNumber numberWithInt:num3] forKey:@"x"];
        num3=num3+3;
        [sofaDic setObject:[NSNumber numberWithInt:sofaNum *100+num3] forKey:@"tag"];//将tag值保存
        
        [sofaDic setObject:[NSNumber numberWithInt:3] forKey:@"y"];
    }
    
    
    [sofaDic setObject:[NSNumber numberWithInt:1] forKey:@"sofaDirect"];//沙发方向,默认为1,面向上
    
    NSMutableArray *temp =[NSMutableArray new];
    for (int i = 0; i<(sofaNum == 1 ? sofaNum : 2); i++) {
        
        
        NSMutableDictionary *tempSofaDic = [NSMutableDictionary new];
        
        //            [tempSofaDic setObject:@"020304050607" forKey:@"id"];
        [tempSofaDic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];//当前沙发是否锁定
        [tempSofaDic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];//是否自己锁定操作
        [tempSofaDic setObject:[NSNumber numberWithInt:0] forKey:@"isCurrentPosition"];//是否当前自己的位置
        [tempSofaDic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];//是否有故障
        [temp addObject:tempSofaDic];
    }
    [sofaDic setObject:temp forKey:@"sofadata"];//将sofa值保存
    
    return sofaDic;

}


-(NSString *)allPosition:(NSArray *)storePositionArr{
    
    //配置从首页中获取
    NSString *currentStr = [[storePositionArr objectAtIndex:0] objectAtIndex:0];
//    NSLog(@"currentSt==%@",currentStr);
    for (int i=1; i<storePositionArr.count; i++) {
        //全部或的结果,如果为1时,此位置被占用,为0时,此位置为空
        NSString *p2 = [[storePositionArr objectAtIndex:i] objectAtIndex:0];
        
        NSMutableString *temp = [NSMutableString new];
//        NSLog(@"p2==%@",p2);
        for (int j=0; j<5; j++) {
            int temp1 = [[[currentStr substringFromIndex:j] substringToIndex:1] intValue];
            int temp2 = [[[p2 substringFromIndex:j] substringToIndex:1] intValue];
            [temp appendString:[NSString stringWithFormat:@"%d",temp1 | temp2]];
        }
        
        currentStr = temp;
    }

    return currentStr;
}

/*
//所有设备的位置情况
-(NSString *)allPosition:(NSArray *)storePositionArr{
    
    //配置从首页中获取
    int  p1 = [[[storePositionArr objectAtIndex:0] objectAtIndex:0] intValue] | 00000;
    NSLog(@"p1==%05d",p1);
    int p3 = p1;
    for (int i=1; i<storePositionArr.count; i++) {
        //全部或的结果,如果为1时,此位置被占用,为0时,此位置为空
        char p2 = [[[storePositionArr objectAtIndex:i] objectAtIndex:0] intValue] | 00000;
        NSLog(@"p2==%05d",p2);
        p3 = p3 | p2 | 00000;
        NSLog(@"p3==%05d",p3);
    }
    
    NSString * currentScreen = [NSString stringWithFormat:@"%05d",p3 | 00000];

    return currentScreen;
}
*/


@end
