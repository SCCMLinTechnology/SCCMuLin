//
//  BLEModel.m
//  BLEDemo
//
//  Created by Longma on 17/5/11.
//  Copyright © 2017年 ZhangK. All rights reserved.
//

#import "BLEModel.h"
#import "BLEIToll.h"


//#include "CRC.h"

@interface BLEModel ()<CBCentralManagerDelegate,CBPeripheralDelegate>{
    
    NSMutableArray *bleListArr;
    BOOL isFirstScan;
    
    NSString *identifierPeripheral;
    NSString *serviceUUIDsPeripheral;
    
    NSArray *storeBLEArr;
}
/**
 *  蓝牙连接必要对象
 */
@property (nonatomic, strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) CBCharacteristic* writeCharacteristic;
@property (strong, nonatomic) CBCharacteristic* readCharacteristic;


@property (nonatomic,assign) BOOL isInitiativeDisconnect;//主动断开连接



@end


@implementation BLEModel

- (instancetype)init
{
    self = [super init];
    if (self) {
//        建立一个Central Manager实例进行蓝牙管理
        _centralMgr = [[CBCentralManager alloc]initWithDelegate:self queue:dispatch_get_main_queue()];

    }
    return self;
}

/**
 *  开始扫描
 */

- (void)startScan{
    _centralMgr = [[CBCentralManager alloc]initWithDelegate:self queue:nil];

}

/**
 *  停止扫描
 */
-(void)stopScan
{
    [_centralMgr stopScan];
    
}

-(void)scanMgr{
    
    isFirstScan = YES;
//    [self stopScan];
    bleListArr = [NSMutableArray new];
//    NSLog(@"ssss == %@",_centralMgr);
    [_centralMgr scanForPeripheralsWithServices:nil options:nil];
}

#pragma mark - 蓝牙的状态 //只要中心管理者初始化 就会触发此代理方法 判断手机蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStateUnknown:
        {
            //NSLog(@"无法获取设备的蓝牙状态");
            self.connectState = kCONNECTED_UNKNOWN_STATE;
        }
            break;
        case CBManagerStateResetting:
        {
            //NSLog(@"蓝牙重置");
            self.connectState = kCONNECTED_RESET;
        }
            break;
        case CBManagerStateUnsupported:
        {
            //NSLog(@"该设备不支持蓝牙");
            self.connectState = kCONNECTED_UNSUPPORTED;
        }
            break;
        case CBManagerStateUnauthorized:
        {
            //NSLog(@"未授权蓝牙权限");
            self.connectState = kCONNECTED_UNAUTHORIZED;
        }
            break;
        case CBManagerStatePoweredOff:
        {
            //NSLog(@"蓝牙已关闭");
            self.connectState = kCONNECTED_POWERED_OFF;
//            [self stopScan];//停止搜索
        }
            break;
        case CBManagerStatePoweredOn:
        {
//            NSLog(@"蓝牙已打开");
            self.connectState = kCONNECTED_POWERD_ON;
            [self stopScan];//停止搜索
            bleListArr = [NSMutableArray new];
            
            isFirstScan = YES;
            
//            NSLog(@"sssseeee == %@",_centralMgr);
            // 搜索外设,如果第一个参数设置为nil,则寻找所有服务
//            _centralMgr.delegate =self;
            [_centralMgr scanForPeripheralsWithServices:nil options:nil];
            
        }
            break;
            
        default:
        {
            //NSLog(@"未知的蓝牙错误");
            self.connectState = kCONNECTED_ERROR;
        }
            break;
    }
    self.linkBlcok(self.connectState);
    //[self getConnectState];
    
}



