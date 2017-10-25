//
//  PZMessageUtils.m
//  iso8583_demo
//
//  Created by mark zheng on 15/6/10.
//  Copyright (c) 2015年 codefunny. All rights reserved.
//

#import "PZMessageUtils.h"
//#import "dl_output.h"

@implementation PZMessageUtils

+ (NSString *)hexToAscii:(NSString *)str {
    NSData    *hexData = [self hexToBytes:str];
    NSString  *asciiStr = [[NSString alloc] initWithData:hexData encoding:NSASCIIStringEncoding];

    return asciiStr;
}

+ (NSString *)asciiToHex:(NSString *)str {
    NSData  *hexData = [str dataUsingEncoding:NSASCIIStringEncoding];
    NSString    *hexStr = [self hexStringFromData:hexData];
    
    return hexStr;
}

+ (NSData*) hexToBytes:(NSString *)str
{
    NSMutableData* data = [NSMutableData data];
    
    int idx;
    for (idx = 0; idx+2 <= str.length; idx+=2) {
        
        NSRange range = NSMakeRange(idx, 2);
        
        NSString* hexStr = [str substringWithRange:range];
        
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        
        unsigned int intValue;
        
        [scanner scanHexInt:&intValue];
        
        [data appendBytes:&intValue length:1];
        
    }
    
    return data;
}

+ (NSString *)hexStringFromData:(NSData *)data
{
    NSMutableString *str = [NSMutableString string];
    
    Byte *byte = (Byte *)[data bytes];
    
    for (int i = 0; i<[data length]; i++) {
        // byte+i为指针
        [str appendString:[self stringFromByte:*(byte+i)]];
    }
    
    return str;
}

+ (NSString *)stringFromByte:(Byte)byteVal
{
    NSMutableString *str = [NSMutableString string];
    
    //取高四位
    Byte byte1 = byteVal>>4;
    
    //取低四位
    Byte byte2 = byteVal & 0xf;
    
    //拼接16进制字符串
    [str appendFormat:@"%x",byte1];
    [str appendFormat:@"%x",byte2];
    
    return str;
}

//+ (void)showMessageHexWithData:(NSData *)data {
//    DL_UINT8 *bytes = (DL_UINT8 *)[data bytes];
//    DL_OUTPUT_Hex(stdout, NULL, bytes, (DL_UINT32)data.length);
//}

//将字符串通过crc16加密返回
+(NSString *)stringCRC16string:(NSString *)str
{
    
//    NSData *hexdata = [PZMessageUtils hexToBytes:str];
//    
//    NSData *crcData =[self calCRCWithData:hexdata];
//    NSLog(@"crcdata::%@",crcData);
    
    /*
    //将字符串转换成16进制
    unsigned char test[str.length/2];
   
    unsigned char c =CheckCRC([hexdata bytes], sizeof(test));
    
  
    
    for (int i =0 ; i<sizeof(test); i+2) {
        
        test[i]=[NSString stringWithFormat:@"%x",NSMakeRange(i, 2)];
    }
//    test[0]=0x55;
//    test[1]=0x55;
//    test[2]=0x00;
//    test[3]=0x08;
//    test[4]=0x01;
//    test[5]=0x00;
//    
//    NSLog(@"sizeof(test)::%d",sizeof(test));
    
    //            NSLog(@"ccc====%x===%c",c,test[0]);
    
    for (int i = 0; i <sizeof(test); i++) {
        NSLog(@"%c", test[i]);
        NSString *string = [NSString stringWithFormat:@"%02lx", test[i]];
        NSLog(@"string::%@",string);
        
    }
*/
    
    return @"2222";
    
}




 #pragma mark - 将字符表示的16进制数转化为二进制数据
 - (NSMutableData *)dataWithHexString:(NSString *)hexString
 {
     if (!hexString || [hexString length] == 0) {
         return nil;
     }
 
     NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
     NSRange range;
     if ([hexString length] % 2 == 0) {
         range = NSMakeRange(0, 2);
     } else {
         range = NSMakeRange(0, 1);
     }
     for (NSInteger i = range.location; i < [hexString length]; i += 2) {
         unsigned int anInt;
         NSString *hexCharStr = [hexString substringWithRange:range];
         NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
 
         [scanner scanHexInt:&anInt];
         NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
         [hexData appendData:entity];
 
        range.location += range.length;
        range.length = 2;
    }
 
     return hexData;
 }
 
 
 #pragma mark - 将16进制字符串转成NSData+CRC数据
 + (NSData *)calCRCWithData:(NSData *)visibleData
 {
     //将16进制字符串转成NSData数据
     NSMutableData *visibleDataM = [visibleData mutableCopy];
     //    Byte byte[5] = {0x00,0xc0,0x00,0x00,0x32};
//     NSLog(@"visibleDataM==::%@",visibleDataM);
 
     //NSData做crc验证得到short返回值
     Byte *byte = (Byte *)[visibleDataM bytes];
//     NSLog(@"byte::%s",byte);
//     NSLog(@"(int)visibleDataM.length==%d",(int)visibleDataM.length);
     unsigned char crcShort = CheckCRC(byte, (int)visibleDataM.length+2);
     //将short返回值转成byte类型添加到可变数组末尾
     Byte bytes[2];
     bytes[0] = (Byte) (crcShort >> 8);
     bytes[1] = (Byte) (crcShort);
 
     [visibleDataM appendBytes:bytes length:sizeof(bytes)];
 
     return visibleDataM;
 }

