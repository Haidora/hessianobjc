//
//  HessianProxy.m
//  HessianObjC

// Copyright Byron Wright, Blue Bear Studio
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "BBSHessianProxy.h"
#import "BBSHessianCall.h"
#import "BBSHessianResult.h"
#import "BBSHessianEncoder.h"
#import "BBSHessianDecoder.h"
#import "BBSHessianInvocation.h"

@implementation BBSHessianProxy

- (id)initWithUrl:(NSURL *)aServiceUrl
{
    if ((self = [super init]) != nil)
    {
        [self setServiceUrl:aServiceUrl];
    }
    return self;
}

- (void)setRemoteClassPrefix:(NSString *)aRemoteClassPrefix
{
    remoteClassPrefix = aRemoteClassPrefix;
}

- (NSURL *)serviceUrl
{
    return serviceUrl;
}

- (void)setServiceUrl:(NSURL *)aServiceUrl
{
    serviceUrl = aServiceUrl;
}

- (id)callSynchronous:(NSString *)methodName
       withParameters:(NSArray *)parameters
      timeoutInterval:(NSTimeInterval)timeoutInterval
{
    timeoutInterval = (timeoutInterval <= 0) ? 60 : timeoutInterval;

    BBSHessianCall *hessianRequest = [[BBSHessianCall alloc] initWithRemoteMethodName:methodName];
    [hessianRequest setRemoteClassPrefix:remoteClassPrefix];

    [hessianRequest setParameters:parameters];
//    //查询Cookie
//    NSString *JSESSIONIDValue = [UIApplication sharedApplication].userInfo[JSESSIONID];
//    if (JSESSIONIDValue)
//    {
//        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
//        [cookieProperties setObject:JSESSIONID forKey:NSHTTPCookieName];
//        [cookieProperties setObject:JSESSIONIDValue forKey:NSHTTPCookieValue];
//        [cookieProperties setObject:[[self serviceUrl] host] forKey:NSHTTPCookieDomain];
//        [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
//        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    }
//    else
//    {
//        NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
//        [cookieProperties setObject:JSESSIONID forKey:NSHTTPCookieName];
//        [cookieProperties setObject:@"" forKey:NSHTTPCookieValue];
//        [cookieProperties setObject:[[self serviceUrl] host] forKey:NSHTTPCookieDomain];
//        [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
//        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
//        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
//    }
    NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:[self serviceUrl]
                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                 timeoutInterval:timeoutInterval];
    // add all the paramters to the data
    [request setHTTPMethod:@"POST"];

    [request setHTTPBody:[hessianRequest data]];
    // force this header field to be text/xml... Tomcat 4 blows up otherwise
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    // [request setValue:@"" forHTTPHeaderField:(NSString *)field
    NSHTTPURLResponse *returnResponse = nil;

    NSError *requestError = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request
                                            returningResponse:&returnResponse
                                                        error:&requestError];
    if (requestError == nil)
    {
        if (returnResponse != nil)
        {
            if ([returnResponse statusCode] == 200)
            { /* all went well */
//                //保存Cookie
//                NSArray *cookies = [NSHTTPCookieStorage sharedHTTPCookieStorage].cookies;
//                [cookies enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                  NSHTTPCookie *cookie = obj;
//                  if ([JSESSIONID isEqualToString:cookie.name])
//                  {
//                      if (cookie.value)
//                      {
//                          [UIApplication sharedApplication].userInfo[JSESSIONID] = cookie.value;
//                      }
//                      *stop = YES;
//                  }
//                }];
                // deserialize the data
                BBSHessianResult *response =
                    [[BBSHessianResult alloc] initForReadingWithData:retData];
                [response setRemoteClassPrefix:remoteClassPrefix];
                id decodedObject = [response resultValue];
                return decodedObject;
            }
            else
            {
                // create an exception poo poo response from server here
                NSMutableDictionary *userInfo = [NSMutableDictionary
                    dictionaryWithObject:
                        [NSString
                            stringWithFormat:@"%i - %@", [returnResponse statusCode],
                                             [NSHTTPURLResponse localizedStringForStatusCode:
                                                                    [returnResponse statusCode]]]
                                  forKey:NSLocalizedDescriptionKey];
                // make sure it's NULL terminated
                uint8_t *readData = NULL;
                int len = [retData length] + 1;
                readData = malloc(len * sizeof(uint8_t));
                if (readData == NULL)
                {
                    NSLog(@"failed to alloc memory for binary data with len =%i", len);
                    return nil;
                }
                memset(readData, 0, len);
                [retData getBytes:(void *)readData length:[retData length]];
                NSString *details = [NSString stringWithUTF8String:(const char *)readData];
                free(readData);
                [userInfo setObject:details forKey:NSLocalizedFailureReasonErrorKey];
                return [NSError errorWithDomain:NSCocoaErrorDomain
                                           code:[returnResponse statusCode]
                                       userInfo:userInfo];
            }
        }
        else
        {
            return [NSError
                errorWithDomain:NSCocoaErrorDomain
                           code:[returnResponse statusCode]
                       userInfo:[NSDictionary dictionaryWithObject:@"Response from server is nil"
                                                            forKey:NSLocalizedDescriptionKey]];
        }
    }
    else
    {
        return requestError;
    }
    return nil;
}

