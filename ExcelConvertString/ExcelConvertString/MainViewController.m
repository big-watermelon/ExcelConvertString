//
//  MainViewController.m
//  ExcelConvertString
//
//  Created by admin on 2018/11/14.
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
#import "CommonFunction.h"
#import "KeyValueStateModel.h"
static NSInteger const NewlineCharactersCount = 60;//换行需要字符数 60
static NSString *const kNewLineString = @"\n";
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
@property (strong, nonatomic) NSMutableArray *stringValueArray;
@property (strong, nonatomic) NSMutableDictionary *stringKeyannotationDic;

/**
 转换成%@ 用#隔开
 */
@property (nonatomic, strong) NSArray *keyConvertArray;


/**
 保存重复键值对的数组
 */
@property (nonatomic, strong) NSMutableArray *keyValueModelArray;
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
//    NSString *str1 = @"1. Make sure your device's screen is unlocked;";
//    NSString *str2 = @"1. Stellen Sie sicher, dass der Bildschirm Ihres Geräts nicht gesperrt ist.";
//    NSLog(@"匹配 %d", [CommonFunction formatSpecifiersIsEqual:str1 str2:str2]);
//    NSString *str3 = @"Not Delivered";
//    NSString *str4 = @"Not Delivered";
//    NSLog(@"匹配 %d", [CommonFunction formatSpecifiersIsEqual:str3 str2:str4]);
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
    [self initStartLine];
}

