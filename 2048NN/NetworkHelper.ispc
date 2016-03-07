export void activate(uniform float vector[], uniform int size){
	foreach(i=0 ... size){
		float f = vector[i];
		vector[i] = f/(1+abs(f));
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