- (void)callWithInvocation:(BBSHessianInvocation *)anInvocation
{

    NSMutableURLRequest *request =
        [[NSMutableURLRequest alloc] initWithURL:[self serviceUrl]
                                     cachePolicy:NSURLRequestReloadIgnoringCacheData
                                 timeoutInterval:60.0];
    // add all the paramters to the data

    [request setHTTPMethod:@"POST"];

    [request setHTTPBody:[anInvocation callData]];
    // force this header field to be text/xml... Tomcat 4 blows up otherwise
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];

    remoteConnection = [[NSURLConnection alloc] initWithRequest:request delegate:anInvocation];
    if (!remoteConnection)
    {
        // call target and selector of invocation with an error
        if ([anInvocation callbackTarget] &&
            [[anInvocation callbackTarget] respondsToSelector:[anInvocation callbackSelector]])
        {
            NSString *errorString =
                [NSString stringWithFormat:@"Failed to create a remote connection with url [%@]",
                                           [self serviceUrl]];
            NSError *err = [NSError
                errorWithDomain:NSCocoaErrorDomain
                           code:-1 /*dunno*/
                       userInfo:[NSDictionary dictionaryWithObject:errorString
                                                            forKey:NSLocalizedDescriptionKey]];
            [anInvocation performSelector:[anInvocation callbackSelector] withObject:err];
        }
    }
}

/*- (void) setClassMapping:(NSDictionary *) aClassMapping {
    [aClassMapping retain];
    [encoderClassMapping release];
    encoderClassMapping = classMapping;
    [decoderClassMapping release];
    decoderClassMapping = [[NSMutableDictionary dictionary] retain];
    NSEnumerator * e = [aClassMapping keyEnumerator];
    id current;
    //this basically switches the key value pairs around for the decoder mapping
    while(current = [e nextObject]) {
        id value = [aClassMapping objectForKey:current];
        [decoderClassMapping setObject:current forKey:value];
    }
}*/
+ (void)setClassMapping:(NSDictionary *)classMapping
{
    NSMutableDictionary *encoderMapping = [NSMutableDictionary dictionary];
    NSEnumerator *e = [classMapping keyEnumerator];
    id current;
    // this basically switches the key value pairs around for the decoder mapping
    while (current = [e nextObject])
    {
        id value = [classMapping objectForKey:current];
        [encoderMapping setObject:current forKey:value];
    }
    [BBSHessianEncoder setClassNameMapping:encoderMapping];
    [BBSHessianDecoder setClassNameMapping:classMapping];
}

+ (void)setEncoderClassMapping:(NSDictionary *)encoderMapping
{
    [BBSHessianEncoder setClassNameMapping:encoderMapping];
}
+ (void)setDecoderClassMapping:(NSDictionary *)decoderMapping
{
    [BBSHessianDecoder setClassNameMapping:decoderMapping];
}

- (void)dealloc
{
    [self setServiceUrl:nil];
    remoteConnection = nil;
}

@end
