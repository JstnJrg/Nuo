package Range

init :: proc(cid: int)
{
	register_operators()
	// register_properties(cid)
	b_methods(cid)
}

b_methods :: proc(cid: int)
{

	B_METHOD(cid,".iterate",iterate,.INTRINSICS)
	B_METHOD(cid,".next",next,.INTRINSICS)
	B_METHOD(cid,".end",end,.INTRINSICS)
	// 


	B_METHOD(cid,"length",length,.INTRINSICS)
	B_METHOD(cid,"step",step,.INTRINSICS)
	B_METHOD(cid,"reverse",reverse,.INTRINSICS)
	B_METHOD(cid,"first",first,.INTRINSICS)
	B_METHOD(cid,"last",last,.INTRINSICS)
	B_METHOD(cid,"contains",contains,.INTRINSICS)
	B_METHOD(cid,"at",at,.INTRINSICS)
	B_METHOD(cid,"to_array",to_array,.INTRINSICS)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)


}
