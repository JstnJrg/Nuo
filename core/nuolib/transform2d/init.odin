package Transform2D

init :: proc(cid: int)
{
	register_operators()
	register_properties(cid)
	b_methods(cid)
}

b_methods :: proc(cid: int)
{
	B_METHOD(cid,"basis_xform_inv",basis_xform_inv,.INTRINSICS)
	B_METHOD(cid,"basis_xform",basis_xform,.INTRINSICS)
	B_METHOD(cid,"determinant",determinant,.INTRINSICS)
	B_METHOD(cid,"xform",xform,.INTRINSICS)

	B_METHOD(cid,"xform_inv",xform_inv,.INTRINSICS)
	B_METHOD(cid,"get_inverse",get_inverse,.INTRINSICS)
	B_METHOD(cid,"orthonormalized",orthonormalized,.INTRINSICS)
	B_METHOD(cid,"rotated",rotated,.INTRINSICS)

	B_METHOD(cid,"scaled",scaled,.INTRINSICS)
	B_METHOD(cid,"scaledV",scaledV,.INTRINSICS)
	B_METHOD(cid,"scaled_local",scaled_local,.INTRINSICS)
	B_METHOD(cid,"translated_local",translated_local,.INTRINSICS)
	
	B_METHOD(cid,"translated",translated,.INTRINSICS)
	B_METHOD(cid,"untranslated",untranslated,.INTRINSICS)
	B_METHOD(cid,"affine_inverse",affine_inverse,.INTRINSICS)
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
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)
	// B_METHOD(cid,"",)


}
