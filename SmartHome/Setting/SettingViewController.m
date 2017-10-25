//
//  SettingViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/6/29.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingCell.h"

@interface SettingViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    
    int indexNum;
    int indexNum_temp;
    NSMutableArray *sofasetArr;
    
    NSMutableArray *sofaDataArr;
    NSMutableArray *sofaImageArr;
    
    UICollectionView *collection;
    
    int currentIndex;
    NSMutableArray *orderArr;
    
    NSString *screen;
    
    int num1;
    int num2;
    int num3;
    
    int delIndex;
    
    NSMutableString *delStr;
    
    NSString *currentScreen;
    
    NSMutableArray *scanTemp;
    
    int itemIndex;
    
    int delNum;//删除序号
    
    NSMutableArray *bleTotalArr;//蓝牙总数信息
    
    UILabel *nonDesLabel;
    
    BOOL isPowerOff;
    
    BOOL isDelFlag;
    
    BOOL isUnexpected;//是否意外
}

@end

@implementation SettingViewController
@synthesize isNeedDel;

//配置界面布局
-(void)layoutSettingView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    
    collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, sWIDTH, sHEIGHT-64) collectionViewLayout:layout];
    collection.backgroundColor = [UIColor clearColor];
    
    collection.delegate = self;
    collection.dataSource = self;
    
    [self.view addSubview:collection];
    //    [collection registerClass:[SettingCell class] forCellWithReuseIdentifier:@"setting"];
    [collection registerNib:[UINib nibWithNibName:@"SettingCell" bundle:nil] forCellWithReuseIdentifier:@"setting"];
    
    
    UIView *btnView = [UIView new];
    //    btnView.backgroundColor =[UIColor greenColor];
    [self.view addSubview:btnView];
    
    [btnView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSLog(@"重新进入");
    isUnexpected = NO;
    //增加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(UnexpectedInterruptionNotice) name:@"UnexpectedInterruptionNotice" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    //删除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"UnexpectedInterruptionNotice" object:nil];
}

