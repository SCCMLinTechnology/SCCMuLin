//
//  TestViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/7/31.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController (){
    UITextField *contentTxt;
    UITextField *timeTxt;
    
    int successNum;
    int totalNum;
    UILabel *sendcontentLabel;
    
    UILabel *successcontentLabel;
    
    UIButton *sendBtn;
    
    UIButton *stopBtn;
    
    int item;//发送的次数
    int cycleNumber;//需要统计的次数
    
    float delay_Time;//延时
    
    UILabel *totalcontentLabel;
    
}

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UILabel *contentLabel =[UILabel new];
    contentLabel.text = @"发送次数：";
    contentLabel.textColor = [UIColor blackColor];
    contentLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(20);
        
    }];
    
    
    contentTxt =[UITextField new];
    contentTxt.placeholder = @"请输入发送的次数";
    contentTxt.keyboardType = UIKeyboardTypeNumberPad;
    contentTxt.textColor = [UIColor blackColor];
    contentTxt.font =[UIFont systemFontOfSize:15.0];
    contentTxt.textAlignment = NSTextAlignmentLeft;
    contentTxt.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentTxt];
    [contentTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentLabel.mas_right).offset(10);
        make.top.mas_equalTo(contentLabel.mas_top);
        make.centerY.mas_equalTo(contentLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(200, 30));
        
        
    }];
    
    
    
    UILabel *timeLabel =[UILabel new];
    timeLabel.text = @"时间间隔：";
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentLabel.mas_left);
        make.top.mas_equalTo(contentTxt.mas_bottom).offset(20);
        
    }];
    
    
    timeTxt =[UITextField new];
    timeTxt.placeholder = @"请输入时间间隔";
    timeTxt.keyboardType = UIKeyboardTypeNumberPad;
    timeTxt.textColor = [UIColor blackColor];
    timeTxt.font =[UIFont systemFontOfSize:15.0];
    timeTxt.textAlignment = NSTextAlignmentLeft;
    timeTxt.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:timeTxt];
    [timeTxt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeLabel.mas_right).offset(10);
        make.top.mas_equalTo(timeLabel.mas_top);
        make.centerY.mas_equalTo(timeLabel.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(200, 30));
        
    }];

    UILabel *msLabel =[UILabel new];
    msLabel.text = @"ms";
    msLabel.textColor = [UIColor blackColor];
    msLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:msLabel];
    [msLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(timeTxt.mas_right).offset(5);
        make.centerY.mas_equalTo(timeLabel.mas_centerY);
        
    }];
    
    
    
     //操作测试按钮
     sendBtn = [UIButton new];
     [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
     sendBtn.backgroundColor = [UIColor greenColor];
     [sendBtn addTarget:self action:@selector(send) forControlEvents:UIControlEventTouchUpInside];
     [self.view addSubview:sendBtn];
     [sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.left.mas_equalTo(contentLabel.mas_left);
         make.top.mas_equalTo(timeLabel.mas_bottom).offset(20);
         make.size.mas_equalTo(CGSizeMake(100, 40));
     
     }];
    
    stopBtn = [UIButton new];
    [stopBtn setTitle:@"停止" forState:UIControlStateNormal];
    stopBtn.backgroundColor = [UIColor redColor];
    [stopBtn addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:stopBtn];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(timeLabel.mas_bottom).offset(20);
        make.size.mas_equalTo(CGSizeMake(100, 40));
        
    }];
    
    
    UILabel *sendLabel =[UILabel new];
    sendLabel.text = @"发送次数：";
    sendLabel.textColor = [UIColor blackColor];
    sendLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:sendLabel];
    [sendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentLabel.mas_left);
        make.top.mas_equalTo(sendBtn.mas_bottom).offset(20);
        
    }];
    
    
    sendcontentLabel =[UILabel new];
    sendcontentLabel.text = @"0";
    sendcontentLabel.textColor = [UIColor whiteColor];
    sendcontentLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:sendcontentLabel];
    [sendcontentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendLabel.mas_right).offset(10);
        make.top.mas_equalTo(sendLabel.mas_top);
        
    }];

    
    UILabel *successLabel =[UILabel new];
    successLabel.text = @"成功次数：";
    successLabel.textColor = [UIColor blackColor];
    successLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:successLabel];
    [successLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(sendcontentLabel.mas_right).offset(50);
        make.top.mas_equalTo(sendBtn.mas_bottom).offset(20);
        
    }];
    
    
    successcontentLabel =[UILabel new];
    successcontentLabel.text = @"0";
    successcontentLabel.textColor = [UIColor whiteColor];
    successcontentLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:successcontentLabel];
    [successcontentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(successLabel.mas_right).offset(10);
        make.top.mas_equalTo(successLabel.mas_top);
        
    }];
    
    
    UILabel *totalLabel =[UILabel new];
    totalLabel.text = @"总接收数：";
    totalLabel.textColor = [UIColor blackColor];
    totalLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:totalLabel];
    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(contentLabel.mas_left);
        make.top.mas_equalTo(sendLabel.mas_bottom).offset(20);
        
    }];
    
    
    totalcontentLabel =[UILabel new];
    totalcontentLabel.text = @"0";
    totalcontentLabel.textColor = [UIColor whiteColor];
    totalcontentLabel.font =[UIFont systemFontOfSize:15.0];
    [self.view addSubview:totalcontentLabel];
    [totalcontentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(totalLabel.mas_right).offset(10);
        make.top.mas_equalTo(totalLabel.mas_top);
        
    }];


    
}

