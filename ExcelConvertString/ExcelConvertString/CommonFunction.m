//
//  CommonFunction.m
//  ExcelConvertString
//
//  Created by admin on 2019/5/28.
//  Copyright © 2019 大西瓜. All rights reserved.
//

#import "CommonFunction.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation CommonFunction

#pragma mark - 判断是否有中文
+ (BOOL)IsChinese:(NSString *)str
{
    for(int i = 0; i< [str length]; i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    }
    return NO;
}
// !!!:默认都替换成 %@
+ (NSString *)replacingKeyArray:(NSArray *)array value:(NSString *)value
{
    for (NSString *keyStr in array) {
        if (keyStr.length > 0) {
            value = [value stringByReplacingOccurrencesOfString:keyStr withString:@"%@"];
        }
    }
    return value;
}
#pragma mark - 去除首尾空格和换行符(包括软回车\U00002028)
+ (NSString *)deleteSpaceAndNewline:(NSString *)str
{
    //删除软回车
    str = [str stringByReplacingOccurrencesOfString:@"\U00002028" withString:@""];
    
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
#pragma mark - 异常空格替换成正常空格
+ (NSString *)replacingSpace:(NSString *)str
{
    //空格替换,第一个空格Unicode \ua0
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@" "];
    //全角空格，Unicode是　\u3000
    str = [str stringByReplacingOccurrencesOfString:@"　" withString:@" "];
    return str;
}
#pragma mark - 判断字符为空
+ (BOOL)isBlankString:(NSString *)str
{
    NSString *string = str;
    if (string == nil || string == NULL) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0) {
        return YES;
    }
    return NO;
}
#pragma mark - 对strings内容进行处理
+ (void)matchesWithContent:(NSString *)content completeBlock:(void (^)(NSArray  *stringArray, NSDictionary *annotationDic))completeBlock
{
    NSString *pattern = @"[^//*]\".*\".*=.*\".*\".*;";
    NSError *error = nil;
    NSRegularExpression *regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@">>> %@", error.localizedDescription);
        return completeBlock(nil, nil);;
    }
    
    NSArray *results = [regex matchesInString:content options:0 range:NSMakeRange(0, content.length)];
    NSMutableArray *matches = [NSMutableArray array];
    NSMutableDictionary *annotationDic = [NSMutableDictionary dictionary];
    __block NSRange lastRange = NSMakeRange(0, 0);
    if (results.count > 0) {
        [results enumerateObjectsUsingBlock:^(NSTextCheckingResult*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSRange range = obj.range;
            if (range.location != NSNotFound) {
                NSString *substring = [content substringWithRange:range];
                NSInteger location = lastRange.location+lastRange.length;
                NSInteger length = range.location - location;
                NSString *subAnnotation = [content substringWithRange:NSMakeRange(location, length)];
                lastRange = range;
                if (substring.length > 0) {
                    if ([[substring substringToIndex:1] isEqualToString:@"\n"]) {
                        substring = [substring substringFromIndex:1];
                        subAnnotation = [subAnnotation stringByAppendingString:@"\n"];
                    }
                    if (subAnnotation.length > 0) {
                        [annotationDic setObject:subAnnotation  forKey:@(matches.count)];
                    }
                    [matches addObject:substring];
                }
            }
        }];
    }
    return completeBlock(matches, annotationDic);
}
#pragma mark - 添加转义
+ (NSString *)stringTransferredMeaning:(NSString *)str
{
    if (str && str.length > 0) {
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"];
        str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    }
    return str;
}

+ (NSArray *)arrayStringTransferredMeaning:(NSArray *)array
{
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    for (NSString *str in array) {
        NSString *newStr = @"";
        newStr = [self stringTransferredMeaning:str];
        [newArray addObject:newStr];
    }
    return newArray;
}
#pragma mark - 获取关键词位置
+ (void)getKeyRangeWithContent:(NSString *)contentStr
                        keyStr:(NSString *)keyStr
                     withBlock:(void(^)(NSRange range))block
{
    NSArray *array = [contentStr componentsSeparatedByString:keyStr];
    NSMutableArray *arrayOfLocation = [NSMutableArray new];
    int length = 0;
    for (int i = 0; i < array.count - 1; i++) {
        NSString *str = array[i];
        NSNumber *number = [NSNumber numberWithInt:length += str.length];
        length += keyStr.length;
        [arrayOfLocation addObject:number];
        NSRange range = NSMakeRange([number integerValue], keyStr.length);
        if (block) {
            block(range);
        }
    }
}
#pragma mark - 格式说明符匹配
+ (BOOL)formatSpecifiersIsEqual:(NSString *)str1 str2:(NSString *)str2
{
    BOOL isEqual = YES;
    NSArray *formatCountArray = @[@"%@", @"%d", @"%ld", @"%lld", @"%f", @"%lf", @"%s", @"%u", @"%lu", @"%llu", @"%b", @"%o", @"%x", @"%p", @"%tu", @"%zd", @"%c", @"%i"];
    for (NSString *formatStr in formatCountArray) {
        NSArray *array1 = [str1 componentsSeparatedByString:formatStr];
        NSArray *array2 = [str2 componentsSeparatedByString:formatStr];
        if (array1.count != array2.count) {
            return NO;
        }
    }
    return isEqual;
}