- (void)initStartLine
{
    if ([CommonFunction isBlankString:self.startLineTf.stringValue]) {
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
    NSString *string = [CommonFunction deleteSpaceAndNewline:self.leftTextView.string];
    if ([CommonFunction isBlankString:string]) {
        return;
    }
    self.normalKeyArray = [[NSMutableArray alloc] init];
    self.keyRepetitionArray = [[NSMutableArray alloc] init];
    self.annotationDic = [[NSMutableDictionary alloc] init];
    self.keyRepetitionSet = [[NSMutableSet alloc] init];
    NSString *annotationStr = @"";
    NSArray *stringArray = [string componentsSeparatedByString:kNewLineString];
    for (int i = 0; i < stringArray.count; i++) {
        NSString *str = stringArray[i];
        if (![CommonFunction isBlankString:str]){
            if ([CommonFunction IsChinese:str]) {
                annotationStr = [NSString stringWithFormat:@"//MARK: %@\n", str];
                [self.annotationDic setObject:annotationStr forKey:@(self.normalKeyArray.count)];
            }else{
                if ([self.normalKeyArray containsObject:str]) {
                    [self.keyRepetitionArray addObject:str];
                }
                if (i >= [self.startLineTf.stringValue integerValue]) {
                    [self.normalKeyArray addObject:str];
                }
                annotationStr = @"";
            }
        }
    }
    [self.normalKeyArray setArray:[CommonFunction arrayStringTransferredMeaning:self.normalKeyArray]];
    [self.keyRepetitionArray setArray:[CommonFunction arrayStringTransferredMeaning:self.keyRepetitionArray]];
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
    if ([CommonFunction isBlankString:path]) {
        return;
    }else{
        self.rightTextView.string = @"";
        NSString *stringsIsTrue = [CommonFunction stringsIsTrueWithPath:path];
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
    self.stringsKeyArray = [[NSMutableArray alloc] init];
    self.stringKeyRepetitionArray = [[NSMutableArray alloc] init];
    self.stringKeyannotationDic = [[NSMutableDictionary alloc] init];
    self.stringValueArray = [[NSMutableArray alloc] init];
    NSString *stringContent = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];//NSUnicodeStringEncoding
    stringContent = [CommonFunction deleteSpaceAndNewline:stringContent];
//    NSArray *array1 = [str1 componentsSeparatedByString:@";"];
    __block NSArray *keyValueArray = [NSArray array];
    [CommonFunction matchesWithContent:stringContent completeBlock:^(NSArray * _Nonnull stringArray, NSDictionary * _Nonnull annotationDic) {
        keyValueArray = stringArray;
        [self.stringKeyannotationDic setDictionary:annotationDic];
    }];
    for (__strong NSString *str in keyValueArray) {
        if ([str containsString:@"="]) {
            NSDictionary *dic = [str propertyListFromStringsFileFormat];
            NSString *keyStr = dic.allKeys.firstObject;
            NSString *valueStr = dic.allValues.firstObject;
            if (keyStr.length > 0) {
                if ([self.stringsKeyArray containsObject:keyStr]) {
                    [self.stringKeyRepetitionArray addObject:keyStr];
                }
                [self.stringsKeyArray addObject:keyStr];
                [self.stringValueArray addObject:valueStr];
            }
        }else{
        }
    }
    [self.stringsKeyArray setArray:[CommonFunction arrayStringTransferredMeaning:self.stringsKeyArray]];
    [self.stringKeyRepetitionArray setArray:[CommonFunction arrayStringTransferredMeaning:self.stringKeyRepetitionArray]];
    [self.stringValueArray setArray:[CommonFunction arrayStringTransferredMeaning:self.stringValueArray]];
    [self setupShowStringWithType:SetupContentType_StringsKey];
}

- (IBAction)stringsConvertAction:(id)sender
{
    if (self.stringsKeyArray.count == 0) {
        self.rightTextField.hidden = YES;
        self.rightTextView.string = @"stringsKey为空";
        return;
    }
    [self setupShowStringWithType:SetupContentType_StringsValue];
}

- (IBAction)getValueAction:(id)sender
{
    NSString *string = [CommonFunction deleteSpaceAndNewline:self.leftTextView.string];
    if ([CommonFunction isBlankString:string]) {
        return;
    }
    self.valueArray = [NSMutableArray array];
    NSArray *stringArray = [string componentsSeparatedByString:kNewLineString];
    for (int i = 0; i < stringArray.count; i++) {
        NSString *str = stringArray[i];
        if (![CommonFunction isBlankString:str]){
        }else{
            if (self.valueArray.count > 0 &&
                self.stringsKeyArray.count > self.valueArray.count) {
            }
        }
        if (i >= [self.startLineTf.stringValue integerValue]) {
            [self.valueArray addObject:str];
        }
    }
    [self.valueArray setArray:[CommonFunction arrayStringTransferredMeaning:self.valueArray]];
    self.rightTextField.hidden = YES;
    self.rightTextView.string = [NSString stringWithFormat:@"一共有（%ld）个翻译", self.valueArray.count];
}

- (IBAction)getConvertKeyAction:(id)sender {
    NSString *string = [CommonFunction deleteSpaceAndNewline:self.leftTextView.string];
    if ([CommonFunction isBlankString:string]) {
        return;
    }else{
        self.keyConvertArray = [[NSArray alloc] init];
        NSArray *array = [string componentsSeparatedByString:@"#"];
        self.rightTextField.hidden = YES;
        for (NSString *str in array) {
            if (str.length > 0) {
                self.rightTextView.string = [[self.rightTextView.string stringByAppendingString:str] stringByAppendingString:kNewLineString];
            }
        }
        self.keyConvertArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSUInteger len1 = [obj1 length];
            NSUInteger len2 = [obj2 length];
            return len1>len2 ? NSOrderedAscending:NSOrderedDescending;
        }];
    }
}
// !!!: - 组装显示的内容
- (void)setupShowStringWithType:(SetupContentType)type
{
    [self initStartLine];
    self.rightTextField.hidden = YES;
    self.rightTextView.string = @"";
    self.rightTextView.textColor = [NSColor blackColor];
    self.keyValueModelArray = [[NSMutableArray alloc] init];
    NSMutableString *showString = [NSMutableString string];
    NSString *commonStr = @"//MARK:Common Key start\n";
    NSInteger signLength = commonStr.length;
    NSInteger keyCount = 0;
    NSUInteger nullCount = 0;
    NSUInteger formatSpecifiersCount = 0;//格式说明符不匹配数量
    NSArray *keyArray = [[NSArray alloc] init];
    NSArray *valueArray = [[NSArray alloc] init];
    NSArray *repetitionArray = [[NSArray alloc] init];
    NSDictionary *annotationDic = [[NSDictionary alloc] init];
    NSMutableSet *repetitionSet = [[NSMutableSet alloc] init];
    NSControlStateValue checkState = NSOnState;
    switch (type) {
        case SetupContentType_NormalKey:
        case SetupContentType_NormalValue:
        {
            checkState = self.buttonKeyRepetition.state;
            keyArray = self.normalKeyArray;
            valueArray = self.valueArray;
            repetitionArray = self.keyRepetitionArray;
            annotationDic = self.annotationDic;
        }break;
        case SetupContentType_StringsKey:
        case SetupContentType_StringsValue:
        {
            checkState = self.buttonStringsKeyRepetition.state;
            keyArray = self.stringsKeyArray;
            if (type == SetupContentType_StringsKey ||
                self.valueArray.count == 0) {
                valueArray = self.stringValueArray;
            }else{
                valueArray = self.valueArray;
            }
            repetitionArray = self.stringKeyRepetitionArray;
            annotationDic = self.stringKeyannotationDic;
        }break;
        case SetupContentType_getValue:
        {
            
        }break;
    }
 
    if(repetitionArray.count > 0 && !checkState) {
        [showString appendString:[NSString stringWithFormat:@"%@\n//MARK:Common Key end\n", commonStr]];
    }
    for (int i = 0; i < keyArray.count; i++){//start
        NSString *str = @"";
        NSString *keyStr = keyArray[i];
        NSString *valueStr = @"";
        BOOL valueIsNull = NO;
        BOOL formatSpecifiersIsUnequal = NO;
        if (type == SetupContentType_NormalValue ||
            type == SetupContentType_StringsKey ||
            self.valueArray.count == 0) {
            if (i < valueArray.count) {
                valueStr = valueArray[i];
            }
        }else if(type == SetupContentType_StringsValue){
                if ([keyArray indexOfObject:keyStr] != NSNotFound) {
                    NSInteger index = [self.normalKeyArray indexOfObject:keyStr];
                    if (index < valueArray.count) {
                        valueStr = valueArray[index];
                    }
                }
        }
        NSUInteger strLength = 0;
        NSUInteger addStrLength = 0;
        if (valueStr && keyStr) {
            //替换关键字
            if (self.keyConvertArray.count > 0) {
                valueStr = [CommonFunction replacingKeyArray:self.keyConvertArray value:valueStr];
            }
            strLength = keyStr.length + valueStr.length;
            if (strLength > NewlineCharactersCount) {
                str = [NSString stringWithFormat:@"\"%@\" = \n\"%@\";", keyStr,valueStr];
            }else{
                str = [NSString stringWithFormat:@"\"%@\" = \"%@\";", keyStr,valueStr];
            }
            if (type == SetupContentType_NormalKey ||
                type == SetupContentType_NormalValue) {
                str = [str stringByAppendingString:kNewLineString];
                addStrLength += kNewLineString.length;
            }
        }
        if ([CommonFunction isBlankString:valueStr]) {
            valueIsNull = YES;
        }
        if (![CommonFunction formatSpecifiersIsEqual:keyStr str2:valueStr]) {
            formatSpecifiersIsUnequal = YES;
        }
        if (type != SetupContentType_getValue) {
            if ([annotationDic.allKeys containsObject:@(i)]) {
                [showString appendString:[annotationDic objectForKey:@(i)]];
            }
        }
        if (checkState == NSOnState) {
            [showString appendString:str];
        }else{
            if ([repetitionArray containsObject:keyStr]) {
                if (![repetitionSet containsObject:keyStr]) {//Common Key
                    [repetitionSet addObject:keyStr];
                    if (type == SetupContentType_StringsKey ||
                        type == SetupContentType_StringsValue) {
                        str = [str stringByAppendingString:kNewLineString];
                        addStrLength += kNewLineString.length;
                    }
                    [showString insertString:str atIndex:signLength];
                    KeyValueStateModel *model = [[KeyValueStateModel alloc] init];
                    model.repetitionString = keyStr;
                    model.valueIsNull = valueIsNull;
                    model.formatSpecifiersIsUnequal = formatSpecifiersIsUnequal;
                    [self.keyValueModelArray addObject:model];
                    signLength += str.length;
                }else{
                    for (KeyValueStateModel *model in self.keyValueModelArray) {
                        if ([model.repetitionString isEqualToString:keyStr]) {
                            valueIsNull = model.valueIsNull;
                            formatSpecifiersIsUnequal = model.formatSpecifiersIsUnequal;
                            break;
                        }
                    }
                }
            }else{
                [showString appendString:str];
            }
        }
        if (valueIsNull) {
            nullCount ++;
            if (!([repetitionArray containsObject:keyStr] &&
                checkState == NSOffState)) {
                [showString insertString:@"//缺少翻译" atIndex:showString.length-addStrLength];
            }
        }
        if (formatSpecifiersIsUnequal) {
            formatSpecifiersCount ++;
            if (!([repetitionArray containsObject:keyStr] &&
                checkState == NSOffState)) {
                [showString insertString:@"//说明符不匹配" atIndex:showString.length-addStrLength];
            }
        }
    }//end
    
    if (checkState) {
        keyCount = keyArray.count;
    }else{
        keyCount = keyArray.count - repetitionArray.count;
    }
    
    NSString *nullStr = [NSString stringWithFormat:@"//一共有（%ld）个翻译，缺少（%ld）个翻译, 说明符有 (%ld)个不匹配\n\n", keyCount, nullCount, formatSpecifiersCount];
    [showString insertString:nullStr atIndex:0];
    self.rightTextView.string = showString;
    [self setRightTextViewKeyStrColorWithStr:showString];
}
//MARK:对rightTextView进行标记
- (void)setRightTextViewKeyStrColorWithStr:(NSString *)str
{
    __weak typeof(self) weakSelf = self;
    [CommonFunction getKeyRangeWithContent:str keyStr:@"%" withBlock:^(NSRange range) {
        [weakSelf.rightTextView setTextColor:[NSColor redColor] range:range];
    }];
    [CommonFunction getKeyRangeWithContent:str keyStr:@"//MARK:" withBlock:^(NSRange range) {
        [weakSelf.rightTextView setTextColor:[NSColor greenColor] range:range];
    }];

    [CommonFunction getKeyRangeWithContent:str keyStr:@"\"\"" withBlock:^(NSRange range) {
        [weakSelf.rightTextView setTextColor:[NSColor blueColor] range:range];
    }];

}
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
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

@end
