//
//  AppDelegate.m
//  ExcelConvertString
//
//  Created by 大西瓜 on 2018/9/4.
//  Copyright © 2018年 大西瓜. All rights reserved.
//



//TODO:暂时解决不了软回车control+return(硬回车option+return是\n)

/*
 使用说明：**先全选excel表，搜索\n，将所有换行去掉或替换成$$$$$（最后根据需求去掉还是变成\n）**
 1.获取key最多为2列，一列注释，一列key
 2.获取key时设置起始行，从0开始 一列一般为 1，两列为 3
 3.convert时设置起始行,一般为1
 4.注释列每行至少一个中文，没有自行添加
 5.key区分大小写
 6.若翻译数量为负数，说明：翻译多了或者翻译中有软回车
 */
#import "AppDelegate.h"
#import "BRNumberField.h"
@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (unsafe_unretained) IBOutlet NSTextView *leftTextView;
@property (unsafe_unretained) IBOutlet NSTextView *rightTextView;
@property (strong, nonatomic) NSTextField *rightTextField;


@property (weak) IBOutlet NSButton *buttonGetKey;
@property (weak) IBOutlet NSButton *buttonConvert;
@property (weak) IBOutlet NSButton *buttonClear;
@property (weak) IBOutlet NSButton *buttonValueRepetition;
@property (weak) IBOutlet NSButton *buttonKeyRepetition;

@property (weak) IBOutlet NSTextField *keyLabel;
@property (weak) IBOutlet NSTextField *convertLabel;

/**
 用于获取key时设置，从0开始 一列一般为 1，两列为 3
 */
@property (weak) IBOutlet BRNumberField *keyStartLineTf;
@property (weak) IBOutlet BRNumberField *valueStartLineTf;

@property (strong, nonatomic) NSMutableArray *keyArray;
@property (strong, nonatomic) NSMutableArray *keyRepetitionArray;
@property (strong, nonatomic) NSMutableSet *keyRepetitionSet;
@property (strong, nonatomic) NSMutableDictionary *annotationDic;


@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    [self setupDefault];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)setupDefault
{
    NSString *str = @"设置起始行，默认为1";
    self.keyStartLineTf.placeholderString = str;
    self.valueStartLineTf.placeholderString = str;
    [self initInstructions];
}

