package General


murmur3_one_float :: proc{murmur3_one_f32,murmur3_one_f64}


@(optimization_mode="favor_size")
one_64 :: proc "contextless" ( #any_int value : u64) -> u32 {
	v := value
	v  = (~v) + (v << 18)
	v  = v ~ (v >> 31)
	v  = v * 21
	v  = v ~ (v >> 11);
	v  = v + (v << 6);
	v  = v ~ (v >> 22);
	return u32(v)
}


@(optimization_mode="favor_size")
djb2 :: proc "contextless" (data: []byte, seed := u32(5381)) -> u32 {
	hash: u32 = seed
	for b in data {
		hash = (hash << 5) + hash + u32(b) // hash * 33 + u32(b)
	}
	return hash
}


@(optimization_mode="favor_size")
djb2_32 :: proc "contextless" ( #any_int data: u32 , seed := u32(5381)) -> u32 {
	hash: u32 = seed
	return ((hash << 5)+hash)+data
}

@(optimization_mode="favor_size")
djb2_f32 :: proc "contextless" ( value : f64 , seed := u32(5381)) -> u32 {
	u  : union { f64, u64 }
	hash := seed
	u     = value
	return ((hash << 5)+hash)+one_64(transmute(u64)u.(f64))
}

@(optimization_mode="favor_size")
fnv32a :: proc "contextless" (data: []byte, seed := u32(0x811c9dc5)) -> u32 {
	h: u32 = seed
	for b in data {
		h = (h ~ u32(b)) * 0x01000193
	}
	return h
}

// @(optimization_mode="favor_size")
// djb2_f64 :: proc "contextless" ( value : f64 , seed := u32(5381)) -> u32 {
// 	u  : union { f64, u64 }
// 	hash := seed
// 	u     = value
// 	return ((hash << 5)+hash)+one_64(transmute(u64)u.(f64))
// }

@(optimization_mode="favor_size")
murmur3_64 :: proc "contextless" (#any_int value,seed: u64) -> u64 {
	value := value
	value ~= seed
	value ~= value >> 33
	value *= 0xff51afd7ed558ccd
	value ~= value >> 33
	value *= 0xc4ceb9fe1a85ec53
	value ~= value >> 33
	return value
}

@(optimization_mode="favor_size")
murmur3_one_32 :: proc "contextless" (#any_int value: u32 , seed := u32(0)) -> u32 {
	value := value
	seed  := seed
	value *= 0xcc9e2d51;
	value  = (value << 15) | (value >> 17);
	value *= 0x1b873593;
	seed  ~= value;
	seed   = (seed << 13) | (seed >> 19);
	seed   = seed * 5 + 0xe6546b64;
	return seed
}

@(optimization_mode="favor_size")
murmur3_one_f32 :: proc "contextless" (value: f32 , seed := u32(0)) -> u32 {
	u  : union { f32, u32}
	u  = value
	return murmur3_one_32(transmute(u32)u.(f32),seed)
}

@(optimization_mode="favor_size")
murmur3_one_64 :: proc "contextless" (value: u64 , seed := u32(0)) -> u32 {
	seed := murmur3_one_32( value & 0xFFFFFFFF, seed)
	return  murmur3_one_32( value >> 32, seed)
}

@(optimization_mode="favor_size")
murmur3_one_f64 :: proc "contextless" (value: f64 , seed := u32(0)) -> u32 {
	u  : union { f64, u64}
	u  = value
	return murmur3_one_64(transmute(u64)u.(f64),seed)
}


@(optimization_mode="favor_size")
rotl32 :: proc "contextless" (x: u32, r: u8) -> u32 {
	return (x << r) | (x >> (32-r))
}


@(optimization_mode="favor_size")
fmix32 :: proc "contextless" ( #any_int value : u32) -> u32 {
	value := value
	value ~= value >> 16
	value *= 0x85ebca6b
	value ~= value >> 13
	value *= 0xc2b2ae35
	value ~= value >> 16
	return value
}
