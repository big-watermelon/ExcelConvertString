//
//  CommonFunction.m
//  ExcelConvertString
//
//  Created by admin on 2019/5/28.
//  Copyright © 2019 大西瓜. All rights reserved.
//

#import "CommonFunction.h"

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
    NSString *str3 = @"plutil -lint Localizable.strings";
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
@end