#pragma mark -- CBCentralManagerDelegate
#pragma mark- 扫描设备，连接   搜索成功之后,会调用我们找到外设的代理方法
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"name==:%@----%@---==%ld",peripheral.name,advertisementData,(long)[RSSI integerValue]);
  
    /**
     当扫描到蓝牙数据为空时,停止扫描
     */
    if (!peripheral || !peripheral.name || ([peripheral.name isEqualToString:@""])) {
        return;
    }
    
    /**
     当扫描到服务UUID与设备UUID相等时,进行蓝牙与设备链接
     */
    //&& [RSSI integerValue] > -100 && [RSSI integerValue] < 0
    //通过过滤。筛选出我们需要连接的外设,通过蓝牙名称为PMServiceName
    if ((!self.discoveredPeripheral || (self.discoveredPeripheral.state == CBPeripheralStateDisconnected)) && ([[advertisementData objectForKey:@"kCBAdvDataLocalName"] isEqualToString:PMServiceName])) {
        //-127~127
//        NSLog(@"advertisementData==%@",advertisementData);
//        [service.UUID UUIDString]
//        NSLog(@"connect peripheral:  %@",peripheral);
        
        if (isFirstScan) {
            if([[advertisementData allKeys] containsObject:@"kCBAdvDataServiceUUIDs"] && [[advertisementData allKeys] containsObject:@"kCBAdvDataManufacturerData"]){
                
                /*
                 NSArray *services = [peripheral services];
                 NSLog(@"%@",services);
                 for (CBService *service in services) {
                 
                 NSLog(@"该设备的service:%@",service);
                 }
                 */
                /*
                 kCBAdvDataIsConnectable = 1;
                 kCBAdvDataLocalName = MulinDev;
                 kCBAdvDataManufacturerData = <aaff125e ccfa51e8>;
                 kCBAdvDataServiceUUIDs =     (
                    "00001523-0102-0700-1C00-000000000000"
                 );
                 */
                
                //扫描到kCBAdvDataServiceUUIDs
                NSString *serviceUUIDs = [NSString stringWithFormat:@"%@",[[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"] objectAtIndex:0] ];
                //            NSLog(@"serviceUUIDs==%@",serviceUUIDs);
                
                NSMutableDictionary *temp =[NSMutableDictionary new];
                [temp setObject:serviceUUIDs forKey:@"serviceUUIDs"];
                [temp setObject:peripheral forKey:@"peripheral"];
                [temp setObject:[peripheral.identifier UUIDString] forKey:@"identifier_temp"];
                
                
                NSString *mac = [PZMessageUtils hexStringFromData:[advertisementData objectForKey:@"kCBAdvDataManufacturerData"]];
                //NSLog(@"mac==%@",mac);
                
                // 字符串查找：查询某个string的范围信息，使用一个结构体NSRange包含两个成员变量：location(要查找的起始位置)和length（从当前位置向后数多长）.
                NSRange range = [mac rangeOfString:@"aaff"];
                //                NSLog(@"location = %ld, length = %ld", range.location, range.length);
                //获取mac地址
                [temp setObject:[[mac substringFromIndex:range.location] substringToIndex:2*8] forKey:@"identifier"];
                
                
//                UIAlertView *alert =[[UIAlertView alloc] initWithTitle:serviceUUIDs message:mac delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//                
//                [alert show];
                
                
                //如果服务器的serviceUUIDs == 4
                if (serviceUUIDs.length == 4 ) {
                    //V1.8.0
                     [temp setObject:[[mac substringFromIndex:2*8] substringToIndex:2] forKey:@"per_number"];//设备个数
                    
                     [temp setObject:[[mac substringFromIndex:2*8+2] substringToIndex:16] forKey:@"uuids"];
                
                    //设备id
                     [temp setObject:[[mac substringFromIndex:(mac.length - 12)] substringToIndex:12] forKey:@"peripheralID"];
                }
                else{
                    
                    NSString *uuids = [[[serviceUUIDs substringFromIndex:9] substringToIndex:14] stringByReplacingOccurrencesOfString:@"-" withString:@""];
                    //            NSLog(@"uuids==%@",uuids);
                    [temp setObject:uuids forKey:@"uuids"];
                    
                    //如果字符个数大于8个字节
                    if (mac.length > 2*8) {
                        if (range.location == 0) {
                            [temp setObject:[[mac substringFromIndex:2*8] substringToIndex:2] forKey:@"per_number"];//设备个数
                        }
                        else{
                            [temp setObject:[[mac substringFromIndex:0] substringToIndex:2]  forKey:@"per_number"];//设备个数
                        }
                    }
                    else{
                        [temp setObject:@"00" forKey:@"per_number"];//设备个数
                    }
                }
            
                BOOL isFlag = NO;
                for (int i = 0; i<bleListArr.count; i++) {
                    if ([[[bleListArr objectAtIndex:i] objectForKey:@"identifier"] isEqualToString:[temp objectForKey:@"identifier"]]) {
                        isFlag = YES;
                        break;
                    }
                }
                
                if (!isFlag) {
                    [bleListArr addObject:temp];
                    storeBLEArr = [[NSArray alloc] initWithArray:bleListArr];
                }
            }
            
            self.listBlock(bleListArr);//返回蓝牙列表
        }
        /*
        else{
            
//            NSLog(@"====%@",[peripheral.identifier UUIDString]);
            if ([identifierPeripheral isEqualToString:[peripheral.identifier UUIDString]]) {
                
//                NSLog(@"不是第一次进入了。。。。");
                self.discoveredPeripheral = [peripheral copy];
                //直接连接
                [self.centralMgr connectPeripheral:peripheral options:nil];
            }
            else{
//                NSLog(@"identifier验证不通过。。。");
            }
        }
         */
        
    }
}

//-(void)connectBlePeripheral:(CBPeripheral *)peripheral
//点击连接蓝牙设备
-(void)connectBlePeripheral:(NSString *)serviceUUIDs identifier:(NSString *)identifier{
    
    isFirstScan = NO;
    identifierPeripheral = [identifier copy];
    serviceUUIDsPeripheral = [serviceUUIDs copy];
    /*
    [self stopScan];//停止扫描
    [self cancelPeripheralConnection];//断开蓝牙连接
    */
    
    
    //使用identifier坐判断当前蓝牙
    BOOL perBoolten = NO;
    CBPeripheral *per = nil;
//    NSLog(@"blearr==%@===peripheral==%@",storeBLEArr,identifier);
    for (int i=0; i<storeBLEArr.count; i++) {
       per = (CBPeripheral *)[[storeBLEArr objectAtIndex:i] objectForKey:@"peripheral"];
        //[per.identifier UUIDString]
        if ([[[storeBLEArr objectAtIndex:i] objectForKey:@"identifier"] isEqualToString:identifier]) {
            perBoolten = YES;
            break;
        }
    }
    
    if (per != nil && perBoolten) {
        
//        NSLog(@"准备连接蓝牙");
        self.discoveredPeripheral = [per copy];
        self.isInitiativeDisconnect = NO;
        
        [self performSelector:@selector(timeoutConnect) withObject:nil afterDelay:1.5];
        // 发现完之后就是进行连接
        [self.centralMgr connectPeripheral:per options:nil];
    }
    else{
        /*
        //提示弹出框
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"无匹配相应蓝牙" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
        [alert show];
         */
//        NSLog(@"无匹配蓝牙");
        self.noPeripheralBlock(@"1");//返回无匹配相应蓝牙
    }
    
    
    
    /*
    self.discoveredPeripheral = [peripheral copy];
    // 发现完之后就是进行连接
    [self.centralMgr connectPeripheral:peripheral options:nil];
     */
    
}


#pragma park- 连接成功,扫描services
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    NSLog(@"2222ssss");
    if (!peripheral) {
//        NSLog(@"到了这里");
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutConnect) object:nil];
    
    [self.centralMgr stopScan];  //连接成功之后，停止扫描，如果不停止，支持一对多连接
    
//    self.stateBlock(BLEState_Successful,[peripheral.identifier UUIDString],0);   //连接成功，返回连接成功状态
    
    for (int i=0; i<storeBLEArr.count; i++) {
        if ([[[storeBLEArr objectAtIndex:i] objectForKey:@"identifier_temp"] isEqualToString:[peripheral.identifier UUIDString]]) {
            self.stateBlock(BLEState_Successful,[[storeBLEArr objectAtIndex:i] objectForKey:@"identifier"],0);//返回蓝牙断开的状态
            break;
        }
    }
    
//    NSLog(@"peripheral did connect:  %@",peripheral);
    [self.discoveredPeripheral setDelegate:self];  //  设置外设的代理
    [self.discoveredPeripheral discoverServices:nil]; // 外设发现服务,传nil代表不过滤,读取外设上的所有服务
}

