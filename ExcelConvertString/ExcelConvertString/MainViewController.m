//
//  MainViewController.m
//  ExcelConvertString
//
//  Created by Tenorshare Developer on 2018/11/14.
//  Copyright © 2018 大西瓜. All rights reserved.
//
/*
 **操作步骤**
 **先全选excel表，搜索\n，将所有换行去掉或替换成$$$$$（最后根据需求去掉还是变成\n）**
 1.(必须)粘贴Excel的key列(推荐用英文作为key) -> getNormalKey
 2.(必须)粘贴Excel的value列 -> GetValue
 3.拖入.strings或粘贴路径 -> getStringsKey
 4.根据需求选择convert和repetition
 使用说明：
 1.获取normalKey最多为2列，一列注释，一列key
 2.getKey时设置起始行(默认为1)，从0开始
 3.注释列每行至少一个中文，没有自行添加
 4.key区分大小写
 5.getConvertKey默认都转换成%@,用#隔开，每次获取都会重置(例如：产品名#链接#www.xxx.com#Open)
 */

#import "MainViewController.h"
#import "BRNumberField.h"
#import <stdlib.h>

static NSInteger const NewlineCharactersCount = 1000;//换行需要字符数 60
typedef NS_ENUM(NSInteger, SetupContentType)
{
    SetupContentType_NormalKey = 0,
    SetupContentType_NormalValue,
    SetupContentType_StringsKey,//按strings文件key顺序
    SetupContentType_StringsValue,
    SetupContentType_getValue,
};
@interface MainViewController ()
@property (unsafe_unretained) IBOutlet NSTextView *leftTextView;
@property (unsafe_unretained) IBOutlet NSTextView *rightTextView;
@property (strong, nonatomic) NSTextField *rightTextField;


@property (weak) IBOutlet NSButton *buttonKeyRepetition;
@property (weak) IBOutlet NSButton *buttonStringsKeyRepetition;

/**
 用于获取key时设置，从0开始 一列一般为 1，两列为 3
 */
@property (weak) IBOutlet BRNumberField *startLineTf;

@property (strong, nonatomic) NSMutableArray *normalKeyArray;
@property (strong, nonatomic) NSMutableArray *keyRepetitionArray;

@property (strong, nonatomic) NSMutableSet *keyRepetitionSet;
@property (strong, nonatomic) NSMutableDictionary *annotationDic;

/**
 获取所有value
 */
@property (strong, nonatomic) NSMutableArray *valueArray;

/**
 按strings文件key顺序
 */
@property (strong, nonatomic) NSMutableArray *stringsKeyArray;
@property (strong, nonatomic) NSMutableArray *stringKeyRepetitionArray;
/**
 转换成%@ 用#隔开
 */
@property (nonatomic, strong) NSArray *keyConvertArray;

@end

@implementation MainViewController
- (instancetype)init
{
    if (self = [super initWithNibName:[self className] bundle:nil]) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setupDefault];
}

- (void)setupDefault
{
    NSString *str = @"设置起始行，默认为1";
    self.startLineTf.placeholderString = str;
    [self initInstructions];
}

- (void)initStartLine
{
    if ([self isBlankString:self.startLineTf.stringValue]) {
        self.startLineTf.stringValue = @"1";
    }
}
#pragma mark - 使用说明
- (void)initInstructions
{
    if (!_rightTextField) {
        _rightTextField = [[NSTextField alloc] init];
        [self initTextField:self.rightTextField withTextView:self.rightTextView];
    }
}

