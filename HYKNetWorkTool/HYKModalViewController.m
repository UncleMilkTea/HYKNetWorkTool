//
//  HYKModalViewController.m
//  
//
//  Created by 侯玉昆 on 16/2/24.
//  Copyright © 2016年 侯玉昆. All rights reserved.
//

#import "HYKModalViewController.h"
#import "HYKNetWorkTool.h"

@interface HYKModalViewController ()

@property(strong,nonatomic) NSString *urlStr;

@end

@implementation HYKModalViewController



+ (instancetype)controllerWithUrlStr:(NSString *)urlStr{
    
    HYKModalViewController *modalVC = [[HYKModalViewController alloc] init];
    
    modalVC.urlStr = urlStr;
    
    return modalVC;

}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [[HYKNetWorkTool sharedNetWork] loadWebPageWithUrlStr:self.urlStr addView:self.view];
    
   UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [btn setTitle:@"关闭" forState:UIControlStateNormal];
    
    btn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40, 20, 40, 20);
    
    [self.view addSubview:btn];
    
    [self.view bringSubviewToFront:btn];
    
    
    
//设置导航栏item
    
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(clickButton)];
    
    [btn addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)clickButton {

    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
