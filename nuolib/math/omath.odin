package Math

import linalg "core:math/linalg"
import math   "core:math"
import rand   "core:math/rand"


PI   :: linalg.PI
TAU  :: linalg.TAU
E    :: linalg.E



to_radians :: linalg.to_radians
to_degrees :: linalg.to_degrees

min        :: linalg.min
max        :: linalg.max
abs        :: linalg.abs

sign       :: linalg.sign
clamp      :: linalg.clamp
lerp       :: linalg.lerp

unlerp     :: linalg.unlerp
smoothstep :: linalg.smoothstep
sqrt       :: linalg.sqrt

cos        :: linalg.cos
sin        :: linalg.sin
tan        :: linalg.tan

atan2      :: linalg.atan2

acos       :: linalg.acos
asin       :: linalg.asin
atan       :: linalg.atan

ln         :: linalg.ln
log        :: linalg.log
exp        :: linalg.exp

pow        :: linalg.pow

smootherstep :: linalg.smootherstep
floor        :: linalg.floor
round        :: linalg.round
mod          :: linalg.mod

// 
remap         :: math.remap
remap_clamped :: math.remap_clamped
wrap          :: math.wrap
// smoothstep    :: math.smoothstep

hypot         :: math.hypot

// 
int31         :: rand.int31
float32       :: rand.float32
float32_range :: rand.float32_range