-(void)timeoutConnect{
//    NSLog(@"连接超时");
    self.readyBlock(@"0");
}

#pragma park- 连接失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
//    NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
    
}

//#pragma park- 断开连接
//-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
//    
//    NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
//    
//}

#pragma mark- 外设断开连接/掉线
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error{
//    NSLog(@"外设断开连接 %@: %@:%ld\n", [peripheral name], [error localizedDescription],[error code]);
    
    if (!self.isInitiativeDisconnect) {
        
        //断开连接。返回状态码
        for (int i=0; i<storeBLEArr.count; i++) {
            if ([[[storeBLEArr objectAtIndex:i] objectForKey:@"identifier_temp"] isEqualToString:[peripheral.identifier UUIDString]]) {
                self.stateBlock(BLEState_Disconnect,[[storeBLEArr objectAtIndex:i] objectForKey:@"identifier"],(int)[error code]);//返回蓝牙断开的状态
                break;
            }
        }
        
        //意外断开，重新连接
        [self.centralMgr connectPeripheral:peripheral options:nil];
    }
    else{
        
        //主动断开连接，返回提示
        self.autoPeripheralBlock(@"1");
    }
    

}


#pragma mark - 扫描service,获得外围设备的服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSArray *services = nil;
    
    if (peripheral != self.discoveredPeripheral) {
//        NSLog(@"Wrong Peripheral.\n");
        return ;
    }
    
    if (error != nil) {
//        NSLog(@"Error %@\n", error);
        return ;
    }
    
    services = [peripheral services];
