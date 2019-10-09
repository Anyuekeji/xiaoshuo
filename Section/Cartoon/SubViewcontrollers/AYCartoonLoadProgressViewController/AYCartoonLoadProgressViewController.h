//
//  AYCartoonLoadProgressViewController.h
//  AYNovel
//
//  Created by liuyunpeng on 2019/2/15.
//  Copyright © 2019 liuyunpeng. All rights reserved.
//

#import "LEAFViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AYCartoonLoadProgressViewController : LEAFViewController
@property(nonatomic,strong)NSString *cartoonImageUrl;

@property(nonatomic,assign)CGFloat downProgress;

@end

NS_ASSUME_NONNULL_END
