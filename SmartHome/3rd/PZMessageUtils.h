//
//  PZMessageUtils.h
//  iso8583_demo
//
//  Created by mark zheng on 15/6/10.
//  Copyright (c) 2015年 codefunny. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "CRC.h"

@interface PZMessageUtils : NSObject

+ (NSString *)hexToAscii:(NSString *)str;

+ (NSString *)asciiToHex:(NSString *)str;

+ (NSData*) hexToBytes:(NSString *)str;

+ (NSString *)hexStringFromData:(NSData *)data;

//+ (void)showMessageHexWithData:(NSData *)data ;

+(NSString *)stringCRC16string:(NSString *)str;

/**
 十进制转换为二进制
 
 @param decimal 十进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByDecimal:(NSInteger)decimal;

/**
 十六进制转换为二进制
 
 @param binary 十六进制数
 @return 二进制数
 */
+ (NSString *)getHexByBinary:(NSString *)binary;

/**
 十进制转换十六进制
 
 @param decimal 十进制数
 @return 十六进制数
 */

+ (NSString *)getHexByDecimal:(NSInteger)decimal;

/**
 十六进制转换为二进制
 
 @param hex 十六进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByHex:(NSString *)hex;

@end
