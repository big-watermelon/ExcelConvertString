//
//  CommonFunction.h
//  ExcelConvertString
//
//  Created by admin on 2019/5/28.
//  Copyright © 2019 大西瓜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface CommonFunction : NSObject

/**
 判断是否有中文

 @param str str
 @return YES NO
 */
+ (BOOL)IsChinese:(NSString *)str;
/**
 默认都替换成 %@

 @param array 需要替换的字符类型数组
 @param value 需要替换的内容
 @return string
 */
+ (NSString *)replacingKeyArray:(NSArray *)array value:(NSString *)value;
/**
 去除首尾空格和换行符(包括软回车\U00002028)

 @param str str
 @return str
 */
+ (NSString *)deleteSpaceAndNewline:(NSString *)str;

/**
 异常空格（WPS空格，全角空格）替换成正常空格（半角空格）

 @param str str
 @param btn btn
 @return str
 */
+ (NSString *)replacingSpace:(NSString *)str btn:(NSButton *)btn;
/**
 判断字符为空

 @param str str
 @return YES=空
 */
+ (BOOL)isBlankString:(NSString *)str;
/**
 对strings内容进行处理

 @param content strings Content
 @param completeBlock stringArray(键值对数组) annotationDic(注释字典)
 */
+ (void)matchesWithContent:(NSString *)content completeBlock:(void (^)(NSArray  *stringArray, NSDictionary *annotationDic))completeBlock;
/**
 对" \n 添加转义

 @param str 内容
 @return string
 */
+ (NSString *)stringTransferredMeaning:(NSString *)str;
+ (NSArray *)arrayStringTransferredMeaning:(NSArray *)array;
/**
 获取关键词所在范围

 @param contentStr 内容
 @param keyStr 关键词
 @param block 范围
 */
+ (void)getKeyRangeWithContent:(NSString *)contentStr
                        keyStr:(NSString *)keyStr
                     withBlock:(void(^)(NSRange range))block;
/**
 格式说明符匹配

 @param str1 str1
 @param str2 str2
 @return YES=数量匹配
 */
+ (BOOL)formatSpecifiersIsEqual:(NSString *)str1 str2:(NSString *)str2;

/**
 判断strings文件是否正确(终端检测.strings)

 @param path strings路径
 @return 错误内容
 */
+ (NSString *)stringsIsTrueWithPath:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
