//
//  SCReTextField.m
//  CardRechage
//
//  Created by zhy on 03/06/2017.
//  Copyright © 2017 zhy. All rights reserved.
//

#import "SCReTextField.h"
#import "WTReParser.h"

@interface SCReTextField () <UITextFieldDelegate>

@end

@implementation SCReTextField

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.delegate = self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
    }
    return self;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string

{
    if (!_pattern || !_patternWhenCopy || _gap == 0 || _limit == 0) {
        return YES;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", self.patternWhenCopy];
    
    BOOL isValid = [predicate evaluateWithObject:string];
    
    if (!isValid && ![string isEqualToString:@""]) {
        
        return NO;
        
    }
    
    
    
    NSMutableString *matchStr = [NSMutableString stringWithString:textField.text];
    
    if (string == nil || string.length == 0) {
        if ((range.location + 1) % (self.gap + 1) == 0 && range.length == 1) { //如果删除的为空格，再多删除一位
            range.location -= 1;
            range.length += 1;
        }
        
        [matchStr deleteCharactersInRange:range];
        
    }else{
        
        [matchStr insertString:string atIndex:range.location];
        
    }
    
    NSMutableString *cardNum = [NSMutableString stringWithString:[matchStr stringByReplacingOccurrencesOfString:@" " withString:@""]];//这是获取改变后的textfiled的内容
    
    if (cardNum.length > self.limit) { //大于多少位位不能输入
        
        return NO;
        
    }
    
    //获取当前光标的位置
    
    NSUInteger targetCursorPosition = [textField offsetFromPosition:textField.beginningOfDocument toPosition:textField.selectedTextRange.start];
    
    NSMutableString *str =  [NSMutableString stringWithString:cardNum];
    //这个是判断是删除还是添加内容，假如是删除那就将光标向前移，假如添加就要将光标向后移动
    
    NSMutableString *changedStr = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@" " withString:@""]];
    
    if (changedStr != nil && changedStr.length != 0)
    {
        targetCursorPosition = (targetCursorPosition - targetCursorPosition/(self.gap + 1) + changedStr.length) + (targetCursorPosition - targetCursorPosition/(self.gap + 1) + changedStr.length - 1) / (self.gap);
    }else{
        NSLog(@"%ld", targetCursorPosition);
        
        if (range.location < targetCursorPosition) { //不选取任何范围，进行回删
            targetCursorPosition = range.location;
            if (targetCursorPosition > 0 && targetCursorPosition % (self.gap + 1) == 0) {
                targetCursorPosition--;
            }
        } else if (range.location == targetCursorPosition) { //选取一定范围进行回删
            if (targetCursorPosition > 0 && targetCursorPosition % (self.gap + 1) == 0) {
                targetCursorPosition--;
            }
        }
        
    }
    
    
    
    //此处是在特殊位置添加对应空格
    
    
    
    WTReParser *parser = [[WTReParser alloc] initWithPattern:self.pattern];
    
    NSString *formattedStr = [parser reformatString:str];
    
    
    
    //将最终显示的内容复制给textfield
    
    textField.text = formattedStr;
    
    
    
    //该处其实就是选择内容 只不过这个内容长度为0
    
    UITextPosition *targetPosition = [textField positionFromPosition:[textField beginningOfDocument] offset:targetCursorPosition];
    
    [textField setSelectedTextRange:[textField textRangeFromPosition:targetPosition toPosition:targetPosition]];
    
    return NO;
    
}

@end