- (void)initTextField:(NSTextField *)tf withTextView:(NSTextView *)view
{
    NSString *str = @"/**********\n**操作步骤**\n**先全选excel表，搜索\\n，将所有换行去掉或替换成$$$$$（最后根据需求去掉还是变成\\n**\n1.(必须)粘贴Excel的key列(推荐用英文作为key) -> getNormalKey\n2.(必须)粘贴Excel的value列 -> GetValue\n3.拖入.strings或粘贴路径 -> getStringsKey\n4.根据需求选择convert和repetition\n\n使用说明：\n1.获取key最多为2列，一列注释，一列key\n2.getKey时设置起始行(默认为1)，从0开始\n3.注释列每行至少一个中文，没有自行添加\n4.key区分大小写\n5.getConvertKey默认都转换成%@,用#隔开，每次获取都会重置(例如：产品名#链接#www.xxx.com#Open)\n**********/";
    NSFont *font = [NSFont systemFontOfSize:18.0];
    NSRect rect = view.frame;
    //    tf.frame = NSMakeRect(0, 0, NSWidth(rect), NSHeight(rect));
    tf.editable = NO;
    tf.backgroundColor = [NSColor clearColor];
    tf.bordered = NO;
    tf.font = font;
    tf.placeholderString = str;
    tf.preferredMaxLayoutWidth = NSWidth(rect);
    [view addSubview:tf];
    [self setConstraintWithView:view subView:tf];
}
#pragma mark - Action
//***************最多为2列，一列注释，一列key**********************
- (IBAction)getKeyAction:(id)sender
{
    NSString *string = [self deleteSpaceAndNewline:self.leftTextView.string];
    if ([self isBlankString:string]) {
        return;
    }
    self.normalKeyArray = [[NSMutableArray alloc] init];
    self.keyRepetitionArray = [[NSMutableArray alloc] init];
    self.annotationDic = [[NSMutableDictionary alloc] init];
    self.keyRepetitionSet = [[NSMutableSet alloc] init];
    NSString *annotationStr = @"";//注释
    NSArray *stringArray = [string componentsSeparatedByString:@"\n"];
    for (int i = 0; i < stringArray.count; i++) {
        NSString *str = stringArray[i];
        if (![self isBlankString:str]){
            if ([self IsChinese:str]) {
                annotationStr = [NSString stringWithFormat:@"//MARK: %@\n", str];
                [self.annotationDic setObject:annotationStr forKey:@(self.normalKeyArray.count)];
            }else{
                if ([self.normalKeyArray containsObject:str]) {
                    [self.keyRepetitionArray addObject:str];
                }
                str = [self addSpecifiedWithStr:@"\\" keyStr:@"\"" contentStr:str];
                [self.normalKeyArray addObject:str];
                annotationStr = @"";
            }
        }
    }
    [self setupShowStringWithType:SetupContentType_NormalKey];
}

- (IBAction)convertAction:(id)sender
{
    if (self.normalKeyArray.count == 0) {
        self.rightTextField.hidden = YES;
        self.rightTextView.string = @"normalKey为空";
        return;
    }
    [self setupShowStringWithType:SetupContentType_NormalValue];
}

- (IBAction)clearAction:(id)sender
{
    self.leftTextView.string = @"";
    self.rightTextView.string = @"";
    self.rightTextField.hidden = NO;
}

- (IBAction)keyRepetitionAction:(id)sender
{
    [self convertAction:nil];
}

- (IBAction)stringsKeyRepetitionAction:(id)sender {
    [self stringsConvertAction:nil];
}

- (IBAction)getStringsKeyAction:(id)sender
{
    NSString *path = self.leftTextView.string;
    if ([self isBlankString:path]) {
        return;
    }else{
        NSString *stringsIsTrue = [self stringsIsTrueWithPath:path];
        if (![stringsIsTrue containsString:@"OK"]) {
            if ([stringsIsTrue containsString:@"parser:"]) {
                NSRange range1 = [stringsIsTrue rangeOfString:@"parser:"];
                NSString *keyStr1 = [stringsIsTrue substringFromIndex:range1.location+range1.length];
                NSRange range2 = [keyStr1 rangeOfString:@"."];
                NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:stringsIsTrue];
                [attString addAttribute:NSForegroundColorAttributeName value:[NSColor redColor] range:NSMakeRange(range1.location+range1.length, range2.location+range2.length)];
                [self.rightTextView insertText:attString];
            }else{
                self.rightTextView.string = stringsIsTrue;
            }
            self.rightTextField.hidden = YES;
            return;
        }
    }
    //    NSDictionary *dicAll = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *str1 = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];//NSUnicodeStringEncoding
    str1 = [self deleteSpaceAndNewline:str1];
    NSArray *array1 = [str1 componentsSeparatedByString:@";"];
    self.stringsKeyArray = [[NSMutableArray alloc] init];
    self.stringKeyRepetitionArray = [[NSMutableArray alloc] init];
    for (__strong NSString *str in array1) {
        if ([str containsString:@"="]) {
            str = [str stringByAppendingString:@";"];
            NSDictionary *dic = [str propertyListFromStringsFileFormat];
            NSString *keyStr = dic.allKeys.firstObject;
            if (keyStr.length > 0) {
                if ([self.stringsKeyArray containsObject:keyStr]) {
                    [self.stringKeyRepetitionArray addObject:keyStr];
                }
                str = [self addSpecifiedWithStr:@"\\" keyStr:@"\"" contentStr:str];
                [self.stringsKeyArray addObject:keyStr];
            }
        }else{
        }
    }
    [self setupShowStringWithType:SetupContentType_StringsKey];
}

- (IBAction)stringsConvertAction:(id)sender
{
    if (self.stringsKeyArray.count == 0) {
        self.rightTextField.hidden = YES;
        self.rightTextView.string = @"stringsKey为空";
        return;
    }
    if (self.normalKeyArray.count == 0) {
        self.rightTextField.hidden = YES;
        self.rightTextView.string = @"normalKey为空";
        return;
    }
    [self setupShowStringWithType:SetupContentType_StringsValue];
}