-(void)send{
    
    [contentTxt resignFirstResponder];
    [timeTxt resignFirstResponder];
    
    [sendBtn setEnabled:NO];
    [stopBtn setEnabled:YES];
    
    //循环的数字
    cycleNumber = [contentTxt.text intValue];//发送的次数
//    NSLog(@"心跳数字 ：%d",cycleNumber);
    sendcontentLabel.text = @"0";
    successcontentLabel.text = @"0";
    
    successNum = 0;//统计成功接受的次数
    item = 0;//统计发送的次数
    totalNum = 0;//总接收数
    //[self cycleScan:peripheralNum cycleNumber:cycleNumber];
    delay_Time = [timeTxt.text intValue] /1000.0;
    
    [self performSelector:@selector(sendData) withObject:nil afterDelay:delay_Time];
    
    
    
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
//        NSLog(@"数据返回：read=11=%@",array);
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            
            [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数辆
            [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
            
            return ;
        }
        
        ++totalNum;
        totalcontentLabel.text = [NSString stringWithFormat:@"%d",totalNum];
        
        int temp = [[NSString stringWithFormat:@"%lu",strtoul([[[array objectAtIndex:4] uppercaseString] UTF8String],0,16)] intValue];
        NSString *tempstr =[array componentsJoinedByString:@""];
//        NSLog(@"tempstr==%@",tempstr);
        
        int temp1 = [[NSString stringWithFormat:@"%lu",strtoul([[[array objectAtIndex:6] uppercaseString] UTF8String],0,16)] intValue];
        
        if (temp == 2 || [tempstr isEqualToString:@"aaaa000f0200010000000000006d5d"] || temp1 == 1) {
            
            ++successNum;
            successcontentLabel.text = [NSString stringWithFormat:@"%d",successNum];
            
        }
       
    };

    
}


//发送数据
-(void)sendData{
    
    
    if (item<cycleNumber) {
        
        sendcontentLabel.text = [NSString stringWithFormat:@"%d",item+1];
        
        NSString *number=[NSString stringWithFormat:@"%02d",1];//获取设备数量
        [self writeData:[NSString stringWithFormat:@"%@%@02%@%@%@",msgHead,msgLength,msgType,number,msgCRC16]];
        
        ++item;
        
        [self performSelector:@selector(sendData) withObject:nil afterDelay:delay_Time];
        
    }
    else{
        
        [self updateLog:@"搜索停止"];
        
        [sendBtn setEnabled:YES];
        [stopBtn setEnabled:YES];
        
    }
    
}










-(void)stop{
    
    [contentTxt resignFirstResponder];
    [timeTxt resignFirstResponder];
    
    [sendBtn setEnabled:YES];
    [stopBtn setEnabled:NO];
    
    /*
    peripheralNum = [contentTxt.text intValue];
    
    int cycleNumber = [contentTxt.text intValue];
    NSLog(@"心跳数字 ：%d",cycleNumber);
    
    [self cycleScan:peripheralNum cycleNumber:cycleNumber];
     */
    item = cycleNumber;
    
    [self sendData];
}












/*
-(void)cycleScan:(int)i cycleNumber:(int)cycleNumber{
    
    
    if (peripheralNum<cycleNumber) {
        
        sendcontentLabel.text = [NSString stringWithFormat:@"%d",item+1];
        
        NSString *number=[NSString stringWithFormat:@"%02d",1];//获取设备数量
        [self writeData:[NSString stringWithFormat:@"%@%@02%@%@%@",msgHead,msgLength,msgType,number,msgCRC16]];
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
            
            NSLog(@"数据返回：read=11=%@",array);
            int temp = [[NSString stringWithFormat:@"%lu",strtoul([[[array objectAtIndex:4] uppercaseString] UTF8String],0,16)] intValue];
            if (temp == 2) {
                
                [NSThread sleepForTimeInterval:[timeTxt.text intValue]/1000];
                
                [self cycleScan:++peripheralNum cycleNumber:cycleNumber];
                
                successcontentLabel.text = [NSString stringWithFormat:@"%d",i+1];
                
            }
        };
        
    }
    else{
        
        [self :@"搜索停止"];
        
        [sendBtn setEnabled:YES];
        [stopBtn setEnabled:YES];
        
    }
}
*/



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
