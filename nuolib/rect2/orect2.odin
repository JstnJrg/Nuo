package Rect2

import vector2   "nuo:nuolib/vec2"
import linalg	 "core:math/linalg"
import math      "core:math"


_abs :: #force_inline proc "contextless" (r,o: ^Rect2) { 

	pos   := &r[0]
	size  := &r[1]

	o[0] = Vec2{pos.x+linalg.min(size.x,0),pos.y+linalg.min(size.y,0)}
	o[1] = Vec2{linalg.abs(size.x),linalg.abs(size.y)}
}

_clip :: #force_inline proc "contextless" (r0,r1,o: ^Rect2)
{
	if !_intersects(r0,r1) do return 

	position0   := &r0[0]
	size0  	    := &r0[1]

	position1   := &r1[0]
	size1  	    := &r1[1]

	o[0].x = linalg.max(position1.x,position0.x)
	o[0].y = linalg.max(position1.y,position0.y)

	end1 := position1^+size1^
	end0 := position0^+size0^

	o[1].x = linalg.min(end1.x,end0.x)-o[0].x
	o[1].y = linalg.min(end1.y,end0.y)-o[0].y
}

_distance_to :: #force_inline proc "contextless" (r: ^Rect2, point: ^Vec2, o: ^Float)
{
	dist   : Vec2
	inside : bool = true

	position := &r[0]
	size     := &r[1]

	if point.x < position.x
	{
		dist.x = position.x-point.x
		inside = false
	}

	if point.y < position.y
	{
		d := position.y-point.y
		dist.y += d if inside else linalg.min(d,dist.y)
		inside = false
	}

	if point.x >= position.x+size.x
	{
		d := point.x-(position.x+size.x)
		dist.x += d if inside else linalg.min(d,dist.x)
		inside = false
	}

	if point.y >= position.y+size.y
	{
		d := point.y-(position.y+size.y)
		dist.y += d if inside else linalg.min(d,dist.y)
		inside = false
	}

	o^ = 0 if inside else vector2._length(&dist)
}

_encloses :: #force_inline proc "contextless"(r0,r1: ^Rect2) -> bool {

	position0 := &r0[0]
	size0     := &r0[1]

	position1 := &r1[0]
	size1     := &r1[1]

	return (position1.x >= position0.x && position1.y >= position0.y && position1.x+size1.x <= position0.x+size0.x && position1.y+size1.y <= position0.y+size0.y)
}

_expand :: #force_inline proc "contextless" (r,o: ^Rect2,to: ^Vec2) {

	pos   := &r[0]
	size  := &r[1]

	begin := pos^
	end   := size^+begin

	if to.x < begin.x do begin.x = to.x
	if to.y < begin.y do begin.y = to.y
	if to.x > end.x do end.x = to.x
	if to.y > end.y do end.y = to.y

	o[0] = begin
	o[1] = end-begin
}

_get_center :: #force_inline proc "contextless" (r: ^Rect2,o: ^Vec2) { o^ = (r[0]+r[1])*0.5 }
_get_area   :: #force_inline proc "contextless" (r: ^Rect2,o: ^Float) { o^ = r[1].x*r[1].y }

_get_support :: #force_inline proc "contextless" (r: ^Rect2,direction,support: ^Vec2) { 
	
	if direction.x > 0.0 do support.x += r[1].x
	if direction.y > 0.0 do support.y += r[1].y

	support.x += r[0].x
	support.y += r[0].y
}

_grow :: #force_inline proc "contextless" (r,o: ^Rect2,offset: ^Float) {
	o[0] = r[0]-offset^
	o[1] = r[1]+offset^*2
 }

_grow_individual :: #force_inline proc "contextless" (r,o: ^Rect2, pos_p : ^[4]Float ) {
	
	// left
	// top
	// right
	// bottom


	o[0] = r[0]
	o[1] = r[1]

	o[0].x -= pos_p[0] //left
	o[0].y -= pos_p[1] //top
	
	o[1].x += pos_p[0]+pos_p[2]
	o[1].y += pos_p[1]+pos_p[3]
}


_has_point :: #force_inline proc "contextless" (r: ^Rect2, point: ^Vec2) -> (has: bool)
{
	position   := &r[0]
	size  	   := &r[1]

	if point.x < position.x do return 
	if point.y < position.y do return

	if point.x >= position.x+size.x do return
	if point.y >= position.y+size.y do return

	has = true
	return
}


_has_no_area :: #force_inline proc "contextless" (r: ^Rect2) -> bool
{
	position   := &r[0]
	size  	   := &r[1]
	return size.x <= 0 || size.y <= 0
}


_intersects :: #force_inline proc "contextless" (r0,r1: ^Rect2, include_borders:= true) -> bool
{
	position0   := &r0[0]
	size0  	    := &r0[1]

	position1   := &r1[0]
	size1  	    := &r1[1]

	if include_borders
	{
		if position0.x > position1.x+size1.x do return false
		if position0.x+size0.x < position1.x do return false
		if position0.y > position1.y+size1.y do return false
		if position0.y+size0.y < position1.y do return false
	}
	else 
	{
		if position0.x >= position1.x+size1.x do return false
		if position0.x+size0.x <= position1.x do return false
		if position0.y >= position1.y+size1.y do return false
		if position0.y+size0.y <= position1.y do return false
	}
	return true
}


_merge :: #force_inline proc "contextless" (r0,r1,o: ^Rect2)
{

	position0   := &r0[0]
	size0  	    := &r0[1]

	position1   := &r1[0]
	size1  	    := &r1[1]

	o[0].x = linalg.min(position1.x,position0.x)
	o[0].y = linalg.min(position1.y,position0.y)

	o[1].x = linalg.max(position1.x+size1.x,position0.x+size0.x)
	o[1].y = linalg.max(position1.y+size1.y,position0.y+size0.y)

	o[1] -= o[0] 
}