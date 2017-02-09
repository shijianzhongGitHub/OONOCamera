//
//  PublicClass.m
//  duang
//
//  Created by jianzhong on 15/7/15.
//  Copyright (c) 2015年 jianzhong. All rights reserved.
//

#import "PublicClass.h"

#define MULITTHREEBYTEUTF16TOUNICODE(x,y) (((((x ^ 0xD800) << 2) | ((y ^ 0xDC00) >> 8)) << 8) | ((y ^ 0xDC00) & 0xFF)) + 0x10000

#define EMOJI_CODE_TO_SYMBOL(x) ((((0x808080F0 | (x & 0x3F000) >> 4) | (x & 0xFC0) << 10) | (x & 0x1C0000) << 18) | (x & 0x3F) << 24)

static id _sharedInstance = nil;
@implementation PublicClass

//表情转字符
+(NSString *)emojiToString:(NSString *)emoji
{
  __block  NSString *returnStr = emoji;
    NSLog(@"returnStr == %@,lenght == %ld",returnStr,(unsigned long)returnStr.length);
   __block NSString *hexstr;
    [emoji enumerateSubstringsInRange:NSMakeRange(0, [emoji length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                NSLog(@"subString === %@",substring);
                                if ([substring length] >= 2) {
                                    
                                    for (int i = 0; i < [substring length] / 2 && ([substring length] % 2 == 0) ; i++)
                                    {
                                        // three bytes
                                        if (([substring characterAtIndex:i*2] & 0xFF00) == 0 )
                                        {
                                            hexstr = [NSString stringWithFormat:@"Ox%1X 0x%1X",[substring characterAtIndex:i*2],[substring characterAtIndex:i*2+1]];
                                        }
                                        else
                                        {// four bytes
                                            hexstr = [NSString stringWithFormat:@"%1X",MULITTHREEBYTEUTF16TOUNICODE([substring characterAtIndex:i*2],[substring characterAtIndex:i*2+1])];
                                        }
                                    }
                                    NSLog(@"(unicode) %@",hexstr);
                                    hexstr = [NSString stringWithFormat:@"[e]%@[/e]",hexstr];
                                    returnStr = [returnStr stringByReplacingOccurrencesOfString:substring withString:hexstr];
                                }
                            }];

    NSLog(@"返回数据 == %@",returnStr);
    return returnStr;
}
//正则匹配@好友
+(NSArray *)friendFromcomment:(NSString *)comment
{
    NSError *error;
    NSString *regulaStr = @"\\[\\@\\d+\\|[^\\]]+\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:comment options:0 range:NSMakeRange(0, [comment length])];

    return arrayOfAllMatches;
}
//字符转表情
+(NSString *)stringToEmoji:(NSString *)string
{
//    NSLog(@"emojiString===========%@",string);
    NSString *returnString = string;
    NSError *error;
    NSString *regulaStr = @"\\[e\\](.*?)\\[/e\\]";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regulaStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    NSArray *arrayOfAllMatches = [regex matchesInString:string options:0 range:NSMakeRange(0, [string length])];
    
    for (NSTextCheckingResult *match in arrayOfAllMatches)
    {
        NSString* substringForMatch = [string substringWithRange:match.range];
        
//        NSLog(@"subStringForMatch == %@",substringForMatch);
        NSString *tempStr1 = [substringForMatch substringWithRange:NSMakeRange(3, substringForMatch.length-7)];

        tempStr1 = [NSString stringWithFormat:@"0x%@",tempStr1];
        long code = strtoul([tempStr1 UTF8String], 0, 16);
        
        int sym = EMOJI_CODE_TO_SYMBOL(code);
        NSString *emojiStr = [[NSString alloc] initWithBytes:&sym length:sizeof(sym) encoding:NSUTF8StringEncoding];

//        NSLog(@"%@-----emojiStr == %@  returnStr === %@",tempStr1,emojiStr,returnString);
        if(!emojiStr || [emojiStr isEqualToString:@"(null)"])
        {
            emojiStr = @"𞨏";
        }
        returnString = [returnString stringByReplacingOccurrencesOfString:substringForMatch withString:emojiStr];
    }
    return returnString;
}
//判断是否有新消息
+(BOOL)getNewMegInt:(NSDictionary *)megDic
{
    BOOL newBool = YES;
    NSArray *keys = [megDic allKeys];
    for(int i=0;i<keys.count;i++)
    {
        NSString *keyStr =[NSString stringWithFormat:@"%@",[keys objectAtIndex:i]];
        NSString *megNum = [NSString stringWithFormat:@"%@",[megDic objectForKey:keyStr]];
        if(megNum.integerValue >0)
        {
            newBool = NO;
        }
    }
    NSLog(@"newBool == %@",newBool?@"yes":@"no");
    return newBool;
}
+(BOOL)isContainsEmoji:(NSString *)string
{
    __block BOOL isEomji = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0,  [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
         for(int i=0;i<substring.length;i++)
         {
             NSLog(@"-----------%@",[substring substringToIndex:i]);
         }
         NSLog(@"subString === %@  hs =  %d",substring,hs);
        if(10123<= hs && hs <= 10130)
        {
            isEomji = NO;
        }

       else if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;                  if (0x1d000 <= uc && uc <= 0x1f77f) {
                    isEomji = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                isEomji = YES;
            }
        } else {
            if (0x2100 <= hs && hs <= 0x27ff && hs != 0x263b) {
                isEomji = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                isEomji = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                isEomji = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                isEomji = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs  == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50|| hs == 0x231a ) {
                isEomji = YES;
            }
        }
    }];
    return isEomji;
}
//判断身份证号
+ (BOOL)validateIdentityCard: (NSString *)identityCard
{
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
//判断QQ号(5~11位)
+ (BOOL)validateQQ:(NSString *)QQ
{
    if (QQ.length < 5 && QQ.length > 11)
    {
        return NO;
    }
    
    NSString * QQStr = @"^([1-9])\\d{4,10}$";
    NSPredicate *regextestQQ = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",QQStr];
    if ([regextestQQ evaluateWithObject:QQ] == YES)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

//正则判断手机号
+ (BOOL)validateMobile:(NSString *)mobileNum
{
//    test 168
    NSString *TEST = @"^168\\d{8}$";
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     新添加:181,183,184,170,176,177,178,145,
     */
    NSString * MOBILE = @"^1(3[0-9]|4[5]|5[0-35-9]|7[0678]|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|4[5]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[01349]|7[0678])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestTEST = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",TEST];
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES)
        || ([regextestTEST evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
//时间戳转时间
+ (NSString *)conversionStringToDate:(NSString *)TimeString
{
    NSDate *result1=[NSDate dateWithTimeIntervalSince1970:[TimeString longLongValue]/1000];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm +0800"];
    NSString *dateStr=[dateFormatter stringFromDate:result1];
    NSString *resultDay=[dateStr substringWithRange:NSMakeRange(0, 10)];
    
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long int nowTime = (long long int)time;
    double timeCha=nowTime-[TimeString longLongValue]/1000;
    NSString *result;
    NSLog(@"之前时间== %lld  现在时间=== %lld 相减=== %f",[TimeString longLongValue],nowTime,timeCha);
    if(timeCha < 60)
    {
        result=@"刚刚";
    }
    else if (timeCha<3600)
    {
        result=[NSString stringWithFormat:@"%d分钟前",(int)(timeCha/60)];
    }
    else if(timeCha<(24*3600))
    {
        result=[NSString stringWithFormat:@"%d小时前",(int)(timeCha/3600)];
    }
    else
    {
        result=resultDay;
        
    }
    return result ;

}
//获取等级对应的职称
+(NSString *)getUrankString:(NSString *)Urank type:(NSString *)type
{
    if(Urank.length >2)
    {
        Urank = @"1";
    }
    if(type.length >2)
    {
        type = @"1";
    }
    NSInteger urankInt = [Urank integerValue];
    if(urankInt < 1 || urankInt > 9)
    {
        urankInt = 1;
    }
    urankInt = 9-urankInt;
    NSInteger typeInt=[type integerValue];
    NSArray *positionArray;
    switch (typeInt) {
//        case 1:
//        {
//            positionArray=@[@"GCD",@"ECD",@"CD",@"ACD",@"SAD",@"AD",@"AAD",@"AS",@"Designer"];
//
//        }
//            break;
            case 2:
        {
            positionArray=@[@"DUANG大神",@"DUANG大仙",@"DUANG大侠",@"DUANG舵主",@"DUANG侠客",@"DUANG高手",@"DUANG精英",@"DUANG点子",@"DUANG小白"];
 
        }
            break;
        default:
        {
            positionArray=@[@"首席创意总监",@"创意群总监",@"创意总监",@"助理创意总监",@"资深美术指导",@"美术指导",@"助理美术指导",@"美术助理",@"设计师"];

        }
            break;
    }
    return [positionArray objectAtIndex:urankInt%positionArray.count];
}


#pragma mark ------------获取好友昵称 ID--------------
+(NSArray *)getFriendsFromComment:(NSString *)comment type:(NSInteger)typeInt
{
    NSMutableArray *backArray=[NSMutableArray array];

    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[\\@\\d+\\|[^\\]]+\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *IdArray = [regex matchesInString:comment options:0 range:NSMakeRange(0,comment.length)];
    NSString *string;
//    NSLog(@"idArray = %@",IdArray);
    for(int i=0;i<IdArray.count;i++)
    {
        NSTextCheckingResult *result = (NSTextCheckingResult *)[IdArray objectAtIndex:i];
        NSArray *subArray=[[comment substringWithRange:result.range] componentsSeparatedByString:@"|"];
//        NSLog(@"subarray ===%@",subArray);
        switch (typeInt) {
            case 0:
            {//返回ID
                string = [subArray objectAtIndex:0];
                string = [string substringFromIndex:2];
            }
                break;
            default:
            {//返回昵称
                string = [subArray objectAtIndex:1];
                string = [string substringToIndex:string.length-1];
                string =[NSString stringWithFormat:@"%@",string];
            }
                break;
        }
//        NSLog(@"string == %@",string);
        [backArray addObject:string];
    }
    return [NSArray arrayWithArray:backArray];
}


@end
