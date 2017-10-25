//
//  CRC.c
//  SmartHome
//
//  Created by 晁广喜 on 2017/7/14.
//  Copyright © 2017年 晁广喜. All rights reserved.
//

#include "CRC.h"


#define CRC16_POLY 0x8005   //CRC校验

//***********************CRC子程序*****************************
unsigned char CheckCRC(unsigned char *DataIn, unsigned int CrcLen)
{
    unsigned char iTemp,crcData;
    unsigned short crcReg=0xffff,CrcCompare=0;
    
    if(CrcLen>20)  //CRC 长度超范围
        return 0;

    CrcCompare=*(DataIn+CrcLen);
    CrcCompare=(CrcCompare<<8)+*(DataIn+CrcLen+1);
    
    while(CrcLen != 0 )
    {
        crcData=*DataIn;
        
        for(iTemp = 0; iTemp < 8; iTemp++)
        {
            if( ((crcReg & 0x8000) >> 8) ^ (crcData & 0x80) )
                crcReg = (crcReg << 1) ^ CRC16_POLY;
            else
                crcReg = (crcReg << 1);
            
            crcData <<= 1;
        }
        
        DataIn++;
        CrcLen--;
    }

    *DataIn=crcReg>>8;
    *(DataIn+1)=crcReg;
    
    if(crcReg==CrcCompare)
        return 1;
    else
        return 0;
}
