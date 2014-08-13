//
//  HessianObjCTests.m
//  HessianObjCTests
//
//  Created by DaiLingchi on 14-8-11.
//  Copyright (c) 2014年 Haidora. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "BBSDistantHessianObject.h"

@protocol Test <NSObject>

-(NSString *)test:(NSString *)a b:(NSString *)b;

@end


@interface HessianObjCTests : XCTestCase

@end

@implementation HessianObjCTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
	BBSDistantHessianObject *object = [BBSDistantHessianObject proxyWithProtocol:@protocol(Test)];
	id<Test> test = (id<Test>)object;
	id result = [test test:@"1" b:@"2"];
	NSLog(@"%@",result);
}

@end
