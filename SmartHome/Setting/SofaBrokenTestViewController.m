//
//  SofaBrokenTestViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/9/1.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "SofaBrokenTestViewController.h"

@interface SofaBrokenTestViewController (){
    LayoutSofaView *layoutsofa;
    UILabel *testResultLable;
    
    UILabel *currentStateLabel;
    UILabel *guzhangStateLabel;
    
    NSString *pos;
    int power;
    
    BOOL isPowerOff;
    
    NSMutableDictionary *currentDic;
    NSMutableArray *sofa_arr;
    
    int currentPos;
    int currentIndexPos;
}

@end

@implementation SofaBrokenTestViewController
@synthesize sofaArr;


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //删除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UnexpectedInterruptionNotice" object:nil];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18]}];
}

-(void)stateChange:(int)err{
//    NSLog(@"currentDic==%@",currentDic);
    if (!currentDic) {//如果没有选中的设备
        return;
    }
    NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
    
    for (int i =0; i<temp_arr.count; i++) {
        //沙发位的序号
        NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc] initWithDictionary:[temp_arr objectAtIndex:i]];
        [temp_dic setObject:[NSNumber numberWithInt:err] forKey:@"isError"];
    
        [temp_arr removeObjectAtIndex:i];
        [temp_arr insertObject:temp_dic atIndex:i];
    }
   
    [currentDic setObject:temp_arr forKey:@"sofadata"];
//    NSLog(@"currentDic==%@",currentDic);
    
    [sofa_arr removeObjectAtIndex:currentPos];//沙发的序号
    [sofa_arr insertObject:currentDic atIndex:currentPos];
    
//    NSLog(@"sofa_arr=333=4444=%@",sofa_arr);
    [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
}

-(void)initData{
    
    for (int i = 0; i<sofa_arr.count; i++) {
        
        NSMutableDictionary *temp = [[NSMutableDictionary alloc] initWithDictionary:[sofa_arr objectAtIndex:i]];
        
        NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[temp objectForKey:@"sofadata"]];
        
        for (int j =0; j<temp_arr.count; j++) {
            //沙发位的序号
            NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc] initWithDictionary:[temp_arr objectAtIndex:j]];
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
            [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
            
            [temp_arr removeObjectAtIndex:j];
            [temp_arr insertObject:temp_dic atIndex:j];
        }
        
        [temp setObject:temp_arr forKey:@"sofadata"];
        //        NSLog(@"currentDic==%@",currentDic);
        
        [sofa_arr removeObjectAtIndex:i];//沙发的序号
        [sofa_arr insertObject:temp atIndex:i];
    }
    
