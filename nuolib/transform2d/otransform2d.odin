
package Transform2D

import vector2   "nuo:nuolib/vec2"
import rect2     "nuo:nuolib/rect2"
import linalg    "core:math/linalg"

// import rect2    "olib:rect2"

// import intrinsics "base:intrinsics"

mult_x :: proc "contextless" (t: ^mat2x3 ,a: ^Vec2) -> Float #no_bounds_check {	return t[0,0]*a.x+t[0,1]*a.y }
mult_y :: proc "contextless" (t: ^mat2x3 ,a: ^Vec2) -> Float #no_bounds_check {	return t[1,0]*a.x+t[1,1]*a.y }


_affine_inverse    :: proc "contextless" (t,r: ^mat2x3) -> bool {

	err : bool

	r[0] = t[0]
	r[1] = t[1]
	r[2] = t[2]

	det := _basis_determinant(t)
	if det == 0 { err = true; det = 1e6 }
	
	idet := 1.0/det

	// SWAP
	r[0,0] = t[1,1]
	r[1,1] = t[0,0]

	r[0]  *= Vec2{idet,-idet}
	r[1]  *= Vec2{-idet,idet}

	temp  := -r[2]
	r[2]   = _basis_xform(r,&temp)

	return err
}

_basis_xform_inv   :: proc "contextless" (t: ^mat2x3, a: ^Vec2) -> Vec2 { return Vec2{vector2._dot(&t[0],a),vector2._dot(&t[1],a)}}
_basis_xform 	   :: proc "contextless" (t: ^mat2x3, a: ^Vec2) -> Vec2 { return Vec2{mult_x(t,a),mult_y(t,a)}}

_basis_determinant :: proc "contextless" (t: ^mat2x3) -> Float {	d := swizzle(t[0],0,1)*swizzle(t[1],1,0); return d.x-d.y }

// get_identity :: proc "contextless" () -> transform2d #no_bounds_check { t : transform2d; t[0] = vector2.RIGHT; t[1] = vector2.DOWN;t[2] = vector2.ZERO; return t}
_get_rotation_ox :: proc "contextless" (t: ^mat2x3) -> Float { return linalg.atan2(t[0].y,t[0].x)}
_get_rotation_oy :: proc "contextless" (t: ^mat2x3) -> Float { return linalg.atan2(t[1].x,t[1].y)}
// get_rotation_origin :: proc "contextless" (t: transform2d) -> f32 #no_bounds_check { return linalg.atan2(t[2].y,t[2].x)}
_get_origin      :: proc "contextless" (t: ^mat2x3) -> Vec2  { return t[2] }

@(private="file")
get_rotation_mat :: #force_inline proc "contextless" (theta: Float) -> matrix[2,2]Float
{
	cos := linalg.cos(theta)
	sin := linalg.sin(theta)

	m := matrix[2,2]Float{
		 cos,  sin,
		 -sin,  cos
	}

	return m
}


_from_angle :: #force_inline proc "contextless" (t,o: ^mat2x3,theta: Float)
{
	cos := linalg.cos(theta)
	sin := linalg.sin(theta)

	o[0] = Vec2{cos,sin}
	o[1] = Vec2{-sin,cos}
	o[2] = t[2]
}




// get_rotation_mat_scaled :: proc "contextless" (theta,scale: f32) -> matrix[2,2]f32 #no_bounds_check
// {
// 	cos := linalg.cos(theta)*scale
// 	sin := linalg.sin(theta)*scale

// 	m := matrix[2,2]f32 {
// 		 cos, sin,
// 		 -sin,  cos
// 	}
// 	return m
// }
// get_rotation_mat_scaledV :: proc "contextless" (theta: f32, scale: vec2) -> matrix[2,2]f32 #no_bounds_check
// {
// 	cos := linalg.cos(theta)
// 	sin := linalg.sin(theta)

