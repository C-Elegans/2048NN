//
//  CENetworkLayer.h
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CENetworkLayer : NSObject
@property float* matrix;
@property int width;
@property int height;
-(id)initRandom:(int)width height:(int)height;
-(id)init:(int)width height:(int)height;
-(id)init:(float*)matrix width:(int)width height:(int)height;
@end
