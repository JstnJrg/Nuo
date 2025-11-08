package Complex

import linalg	  "core:math/linalg"
// import intrinsics "base:intrinsics"
// import rand       "core:math/rand"
// import math       "core:math"




_arg    :: proc(z: ^Complex) -> Float 
{ 
	return linalg.atan2(z.y,z.x) 
}

_module :: proc(z: ^Complex) -> Float 
{ 
	return linalg.sqrt(z.x*z.x+z.y*z.y) 
}

_from_polar :: proc(m,p : Float) -> Complex
{
	return Complex{linalg.cos(p),linalg.sin(p)}*m
}

_pow    :: proc(z: ^Complex, n: int) -> Complex
{ 
	n := Float(n)
	m := linalg.pow(_module(z),n)
	p := n*_arg(z)
	return Complex{linalg.cos(p),linalg.sin(p)}*m
}








// linalg :: linalg
// math   :: math
// rand   :: rand


// _EPSILON 	::  0.000001

// _UP 		::  Vec2{0,-1}
// _DOWN 		::  Vec2{0,1}
// _RIGHT 		::  Vec2{1,0}
// _LEFT 		::  Vec2{-1,0}
// _ZERO		:: 	Vec2{0,0}
// _ONE 		:: 	Vec2{1,1}




// // Nota(jstn)
// // set distance = normal.dot(point) -> devolve a distancia a um plano ou recta


// _abs		:: proc "contextless" (a: ^Vec2) -> Vec2  { return Vec2{linalg.abs(a.x),linalg.abs(a.y)}}
// _aspect 	:: proc "contextless" (a: ^Vec2) -> Float { return a.x/a.y}

// _angle 		:: proc "contextless" (a: ^Vec2) -> Float { return linalg.atan2(a.y,a.x) }


// _clampf     :: proc "contextless" (value,min,max: Float) -> Float {
// 	if 		value < min do return min
// 	else if value > max do return max
// 	return 	value
// }
// _clamp 		:: proc "contextless" (a,min,max: ^Vec2) -> Vec2{ return Vec2{math.clamp(a.x,min.x,max.x),math.clamp(a.y,min.y,max.y)} }
// _cross		:: proc "contextless" (a,b: ^Vec2) -> Float{ return a.x*b.y-a.y*b.x }

// _div 		:: proc "contextless" (a,b: ^Vec2) -> Vec2{ return a^/b^ }
// _dot 		:: proc "contextless" (a,b: ^Vec2) -> Float { r := a^*b^; return r.x+r.y }

// _floor 		:: proc "contextless" (a: ^Vec2)      -> Vec2 { return Vec2{linalg.floor(a.x),linalg.floor(a.y)}}
// _from_angle :: proc "contextless" (angle: Float) -> Vec2 { return Vec2{linalg.sin(angle),linalg.cos(angle)}}

// _from_circle :: proc "contextless" (angle,radius: Float) -> Vec2 { return Vec2{radius*linalg.sin(angle),radius*linalg.cos(angle)} }

// _invert 		 :: proc "contextless" (a: ^Vec2)    -> Vec2 { return swizzle(a^,1,0)}
// _is_equal_approx :: proc "contextless" (a,b: ^Vec2) -> bool {
// 	dx := linalg.abs(b.x-a.x)
// 	dy := linalg.abs(b.y-a.y)
// 	return true if dx <= _EPSILON && dy <= _EPSILON else false
// }

// _is_normalized :: proc "contextless" (a: ^Vec2) -> bool { return linalg.abs(1-_length_squared(a)) <= _EPSILON}

// _mult  		 :: proc "contextless" (a,b: ^Vec2) -> Vec2{ return a^*b^ }
// _max 		 :: proc "contextless" (a,b: ^Vec2) -> Vec2{ return Vec2{ a.x > b.x ? a.x: b.x,a.y > b.y ? a.y: b.y} }
// _normalize 	 :: proc "contextless" (a: ^Vec2)   -> Vec2{ return a^/_length(a)}
// _min 		 :: proc               (a,b: ^Vec2) -> Vec2{ return Vec2{ a.x < b.x ? a.x: b.x,a.y < b.y ? a.y: b.y}}
// _move_toward :: proc "contextless" (a,b: ^Vec2, dt: Float) -> Vec2 {
// 	vd := b^-a^
// 	len := _length(&vd)
// 	return b^ if (len <= dt || len < _EPSILON) else a^+(vd/len)*dt
// }