//意外中断
-(void)UnexpectedInterruptionNotice{
    NSLog(@"意外中断");
    [[VWProgressHUD shareInstance] dismiss];
    isUnexpected = YES;//有意外
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //不需要显示删除按钮
    if (!isNeedDel) {
        
        self.navigationItem.leftBarButtonItem = nil;
        self.navigationItem.backBarButtonItem = nil;
        self.navigationItem.hidesBackButton = YES;
    }
    
    //导航栏背景图片
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    
    //删除提示Label
    [nonDesLabel removeFromSuperview];
    
    //背景图片
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    
    sofaDataArr = [NSMutableArray new];//将布局的所有数据保存下来
    sofaImageArr = [NSMutableArray new];//将布局的所有图片保存下来
    
    [self layoutSettingView];//显示布局
    
    [self readSettingData];//读取配置数据,并显示
    

    //判断蓝牙是打开/关闭
    [[AppDelegate shareGlobal] manager].linkBlcok = ^(NSString *state){
        [AppDelegate shareGlobal].link = state;
        if ([state isEqualToString:kCONNECTED_POWERD_ON]) {
  
        }
        else{
            [[VWProgressHUD shareInstance] dismiss];
            [self updateLog:@"Please open Bluetooth"];
            if (isNeedDel) {
                [AppDelegate shareGlobal].globalBleDis = YES;
            }
            //返回上一层
//            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    

    /*
    [[[AppDelegate shareGlobal] manager] scanMgr];
    
    
    //获取搜索蓝牙设备列表
    [[AppDelegate shareGlobal] manager].listBlock = ^(NSMutableArray *array) {
        NSLog(@"蓝牙列表==%@",array);
        [AppDelegate shareGlobal].bleListArr  = array;
        
        [self performSelector:@selector(readSettingData) withObject:nil afterDelay:1.5];
    };
     */
    
    //超时断网显示
    [[AppDelegate shareGlobal] manager].stateBlock = ^(int number,NSString *idFlag,int errCode) {
//        NSLog(@"状态==%d==err==%d",number,errCode);
        if (errCode != 0) {//断电的情况
        
            if (indexNum_temp < [AppDelegate shareGlobal].bleListArr.count) {
                NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:indexNum_temp];
                if ([idFlag isEqualToString:[bleDic objectForKey:@"identifier"]]) {
                    
                    ++indexNum_temp;
                    [self scan];
                }
            }
            else{
                
                isPowerOff = YES;
                [[VWProgressHUD shareInstance] dismiss];
                if (scanTemp.count > 0 && sofaDataArr.count > 0) {
                }
                else{
                    
                    [[VWProgressHUD shareInstance] dismiss];
                    [self scanNoPer];
                }
            }
            
            if (isNeedDel) {
                //[AppDelegate shareGlobal].globalPowerOff = YES;
                if ([[[AppDelegate shareGlobal].globalSofaDic objectForKey:@"identifier"] isEqualToString:idFlag]) {
                    [AppDelegate shareGlobal].globalPowerOff = YES;
                }
            }
        }
    };

  
    
}


-(void)scanNoPer{
    
    [nonDesLabel removeFromSuperview];
    nonDesLabel = [UILabel commonLabelWithFrame:CGRectMake(15, sHEIGHT/2 -100, sWIDTH - 15*2, 20) text:@"No layouts available now." color:kUIColorFromRGB(0x444444) font:[UIFont systemFontOfSize:(ipad ? 20.0 : 16.0)] bgColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
    [self.view addSubview:nonDesLabel];
}

//读取配置数据
-(void)readSettingData{
    //显示获取布局
    [[VWProgressHUD shareInstance] showLoadingWithTip:@"Obtaining layout"];
    isPowerOff = NO;
    
    scanTemp =[NSMutableArray new];
    bleTotalArr = [NSMutableArray new];
    indexNum_temp = 0;
    
    [self scan];//获取布局
    
}


//扫描布局
-(void)scan{
    
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {

    }
    else{
        [[VWProgressHUD shareInstance] dismiss];
        [self updateLog:@"Please open Bluetooth"];
        [self scanNoPer];
        return;
    }
    
    if (isUnexpected) {
        
        return;
    }
    //根据连接设备获取
    if (indexNum_temp < [AppDelegate shareGlobal].bleListArr.count) {
        //连接
        NSDictionary *bleDic = [[AppDelegate shareGlobal].bleListArr objectAtIndex:indexNum_temp];
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
        
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
//            NSLog(@"state===%@",state);
            
            //连接成功之后
            if ([state isEqualToString:@"1"]) {
                if (indexNum_temp >= [AppDelegate shareGlobal].bleListArr.count) {
                    return ;
                }
                
                [self writeData:[NSString stringWithFormat:@"%@%@06%@",msgHead,msgLength,msgCRC16]];
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                    NSLog(@"位置信息=%@",array);
                    //[self updateLog:[array componentsJoinedByString:@","]];
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        
                        [[VWProgressHUD shareInstance] dismiss];
                        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数辆
                        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
//                        [self.navigationController popViewControllerAnimated:YES];
                        
                        return ;
                    }
                    
                    if ([[self responseData:array] intValue] == 0 || [[self responseData:array] intValue] == 1 ) {
                        //位置信息
                        int  position_d = (int)(strtoul([[array objectAtIndex:5] UTF8String],0,16));
                        if (position_d > 0) {
                            
                            NSMutableArray *temp_arr = [NSMutableArray new];
                            //转换成二进制
                            NSString *screen1=[PZMessageUtils getBinaryByHex:[[array objectAtIndex:5] uppercaseString]];
                            NSMutableString *currentScreen1 = [[NSMutableString alloc] initWithString:[screen1 substringFromIndex:3]];
//                            NSString *currentScreen1 = [screen1 substringFromIndex:3];
//                            currentScreen1 = @"01000";
//                            [temp_arr addObject:currentScreen1];
                            
                            //位置及方向信息
                            NSArray *screenArr =[array subarrayWithRange:NSMakeRange(6, 10)];
//                            screenArr = @[@"00",@"00",@"07",@"00",@"07",@"00",@"00",@"00",@"00",@"00"];
//                            NSLog(@"screenArr==%@",screenArr);
                            BOOL isFlag = NO;
                            for (int i=0; i<5; i++) {
//                                [temp_arr addObject:[screenArr subarrayWithRange:NSMakeRange(2*i,2)]];
                                NSArray *sigleArr = [screenArr subarrayWithRange:NSMakeRange(2*i,2)];
                                int  position_num = (int)(strtoul([[sigleArr objectAtIndex:0] UTF8String],0,16));//位置转换成10进制
                                
                                //位置信息
                                NSString *currentStr = [[currentScreen1 substringFromIndex:4-i] substringToIndex:1];
                               
                                if (position_num > 0 && [currentStr intValue] == 1) {
                                    isFlag = YES;
                                    
                                    [temp_arr addObject:sigleArr];
                                }
                                else{
                                    [currentScreen1 replaceCharactersInRange:NSMakeRange(4-i, 1) withString:@"0"];
                                    [temp_arr addObject:@[@"00",@"00"]];
                                }
                            }
                            //如果有一个符合标准则进行保存
                            if (isFlag) {
                                [temp_arr insertObject:currentScreen1 atIndex:0];
                                [scanTemp addObject:temp_arr];
                                //将存储的蓝牙信息保存
                                [bleTotalArr addObject:bleDic];
                            }
                           
                            ++indexNum_temp;
                            [self scan];
                        }
                        else{
                       
                            ++indexNum_temp;
                            [self scan];
                        }
                    }
                    else{
                        //有故障或者忙碌,直接查询下一个设备
                        ++indexNum_temp;
                        [self scan];
                    }
                };
            }
            else{
                //超时
                ++indexNum_temp;
                [self scan];
            }
        };
    }
    else{
        
        NSLog(@"scanTemp==%@",scanTemp);
        if (scanTemp.count > 0) {
            //获取场景位置信息
            currentScreen = [self allPosition:scanTemp];
//            NSLog(@"currentScreen==%@",currentScreen);
            [self startScanScreen];
        }
        else{
            
            [[VWProgressHUD shareInstance] dismiss];
//            NSLog(@"无法获取场景信息");
            [self scanNoPer];
        }
        
    }
    
}


