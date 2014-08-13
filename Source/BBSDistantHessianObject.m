//
//  BBSDistantHessianObject.m
//  HessianObjC
//
//  Created by DaiLingchi on 14-8-12.
//  Copyright (c) 2014年 Haidora. All rights reserved.
//

#import "BBSDistantHessianObject.h"
#import "BBSHessianProxy.h"
#import <objc/runtime.h>

static NSMethodSignature* getMethodSignatureRecursively(Protocol *p, SEL aSel)
{
	NSMethodSignature* methodSignature = nil;
	struct objc_method_description md = protocol_getMethodDescription(p, aSel, YES, YES);
	if (md.name == NULL) {
		unsigned int count = 0;
		__unsafe_unretained Protocol **pList = protocol_copyProtocolList(p, &count);
		for (int index = 0; !methodSignature && index < 0; index++) {
			methodSignature = getMethodSignatureRecursively(pList[index], aSel);
		}
		free(pList);
	} else {
		methodSignature = [NSMethodSignature signatureWithObjCTypes:md.types];
	}
	return methodSignature;
}

@implementation BBSDistantHessianObject

-(id)initWithProtocol:(Protocol *)aProtocol
		   serviceUrl:(NSString *)urlString
		 classMapping:(NSDictionary *)classMapping
	remoteClassPrefix:(NSString *)remoteClassPrefix
{
	protocol = aProtocol;
	_urlString = urlString;
	_classMapping = classMapping;
	_remoteClassPrefix = remoteClassPrefix;
	return self;
}


+(BBSDistantHessianObject *)proxyWithProtocol:(Protocol *)aProtocol
								   serviceUrl:(NSString *)urlString
								 classMapping:(NSDictionary *)classMapping
							remoteClassPrefix:(NSString *)remoteClassPrefix
{
	BBSDistantHessianObject *heesianObject = [[BBSDistantHessianObject alloc]initWithProtocol:aProtocol
																				   serviceUrl:urlString
																				 classMapping:classMapping
																			remoteClassPrefix:remoteClassPrefix];
	return heesianObject;
}

#pragma mark
#pragma mark NSProxy

- (void)forwardInvocation:(NSInvocation *)invocation
{
	NSInteger numberOfArguments = [[invocation methodSignature] numberOfArguments];
#ifdef DEBUG
	NSLog(@"Forward method %@ for proxy %@", NSStringFromSelector([invocation selector]),NSStringFromProtocol(protocol));
	NSLog(@"Hessian Request Argument Start=============================\n");
	for (int i=2; i<numberOfArguments; i++)
	{
		id argument;
		[invocation getArgument:&argument atIndex:i];
		NSLog(@"\n\n%@\n\n%@\n",NSStringFromClass([argument class]),argument);
	}
	NSLog(@"Hessian Request Argument End=============================\n");
#endif
	[BBSHessianProxy setClassMapping:self.classMapping];
	BBSHessianProxy *proxy = [[BBSHessianProxy alloc]initWithUrl:[NSURL URLWithString:self.urlString]];
	[proxy setRemoteClassPrefix:self.remoteClassPrefix];
	NSString *methodName = NSStringFromSelector([invocation selector]);
	methodName = [[methodName componentsSeparatedByString:@":"] firstObject];
	NSMutableArray *arguments;
	if (numberOfArguments>2)
	{
		arguments = [NSMutableArray array];
	}
	for (int i=2; i<numberOfArguments; i++)
	{
		id argument;
		[invocation getArgument:&argument atIndex:i];
		[arguments addObject:argument];
	}
	id result = [proxy callSynchronous:methodName withParameters:arguments];
	[self setReturnValue:result invocation:invocation];
}


-(void)setReturnValue:(id)value invocation:(NSInvocation *)invocation
{
	BOOL isInvalidClass = NO;
	const char *type = [[invocation methodSignature] methodReturnType];
	if (strcmp(type, @encode(void)) == 0)
	{
		//void method not return
	}
	else if (strcmp(type, @encode(BOOL)) == 0)
	{
		if ([value isKindOfClass:[NSNumber class]])
		{
			BOOL tmp = [(NSNumber *)value boolValue];
			[invocation setReturnValue:&tmp];
		}
		else
		{
			isInvalidClass = YES;
		}
	}
	else if (strcmp(type, @encode(int32_t)) == 0)
	{
		if ([value isKindOfClass:[NSNumber class]])
		{
			int32_t tmp = [(NSNumber*)value intValue];
			[invocation setReturnValue:&tmp];
		}
		else
		{
			isInvalidClass = YES;
		}
	} else if (strcmp(type, @encode(int64_t)) == 0)
	{
		if ([value isKindOfClass:[NSNumber class]])
		{
			int64_t tmp = [(NSNumber*)value longLongValue];
			[invocation setReturnValue:&tmp];
		}
		else
		{
			isInvalidClass = YES;
		}
	} else if (strcmp(type, @encode(float)) == 0)
	{
		if ([value isKindOfClass:[NSNumber class]])
		{
			float tmp = [(NSNumber*)value floatValue];
			[invocation setReturnValue:&tmp];
		}
		else
		{
			isInvalidClass = YES;
		}
	} else if (strcmp(type, @encode(double)) == 0)
	{
		if ([value isKindOfClass:[NSNumber class]])
		{
			double tmp = [(NSNumber*)value doubleValue];
			[invocation setReturnValue:&tmp];
		}
		else
		{
			isInvalidClass = YES;
		}
	} else if (strcmp(type, @encode(id)) == 0)
	{
		if ([value isKindOfClass:[NSNull class]])
		{
			value = nil;
		}
		[invocation setReturnValue:&value];
	} else
	{
		[NSException raise:NSInvalidUnarchiveOperationException format:@"Unsupported type %s", type];
	}
	
	if (isInvalidClass)
	{
		[NSException raise:NSInvalidUnarchiveOperationException format:@"Invalid type %@", NSStringFromClass([value class])];
	}
}

-(NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	if (sel != _cmd && ![NSStringFromSelector(sel) hasPrefix:@"_cf"])
	{
		NSMethodSignature *signature = getMethodSignatureRecursively(protocol, sel);
		return signature;
	}
	else
	{
		return nil;
	}
}

@end