//    NSLog(@"%@",services);
    if (!services || ![services count]) {
//        NSLog(@"No Services");
        return ;
    }
    
    for (CBService *service in services) {
//        NSLog(@"该设备的service:%@",service);
        /*
           选择我们要使用的服务
         */
        
        if ([[[[service.UUID UUIDString] substringFromIndex:4] substringToIndex:4] isEqualToString:@"1523"]) {
//            NSLog(@"i m here");
            [peripheral discoverCharacteristics:nil forService:service];
            
            return ;
        }
        
        
        //读取mac地址
//        if ([[service.UUID UUIDString] isEqualToString:@"180A"]) {
//            
//            [peripheral discoverCharacteristics:nil forService:service];
//        }
        
        
    }
    
}


/*
 *  发现外设服务里的特征的时候调用的代理方法
 *  (这个是比较重要的方法，你在这里可以通过事先知道UUID找到你需要的特征，订阅特征，或者这里写入数据给特征也可以)
 *
 */


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error)
    {
//        NSLog(@"didDiscoverCharacteristicsForService error : %@", [error localizedDescription]);
        return;
    }
    
    for (CBCharacteristic *c in service.characteristics)
    {
        
//        NSLog(@"\n>>>\t特征UUID FOUND(in 服务UUID:%@): %@ (data:%@)====%lu",service.UUID.description,c.UUID,c.UUID.data,(unsigned long)c.properties);
        /**
         >>>	特征UUID FOUND(in 服务UUID:FFE0): FFE1 (data:<ffe1>)
         
         >>>	特征UUID FOUND(in 服务UUID:FFE0): FFE2 (data:<ffe2>)
         
         */
        
        /*
        // 根据特征不同属性去读取或者写
         if (c.properties==CBCharacteristicPropertyRead) {
             NSLog(@"read==%@",c.UUID);
             
             
         }
         if (c.properties==CBCharacteristicPropertyWrite) {
             
              NSLog(@"write===%@",c.UUID);
             
         }
         if (c.properties==CBCharacteristicPropertyNotify) {
             
             NSLog(@"notice==%@",c.UUID);
         }
        */
    
        /*
         主机写入UUID
        */
        if ([[[[c.UUID UUIDString] substringFromIndex:4] substringToIndex:4] isEqual:@"1525"]) {
            
            self.writeCharacteristic = c;
        }
        
        /**
         主机读取UUID
         */
        if ([[[[c.UUID UUIDString] substringFromIndex:4] substringToIndex:4]  isEqual:@"1524"]) {

            self.readCharacteristic = c;
            //订阅特征
            [_discoveredPeripheral setNotifyValue:YES forCharacteristic:self.readCharacteristic];
        }
    }
    
    self.readyBlock(@"1");
}



- (NSData *)hexToBytes:(NSString *)str
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

/*
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
    
    //    NSLog(@"hexdata: %@", hexData);
    return hexData;
}


#pragma mark - 将16进制字符串转成NSData+CRC数据
- (NSData *)calCRCWithData:(NSData *)visibleData
{
    //将16进制字符串转成NSData数据
    NSMutableData *visibleDataM = [visibleData mutableCopy];
    //    Byte byte[5] = {0x00,0xc0,0x00,0x00,0x32};
    NSLog(@"visibleDataM==::%@",visibleDataM);
    
    //NSData做crc验证得到short返回值
    Byte *byte = (Byte *)[visibleDataM bytes];
    NSLog(@"byte::%s",byte);
    
    unsigned char crcShort = CheckCRC(byte, (int)visibleDataM.length);
    //将short返回值转成byte类型添加到可变数组末尾
    Byte bytes[2];
    bytes[0] = (Byte) (crcShort >> 8);
    bytes[1] = (Byte) (crcShort);
    
    [visibleDataM appendBytes:bytes length:sizeof(bytes)];
    
    return visibleDataM;
}
*/


