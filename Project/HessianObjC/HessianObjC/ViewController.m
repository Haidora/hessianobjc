//
//  ViewController.m
//  HessianObjC
//
//  Created by DaiLingchi on 14-8-11.
//  Copyright (c) 2014年 Haidora. All rights reserved.
//

#import "ViewController.h"
#import "BBSDistantHessianObject.h"

@protocol Test <NSObject>

-(NSString *)test:(NSString *)testa b:(NSString *)testb;
-(void)testa;

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

 id<Test> test = 	HessianSrvPUMMR(Test, @"", nil, nil);
	[test test:@"1" b:@"2"];
	[test testa];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
