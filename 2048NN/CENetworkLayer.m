//
//  CENetworkLayer.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "CENetworkLayer.h"
#include <immintrin.h>
#include <mm_malloc.h>
#define randf() ((CGFloat)rand() / RAND_MAX)-0.5
@implementation CENetworkLayer
-(id)init:(float*)matrix width:(int)width height:(int)height{
	self = [super init];
	
	_matrix = _mm_malloc(sizeof(float)*width*height, 32);
	memcpy(_matrix, matrix, sizeof(float)*width*height);
	_width = width;
	_height = height;
	return self;
}
-(id)init:(int)width height:(int)height{
	self = [super init];
	_width = width;
	_height = height;
	_matrix = _mm_malloc(sizeof(float)*width*height,32);
	return self;
}
-(id)initRandom:(int)width height:(int)height{
	self = [super init];
	_width = width;
	_height = height;
	unsigned int r;
	_matrix = _mm_malloc(sizeof(float)*width*height,32);
	for(int j=0;j<_height;j++){
		for(int i=0;i<_width;i++){
			_rdrand32_step(&r);
			_matrix[j*_width + i] = (float)(signed int)(r&~(2>>31))/(float)INT_MAX;
		}
	}
	return self;
}
-(void)dealloc{
	if(_matrix != nil)_mm_free(_matrix);
	_matrix = nil;
}

@end
