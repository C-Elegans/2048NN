//
//  CENetworkLayer.m
//  2048NN
//
//  Created by Michael Nolan on 3/2/16.
//  Copyright © 2016 Michael Nolan. All rights reserved.
//

#import "CENetworkLayer.h"
#define randf() ((CGFloat)rand() / RAND_MAX)
@implementation CENetworkLayer
-(id)init:(float*)matrix width:(int)width height:(int)height{
	self = [super init];
	_matrix = malloc(sizeof(float)*width*height);
	memcpy(_matrix, matrix, sizeof(float)*width*height);
	_width = width;
	_height = height;
	return self;
}
-(id)initRandom:(int)width height:(int)height{
	self = [super init];
	_width = width;
	_height = height;
	_matrix = malloc(sizeof(float)*width*height);
	for(int j=0;j<_height;j++){
		for(int i=0;i<_width;i++){
			_matrix[j*_width + i] = randf();
		}
	}
	return self;
}
-(void)dealloc{
	free(_matrix);
}

@end