#pragma mark - 读取数据
/*
 * 更新特征的value的时候会调用 
 *（凡是从蓝牙传过来的数据都要经过这个回调，简单的说这个方法就是你拿数据的唯一方法） 你可以判断是否
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    
    if (error)
    {
//        NSLog(@"didUpdateValueForCharacteristic error : %@==info::%@===value===%@", error.localizedDescription,characteristic.UUID,characteristic.value);
        return;
    }
    
    
    NSData *data = characteristic.value;
//    NSLog(@"返回::%@",data);
    NSMutableArray *dataArr = [BLEIToll convertDataToHexStr:data];
    self.dataBlock(dataArr);
    
}



//订阅成功／失败判断
-(void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    
    if (error) {
      
//        NSLog(@"Error changing notification state: %@",[error localizedDescription]);
       
    }
    else{
//        NSLog(@"订阅成功");
//        NSLog(@"didUpdateValueForCharacteristic error : %@==info::%@===value===%@", error.localizedDescription,characteristic.UUID,characteristic.value);
        /*
        NSData *data = characteristic.value;
        
        NSLog(@"data::%@",data);
        NSMutableArray *dataArr = [BLEIToll convertDataToHexStr:data];
        self.dataBlock(dataArr);
         */
        
       // [_discoveredPeripheral readValueForCharacteristic:self.readCharacteristic];

    }
}


#pragma mark - 主动断开连接
-(void)cancelPeripheralConnection{
    
    self.isInitiativeDisconnect = YES;//主动断开连接
    if (self.discoveredPeripheral) {//已经连接外设，则断开
        [self.centralMgr cancelPeripheralConnection:self.discoveredPeripheral];
    }
}

//断开所有蓝牙
-(void)disAllBle{
    
    self.isInitiativeDisconnect = YES;//主动断开连接
    CBPeripheral *per = nil;
    //    NSLog(@"blearr==%@===peripheral==%@",storeBLEArr,identifier);
    for (int i=0; i<storeBLEArr.count; i++) {
        per = (CBPeripheral *)[[storeBLEArr objectAtIndex:i] objectForKey:@"peripheral"];
        
        [self.centralMgr cancelPeripheralConnection:per];
    }
    
    
    [bleListArr removeAllObjects];
    bleListArr = nil;
    storeBLEArr = nil;
    self.centralMgr = nil;

}
/**
 发送命令
 */
- (void)sendData:(NSData *)data{
    
     /**
      通过CBPeripheral 类 将数据写入蓝牙外设中,蓝牙外设所识别的数据为十六进制数据,在ios系统代理方法中将十六进制数据改为 NSData 类型 ,但是该数据形式必须为十六进制数 0*ff 0*ff格式 在iToll中有将 字符串转化为 十六进制 再转化为 NSData的方法
      
      */
    
    //第一个参数是已连接的蓝牙设备 ；第二个参数是要写入到哪个特征； 第三个参数是通过此响应记录是否成功写入
    //写特征到设备中  CBCharacteristicWriteWithoutResponse
    /*
    unsigned char test[8];
    test[0]=0x55;
    test[1]=0x55;
    test[2]=0x00;
    test[3]=0x08;
    test[4]=0x01;
    test[5]=0x00;
    
    //            test[6]=0x00;
    //            test[7]=0x00;
    
    NSLog(@"sizeof(test)::%d",sizeof(test));
    unsigned char c =CheckCRC(test, sizeof(test));
    //            NSLog(@"ccc====%x===%c",c,test[0]);
    
    for (int i = 0; i <sizeof(test); i++) {
        NSLog(@"%c", test[i]);
        NSString *string = [NSString stringWithFormat:@"%02lx", test[i]];
        NSLog(@"string::%@",string);
        //                NSLog(@"%@",[PZMessageUtils asciiToHex:string]);
    }
    */
    
//    NSLog(@"data::%@===%@",data,self.writeCharacteristic);
    
    if (self.writeCharacteristic !=nil) {
        [self.discoveredPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:CBCharacteristicWriteWithResponse];//CBCharacteristicWriteWithoutResponse
        //CBCharacteristicWriteWithResponse
    }
    
    
}

//向peripheral中写入数据后的回调函数
- (void)peripheral:(CBPeripheral*)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    //该方法可以监听到写入外设数据后的状态
    if (error) {
//        NSLog(@"didWriteValueForCharacteristic error : %@,info==%@==value===%@", error.localizedDescription,characteristic.UUID,characteristic.value);
        return;
        
    }
    
//    NSLog(@"write value success : %@", characteristic);
   
}



@end
