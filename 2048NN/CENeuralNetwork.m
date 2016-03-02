//
//  CENeuralNetwork.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "CENeuralNetwork.h"
#import "CENetworkLayer.h"
#import <Accelerate/Accelerate.h>
#define RANDB (rand() & 1)
@implementation CENeuralNetwork
-(id)init:(int)inputs outputs:(int)outputs layers:(int)numLayers layerSize:(int)layerSize{
	self = [super init];
	_layerList = [NSMutableArray new];
	_inputs = inputs;
	_outputs = outputs;
	_layers = numLayers;
	_layersize = layerSize;
	_score = 0;
	[_layerList addObject:[[CENetworkLayer alloc]initRandom:_inputs height:_layersize]];
	for(int i=0;i<numLayers;i++){
		[_layerList addObject:[[CENetworkLayer alloc]initRandom:_layersize height:_layersize]];
	}
	[_layerList addObject:[[CENetworkLayer alloc]initRandom:_layersize height:_outputs]];
	return self;
}
-(void)activate:(float*)vector size:(int)size{
	for(int i=0;i<size;i++){
		vector[i] = tanhf(vector[i]);
	}
}
-(void)solve:(float*)inputs outputs:(float*)outputs{
	float mat_result[_layersize];
	vDSP_mmul(inputs, 1, [_layerList objectAtIndex:0].matrix, 1, mat_result, 1, 1, _layersize, _inputs);
	[self activate:mat_result size:_layersize];
	for(int i=1;i<[_layerList count] -1;i++){
		float mat_result_new[_layersize];
		vDSP_mmul(mat_result, 1, [_layerList objectAtIndex:i].matrix, 1, mat_result_new, 1, 1, _layersize, _layersize);
		[self activate:mat_result_new size:_layersize];
		memcpy(mat_result, mat_result_new, _layersize);
	}
	
	vDSP_mmul(mat_result, 1, [_layerList lastObject].matrix, 1, outputs, 1, 1, _outputs, _layersize);
	[self activate:outputs size:_outputs];
}
+(CENeuralNetwork*)breedNetwork:(CENeuralNetwork*)one with:(CENeuralNetwork*)two{
	CENeuralNetwork* net = [[CENeuralNetwork alloc]init:one.inputs outputs:one.outputs layers:one.layers layerSize:one.layersize];
	for(int i=0;i<[one.layerList count];i++){
		CENetworkLayer* layerOne = [one.layerList objectAtIndex:i];
		CENetworkLayer* layerTwo = [two.layerList objectAtIndex:i];
		CENetworkLayer* newLayer = [net.layerList objectAtIndex:i];
		int width = layerOne.width;
		for(int j=0;j<layerOne.height;j++){
			for(int i=0;i<layerOne.width;i++){
				newLayer.matrix[j*width + i] = RANDB ? layerOne.matrix[j*width+i] : layerTwo.matrix[j*width+i];
			}
		}
	}
	return net;
}

@end