- (IBAction)getValueAction:(id)sender
{
    [self getValue];
}

- (IBAction)getConvertKeyAction:(id)sender {
    NSString *string = [self deleteSpaceAndNewline:self.leftTextView.string];
    if ([self isBlankString:string]) {
        return;
    }else{
        self.keyConvertArray = [[NSArray alloc] init];
        NSArray *array = [string componentsSeparatedByString:@"#"];
        self.rightTextField.hidden = YES;
        for (NSString *str in array) {
            if (str.length > 0) {
                self.rightTextView.string = [[self.rightTextView.string stringByAppendingString:str] stringByAppendingString:@"\n"];
            }
        }
        self.keyConvertArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSUInteger len1 = [obj1 length];
            NSUInteger len2 = [obj2 length];
            return len1>len2 ? NSOrderedAscending:NSOrderedDescending;
        }];
    }
}
#pragma mark - 组装显示的内容
- (void)setupShowStringWithType:(SetupContentType)type
{
    self.rightTextField.hidden = YES;
    NSMutableString *showString = [NSMutableString string];
    NSString *commonStr = @"//MARK:Common Key start\n";
    NSInteger signLength = commonStr.length;
    NSInteger keyCount = 0;
    NSUInteger nullCount = 0;
    NSArray *keyArray = [[NSArray alloc] init];
    NSArray *repetitionArray = [[NSArray alloc] init];
    NSMutableSet *repetitionSet = [[NSMutableSet alloc] init];
    NSControlStateValue checkState = NSOnState;
    switch (type) {
        case SetupContentType_NormalKey:
        {
            keyArray = self.normalKeyArray;
        }break;
        case SetupContentType_NormalValue:
        {
            checkState = self.buttonKeyRepetition.state;
            keyArray = self.normalKeyArray;
            repetitionArray = self.keyRepetitionArray;
        }break;
        case SetupContentType_StringsKey:
        {
            keyArray = self.stringsKeyArray;
        }break;
        case SetupContentType_StringsValue:
        {
            checkState = self.buttonStringsKeyRepetition.state;
            keyArray = self.stringsKeyArray;
            repetitionArray = self.stringKeyRepetitionArray;
        }break;
        case SetupContentType_getValue:
        {
            
        }break;
    }
    if(repetitionArray.count > 0 && !checkState) {
        [showString appendString:[NSString stringWithFormat:@"%@//MARK:Common Key end\n", commonStr]];
    }
    for (int i = 0; i < keyArray.count; i++){
        NSString *str = @"";
        NSString *keyStr = keyArray[i];
        NSString *valueStr = @"";
        if (type == SetupContentType_NormalValue) {
            if (i < self.valueArray.count) {
                valueStr = self.valueArray[i];
            }
        }else if(type == SetupContentType_StringsValue){
                if ([self.normalKeyArray indexOfObject:keyStr] != NSNotFound) {
                    NSInteger index = [self.normalKeyArray indexOfObject:keyStr];
                    if (index < self.valueArray.count) {
                        valueStr = self.valueArray[index];
                    }
                }
        }
        NSUInteger strLength = 0;
        if (valueStr && keyStr) {
            // !!!:替换关键字
            if (self.keyConvertArray.count > 0) {
                valueStr = [self replacingKeyArray:self.keyConvertArray value:valueStr];
            }
            strLength = keyStr.length + valueStr.length;
            if (strLength > NewlineCharactersCount) {
                str = [NSString stringWithFormat:@"\"%@\" = \n\"%@\";\n", keyStr,valueStr];
            }else{
                str = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n", keyStr,valueStr];
            }
        }
        if ([self isBlankString:valueStr]) {
            nullCount ++;
        }
        if (type == SetupContentType_NormalKey ||
            type == SetupContentType_NormalValue) {
            [self addAnnotationWithShowString:showString withInt:i];
        }
        if (checkState == NSOnState) {
            [showString appendString:str];
        }else{
            if ([repetitionArray containsObject:keyStr]) {
                if (![repetitionSet containsObject:keyStr]) {//Common Key
                    [repetitionSet addObject:keyStr];
                    [showString insertString:str atIndex:signLength];
                    signLength += str.length;
                }
            }else{
                [showString appendString:str];
            }
        }
    }
    if (checkState) {
        keyCount = keyArray.count;
    }else{
        keyCount = keyArray.count - repetitionArray.count;
    }
    
    NSString *nullStr = [NSString stringWithFormat:@"//一共有（%ld）个翻译，缺少（%ld）个翻译\n\n", keyCount, nullCount];
    [showString insertString:nullStr atIndex:0];
    self.rightTextView.string = showString;
    [self setRightTextViewKeyStrColorWithStr:showString];
}
//MARK:getValue
- (void)getValue
{
    NSString *string = [self deleteSpaceAndNewline:self.leftTextView.string];
    if ([self isBlankString:string]) {
        return;
    }
    self.valueArray = [NSMutableArray array];
    NSArray *stringArray = [string componentsSeparatedByString:@"\n"];
    for (int i = 0; i < stringArray.count; i++) {
        NSString *str = stringArray[i];
        if (![self isBlankString:str]){
        }else{
            if (self.valueArray.count > 0 && self.stringsKeyArray.count > self.valueArray.count) {
            }
        }
        if (i >= [self.startLineTf.stringValue integerValue]) {
            str = [self addSpecifiedWithStr:@"\\" keyStr:@"\"" contentStr:str];
            [self.valueArray addObject:str];
        }
    }
    self.rightTextField.hidden = YES;
    self.rightTextView.string = [NSString stringWithFormat:@"一共有（%ld）个翻译", self.valueArray.count];
}
//MARK:对rightTextView进行标记
- (void)setRightTextViewKeyStrColorWithStr:(NSString *)str
{
    __weak typeof(self) weakSelf = self;
    [self setContent:str withKeyString:@"%" withBlock:^(NSRange range) {
        [weakSelf.rightTextView setTextColor:[NSColor redColor] range:range];
    }];
    [self setContent:str withKeyString:@"//MARK:" withBlock:^(NSRange range) {
        [weakSelf.rightTextView setTextColor:[NSColor greenColor] range:range];
    }];
    [self setContent:str withKeyString:@"\"\"" withBlock:^(NSRange range) {
        [weakSelf.rightTextView setTextColor:[NSColor blueColor] range:range];
    }];
}
//MARK:对所有关键词添加指定字符：主要是给(") 添加(\)
- (NSString *)addSpecifiedWithStr:(NSString *)str keyStr:(NSString *)keyStr contentStr:(NSString *)contentStr
{
    __block NSUInteger addCount = 0;
    NSMutableString *newContentStr = [NSMutableString stringWithString:contentStr];
    if ([contentStr rangeOfString:keyStr].location != NSNotFound) {
        [self setContent:contentStr withKeyString:keyStr withBlock:^(NSRange range) {
            NSRange signRange = NSMakeRange(range.location+addCount-1, 1);
            [newContentStr insertString:str atIndex:signRange.location+1];
            addCount ++; 
        }];
    }
    return newContentStr;
}
//MARK:获取关键词位置
- (void)setContent:(NSString*)contentStr withKeyString:(NSString *)keyStr withBlock:(void(^)(NSRange range))block
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

