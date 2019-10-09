//
//  LEAlertView+ZW.h
//  CallU
//
//  Created by Leaf on 16/5/12.
//  Copyright © 2016年 NHZW. All rights reserved.
//


UIKIT_EXTERN void occasionalHint(NSString *message);

#define hint(message)   ZWAlert(message, -1, nil, @"确定")



