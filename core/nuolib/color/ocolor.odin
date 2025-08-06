package Color

import math "core:math"
import rand "core:math/rand"

_rand31              :: rand.int31
_float32             :: rand.float32

rgba_to_Color        :: proc(r,b,g,a: u8)  -> Color {return Color{r,g,b,a} }
rgba_to_Color_remap  :: proc(r,b,g,a: Float)  -> Color { return Color{255-remap(r,u8),255-remap(g,u8),255-remap(b,u8),255-remap(a,u8)} }

remap         :: proc "contextless" (f : Float, $T : typeid ) -> T { return T(math.remap(f,0,1,0,255)) }
_luminance    :: proc "contextless" (color: ^Color) -> u8 { return color.r*remap(0.2126,u8)+color.g*remap(0.7152,u8)+color.b*remap(0.0722,u8) }

_darkened     :: proc "contextless" (color: ^Color, amount: ^Float) -> Color { return Color{ color.r*(255-remap(amount^,u8)),color.g*(255-remap(amount^,u8)),color.b*(255-remap(amount^,u8)),color.a} } 

_lightened    :: proc "contextless" (color: ^Color, amount: ^Float) -> Color { return Color{ color.r+(255-remap(amount^,u8)),color.g+(255-remap(amount^,u8)),color.b+(255-remap(amount^,u8)),color.a} }

_invert       :: proc "contextless" (color: ^Color) -> Color 
{
	r : Color
	r.r = 0xFF - color.r
	r.g = 0xFF - color.g
	r.b = 0xFF - color.b
	r.a = 0xFF - color.a

	return r
}
_lerp         :: proc "contextless" (color,color_to: ^Color, dt: Float) -> Color 
{
	r : Color
	r.r = math.lerp(color.r,color_to.r,u8(dt))
	r.g = math.lerp(color.g,color_to.g,u8(dt))
	r.b = math.lerp(color.b,color_to.b,u8(dt))
	r.a = math.lerp(color.a,color_to.a,u8(dt))
	return r
}
