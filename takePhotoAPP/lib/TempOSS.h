//
//  TempOSS.h
//  OSS对象储存Demo
//
//  Created by 许惠占 on 2017/9/4.
//  Copyright © 2017年 刘高升. All rights reserved.
//
/**
 *                       .::::.
 *                     .::::::::.
 *                    :::::::::::  FUCK YOU
 *                 ..:::::::::::'
 *              '::::::::::::'
 *                .::::::::::
 *           '::::::::::::::..
 *                ..::::::::::::.
 *              ``::::::::::::::::
 *               ::::``:::::::::'        .:::.
 *              ::::'   ':::::'       .::::::::.
 *            .::::'      ::::     .:::::::'::::.
 *           .:::'       :::::  .:::::::::' ':::::.
 *          .::'        :::::.:::::::::'      ':::::.
 *         .::'         ::::::::::::::'         ``::::.
 *     ...:::           ::::::::::::'              ``::.
 *    ```` ':.          ':::::::::'                  ::::..
 *                       '.:::::'                    ':'````..
 *
 */

#import "AliyunOSS.h"

@interface TempOSS : AliyunOSS

- (void)uploadObjectAsyncWithImageData:(NSData *)data;
@end