// 	m := matrix[2,2]f32 {
// 		 cos*scale.x, sin*scale.x,
// 		 -sin*scale.y,  cos*scale.y
// 	}
// 	return m
// }
_get_scale :: proc "contextless" (t: ^mat2x3) -> Vec2 { sum := t[0]+t[1]; return vector2._abs(&sum) }


// Nota(jstn): essa função presume que a matriz não possui escala, seja
// X: Vector2(1,0) e Y: Vector2(0,1)
_inverse ::   proc "contextless" (from,to: ^mat2x3) {
	
	// SWAP
	to[0]   = from[0]
	to[1]   = from[1]

	to[0,1] = from[1,0]
	to[1,0] = from[0,1]

	temp    := -from[2]
	to[2]   = _basis_xform(from,&temp)
}


// looking_at :: proc "contextless" (t,r: ^mat2x3, to: ^Vec2)
// {


// }


_move_toward :: proc "contextless" (from: ^mat2x3, to: ^Vec2, dt: Float) { from[2] = vector2._move_toward(&from[2],to,dt) }


// mult_transform :: proc "contextless" (t1,t2: transform2d) -> transform2d #no_bounds_check
// {
// 	t1 := t1
// 	t2 := t2

// 	t1[2] = xform(t1,t2[2])
// 	x0,x1,y0,y1 := mult_x(t1,t2[0]),mult_y(t1,t2[0]),mult_x(t1,t2[1]),mult_y(t1,t2[1])

// 	t1[0].x = x0
// 	t1[0].y = x1
// 	t1[1].x = y0
// 	t1[1].y = y1

// 	return t1
// }


_orthonormalize :: proc "contextless" (t,r: ^mat2x3) 
{
	x := vector2._normalize(&t[0])
	y := (t[1]-x*vector2._dot(&x,&t[1]))

	y = vector2._normalize(&y)
	
	r[0] = x
	r[1] = y
	r[2] = t[2]

}


// Nota(jstn): é equivalente
_rotated :: proc "contextless" (t,r: ^mat2x3,theta: Float) #no_bounds_check
{
	m := get_rotation_mat(theta)
	r[0] = t[0]*m
	r[1] = t[1]*m
	r[2] = t[2]*m
}

_rotate :: proc "contextless" (t: ^mat2x3,theta: Float) #no_bounds_check
{
	m := get_rotation_mat(theta)
	t[0] *= m
	t[1] *= m
	t[2] *= m
}


_set_rotation :: proc "contextless" (t: ^mat2x3, theta: Float)
{
	m := get_rotation_mat(theta)
	t[0] = m*vector2._RIGHT
	t[1] = m*vector2._DOWN
	t[2] *= m 
}

_set_rotation_no_origin :: proc "contextless" (t: ^mat2x3, theta: Float)
{
	m := get_rotation_mat(theta)
	t[0] = m*vector2._RIGHT
	t[1] = m*vector2._DOWN
}


// rotate_rect :: proc "contextless" (t: transform2d, r: rect_2d) -> rect_2d #no_bounds_check
// {
// 	dir_r := vector2.normalize(r.size)
// 	rect : rect_2d

// 	// rect.position = ends[0]
// 	// rect2d.expand(&rect,ends[1])
// 	// rect2d.expand(&rect,ends[2])
// 	// rect2d.expand(&rect,ends[3])

// 	return rect

// }


