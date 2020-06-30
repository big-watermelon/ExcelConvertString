//
//  CommonFunction.h
//  ExcelConvertString
//
//  Created by admin on 2019/5/28.
//  Copyright © 2019 大西瓜. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, LanguageType)
{//需要的语言可以输入语言缩写尝试（可能文档没有）
    LanguageType_en     =0,
    LanguageType_zh,        //简体
    LanguageType_jp,        //日语
    LanguageType_kor,       //韩语
    LanguageType_fra,       //法语
    LanguageType_spa    =5, //西班牙语
    LanguageType_th,        //泰语
    LanguageType_ara,       //阿拉伯语
    LanguageType_ru,        //俄语
    LanguageType_pt,        //葡萄牙语
    LanguageType_vie    =10,//越南语
    LanguageType_id,        //印尼语
    
    LanguageType_auto,      //自动检测
};

typedef NS_ENUM(NSInteger, NeedTranslateType)
{
    NeedTranslateType_missing,   //翻译缺失的
    NeedTranslateType_keyAll,    //翻译根据所有key
    NeedTranslateType_valueAll,  //翻译根据所有value
};
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
 @return str
 */
+ (NSString *)replacingSpace:(NSString *)str;
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
+ (NSString *)md5:(NSString *)input;

+ (void)translateString:(NSString *)string fromType:(LanguageType)fType toType:(LanguageType)tType completed:(void(^)(NSString * _Nullable string, NSString * _Nullable error))completed;

/// 列表选择语言类型数组(无auto)
+ (NSArray <NSString *>*)typeStringArray;
+ (NSArray <NSString *>*)needTransferTypeArray;

/**
 拷贝文本内容

 @param string 内容
 */
+ (void)copyString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
