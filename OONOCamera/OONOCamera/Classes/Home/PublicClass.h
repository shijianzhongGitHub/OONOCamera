//
//  PublicClass.h
//  duang
//
//  Created by jianzhong on 15/7/15.
//  Copyright (c) 2015年 jianzhong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PublicClass : NSObject
{
    
}
//获取当前屏幕显示的viewcontroller
//+ (UIViewController *)getCurrentVC;
//消息已读
+(void)readMeg:(NSString *)mid;
//正则匹配@好友
+(NSArray *)friendFromcomment:(NSString *)comment;
//表情转字符
+(NSString *)emojiToString:(NSString *)emoji;
//字符转表情
+(NSString *)stringToEmoji:(NSString *)string;
//判断是否有新消息
+(BOOL)getNewMegInt:(NSDictionary *)megDic;
//获取网络状况
+(NSString *)getNetWorkStates;
//获取手机型号
+ (NSString*)deviceVersion;
//添加水印
//+(UIImage *)addText:(UIImage *)img IDStr:(NSString *)idStr name:(NSString *)nameStr;
//判断是否有表情
+(BOOL)isContainsEmoji:(NSString *)string;

//是否显示引导页
+(void)showLeaderViewAtView:(NSString *)viewInt;
//判断身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard;
//判断QQ号(5~11位)
+ (BOOL)validateQQ:(NSString *)QQ;
//正则判断手机号
+ (BOOL)validateMobile:(NSString *)mobileNum;

//时间戳转时间
+ (NSString *)conversionStringToDate:(NSString *)TimeString;
//获取等级对应的职称
+(NSString *)getUrankString:(NSString *)Urank type:(NSString *)type;

//获取等级对应的职称颜色
//+(UIColor *)getUrankColor:(NSString *)Urank;

//网络获取图片计算
+(NSArray *)ComputNetworkImgSize:(NSArray *)networkImg imgName:(NSString *)imgName;

//通过图片名字 获取图片大小
//+ (CGSize )getImgSizeFromName:(NSString *)imgName;
//通过字符串 获取@好友数组
+ (NSArray *)getFriendsFromComment:(NSString *)comment type:(NSInteger)typeInt;

//字符串转字典
//+(NSDictionary *)getDicFromString:(NSString *)string;

//评论添加好友
+(NSString *)addFriendToComment:(NSString *)friendUid comment:(NSString *)friendName;

//错误提示
+(void)showErrorPrompt:(NSString *)code;

@end
