//
//  DetailViewController.m
//  DemoOfGetContact
//
//  Created by 吴 吴 on 15/10/13.
//  Copyright © 2015年 吴 吴. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
{
    UIImageView *icon;
    UILabel *phoneLbl;
}

@end

@implementation DetailViewController

- (id)init {
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.tempContact.givenName;
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    [self uploadDataReq];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 创建UI

- (void)setupUI {
    
    float originX = ([UIScreen mainScreen].bounds.size.width - 96)/2;
    float y = 84;
    icon = [[UIImageView alloc]initWithFrame:CGRectMake(originX, y, 96, 96)];
    icon.backgroundColor = [UIColor clearColor];
    icon.layer.cornerRadius = 50.0;
    icon.layer.masksToBounds = YES;
    icon.userInteractionEnabled = YES;
    [self.view addSubview:icon];
    
    y+=96;
    y+=14;
    
    float phoneLblX = ([UIScreen mainScreen].bounds.size.width - 200)/2;
    phoneLbl = [[UILabel alloc]initWithFrame:CGRectMake(phoneLblX, y, 200, 16)];
    phoneLbl.font = [UIFont systemFontOfSize:16];
    phoneLbl.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:phoneLbl];
    
    UITapGestureRecognizer *iconGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconPressed)];
    [icon addGestureRecognizer:iconGes];
}

#pragma mark - 按钮点击事件

- (void)iconPressed {
    
    NSString *phone = phoneLbl.text;
    NSString *title = [NSString stringWithFormat:@"拨打电话:%@",phone];
    UIAlertController *alerVC = [UIAlertController alertControllerWithTitle:title message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSMutableString *str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }];
    [alerVC addAction:ok];
    [alerVC addAction:cancel];
    [self presentViewController:alerVC animated:YES completion:NULL];
}

#pragma mark - 数据源

- (void)uploadDataReq {
    if (self.tempContact.imageData)
    {
        icon.image = [UIImage imageWithData:self.tempContact.imageData];
    }
    else
    {
        icon.image = [UIImage imageNamed:@"contact"];
    }
    
    NSString *phone = ((CNPhoneNumber *)(self.tempContact.phoneNumbers.lastObject.value)).stringValue;
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"+86 " withString:@""];
    phoneLbl.text = phone;
}

@end