//MARK:添加注释
- (void)addAnnotationWithShowString:(NSMutableString *)str withInt:(int)i
{
    if ([self.annotationDic.allKeys containsObject:@(i)]) {
        NSString *annotationStr = [self.annotationDic objectForKey:@(i)];
        [str appendString:annotationStr];
    }
}
//MARK:判断是否有中文
- (BOOL)IsChinese:(NSString *)str {
    for(int i = 0; i< [str length]; i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    }
    return NO;
}
// !!!:默认都替换成 %@
- (NSString *)replacingKeyArray:(NSArray *)array value:(NSString *)value
{
    for (NSString *keyStr in array) {
        if (keyStr.length > 0) {
            value = [value stringByReplacingOccurrencesOfString:keyStr withString:@"%@"];
        }
    }
    return value;
}
//MARK:去除首尾空格和换行符(包括软回车\U00002028)
- (NSString *)deleteSpaceAndNewline:(NSString *)str
{
    [self initStartLine];
    //删除软回车
    str = [str stringByReplacingOccurrencesOfString:@"\U00002028" withString:@""];
    
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}
#pragma mark - 判断字符为空
- (BOOL)isBlankString:(NSString *)str {
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
#pragma mark - 约束
- (void)setConstraintWithView:(NSView *)view subView:(NSView *)subView
{
    NSLayoutConstraint *left = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    //    NSLayoutConstraint *right = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *width = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0];
    //    NSLayoutConstraint *height = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    NSLayoutConstraint *top = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *bottom = [NSLayoutConstraint constraintWithItem:subView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    subView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addConstraints:@[left, width, top, bottom]];
}
#pragma mark - 判断strings文件是否正确(终端检测.strings)
- (NSString *)stringsIsTrueWithPath:(NSString *)path
{
    NSString *str1 = [NSString stringWithFormat:@"cd %@/;", path.stringByDeletingLastPathComponent];
    NSString *str2 = @"sudo chmod -R 777;";
    NSString *str3 = @"plutil -lint Localizable.strings";
    NSString *str4 = [NSString stringWithFormat:@"%@ %@ %@", str1, str2, str3];
    NSString *str5 = [self cmd:str4];
    return str5;
}

- (NSString *)cmd:(NSString *)cmd
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