#pragma mark - 判断strings文件是否正确(终端检测.strings)
+ (NSString *)stringsIsTrueWithPath:(NSString *)path
{
    NSString *str1 = [NSString stringWithFormat:@"cd %@/;", path.stringByDeletingLastPathComponent];
    NSString *str2 = @"sudo chmod -R 777;";
    NSString *str3 = [@"plutil -lint " stringByAppendingString:path.lastPathComponent];//@"plutil -lint Localizable.strings"
    NSString *str4 = [NSString stringWithFormat:@"%@ %@ %@", str1, str2, str3];
    NSString *str5 = [self cmd:str4];
    return str5;
}

+ (NSString *)cmd:(NSString *)cmd
{
    //初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    //-c 用来执行string-commands(命令字符串)
    NSArray *arguments = [NSArray arrayWithObjects:@"-c", cmd, nil];
    [task setArguments:arguments];
    
    //新建输出管道作为task的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    [task setStandardError:pipe];
    //开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    [task launch];
    //获取运行结果
    NSData *data = [file readDataToEndOfFile];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

+ (NSString *)md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (int)strlen(cStr), digest); // This is the md5 call
        NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return output;
}

+ (void)translateString:(NSString *)string fromType:(LanguageType)fType toType:(LanguageType)tType completed:(void (^)(NSString * _Nullable, NSString * _Nullable))completed
{
    //创建URL
    NSString *encodeStr = [string stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
    NSString *httpStr = @"http://api.fanyi.baidu.com/api/trans/vip/translate";
//    NSString *httpsStr = @"https://fanyi-api.baidu.com/api/trans/vip/translate";//备用
    NSString *appIdStr = @"20200315000398557";
    NSString *saltStr = @"1435660288";
    NSString *secretStr = @"bwJmdJ4G_uzM9ClZQgRN";
    NSString *signStr = [NSString stringWithFormat:@"%@%@%@%@", appIdStr, string, saltStr, secretStr];
    NSString *urlStr = [NSString stringWithFormat:@"%@?q=%@&from=%@&to=%@&appid=%@&salt=%@&sign=%@", httpStr, encodeStr, [self typeString:fType], [self typeString:tType], appIdStr, saltStr, [CommonFunction md5:signStr]];
    NSURL *url = [NSURL URLWithString:urlStr];

    NSURLRequest *quest = [NSURLRequest requestWithURL:url cachePolicy:0 timeoutInterval:15];
    //发送请求
//    NSURLResponse *responce = nil;
    //创建一个队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:quest queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
           
//        NSLog(@"%@---\n--%@---\n---%@",[NSThread currentThread],responce,[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        if (!data) {
            completed(nil, @"data为空");
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        if ([dict.allKeys containsObject:@"error_code"]) {
            __block NSString *error = @"";
            [dict.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (error.length > 0) {
                    error = [error stringByAppendingString:@"\n"];
                }
                error = [error stringByAppendingFormat:@"%@:%@", obj, [dict valueForKey:obj]];
//                NSLog(@"%@:%@", obj, [dict valueForKey:obj]);
            }];
            completed(nil, error);
        }else{
            NSArray *array1 = dict[@"trans_result"];
            NSDictionary *dict2 = array1.firstObject;
            [dict2 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                if ([key isEqualToString:@"dst"]) {
                    completed([dict2 valueForKey:key], nil);
                }
            }];
        }
        
    }];
}

+ (NSString *)typeString:(LanguageType)type
{//
    NSString *str = @"";
    switch (type) {
        case LanguageType_auto:
            str = @"auto";
            break;
        case LanguageType_en:
            str = @"en";
            break;
        case LanguageType_zh:
            str = @"zh";
            break;
        case LanguageType_jp:
            str = @"jp";
            break;
        case LanguageType_kor:
            str = @"kor";
            break;
        case LanguageType_fra:
            str = @"fra";
            break;
        case LanguageType_spa:
            str = @"spa";
            break;
        case LanguageType_ara:
            str = @"ara";
            break;
        case LanguageType_th:
            str = @"th";
            break;
        case LanguageType_vie:
            str = @"vie";
            break;
    }
    return str;
}

+ (NSArray<NSString *> *)typeStringArray
{
    return @[@"英语en补缺翻译",
             @"中文zh补缺翻译",
             @"日语jp补缺翻译",
             @"韩语kor补缺翻译",
             @"法语fra补缺翻译",
             @"西语spa补缺翻译",
             @"泰语th补缺翻译",
             @"阿语ara补缺翻译",
             @"越南语vie补缺翻译"];
}
@end
