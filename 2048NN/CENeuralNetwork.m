//
//  CENeuralNetwork.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "CENeuralNetwork.h"
#import <Accelerate/Accelerate.h>
@implementation CENeuralNetwork
-(id)init:(int)inputs outputs:(int)outputs layers:(int)numLayers layerSize:(int)layerSize{
	self = [super init];
	_layerList = [NSMutableArray new];
	_inputs = inputs;
	_outputs = outputs;
	_layers = numLayers;
	_layersize = layerSize;
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

@end
