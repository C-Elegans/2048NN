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
#include <immintrin.h>
#include <mm_malloc.h>
#include "NetworkHelper.h"
#define RANDB (rand() & 1)
@implementation CENeuralNetwork
//float* mat_result= NULL;
//float* mat_result_new=NULL;
-(id)init:(int)inputs outputs:(int)outputs layers:(int)numLayers layerSize:(int)layerSize{
	self = [super init];
	_layerList = [NSMutableArray new];
	_inputs = inputs;
	_outputs = outputs;
	_layers = numLayers;
	_layersize = layerSize;
	_score = 0;
	/*mat_result = _mm_malloc(_layersize*sizeof(float), 32);
	mat_result_new = _mm_malloc(_layersize*sizeof(float), 32);
	if(mat_result == NULL){
		NSLog(@"Mat_result is NULL!");
		exit(-1);
	}*/
	[_layerList addObject:[[CENetworkLayer alloc]initRandom:_inputs height:_layersize]];
	for(int i=0;i<numLayers;i++){
		[_layerList addObject:[[CENetworkLayer alloc]initRandom:_layersize height:_layersize]];
	}
	[_layerList addObject:[[CENetworkLayer alloc]initRandom:_layersize height:_outputs]];
	return self;
}
-(void)dealloc{
	/*mat_result = nil;
	mat_result_new = nil;
	_mm_free(mat_result);
	_mm_free(mat_result_new);*/
}
-(id)initNoRand:(int)inputs outputs:(int)outputs layers:(int)numLayers layerSize:(int)layerSize{
	self = [super init];
	_layerList = [NSMutableArray new];
	_inputs = inputs;
	_outputs = outputs;
	_layers = numLayers;
	_layersize = layerSize;
	_score = 0;
	
	/*mat_result = _mm_malloc(_layersize*sizeof(float), 32);
	mat_result_new = _mm_malloc(_layersize*sizeof(float), 32);
	if(mat_result == NULL){
		NSLog(@"Mat_result is NULL!");
		exit(-1);
	}*/
	[_layerList addObject:[[CENetworkLayer alloc]init:_inputs height:_layersize]];
	for(int i=0;i<numLayers;i++){
		[_layerList addObject:[[CENetworkLayer alloc]init:_layersize height:_layersize]];
	}
	[_layerList addObject:[[CENetworkLayer alloc]init:_layersize height:_outputs]];
	return self;
}
-(void)mutate{
	for(CENetworkLayer* layer in _layerList){
		float *mat = layer.matrix;
		unsigned int r;
		_rdrand32_step(&r);
		mutate(mat, layer.width*layer.height, r);
		/*for(int i=0;i<layer.width*layer.height;i++){
			unsigned int r;
			if(_rdrand32_step(&r)){
				if((r&65535)==0){
					_rdrand32_step(&r);
					mat[i] = 2*((float)r/(float)INT_MAX-0.5);
				}
				if((r&(16383<<16))==0){
					_rdrand32_step(&r);
					mat[i] = mat[i]+.15*((float)r/(float)INT_MAX-0.5);
				}
			}
		}*/
	}
}
-(void)activate:(float*)vector size:(int)size{
	activate(vector, size);
	/*int i=0;
	__m256 sign_mask = _mm256_set1_ps(-0.f); // -0.f = 1 << 31
	if(size>=8){
		for(;i<size;i+=8){
			__m256 data= _mm256_loadu_ps(vector);
			__m256 data2 = _mm256_andnot_ps(sign_mask, data);
			data2 = _mm256_add_ps(data2, _mm256_set1_ps(1));
			data = _mm256_mul_ps(data, _mm256_rcp_ps(data2));
			//data = _mm256_mul_ps(data, _mm256_set1_ps(0.5));
			//data = _mm256_add_ps(data, _mm256_set1_ps(0.5));
			_mm256_storeu_ps(vector, data);
			vector += 8;
			
		}
		_mm256_zeroupper();
	}
	for(;i<size;i++){
		//vector[i] = tanhf(vector[i]);
		*vector = *vector/(1+fabs(*vector));
		vector++;
	}*/
}

-(void)solve:(float*)inputs outputs:(float*)outputs{
	float mat_result[(_layersize+8)&~0x7] __attribute__((aligned(32)));
	float mat_result_new[(_layersize+8)&~0x7] __attribute__((aligned(32)));
	vDSP_mmul(inputs, 1, [_layerList objectAtIndex:0].matrix, 1, mat_result, 1, 1, _layersize, _inputs);
	[self activate:mat_result size:_layersize];
	for(int i=1;i<[_layerList count] -1;i++){
		
		vDSP_mmul(mat_result, 1, [_layerList objectAtIndex:i].matrix, 1, mat_result_new, 1, 1, _layersize, _layersize);
		[self activate:mat_result_new size:_layersize];
		memcpy(mat_result, mat_result_new, _layersize);
	}
	
	vDSP_mmul(mat_result, 1, [_layerList lastObject].matrix, 1, outputs, 1, 1, _outputs, _layersize);
	//[self activate:outputs size:_outputs];
}
+(CENeuralNetwork*)breedNetwork:(CENeuralNetwork*)one with:(CENeuralNetwork*)two{
	CENeuralNetwork* net = [[CENeuralNetwork alloc]initNoRand:one.inputs outputs:one.outputs layers:one.layers layerSize:one.layersize];
	if(net == nil){
		NSLog(@"Nil Network");
		exit(-1);
	}
	for(int i=0;i<[one.layerList count];i++){
		CENetworkLayer* layerOne = [one.layerList objectAtIndex:i];
		CENetworkLayer* layerTwo = [two.layerList objectAtIndex:i];
		CENetworkLayer* newLayer = [net.layerList objectAtIndex:i];
		int width = layerOne.width;
		for(int j=0;j<layerOne.height;j++){
			//int sw = arc4random_uniform(layerOne.width);
			//bool first = RANDB;
			unsigned int seed;
			_rdrand32_step(&seed);
			srand(seed);
			for(int i=0;i<layerOne.width;i++){
				bool sel = RANDB;
				//newLayer.matrix[j*width + i] =  (layerOne.matrix[j*width+i] +layerTwo.matrix[j*width+i])/2;
				//newLayer.matrix[j*width + i] = (i>=sw)^first ? layerOne.matrix[j*width+i] :layerTwo.matrix[j*width+i];
				newLayer.matrix[j*width + i] = sel ? layerOne.matrix[j*width+i] :layerTwo.matrix[j*width+i];
			}
		}
	}
	return net;
}

@end
