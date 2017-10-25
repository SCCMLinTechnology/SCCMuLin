//
//  IntroduceViewController.m
//  SmartHome
//
//  Created by 晁广喜 on 2017/9/4.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#import "IntroduceViewController.h"

@interface IntroduceViewController ()

@end

@implementation IntroduceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    //按钮
    UIButton * enBtn = [UIButton new];
    [enBtn setBackgroundImage:[UIImage imageNamed:@"bt_engliash_n"] forState:UIControlStateNormal];
    enBtn.tag = 1;
    [enBtn addTarget:self action:@selector(translateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enBtn];
    [enBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view.mas_centerY).offset(-50);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(150, 77));
    }];
    
    
    UIButton * cnBtn = [UIButton new];
    [cnBtn setBackgroundImage:[UIImage imageNamed:@"bt_zhongwenban_n"] forState:UIControlStateNormal];
    cnBtn.tag = 2;
    [cnBtn addTarget:self action:@selector(translateBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cnBtn];
    [cnBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(enBtn.mas_top).offset(-50);
        make.centerX.mas_equalTo(self.view.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(150, 77));
    }];
    
    
}

-(void)translateBtn:(UIButton *)sender{
    
    UserOPViewController *user = [UserOPViewController new];
    if (sender.tag == 1) {
        user.language = @"1";//英文
    }
    else{
        user.language = @"2";//中文
    }
    user.title = self.title;
    [self.navigationController pushViewController:user animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
