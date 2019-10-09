#import "LEBaseModel.h"
#import "ZWCacheProtocol.h"

@interface ZWBaseModel : LEBaseModel

@end


@interface ZWDBBaseModel : LEDBBaseModel<ZWCacheProtocol>

@end
