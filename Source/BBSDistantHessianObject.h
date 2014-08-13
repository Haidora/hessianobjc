//
//  BBSDistantHessianObject.h
//  HessianObjC
//
//  Created by DaiLingchi on 14-8-12.
//  Copyright (c) 2014年 Haidora. All rights reserved.
//

#import <Foundation/Foundation.h>

#define HessianSrvPUMMR(protocolName,urlString,classMap,remoteModelPrefixString)\
	(id<protocolName>)[BBSDistantHessianObject proxyWithProtocol:@protocol(protocolName) serviceUrl:urlString classMapping:classMap remoteClassPrefix:remoteModelPrefixString]

/**
 *  DistantHessianObject
 */
@interface BBSDistantHessianObject : NSProxy
{
	@private
	Protocol *protocol;
}

@property (nonatomic, strong) NSString *urlString;
@property (nonatomic, strong) NSDictionary *classMapping;
@property (nonatomic, strong) NSString *remoteClassPrefix;

-(id)initWithProtocol:(Protocol *)aProtocol
		   serviceUrl:(NSString *)urlString
		 classMapping:(NSDictionary *)classMapping
	remoteClassPrefix:(NSString *)remoteClassPrefix;

+(BBSDistantHessianObject *)proxyWithProtocol:(Protocol *)aProtocol
								   serviceUrl:(NSString *)urlString
								 classMapping:(NSDictionary *)classMapping
							remoteClassPrefix:(NSString *)remoteClassPrefix;
@end
