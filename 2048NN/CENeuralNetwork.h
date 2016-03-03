//
//  CENeuralNetwork.h
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CENetworkLayer.h"
@interface CENeuralNetwork : NSObject
@property int inputs;
@property int outputs;
@property int layers;
@property int layersize;
@property float score;
@property NSMutableArray<CENetworkLayer*>* layerList;
-(id)init:(int)inputs outputs:(int)outputs layers:(int)numLayers layerSize:(int)layerSize;
-(id)initNoRand:(int)inputs outputs:(int)outputs layers:(int)numLayers layerSize:(int)layerSize;
-(void)solve:(float*)inputs outputs:(float*)outputs;
+(CENeuralNetwork*)breedNetwork:(CENeuralNetwork*)one with:(CENeuralNetwork*)two;
@end