- (void)initStartLine
{//TODO:没有进入
    if (self.keyStartLineTf.stringValue.length == 0) {
        self.keyStartLineTf.stringValue = @"1";
    }
    if (self.valueStartLineTf.stringValue.length == 0) {
        self.valueStartLineTf.stringValue = @"1";
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
    NSString *str = @"/**********\n使用说明：**先全选excel表，搜索\\n，将所有换行去掉或替换成$$$$$（最后根据需求去掉还是变成\\n）****\n1.获取key最多为2列，一列注释，一列key\n2.获取key时设置，从0开始 一列一般为 1，两列为 3\n3.convert时设置起始行,一般为1\n4.注释列每行至少一个中文，没有自行添加\n5.key区分大小写\n6.若翻译数量为负数，说明：翻译多了或者翻译中有软回车\n**********/";
    NSFont *font = [NSFont systemFontOfSize:18.0];
    NSRect rect = view.frame;
    tf.frame = NSMakeRect(0, 0, NSWidth(rect), NSHeight(rect));
    tf.editable = NO;
    tf.bordered = NO;
    tf.font = font;
    tf.placeholderString = str;
    [view addSubview:tf];
}
#pragma mark - Action
//***************最多为2列，一列注释，一列key**********************
- (IBAction)getKeyAction:(id)sender
{
    [self initStartLine];
    NSString *string = [self deleteSpaceAndNewline:self.leftTextView.string];
    self.keyArray = [[NSMutableArray alloc] init];
    self.keyRepetitionArray = [[NSMutableArray alloc] init];
    self.annotationDic = [[NSMutableDictionary alloc] init];
    self.keyRepetitionSet = [[NSMutableSet alloc] init];
    NSString *annotationStr = @"";//注释
    NSArray *stringArray = [string componentsSeparatedByString:@"\n"];
    for (int i = 0; i < stringArray.count; i++) {
        NSString *str = stringArray[i];
        if (![str isEqualToString:@""]){
            if ([self IsChinese:str]) {
                annotationStr = [NSString stringWithFormat:@"//MARK:%@\n", str];
                [self.annotationDic setObject:annotationStr forKey:@(self.keyArray.count)];
            }else{
                if (i >= [self.keyStartLineTf.stringValue integerValue]) {
                    if ([self.keyArray containsObject:str]) {
                        [self.keyRepetitionArray addObject:str];
                    }
                    [self.keyArray addObject:str];
                    
                    annotationStr = @"";
                }
            }
        }
    }
    [self setupShowStringIsKey:YES valueArray:[NSArray new]];
}

- (IBAction)convertAction:(id)sender
{
    if (self.keyArray.count == 0) {
        self.rightTextView.string = @"key为空";
        return;
    }
    [self initStartLine];
    NSString *string = [self deleteSpaceAndNewline:self.leftTextView.string];
    NSMutableArray *valueArray = [NSMutableArray array];
    self.keyRepetitionSet = [[NSMutableSet alloc] init];
    
    NSArray *stringArray = [string componentsSeparatedByString:@"\n"];
    for (int i = 0; i < stringArray.count; i++) {
        NSString *str = stringArray[i];
        if (![str isEqualToString:@""]){
        }else{
            if (valueArray.count > 0 && self.keyArray.count > valueArray.count) {
            }
        }
        if (i >= [self.valueStartLineTf.stringValue integerValue]) {
            str = [self addSpecifiedWithStr:@"\\" keyStr:@"\"" contentStr:str];
            [valueArray addObject:str];
        }
    }
    [self setupShowStringIsKey:NO valueArray:valueArray];
}
- (IBAction)clearAction:(id)sender
{
    self.leftTextView.string = @"";
    self.rightTextView.string = @"";
    self.convertLabel.stringValue = @"";
    self.rightTextField.hidden = NO;
}
- (IBAction)keyRepetitionAction:(id)sender
{
    [self getKeyAction:nil];
}

- (IBAction)valueRepetitionActiton:(id)sender
{
    [self convertAction:nil];
}
#pragma mark - 组装显示的内容
- (void)setupShowStringIsKey:(BOOL)isKey valueArray:(NSArray *)valueArray
{
    self.rightTextField.hidden = YES;
    NSMutableString *showString = [NSMutableString string];
    NSString *commonStr = @"//MARK:Common Key\n";
    NSInteger signLength = commonStr.length;
    NSInteger keyCount = 0;
    NSControlStateValue checkState = isKey ? self.buttonKeyRepetition.state:self.buttonValueRepetition.state;
    if (self.keyRepetitionArray.count > 0) {
        [showString appendString:commonStr];
    }
    for (int i = 0; i < self.keyArray.count; i++){
        NSString *str = @"";
        NSString *keyStr = self.keyArray[i];
        NSString *valueStr = @"";
        if (!isKey) {
            if (i < valueArray.count) {
                valueStr = valueArray[i];
            }
        }
        NSUInteger strLength = 0;
        if (valueStr && keyStr) {
            strLength = keyStr.length + valueStr.length;
            if (strLength > 40) {
                str = [NSString stringWithFormat:@"\"%@\" = \n\"%@\";\n", keyStr,valueStr];
            }else{
                str = [NSString stringWithFormat:@"\"%@\" = \"%@\";\n", keyStr,valueStr];
            }
        }
        [self addAnnotationWithShowString:showString withInt:i];
        if (checkState == NSOnState) {
            [showString appendString:str];
        }else{
            if ([self.keyRepetitionArray containsObject:keyStr]) {
                if (![self.keyRepetitionSet containsObject:keyStr]) {
                    [self.keyRepetitionSet addObject:keyStr];
                    [showString insertString:str atIndex:signLength];
                    signLength += str.length;
                }
            }else{
                [showString appendString:str];
            }
        }
    }
    if (checkState) {
        keyCount = self.keyArray.count;
    }else{
        keyCount = self.keyArray.count - self.keyRepetitionArray.count;
    }
    NSInteger nullCount = isKey ? 0:self.keyArray.count - valueArray.count;
    NSString *missingStr = @"";
    if (nullCount >= 0) {
        missingStr = [NSString stringWithFormat:@"缺少 (%ld)个翻译", nullCount];
    }else{
        missingStr = [NSString stringWithFormat:@"多出(%ld)个翻译或有(%ld)个软回车", nullCount, nullCount];
    }
    NSString *nullStr = [NSString stringWithFormat:@"//一共有（%ld）个翻译，%@\n\n", keyCount, missingStr];
    [showString insertString:nullStr atIndex:0];
    if (isKey) {
        self.keyLabel.stringValue = [NSString stringWithFormat:@"keyCount:%ld 个", keyCount];
    }else{
        self.convertLabel.stringValue = missingStr;
    }
    self.rightTextView.string = showString;
    [self setRightTextViewKeyStrColorWithStr:showString];
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
}
//MARK:对所有关键词添加指定字符：主要是给(") 添加(\)
- (NSString *)addSpecifiedWithStr:(NSString *)str keyStr:(NSString *)keyStr contentStr:(NSString *)contentStr
{
    __block NSUInteger addCount = 0;
    NSMutableString *newContentStr = [NSMutableString stringWithString:contentStr];
    if ([contentStr rangeOfString:keyStr].location != NSNotFound) {
        [self setContent:contentStr withKeyString:keyStr withBlock:^(NSRange range) {
            NSRange signRange = NSMakeRange(range.location+addCount-1, 1);
            NSString *subStr = [contentStr substringWithRange:signRange];
            if (![subStr isEqualToString:str]) {
                [newContentStr insertString:str atIndex:signRange.location+1];
                addCount ++;
            }
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
    for(int i=0; i< [str length];i++){
        int a = [str characterAtIndex:i];
        if( a > 0x4e00 && a < 0x9fff){
            return YES;
        }
    }
    return NO;
}
//MARK:去除首尾空格和换行符
- (NSString *)deleteSpaceAndNewline:(NSString *)str
{
    return [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

@end
