//
//  ProfileViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/7/4.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "ProfileViewController.h"
#import "SettingViewController.h"

@interface ProfileViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *opArr;
}

@end

@implementation ProfileViewController
@synthesize sofaArr;

//返回上一层
-(void)popToPre{
    
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"bg"] forBarMetrics:UIBarMetricsDefault];
    
    self.title =@"Settings";
    
    //背景图片
    UIImageView *bgImg = [UIImageView new];
    bgImg.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.mas_equalTo(0);
    }];
    /*
    //返回按钮
    UIView *customView=[[UIView alloc] initWithFrame:CGRectMake(0, 0,50,40)];
    customView.backgroundColor=[UIColor clearColor];
    UIImageView *img=[[UIImageView alloc] initWithFrame:CGRectMake(0, (40-24)/2, 34,24)];
    img.image=[UIImage imageNamed:@"bt_back"];
    [customView addSubview:img];
    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame=customView.bounds;
    [btn addTarget:self action:@selector(popToPre) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:btn];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:customView];
    self.navigationItem.leftBarButtonItem = backItem;
    */
    //@"场景设置",@"故障协助及上报",@"软件帮助",@"配件服务",@"清除缓存"
    opArr = @[@"Scene-setting",@"Failure checking and reporting",@"Instruction for use",@"Reconnect"];
    
    UITableView *tab = [UITableView new];
    tab.delegate = self;
    tab.dataSource = self;
    tab.backgroundColor = [UIColor clearColor];
    [tab setScrollEnabled:NO];
    [tab setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:tab];
    [tab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.mas_equalTo(0);
    }];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return opArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 120;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sWIDTH, 120.0)];
    view.backgroundColor = [UIColor clearColor];//kUIColorFromRGB(0xf6f6f6);
    
    
    
    UIView *view_bg = [[UIView alloc] initWithFrame:CGRectMake(0, 15, sWIDTH, 90)];
    view_bg.backgroundColor =[UIColor whiteColor];
    
    
    UILabel *line1=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, sWIDTH, 0.5)];
    line1.backgroundColor =[UIColor lightGrayColor];
    [view_bg addSubview:line1];
    
    /*
    UIImageView *head =[[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 60, 60)];
    head.image =[UIImage imageNamed:@"AppIcon"];
    head.layer.cornerRadius = 30.0;
    head.layer.borderWidth = 1;
    head.layer.borderColor = kUIColorFromRGB(0xb1b9bd).CGColor;
    [view_bg addSubview:head];
    */
    
    NSString* userPhoneName = [[UIDevice currentDevice] name];
//    NSLog(@"手机别名: %@", userPhoneName);
    
    UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(15, (90-20)/2, sWIDTH, 20)];
    nameLabel.text = userPhoneName;
    nameLabel.font = [UIFont systemFontOfSize:15.0];
    nameLabel.textColor =kUIColorFromRGB(0x333333);
    [view_bg addSubview:nameLabel];
    
    /*
    UILabel *desLabel=[[UILabel alloc] initWithFrame:CGRectMake(90, 50, sWIDTH, 20)];
    desLabel.text = @"当前设备号为:xxxxxxx";
    desLabel.font = [UIFont systemFontOfSize:14.0];
    desLabel.textColor =kUIColorFromRGB(0x333333);
    [view_bg addSubview:desLabel];
    */
    
    UILabel *line2=[[UILabel alloc] initWithFrame:CGRectMake(0, view_bg.frame.size.height-0.5, sWIDTH, 0.5)];
    line2.backgroundColor =[UIColor lightGrayColor];
    [view_bg addSubview:line2];

    
    
    
    [view addSubview:view_bg];
    
    
    
    UILabel *line3=[[UILabel alloc] initWithFrame:CGRectMake(0, view.frame.size.height-0.5, sWIDTH, 0.5)];
    line3.backgroundColor =[UIColor lightGrayColor];
    [view addSubview:line3];
    
    return view;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    return 50;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIndefiner=@"my_cell";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellIndefiner];
    
    if (cell==nil)
    {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndefiner];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