/**
 十进制转换为二进制
 
 @param decimal 十进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByDecimal:(NSInteger)decimal {
    NSString *binary = @"";
    while (decimal) {
        binary = [[NSString stringWithFormat:@"%ld", decimal % 2] stringByAppendingString:binary];
        if (decimal / 2 < 1)
        {
            break;
        }
        decimal = decimal / 2 ;
    }
    if (binary.length % 4 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    return binary;
}


/**
 十六进制转换为二进制
 
 @param binary 二进制
 @return 二进制数
 */
+ (NSString *)getHexByBinary:(NSString *)binary {
    NSMutableDictionary *binaryDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    [binaryDic setObject:@"0" forKey:@"0000"];
    [binaryDic setObject:@"1" forKey:@"0001"];
    [binaryDic setObject:@"2" forKey:@"0010"];
    [binaryDic setObject:@"3" forKey:@"0011"];
    [binaryDic setObject:@"4" forKey:@"0100"];
    [binaryDic setObject:@"5" forKey:@"0101"];
    [binaryDic setObject:@"6" forKey:@"0110"];
    [binaryDic setObject:@"7" forKey:@"0111"];
    [binaryDic setObject:@"8" forKey:@"1000"];
    [binaryDic setObject:@"9" forKey:@"1001"];
    [binaryDic setObject:@"A" forKey:@"1010"];
    [binaryDic setObject:@"B" forKey:@"1011"];
    [binaryDic setObject:@"C" forKey:@"1100"];
    [binaryDic setObject:@"D" forKey:@"1101"];
    [binaryDic setObject:@"E" forKey:@"1110"];
    [binaryDic setObject:@"F" forKey:@"1111"];
    if (binary.length % 4 != 0) {
        NSMutableString *mStr = [[NSMutableString alloc]init];;
        for (int i = 0; i < 4 - binary.length % 4; i++) {
            [mStr appendString:@"0"];
        }
        binary = [mStr stringByAppendingString:binary];
    }
    
    NSString *hex = @"";
    for (int i=0; i<binary.length; i+=4){
        NSString *key = [binary substringWithRange:NSMakeRange(i, 4)];
        NSString *value = [binaryDic objectForKey:key];
        if (value) {
            hex = [hex stringByAppendingString:value];
        }
    }
    return hex;
}


/**
 十进制转换十六进制
 
 @param decimal 十进制数
 @return 十六进制数
 */
+ (NSString *)getHexByDecimal:(NSInteger)decimal {
     NSString *hex =@"";
     NSString *letter;
     NSInteger number;
     for (int i = 0; i<9; i++) {
         number = decimal % 16;
         decimal = decimal / 16;
         switch (number) {
             case 10:
                 letter =@"A";
                 break;
             case 11:
                 letter =@"B";
                 break;
             case 12:
                 letter =@"C";
                 break;
             case 13:
                 letter =@"D";
                 break;
             case 14:
                 letter =@"E";
                 break;
             case 15:
                 letter =@"F";
                 break;
            default:
                 letter = [NSString stringWithFormat:@"%ld", number];
         }
         hex = [letter stringByAppendingString:hex];
         if (decimal == 0) {
             break;
         }
     }
     
     return hex;
 }


/**
 十六进制转换为二进制
 
 @param hex 十六进制数
 @return 二进制数
 */
+ (NSString *)getBinaryByHex:(NSString *)hex {
     NSMutableDictionary *hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
     [hexDic setObject:@"0000" forKey:@"0"];
     [hexDic setObject:@"0001" forKey:@"1"];
     [hexDic setObject:@"0010" forKey:@"2"];
     [hexDic setObject:@"0011" forKey:@"3"];
     [hexDic setObject:@"0100" forKey:@"4"];
     [hexDic setObject:@"0101" forKey:@"5"];
     [hexDic setObject:@"0110" forKey:@"6"];
     [hexDic setObject:@"0111" forKey:@"7"];
     [hexDic setObject:@"1000" forKey:@"8"];
     [hexDic setObject:@"1001" forKey:@"9"];
     [hexDic setObject:@"1010" forKey:@"A"];
     [hexDic setObject:@"1011" forKey:@"B"];
     [hexDic setObject:@"1100" forKey:@"C"];
     [hexDic setObject:@"1101" forKey:@"D"];
     [hexDic setObject:@"1110" forKey:@"E"];
     [hexDic setObject:@"1111" forKey:@"F"];
     NSString *binary = @"";
     for (int i=0; i<[hex length]; i++) {
         NSString *key = [hex substringWithRange:NSMakeRange(i, 1)];
         NSString *value = [hexDic objectForKey:key.uppercaseString];
         if (value) { binary = [binary stringByAppendingString:value];
         }
     }
     return binary;
 }


@end