_set_identity :: proc "contextless" (t: ^mat2x3) {	t[0] = vector2._RIGHT; t[1] = vector2._DOWN;t[2] = vector2._ZERO }
// set_origin :: proc "contextless" (t: ^transform2d, o: vec2) #no_bounds_check {	t[2] = o }
// set_origin_rl :: proc "contextless" (t: transform2d, o: vec2) -> transform2d #no_bounds_check {	t :=t; t[2] = o ; return t } 
// set_rotation_and_scaleV :: proc "contextless" (t: ^transform2d, theta: f32, scale: vec2) #no_bounds_check
// {
// 	m := get_rotation_mat_scaledV(theta,scale)
// 	t[0] *= m
// 	t[1] *= m
// 	t[2] *= m
// }
_set_scale :: proc "contextless" (t: ^mat2x3, scale : Float)   { t[0] = vector2._normalize(&t[0])*scale; t[1] = vector2._normalize(&t[1])*scale; t[2] *= scale }
_scaled    :: proc "contextless" (t,o: ^mat2x3, scale : Float) { o[0] = t[0]*scale; o[1] = t[1]*scale; o[2] = t[2]*scale }
_scaledV   :: proc "contextless" (t,o: ^mat2x3, scale : ^Vec2) { o[0] = t[0]*scale^; o[1] = t[1]*scale^; o[2] = t[2]*scale^ }

_scaledV_local  :: proc "contextless" (t,o: ^mat2x3, scale : ^Vec2) { o[0] = t[0]*scale^; o[1] = t[1]*scale^; o[2] = t[2] }



// scale_basis :: proc "contextless" (t: ^transform2d, scale : vec2) #no_bounds_check {t[0] *=scale; t[1] *= scale}
// scaleV :: proc "contextless" (t: ^transform2d, scale : vec2) #no_bounds_check { scale_basis(t,scale); t[2] += scale}
// scale :: proc "contextless" (t: ^transform2d, scale : f32) #no_bounds_check { offset := vector2.ONE*scale ;scale_basis(t,offset); t[2] += offset}


_translate               :: proc "contextless" (t: ^mat2x3, offset: ^Vec2)   {t[2] += _basis_xform(t,offset)}
_translated              :: proc "contextless" (t,o: ^mat2x3, offset: ^Vec2) {o[0] = t[0] ; o[1] = t[1] ; o[2] = t[2]+offset^}
_translated_local        :: proc "contextless" (t,o: ^mat2x3, offset: ^Vec2) {o[0] = t[0] ; o[1] = t[1] ; o[2] = t[2]+_basis_xform(t,offset)}

_untranslated            :: proc "contextless" (t,o: ^mat2x3 ) {o[0] = t[0] ; o[1] = t[1] ; o[2] = vector2._ZERO}



_translate_inv           :: proc "contextless" (t: ^mat2x3, offset: ^Vec2)   {t[2] += _basis_xform_inv(t,offset)}
_translateV_no_relactive :: proc "contextless" (t: ^mat2x3, offset: ^Vec2)   {t[2] += offset^}

_xform     :: proc "contextless" (t: ^mat2x3, a: ^Vec2) -> Vec2 { return Vec2{mult_x(t,a),mult_y(t,a)}+t[2]}
_xform_inv :: proc "contextless" (t: ^mat2x3, a: ^Vec2) -> Vec2 { vd := vector2._sub(a,&t[2]); return Vec2{vector2._dot(&t[0],&vd),vector2._dot(&t[1],&vd)}}

_xform_rect :: proc "contextless" (t: ^mat2x3, r,o: ^Rect2) {

	position := &r[0]
	size     := &r[1]

	x := t[0]*size.x
	y := t[1]*size.y

	pos := _xform(t,position)
	o[0] = pos
	
	a := pos+x
	b := pos+y
	c := pos+x+y

	rect2._expand(o,o,&a)
	rect2._expand(o,o,&b)
	rect2._expand(o,o,&c)
}


_relative :: proc "contextless" (t,r,o: ^mat2x3)
{

	o[0] = t[0]
	o[1] = t[1]
	// o[2] = t[2]

	o[2]   = _xform(t,&r[2])

	x0 := mult_x(o,&r[0])
	x1 := mult_y(o,&r[0])

	y0 := mult_x(o,&r[1])
	y1 := mult_y(o,&r[1])

	o[0,0] = x0
	o[0,1] = x1

	o[1,0] = y0
	o[1,1] = y1
}