//    cell.contentView.backgroundColor = [UIColor clearColor];
//    cell.backgroundColor = [UIColor clearColor];
    cell.imageView.image =[UIImage imageNamed:@"Resize"];
    cell.textLabel.text = [opArr objectAtIndex:indexPath.row];
    /*
    if (indexPath.row ==0) {
        
        
    }
    else if (indexPath.row ==1) {
        cell.imageView.image =[UIImage imageNamed:@"Resize"];
        cell.textLabel.text = @"沙发测试";
    }
    else if(indexPath.row == 2){
        cell.imageView.image =[UIImage imageNamed:@"Resize"];
        cell.textLabel.text = @"删除缓存,重新搜索连接";
    }
    else{
        cell.imageView.image =[UIImage imageNamed:@"Resize"];
        cell.textLabel.text = @"测试";
    }
   */
    
    
    return cell;
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        
        SettingViewController *setting = [SettingViewController new];
        setting.isNeedDel = YES;
        [self.navigationController pushViewController:setting animated:YES];
        
        /*
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"This feature is under development. Please stay tuned." message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
         */
        
    }
    else if (indexPath.row == 1) {
        SofaBrokenTestViewController *broken = [SofaBrokenTestViewController new];
        broken.title=@"Failure checking and reporting";
        broken.sofaArr = sofaArr;
        [self.navigationController pushViewController:broken animated:YES];
        
    }
    else if(indexPath.row == 2){
        /*
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"是否确认删除本地缓存？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alert.tag =1;
        [alert show];
        */
        
        
        /*
        //发03指令
        [self writeData:[NSString stringWithFormat:@"%@%@03%@%@%@",msgHead,msgLength,msgType,@"01",msgCRC16]];
        [AppDelegate shareGlobal].manager.dataBlock=^(NSMutableArray *array){
            
            NSLog(@"数据返回：read=02=%@",array);
            
            if ([[[array objectAtIndex:0] uppercaseString] isEqualToString:@"AA"] && [[[array objectAtIndex:1] uppercaseString] isEqualToString:@"AA"] && [[[array objectAtIndex:4] uppercaseString] isEqualToString:@"04"]) {
                
                
                
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:SMARTMULIN];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@", SMARTMULIN,@"sofa"]];
                
                
                HomeViewController *home =[[HomeViewController alloc] init];
                [self.navigationController pushViewController:home animated:YES];
                
            }
        };
         */
        
        IntroduceViewController *intro = [IntroduceViewController new];
        intro.title = @"Instruction for use";
        [self.navigationController pushViewController:intro animated:YES];
        
        
    }
    else if(indexPath.row == 3){
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Reconnect？" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
        alert.tag =1;
        [alert show];
    }
    else{
        
        /*
        TestViewController *test = [TestViewController new];
        test.title = @"测试";
        [self.navigationController pushViewController:test animated:YES];
         */
        
        
        
        
    }
    
    
}



-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [[VWProgressHUD shareInstance] showLoadingWithTip:@"Cleaning"];
        
        if (alertView.tag == 1) {
            
            [AppDelegate shareGlobal].bleListArr = nil;
//            [[[AppDelegate shareGlobal] manager]  cancelPeripheralConnection];
            [[[AppDelegate shareGlobal] manager] disAllBle];//断开所有蓝牙
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:SMARTMULIN];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@_%@", SMARTMULIN,@"sofa"]];
            for (int i = 0; i<sofaArr.count; i++) {
                //09287BAC-9402-4C66-9D73-56B1062C044F021
                //09287BAC-9402-4C66-9D73-56B1062C044F022
                //                NSLog(@"====%@",[NSString stringWithFormat:@"%@%@%@", [[sofaArr objectAtIndex:i] objectForKey:@"identifier"],@"01",@"0"]);
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@%@", [[sofaArr objectAtIndex:i] objectForKey:@"identifier"],@"01",@"1"]];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@%@", [[sofaArr objectAtIndex:i] objectForKey:@"identifier"],@"01",@"2"]];
                
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@%@", [[sofaArr objectAtIndex:i] objectForKey:@"identifier"],@"02",@"1"]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@%@", [[sofaArr objectAtIndex:i] objectForKey:@"identifier"],@"02",@"2"]];
            }
            
            [AppDelegate shareGlobal].bleListArr = nil;
            
            //清除本地
            [self performSelector:@selector(clearLocal) withObject:nil afterDelay:0.5];
        
        }
     
        
    }
}

//清除本地
-(void)clearLocal{
    
    [[VWProgressHUD shareInstance] dismiss];
    
    HomeViewController *home =[[HomeViewController alloc] init];
    [self.navigationController pushViewController:home animated:YES];
}


@end
