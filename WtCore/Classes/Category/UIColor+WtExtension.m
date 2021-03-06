//
// UIColor+WtExtension.m
// WtCore
//
// Created by wtfan on 2017/9/12.
// Copyright © 2017 wtfan.
//
// This source code is licensed under the MIT-style license found in the
// LICENSE file in the root directory of this source tree.
//

#import "UIColor+WtExtension.h"

#import "NSString+WtExtension.h"


UIColor *wtRandomColor(CGFloat alpha) {
  return [UIColor wtRandomWithAlpha:alpha];
}


UIColor *wtHTMLColor(NSString *name) {
  return [UIColor wtColorWithHTMLName:name];
}


@implementation UIColor (WtExtension)
+ (UIColor *)wtRandom {
  return [self wtRandomWithAlpha:1.0];
}

+ (UIColor *)wtRandomWithAlpha:(CGFloat)alpha {
  CGFloat red = (arc4random() % 256) / 256.0;
  CGFloat green = (arc4random() % 256) / 256.0;
  CGFloat blue = (arc4random() % 256) / 256.0;
  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}
@end


@implementation UIColor (WtHTML)

+ (UIColor *)wtColorWithHexString:(NSString *)hex {
  if ([hex hasPrefix:@"#"]) hex = [hex substringFromIndex:1];

  NSArray *hexArray = [hex componentsSeparatedByString:@" "];
  CGFloat alpha = 1.0;
  if (hexArray.count == 2) {
    hex = hexArray[0];
    CGFloat _alpha = [hexArray[1] floatValue];
    if (_alpha >= 0 && _alpha <= 1.0) {
      alpha = _alpha;
    }
  }
  if ([hex length] != 6 && [hex length] != 3) return nil;

  NSUInteger digits = [hex length] / 3.0;
  CGFloat maxValue = (digits == 1) ? 15.0 : 255.0;

  CGFloat red = [[hex substringWithRange:NSMakeRange(0, digits)] wtIntegerValueFromHex] / maxValue;
  CGFloat green = [[hex substringWithRange:NSMakeRange(digits, digits)] wtIntegerValueFromHex] / maxValue;
  CGFloat blue = [[hex substringWithRange:NSMakeRange(2 * digits, digits)] wtIntegerValueFromHex] / maxValue;

  return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (UIColor *)wtColorWithHTMLName:(NSString *)name {
  if ([name hasPrefix:@"#"]) {
    return [UIColor wtColorWithHexString:[name substringFromIndex:1]];
  }

  if ([name hasPrefix:@"rgba"]) {
    NSString *rgbaName = [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"rgba() "]];
    NSArray *rgba = [rgbaName componentsSeparatedByString:@","];

    if ([rgba count] != 4) {
      return nil;
    }

    return [UIColor colorWithRed:[[rgba objectAtIndex:0] floatValue] / 255
                           green:[[rgba objectAtIndex:1] floatValue] / 255
                            blue:[[rgba objectAtIndex:2] floatValue] / 255
                           alpha:[[rgba objectAtIndex:3] floatValue]];
  }

  if ([name hasPrefix:@"rgb"]) {
    NSString *rgbName = [name stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"rbg() "]];
    NSArray *rbg = [rgbName componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];
    if ([rbg count] != 3) {
      // Incorrect syntax
      return nil;
    }
    return [UIColor colorWithRed:[[rbg objectAtIndex:0] floatValue] / 255
                           green:[[rbg objectAtIndex:1] floatValue] / 255
                            blue:[[rbg objectAtIndex:2] floatValue] / 255
                           alpha:1.0];
  }

  return nil;
}

@end
