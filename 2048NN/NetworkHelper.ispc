export void activate(uniform float vector[], uniform int size){
	foreach(i=0 ... size){
		float f = vector[i];
		//vector[i] = f*rcp(1+abs(f));
		vector[i] = 2*rcp(1+exp(-2f));
	}


}
export void mutate(uniform float vector[], uniform int size, uniform int seed){
	RNGState state;
	seed_rng(&state, programIndex+seed);
	foreach(i=0...size){
		if((random(&state)&65535) == 0){
			vector[i] = (frandom(&state)*2)-1;
		}
		if((random(&state)&(16383<<16)) == 0){
			vector[i] =vector[i] + (frandom(&state)-.5)*.1;
		}

	}
}
export void mix_net(uniform float vector1[], uniform float vector2[], uniform int size, uniform int seed, uniform float output[]){
	RNGState state;
	seed_rng(&state, programIndex+seed);
	foreach(i=0...size){
		output[i] = (random(&state)&1) ? vector1[i] : vector2[i];
	}
}