// _posmodf :: proc "contextless" (a,b: $T) -> (value: T) where intrinsics.type_is_numeric(T) {
// 	value = linalg.mod(a,b) //resto
// 	if (value < 0 && b > 0) || (value > 0 && b < 0 ) do value += b
// 	return 
// }

// _posmod :: proc "contextless" (a: ^Vec2, value: Float) -> Vec2 {
// 	return Vec2{_posmodf(a.x,value),_posmodf(a.y,value)}
// }

// _smoothstep :: proc "contextless" (a,b: ^Vec2, dt: Float) -> Vec2 {
// 	x := math.smoothstep(a.x,b.x,dt)
// 	y := math.smoothstep(a.y,b.y,dt)
// 	return Vec2{x,y}
// }
// _slerp :: proc "contextless" (a,b: ^Vec2, dt : Float) -> Vec2 { 

// 	cos_alpha := _dot(a, b)
	
// 	alpha     := linalg.acos(cos_alpha)
// 	sin_alpha := linalg.sin(alpha)

// 	t1 := linalg.sin((1 - dt) * alpha) / sin_alpha
// 	t2 := linalg.sin(dt * alpha) / sin_alpha

// 	// print(t1,t2,sin_alpha)

// 	return a^*t1+b^*t2
// }
// _sign       	:: proc "contextless" (a: ^Vec2)    -> Vec2{ return Vec2{math.sign(a.x),math.sign(a.y)}}
// _sum  			:: proc "contextless" (a,b: ^Vec2)  -> Vec2{ return a^+b^ }
// _sub  			:: proc "contextless" (a,b: ^Vec2)  -> Vec2{ return a^-b^ }
// _slide 			:: proc "contextless" (a,n: ^Vec2) 	   -> Vec2{ return a^-n^*_dot(a,n) }

// _lerp 		  	:: proc "contextless" (a,b: ^Vec2, dt: Float) -> Vec2 { return Vec2{a.x+(b.x-a.x)*dt,a.y+(b.y-a.y)*dt}}
// _limit_length 	:: proc "contextless" (a: ^Vec2, length_t: Float) -> Vec2 { len := _length(a); return (a^/len)*length_t if len > length_t else a^ }
// _length 		:: proc "contextless" (a: ^Vec2) -> Float { return linalg.sqrt(_dot(a,a))}
// _length_squared :: proc "contextless" (a: ^Vec2) -> Float { return _dot(a,a) }


// _orthogonal 	:: proc "contextless" (a:   ^Vec2)   -> Vec2 { return _rotate(a,-math.PI/2)}
// _project 		:: proc "contextless" (a,b: ^Vec2) -> Vec2 { return (_dot(a,b)/_length_squared(b))*b^}

// _round 			:: proc "contextless" (a:   ^Vec2) -> Vec2 { return Vec2{linalg.round(a.x),linalg.round(a.y)}}
// _rand 			:: proc               ()           -> Vec2 { return Vec2{rand.float32(),rand.float32()}}
// _reflect 		:: proc "contextless" (a,n: ^Vec2) -> Vec2{ return a^-2*_dot(a,n)*n^}
// _rotate 		:: proc "contextless" (a:   ^Vec2, theta: Float) -> Vec2 {

// 	cos := linalg.cos(theta)
// 	sin := linalg.sin(theta)

// 	x := a.x*cos-a.y*sin
// 	y := a.x*sin+a.y*cos

// 	a.x = x
// 	a.y = y

// 	return a^
// }


// _stepfy :: proc "contextless" (a:^ Vec2,step : $T) -> Vec2 where type_is_numeric(T) {
// 	if step == 0 do return 0
// 	return Vec2{step*linalg.floor((a.x/step)+0.5),step*linalg.floor((a.y/step)+0.5)}
// }