//    NSLog(@"sofa_arr==%@",sofa_arr);
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //增加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnexpectedInterruptionNotice) name:@"UnexpectedInterruptionNotice" object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16]}];
    
    
    
    isPowerOff = NO;
    sofa_arr =[[NSMutableArray alloc] initWithArray:sofaArr];
    //布局界面
    layoutsofa = [[LayoutSofaView alloc] initWithFrame:CGRectMake(spaceWidth, 15, boxWidth *shu_box, boxWidth *heng_box)];
    layoutsofa.delegate = self;
    [self.view addSubview:layoutsofa];
    
    UIView *testResultView = [[UIView alloc] initWithFrame:CGRectMake(layoutsofa.frame.origin.x, layoutsofa.frame.size.height+layoutsofa.frame.origin.y+20, layoutsofa.frame.size.width, 200)];
    
    testResultLable = [UILabel commonLabelWithFrame:CGRectMake(0, 0, sWIDTH - 15*2, 25) text:@"Test result" color:kUIColorFromRGB(0x000000) font:[UIFont systemFontOfSize:18.0] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    [testResultView addSubview:testResultLable];
    
    //当前状态
    currentStateLabel =[UILabel commonLabelWithFrame:CGRectMake(0, testResultLable.frame.size.height+testResultLable.frame.origin.y+10, sWIDTH - 15*2, 30) text:@"" color:kUIColorFromRGB(0x000000)  font:[UIFont systemFontOfSize:14.0] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
//    currentStateLabel.numberOfLines = 5;
    currentStateLabel.numberOfLines = 0;
//    [currentStateLabel sizeToFit];
//    currentStateLabel.lineBreakMode = UILineBreakModeWordWrap;
    [testResultView addSubview:currentStateLabel];
    
    //故障
    guzhangStateLabel =[UILabel commonLabelWithFrame:CGRectMake(0, currentStateLabel.frame.size.height+currentStateLabel.frame.origin.y+10, sWIDTH - 15*2, 30) text:@"" color:kUIColorFromRGB(0x000000) font:[UIFont systemFontOfSize:14.0] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
    guzhangStateLabel.numberOfLines = 0;
    [testResultView addSubview:guzhangStateLabel];
    [self.view addSubview:testResultView];
    
    
    //判断蓝牙是打开/关闭
    [[AppDelegate shareGlobal] manager].linkBlcok = ^(NSString *state){
        
        [AppDelegate shareGlobal].link = state;
        if ([state isEqualToString:kCONNECTED_POWERD_ON]) {
            
//            [[[AppDelegate shareGlobal] manager] scanMgr];
            [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[currentDic objectForKey:@"serviceUUIDs"] identifier:[currentDic objectForKey:@"identifier"]];
        }
        else{
            currentStateLabel.text = @"Bluetooth disconnected";
            [self updateLog:@"Please open Bluetooth"];
            
            [AppDelegate shareGlobal].globalBleDis = YES;
        }
    };
    
    
    [[AppDelegate shareGlobal] manager].stateBlock = ^(int number,NSString *idFlag,int errCode) {
//        NSLog(@"状态==%d==%d",number,errCode);
        if (errCode != 0) {//断电的情况
            
            if ([[[AppDelegate shareGlobal].globalSofaDic objectForKey:@"identifier"] isEqualToString:idFlag]) {
                NSLog(@"cccc");
                [AppDelegate shareGlobal].globalPowerOff = YES;
            }
            
            if ([idFlag isEqualToString:[currentDic objectForKey:@"identifier"]]) {
                isPowerOff = YES;
                if (number != 0) {
                    
                    //断网或者超时
                    [[VWProgressHUD shareInstance] dismiss];//消除转子
                    currentStateLabel.text = @"The control box is missed or corrupted power supply,please check it.";
                    [self autoLabelHeight:currentStateLabel];
                    
                    [self stateChange:1];
                    
                    [self setClearZero];//断电，自己锁归0
                    
                }
                else{
                    
                }
            }
            
           
            
        }
        else{
              if ([idFlag isEqualToString:[currentDic objectForKey:@"identifier"]]) {
                  isPowerOff = NO;
                  if (number == 0) {
                      currentStateLabel.text = @"";
                      [self stateChange:0];
                  }
                  else{
                      //断开蓝牙
                  }
              }
            
        }
    };
    
    //无匹配蓝牙
    [[AppDelegate shareGlobal] manager].noPeripheralBlock = ^(NSString *state) {
//        NSLog(@"无匹配蓝牙状态状态==%@",state);
        if ([state intValue] == 1) {
            
            [[VWProgressHUD shareInstance] dismiss];//消除转子
            currentStateLabel.text = @"The control box is missed or corrupted power supply,please check it.";
            
           [self autoLabelHeight:currentStateLabel];
        }
    };
    

    //初始化数据,将所有的置为0
    [self initData];
    
    //布局
    [layoutsofa layoutSetDataToBox:sofa_arr  isMove:NO isBack:YES isTest:NO finishCallBack:^(NSDictionary *data, int currentIndex, int position) {
        
        currentStateLabel.text = @"";
        guzhangStateLabel.text = @"";
        //09287BAC-9402-4C66-9D73-56B1062C044F
        //1.连接蓝牙
        //        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"peripheral"]];
        currentDic = [[NSMutableDictionary alloc]initWithDictionary:data];
        currentPos = currentIndex;
        currentIndexPos = position;
        
//        NSLog(@"position==%d",position);
        //判断是左边还是右边座位
        if (position == 0) {
            pos = @"01";
        }
        else{
            pos = @"02";
        }
        
        
        if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        }
        else{
            [[VWProgressHUD shareInstance] dismiss];//消除转子
            [self updateLog:@"Please open Bluetooth"];
            currentStateLabel.text = @"Bluetooth disconnected";
            
            //根据内容大小，动态设置UILabel的高度
            [self autoLabelHeight:currentStateLabel];
            
            return ;
        }
        
        [[VWProgressHUD shareInstance] showLoadingWithTip:@"Testing"];
        
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[data objectForKey:@"serviceUUIDs"] identifier:[data objectForKey:@"identifier"]];
        
        if (isPowerOff) {
            [[VWProgressHUD shareInstance] dismiss];//消除转子
            currentStateLabel.text = @"The control box is missed or corrupted power supply,please check it.";
            //根据内容大小，动态设置UILabel的高度
            [self autoLabelHeight:currentStateLabel];
            
            return ;
        }
        
       
        power = [[data objectForKey:@"powerNum"] intValue];//沙发的个数
        
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
//            NSLog(@"准备完成状态==%@",state);
            if ([state isEqualToString:@"1"]) {
                
                //注册命令
                [self writeData:[NSString stringWithFormat:@"%@%@1002%@%@",msgHead,msgLength,[NSString stringWithFormat:@"%@000000",pos],msgCRC16]];
                //数据返回
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                    
//                    NSLog(@"注册==%@",array);
                    
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        
                        [[VWProgressHUD shareInstance] dismiss];
                        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
                        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
                        
                        return ;
                    }
                    
//                    [self updateLog:[array componentsJoinedByString:@" "]];
                    int state = [[self responseData:array] intValue];
                    NSString *responState = @"";
                    
                    NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
                    //将sofadata中的isSelfLock置为1
                    NSMutableDictionary *temp_dic = [temp_arr objectAtIndex:currentIndexPos];
                    
                    if (state == 0) {
                        responState = @"OK";
                        
                        [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
                        [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
                        [temp_arr removeObjectAtIndex:currentIndexPos];
                        [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
                        
                        [currentDic setObject:temp_arr forKey:@"sofadata"];
                        //        NSLog(@"currentDic==%@",currentDic);
                        
                        [sofa_arr removeObjectAtIndex:currentPos];
                        [sofa_arr insertObject:currentDic atIndex:currentPos];
                        
//                        NSLog(@"sofa_arr=ddd=%@",sofa_arr);
//                        [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
                        
                        [self performSelector:@selector(requestError) withObject:nil afterDelay:300/1000.0];
                        
                    }
                    else if (state == 1 || state == 2 || state == 3){
                        if (state == 1) {
                            responState =@"Locked";
                        }
                        else{
                            //通讯故障
                            responState =@"The control box is missed or corrupted power supply,please check it.";
                        }
                        
                        if (state == 1) {
                            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isLock"];
                        }
                        else{
                            [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
                        }
                        
                        [temp_arr removeObjectAtIndex:currentIndexPos];
                        [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
                        
                        [currentDic setObject:temp_arr forKey:@"sofadata"];
                        //        NSLog(@"currentDic==%@",currentDic);
                        
                        [sofa_arr removeObjectAtIndex:currentPos];
                        [sofa_arr insertObject:currentDic atIndex:currentPos];
                        
                        [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
                    }

                    /*
                    else if (state == 1){
                        responState =@"Locked";
                    }
                    else if (state == 2 || state == 3){
                        
                        responState =@"The control box is missed or corrupted power supply,please check it.";
                        
                        NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
                        //将sofadata中的isSelfLock置为1
                        NSMutableDictionary *temp_dic = [temp_arr objectAtIndex:position];
                        [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
                        [temp_arr removeObjectAtIndex:position];
                        [temp_arr insertObject:temp_dic atIndex:position];
                        
                        [currentDic setObject:temp_arr forKey:@"sofadata"];
                        //        NSLog(@"currentDic==%@",currentDic);
                        
                        [sofa_arr removeObjectAtIndex:currentIndex];
                        [sofa_arr insertObject:currentDic atIndex:currentIndex];
        
                        [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
                        
                    }
                     */
                    else if (state == 3){
                        responState =@"The control box is missed or corrupted power supply,please check it.";
                    }
                    else if (state == 4){
                        responState =@"设备忙碌";
                    }
                    else if (state == 5){
                        responState =@"指令错误";
                    }
                    else if (state == 6){
                        responState =@"写入布局失败";
                    }
                
                    if (state != 0) {
                        
                        [[VWProgressHUD shareInstance] dismiss];//消除转子
                        currentStateLabel.text = responState;
                        
                        [self autoLabelHeight:currentStateLabel];
                    }
                    
                };
            }
            else
            {
                //超时或者断开连接
                [[VWProgressHUD shareInstance] dismiss];//消除转子
                [self stateChange:1];
                currentStateLabel.text = @"The control box is missed or corrupted power supply,please check it.";
                
                //根据内容大小，动态设置UILabel的高度
                [self autoLabelHeight:currentStateLabel];
            }
        };
    }];
}



//意外中断通知
-(void)UnexpectedInterruptionNotice{
    NSLog(@"意外中断");
    
    [[VWProgressHUD shareInstance] dismiss];//消除转子
    currentStateLabel.text = @"";
}

//归0
-(void)setClearZero{
    
    if (!currentDic) {//如果没有选中的设备
        return;
    }
    
    NSMutableArray *temp_sofaArr = [[NSMutableArray alloc] initWithArray:[AppDelegate shareGlobal].globalSofaArr];
    
    NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
    
    for (int i =0; i<temp_arr.count; i++) {
        //沙发位的序号
        NSMutableDictionary *temp_dic = [[NSMutableDictionary alloc] initWithDictionary:[temp_arr objectAtIndex:i]];
        [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isSelfLock"];
        
        [temp_arr removeObjectAtIndex:i];
        [temp_arr insertObject:temp_dic atIndex:i];
    }
    
    [currentDic setObject:temp_arr forKey:@"sofadata"];
    //    NSLog(@"currentDic==%@",currentDic);
    
    [temp_sofaArr removeObjectAtIndex:currentPos];//沙发的序号
    [temp_sofaArr insertObject:currentDic atIndex:currentPos];
    
    [AppDelegate shareGlobal].globalSofaArr = temp_sofaArr;
    
}

//刷新界面数据
-(void)RefreshLayoutData:(NSArray *)data position:(int)position{
    sofa_arr = nil;
    sofa_arr =[[NSMutableArray alloc] initWithArray:data];
    currentIndexPos = position;

}

-(void)requestError{
    
    //注册命令
    [self writeData:[NSString stringWithFormat:@"%@%@1003%@%@",msgHead,msgLength,[NSString stringWithFormat:@"%@000000",pos],msgCRC16]];
    //数据返回
    [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
        
//        NSLog(@"注册=33333=%@",array);
        if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
            [[VWProgressHUD shareInstance] dismiss];
            [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数
            [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
            
            return ;
        }
//        [self updateLog:[array componentsJoinedByString:@" "]];
        [[VWProgressHUD shareInstance] dismiss];//消除转子
        
        
        int state = [[self responseData:array] intValue];
        NSString *responState = @"";
        
        
        NSMutableArray *temp_arr =[[NSMutableArray alloc] initWithArray:[currentDic objectForKey:@"sofadata"]];
        //将sofadata中的isSelfLock置为1
        NSMutableDictionary *temp_dic = [temp_arr objectAtIndex:currentIndexPos];
        
        if (state == 0) {
            if ([[array objectAtIndex:7] intValue] == 0 && [[array objectAtIndex:8] intValue] == 0) {
                responState = @"OK";
                
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isLock"];
                [temp_dic setObject:[NSNumber numberWithInt:0] forKey:@"isError"];
            }
            
            [temp_arr removeObjectAtIndex:currentIndexPos];
            [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
            
            [currentDic setObject:temp_arr forKey:@"sofadata"];
            //        NSLog(@"currentDic==%@",currentDic);
            
            [sofa_arr removeObjectAtIndex:currentPos];
            [sofa_arr insertObject:currentDic atIndex:currentPos];
            
            
//            NSLog(@"sofa_arr==%@",sofa_arr);
//                [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
        }
        else if (state == 1 || state == 2 || state == 3){
            if (state == 1) {
                responState =@"Locked";
            }
            else{
                //通讯故障
                responState =@"The control box is missed or corrupted power supply,please check it.";
            }

            if (state == 1) {
                [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isLock"];
            }
            else{
                [temp_dic setObject:[NSNumber numberWithInt:1] forKey:@"isError"];
            }
            
            [temp_arr removeObjectAtIndex:currentIndexPos];
            [temp_arr insertObject:temp_dic atIndex:currentIndexPos];
            
            [currentDic setObject:temp_arr forKey:@"sofadata"];
            //        NSLog(@"currentDic==%@",currentDic);
            
            [sofa_arr removeObjectAtIndex:currentPos];
            [sofa_arr insertObject:currentDic atIndex:currentPos];
            
            
        }
        else if (state == 3){
            responState =@"The control box is missed or corrupted power supply,please check it.";
        }
        else if (state == 4){
            responState =@"设备忙碌";
        }
        else if (state == 5){
            responState =@"指令错误";
        }
        else if (state == 6){
            responState =@"写入布局失败";
        }
        
        currentStateLabel.text = responState;
        [self autoLabelHeight:currentStateLabel];
        
        //参数3
        NSString *positionrespon = @"";
        if ([[array objectAtIndex:8] isEqualToString:@"01"]) {
            positionrespon =@"The foot motor has been broken.";
        }
        else if ([[array objectAtIndex:8] isEqualToString:@"02"]) {
            positionrespon =@"The head motor has been broken.";
        }
        else if ([[array objectAtIndex:8] isEqualToString:@"04"]) {
            positionrespon =@"The back motor has been broken.";
        }
        
        [layoutsofa layoutRefreshDataToBox:sofa_arr];//刷新布局界面
        
        //将16进制转换成二进制
        NSString *bin =[PZMessageUtils getBinaryByHex:[array objectAtIndex:7]];//40
//        NSLog(@"bin====%@",bin);
        BOOL isHead = NO;
        BOOL isFoot = NO;
        BOOL isBack = NO;
        
        isHead = YES;
        isFoot = YES;
        isBack = YES;
        
        /*
        if (power == 1) {
            isHead = NO;
            isFoot = YES;
            isBack = NO;
        }
        else if(power == 2){
            isHead = YES;
            isFoot = YES;
            isBack = NO;
        }
        else{
            
        }
         */
        NSMutableString *resultrespon = [NSMutableString new];
        for (int i=0; i<bin.length; i++) {
            
            NSString *singleBin = [[bin substringFromIndex:i] substringToIndex:1];
//            NSLog(@"singleBin==%@",singleBin);
            
            if ([singleBin intValue] == 1 && i==1 && power >= 3) {
                isBack = NO;
                //0x40
                [resultrespon appendString:@"The back motor is not connected,please check it. "];
            }
            
            if ([singleBin intValue] == 1 && i==2 && power >= 2) {
                isHead = NO;
                //0x20
                [resultrespon appendString:@"The head motor is not connected,please check it. "];
            }
            
            if ([singleBin intValue] == 1 && i==3 && power >= 1) {
                isFoot = NO;
                //0x10
                [resultrespon appendString:@"The foot motor is not connected,please check it. "];
            }
            
            if ([singleBin intValue] == 1 && i==5 && power >= 3) {
                isBack = NO;
                //0x04
                [resultrespon appendString:@"The back motor has been broken."];
            }
            
            if ([singleBin intValue] == 1 && i==6 && power >= 2) {
                isHead = NO;
                //0x02
                [resultrespon appendString:@"The head motor has been broken."];
            }
            
            if ([singleBin intValue] == 1 && i==7 && power >= 1) {
                isFoot = NO;
                //0x01
                [resultrespon appendString:@"The foot motor has been broken."];
            }
        }
        
//        NSLog(@"resultrespon==%@",resultrespon);
        if ((responState.length == 0 &&  isHead && isFoot && isBack) || ([responState isEqualToString:@"OK"])) {
            currentStateLabel.text = @"OK";
            [self autoLabelHeight:currentStateLabel];
            
        }
        else{
            currentStateLabel.text = resultrespon;
            [self autoLabelHeight:currentStateLabel];
        }
        
        
        /*
        if ([resultrespon containsString:@"foot motor"]) {
            
        }
        else if (responState.length == 0 ) {
            currentStateLabel.text = @"OK";
            
            [self autoLabelHeight:currentStateLabel];
            
        }
        else{
            if ([currentStateLabel.text isEqualToString:@""]) {
                currentStateLabel.text = [NSString stringWithFormat:@"%@%@",positionrespon,resultrespon];
                
                [self autoLabelHeight:currentStateLabel];
            }
            else{
                guzhangStateLabel.text = [NSString stringWithFormat:@"%@%@",positionrespon,resultrespon];
                
                [self autoLabelHeight:guzhangStateLabel];
            }
        }
         */
        
    };
}


-(void)autoLabelHeight:(UILabel *)label{
    
    CGSize size = [label.text sizeWithFont:label.font constrainedToSize:CGSizeMake(label.frame.size.width, 200) lineBreakMode:label.lineBreakMode];
    
    CGRect rect = label.frame;
    rect.size.height = size.height;
    label.frame = rect;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
