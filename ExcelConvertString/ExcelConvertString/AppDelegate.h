//
//  AppDelegate.h
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
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>


@end

