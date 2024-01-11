class ComplexEnum {
			static func User(name:String, surname:String) -> HxEnumConstructor {
					return (_hx_name: "User", _hx_index: 0, enum: "ComplexEnum", params: [name, surname]);
				}
static func Company(id:String) -> HxEnumConstructor {
					return (_hx_name: "Company", _hx_index: 1, enum: "ComplexEnum", params: [id]);
				}
		}