//开始扫描场景
-(void)startScanScreen{
    
    //最多只有5幅场景,存储场景序号
    orderArr = [NSMutableArray new];
    for (int i = 0; i<currentScreen.length; i++) {
        //获取当前的字符
        NSString *currentStr = [[currentScreen substringFromIndex:4-i] substringToIndex:1];
        if ([currentStr isEqualToString:@"1"]) {
            [orderArr addObject:[NSString stringWithFormat:@"%02d",i+1]];
        }
    }
//    NSLog(@"orderArr::%@",orderArr);
    
    currentIndex = 0;
    [self scanData];
}

-(void)scanData{
    //当前最多为5个
    if (currentIndex < orderArr.count) {
        
        //判断当前是否为空，为空就显示默认场景
        if ([[orderArr objectAtIndex:currentIndex] isEqualToString:@""]) {
            ++currentIndex;
            indexNum=0;
            [self scanData];
        }
        else{
            //开始生成布局
            indexNum=0;
            sofasetArr = [NSMutableArray new];
            [self screenData:[orderArr objectAtIndex:currentIndex]];//屏幕显示
        }
    }
    else{
        
        [[VWProgressHUD shareInstance] dismiss];
        if (sofaDataArr.count == 0) {
            if (!isNeedDel) {
                
                LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
            else{
                [self scanNoPer];
            }
        }
//        NSLog(@"==完成场景");
    }
}

//屏幕显示
-(void)screenData:(NSString *)screenNum{
    //获取到的蓝牙设备数量
    if (indexNum < [bleTotalArr count]) {
        
//        NSLog(@"第%d个蓝牙设备",indexNum);
        
        if (indexNum >= scanTemp.count) {
            ++indexNum;
            [self screenData:screenNum];//屏幕显示
            
            return ;
        }
        
        //获取当前数组,位置+位状态
        NSArray *currentArr =[scanTemp objectAtIndex:indexNum];
        //获取相应位置的沙发的位置
        int  position_d = (int)(strtoul([[[currentArr objectAtIndex:[screenNum intValue]] objectAtIndex:0] UTF8String],0,16));
//        NSLog(@"position_d==%d",position_d);
        if (position_d == 0) {
            ++indexNum;
            [self screenData:screenNum];//屏幕显示
            return ;
        }
        
        //连接
        NSDictionary *bleDic = [bleTotalArr objectAtIndex:indexNum];
        
        //获取当前沙发位置信息
        NSMutableDictionary *sofaDic = [[NSMutableDictionary alloc] initWithDictionary:[self getBleArrByDic:bleDic num:indexNum]];
        
        int x = (position_d - 1)%shu_box;
        int y = (position_d - 1)/shu_box;
        
        [sofaDic setObject:[NSNumber numberWithInt:x] forKey:@"x"];
        [sofaDic setObject:[NSNumber numberWithInt:y] forKey:@"y"];
        
        //位置
        NSString *directad = [[currentArr objectAtIndex:[screenNum intValue]] objectAtIndex:1];
        int directInt = 0;//方向值
        
        if ([directad isEqualToString:@"00"]) {
            directInt = 1;//向下
        }
        else if ([directad isEqualToString:@"01"]){
            directInt = 2;//向左
        }
        else if ([directad isEqualToString:@"02"]){
            directInt = 3;//向上
        }
        else if ([directad isEqualToString:@"03"]){
            directInt = 4;//向右
        }
        [sofaDic setObject:[NSNumber numberWithInt:directInt] forKey:@"sofaDirect"];//沙发方向,默认为1,面向上
        
        //每一个布局重新生成一次
        [sofasetArr addObject:sofaDic];
        
        ++indexNum;
        [self screenData:screenNum];//屏幕显示
    }
    else{
    
//        NSLog(@"生成最终布局==%@",sofasetArr);
        if (sofasetArr.count == 0) {
            ++currentIndex;
            indexNum=0;
            
            [self scanData];
            
            return;
        }
        
        
        [sofaDataArr addObject:sofasetArr];
        
        //将图片保存
        DrawImageViewController *image = [DrawImageViewController new];
        UIImage *p = [image getImageByData:sofasetArr];
        [sofaImageArr addObject:p];
        
        [collection reloadData];
        
        //每个设备的下一个位置
        ++currentIndex;
        indexNum=0;
        
        [self scanData];
    }
}

//进入编辑沙发位置界面
-(void)openter
{
    
     //如果从蓝牙控制盒接口中找到存储内容，则进入配置页面（SettingViewController），否则进入沙发位布局界面（LayoutSofaViewController）
     LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
     //vc.title = @"沙发位置布局";
     [self.navigationController pushViewController:vc animated:YES];
    
}



//删除操作
-(void)opdel:(UIButton *)sender{
    
//    NSLog(@"orderArr::%@",orderArr);
    delNum = (int)sender.tag;//序号
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Are you sure to delete the layout settings?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    alert.tag =1;
    [alert show];
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        if (alertView.tag == 1) {
            if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
                
            }
            else{
                [[VWProgressHUD shareInstance] dismiss];
                [self updateLog:@"Please open Bluetooth"];
                return;
            }
            
            if ([[orderArr objectAtIndex:delNum] isEqualToString:@""]) {
//                NSLog(@"此场景无布局");
                return;
            }
            
            //开始删除
            [[VWProgressHUD shareInstance] showLoadingWithTip:@"Cleaning"];
//            NSLog(@"当前场景图序号:%d",delNum);
            
            delIndex = 0;//删除当前设备的序号
        
            /*
            //清除当前位置
            delStr = [[NSMutableString alloc] initWithString:currentScreen];
            NSLog(@"delStr===%@",delStr);
            
            [delStr replaceCharactersInRange:NSMakeRange(currentScreen.length-[[orderArr objectAtIndex:delNum] intValue], 1) withString:@"0"];
            NSLog(@"delStr1==%@",delStr);
            */
            
            isDelFlag = NO;//删除标志
            [self clearACurrentPosition];//清除设备的当前位置
        }
        else{
            if (alertView.tag == 2){
                //新建
                if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
                    
                    //进入布局界面
                    LayoutSofaViewController *vc = [[LayoutSofaViewController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else{
                    [[VWProgressHUD shareInstance] dismiss];
                    [self updateLog:@"Please open Bluetooth"];
                }
            }
        }
    }
}

-(void)clearACurrentPosition{
    
    if ([[AppDelegate shareGlobal].link isEqualToString:kCONNECTED_POWERD_ON]) {
        
    }
    else{
        [[VWProgressHUD shareInstance] dismiss];
        [self updateLog:@"Please open Bluetooth"];
        return;
    }
    
    //出现意外停止
    if (isUnexpected) {
        return ;
    }

    //获取到的蓝牙设备数量
    if (delIndex < [bleTotalArr count]) {
        //连接
        NSDictionary *bleDic = [bleTotalArr objectAtIndex:delIndex];
        //1.连接蓝牙
        [[[AppDelegate shareGlobal] manager] connectBlePeripheral:[bleDic objectForKey:@"serviceUUIDs"] identifier:[bleDic objectForKey:@"identifier"]];
    
        //2.判断状态
        [AppDelegate shareGlobal].manager.readyBlock = ^(NSString *state) {
            
            if (delIndex >= [bleTotalArr count]) {
                return ;
            }
            NSLog(@"state==%@",state);
            //连接成功之后
            if ([state isEqualToString:@"1"]) {
                
                //合成当前位置信息
                NSArray *currentSavePosition = @[@"00",@"00"];
//                NSLog(@"currentSavePosition==%@",currentSavePosition);
                
//                NSLog(@"scanTemp==%@",scanTemp);
                //将数据清空置为0
                NSMutableArray *currentSaveArr =[[NSMutableArray alloc] initWithArray:[scanTemp objectAtIndex:delIndex]];
                
                //清除哪一个场景的位置
                delStr = [[NSMutableString alloc] initWithString:[currentSaveArr objectAtIndex:0]];
//                NSLog(@"前===%@",delStr);
                [delStr replaceCharactersInRange:NSMakeRange(delStr.length-[[orderArr objectAtIndex:delNum] intValue], 1) withString:@"0"];
//                NSLog(@"后==%@",delStr);
                
                [currentSaveArr removeObjectAtIndex:[[orderArr objectAtIndex:delNum] intValue]];
                [currentSaveArr insertObject:currentSavePosition atIndex:[[orderArr objectAtIndex:delNum] intValue]];
                [currentSaveArr removeObjectAtIndex:0];//删除第一个位置信息
                NSMutableArray *delArr = [NSMutableArray new];
                for (int i = 0; i<currentSaveArr.count; i++) {
                    [delArr addObjectsFromArray:[currentSaveArr objectAtIndex:i]];
                }
//                NSLog(@"======%@",[delArr componentsJoinedByString:@""]);
                
                [self writeData:[NSString stringWithFormat:@"%@%@05%@%@%@",msgHead,msgLength,[NSString stringWithFormat:@"%@",[PZMessageUtils getHexByBinary:delStr]],[delArr componentsJoinedByString:@""],msgCRC16]];
                [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
                    
                    NSLog(@"数据最终返回=%@",array);
                    if ([[array objectAtIndex:maxPer] intValue] > maxNumber) {
                        
                        [[VWProgressHUD shareInstance] dismiss];
                        [self updateLog:@"The number of current connection has reached the upper limit"];//提示连接数辆
                        [[AppDelegate shareGlobal].manager cancelPeripheralConnection];//断开连接
//                        [self.navigationController popViewControllerAnimated:YES];
                        return ;
                    }
                    
//                    if ([[self responseData:array] intValue] == 0) {
//                        
//                        ++delIndex;
//                        [self clearACurrentPosition];//清除设备的当前位置
//                    }
                    
                    [currentSaveArr insertObject:delStr atIndex:0];
                    
                    [scanTemp removeObjectAtIndex:delIndex];
                    [scanTemp insertObject:currentSaveArr atIndex:delIndex];
                    
//                    NSLog(@"删除完毕之后scanTemp==%@",scanTemp);
                    isDelFlag = YES;
                    ++delIndex;
                    [self clearACurrentPosition];//清除设备的当前位置
                };
                
            }
            else{
                ++delIndex;
                [self clearACurrentPosition];//清除设备的当前位置
            }
        };
    }
    else{
        
        /*
        [self updateLog:@"清空成功"];
        [orderArr removeAllObjects];
        [sofaDataArr removeAllObjects];
        [sofaImageArr removeAllObjects];
        for (int i = 0; i<5; i++) {
            
            [orderArr addObject:@""];
            //将数据保存
            [sofaDataArr addObject:@""];
            //将图片保存
            [sofaImageArr addObject:@""];
        }
        
        [collection reloadData];
         */
        
        [[VWProgressHUD shareInstance] dismiss];
        
        if (isDelFlag) {
            [self updateLog:@"Delete successfully"];
            
            //        currentScreen = delStr;//将最终的传递给
            //序号数组
            [orderArr removeObjectAtIndex:delNum];
            //        NSLog(@"orderArr==%@",orderArr);
            //将数据保存
            [sofaDataArr removeObjectAtIndex:delNum];
            //        NSLog(@"sofaDataArr==%@",sofaDataArr);
            //将图片保存
            [sofaImageArr removeObjectAtIndex:delNum];
            //        NSLog(@"sofaImageArr==%@",sofaImageArr);
            
            [collection reloadData];
            
            if (orderArr.count == 0 || sofaImageArr.count == 0) {
                [self scanNoPer];
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        else{
            
            [self updateLog:@"Delete failed"];
        }
    }
   
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item == sofaImageArr.count) {
        
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Are you sure to set new layout now?" message:nil delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag =2;
        [alert show];
        
       
    }
    else{
        
        UIView *layoutsofa = [[UIView alloc] initWithFrame:CGRectMake(spaceWidth, (sHEIGHT-boxWidth *heng_box)/2, boxWidth *shu_box, boxWidth *heng_box+80)];
        //            [layoutsofa setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg"]]];
        UIImageView *bgImg =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, layoutsofa.frame.size.width, layoutsofa.frame.size.height - 80)];
        bgImg.image = [sofaImageArr objectAtIndex:indexPath.item];
        [layoutsofa addSubview:bgImg];
     
        
        if (isNeedDel) {
            //点击查看大图,下方有确定
            UIButton *cancelBtn = [[UIButton alloc] init];
            cancelBtn.frame = CGRectMake((layoutsofa.frame.size.width - 50)/2, bgImg.frame.size.height+15, 50, 50);
            cancelBtn.layer.borderColor = kUIColorFromRGB(0xffffff).CGColor;
            cancelBtn.layer.borderWidth = 2;
            cancelBtn.layer.cornerRadius = 25;
            [cancelBtn setImage:[UIImage imageNamed:@"del_bg"] forState:UIControlStateNormal];
            cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            [cancelBtn addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
            [layoutsofa addSubview:cancelBtn];
           
        }
        else{
            
            itemIndex = (int)indexPath.item;
            //不需要删除,可以点击选择大图,并且可以使用场景
            UIButton *cancelBtn = [[UIButton alloc] init];
            cancelBtn.frame = CGRectMake(layoutsofa.frame.size.width/2-30-80, bgImg.frame.size.height+20, 100, 40);
            cancelBtn.layer.borderColor = kUIColorFromRGB(0xffffff).CGColor;
            cancelBtn.layer.borderWidth = 1;
//            cancelBtn.layer.cornerRadius = 25;
//            [cancelBtn setImage:[UIImage imageNamed:@"del_bg"] forState:UIControlStateNormal];
//            cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
            [cancelBtn setTitleColor:kUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
            [cancelBtn addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
            [layoutsofa addSubview:cancelBtn];
            
            
            UIButton *OKBtn = [[UIButton alloc] init];
            OKBtn.frame = CGRectMake(layoutsofa.frame.size.width/2+30, bgImg.frame.size.height+20, 100, 40);
            OKBtn.layer.borderColor = kUIColorFromRGB(0xffffff).CGColor;
            OKBtn.layer.borderWidth = 1;
            //            cancelBtn.layer.cornerRadius = 25;
            //            [cancelBtn setImage:[UIImage imageNamed:@"del_bg"] forState:UIControlStateNormal];
            //            cancelBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
            [OKBtn setTitle:@"Enter" forState:UIControlStateNormal];
            [OKBtn setTitleColor:kUIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            OKBtn.titleLabel.font = [UIFont systemFontOfSize:17.0];
            [OKBtn addTarget:self action:@selector(okBtn) forControlEvents:UIControlEventTouchUpInside];
            [layoutsofa addSubview:OKBtn];
            
        }
        
        [LYTBackView showWithView:layoutsofa isFirst:YES];//弹出视图
    }
  
}

//取消
-(void)cancelBtn{
    [LYTBackView dissMiss];//遮罩消失
}

//进入
-(void)okBtn{
    
    [LYTBackView dissMiss];//遮罩消失
    [UIView animateWithDuration:1.0 animations:^{
        //保存到本地数据
        [[NSUserDefaults standardUserDefaults] setObject:[sofaDataArr objectAtIndex:itemIndex] forKey:[NSString stringWithFormat:@"%@_%@", SMARTMULIN,@"sofa"]];
        
        OPAPViewController *op = [OPAPViewController new];
        op.sofaArr = [sofaDataArr objectAtIndex:itemIndex];
        [self.navigationController pushViewController:op animated:YES];
    }];
   
    
}


//UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!isNeedDel) {
        if (sofaImageArr.count > 0) {
            return sofaImageArr.count + 1;
        }
        else{
            return sofaImageArr.count;
        }
    }
    else{
        return sofaImageArr.count;
    }
    
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SettingCell *cell = (SettingCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"setting" forIndexPath:indexPath];
    
//    NSString *userPhoneName = [[UIDevice currentDevice] name];

    
    
    cell.containerView.layer.borderColor = kUIColorFromRGB(0xb1b9bd).CGColor;
    cell.containerView.layer.borderWidth = 1;
    
     if (indexPath.item < sofaImageArr.count) {
         //显示序号
//         cell.nameLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.item+1];
         
         cell.nameLabel.text = [orderArr objectAtIndex:indexPath.item];
         if ([[sofaImageArr objectAtIndex:indexPath.item] isKindOfClass:[NSString class]]) {
             cell.delBtn.hidden = YES;
             cell.scaleImgView.image = nil;
         }
         else{
             cell.scaleImgView.image = [sofaImageArr objectAtIndex:indexPath.item];//显示图片
             if (isNeedDel) {
                 
                 cell.delBtn.backgroundColor = kUIColorFromRGB(0x333333);
                 cell.delBtn.layer.borderColor = kUIColorFromRGB(0x333333).CGColor;
                 cell.delBtn.layer.borderWidth = 2;
                 cell.delBtn.layer.cornerRadius = 15;
                 cell.delBtn.alpha = 0.6;
                 //显示删除按钮
//                 [cell.delBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 30, 30, 0)];
                 [cell.delBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
                 cell.delBtn.hidden = NO;
                 cell.delBtn.tag = indexPath.item;
                 [cell.delBtn addTarget:self action:@selector(opdel:) forControlEvents:UIControlEventTouchUpInside];
             }
             else{
                 cell.delBtn.hidden = YES;
             }
         }
     }
     else{
         //➕号
         cell.delBtn.hidden = YES;
         cell.nameLabel.text = @"";
         cell.scaleImgView.image = [UIImage imageNamed:@"bt_tianjiachangjing_n"];
     }
    
    return cell;
    
}



//设置每个item的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (ipad) {
        return CGSizeMake((sWIDTH-20*3)/2,350);
    }
    else{
        return CGSizeMake((sWIDTH-15*3)/2,150);
    }
    
    
}

//footer的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//header的size
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
//{
//    return CGSizeMake(10, 10);
//}

//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(10, 15, 0, 15);//上、左、下、右
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

@end
