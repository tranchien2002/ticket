module ParamsValidation

  PARAMS_VALIDATION = {
    create: {
      apartment_user: {
        params_structure: {
          apartment_id: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present?", message: "Không tìm thấy căn hộ"}
            ]
          },
          receival_date: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || (Date.parse(var) rescue nil != nil)", message: "Ngày nhận không hợp lệ"}
            ]
          },
          arrival_date: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || (Date.parse(var) rescue nil != nil)", message: "Ngày đến không hợp lệ"}
            ]
          },
          water_fee_id: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || var.class == Fixnum", message: "Id không hợp lệ"}
            ]
          },
          electricity_fee_id: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || var.class == Fixnum", message: "Id không hợp lệ"}
            ]
          },
          management_fee_id: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || var.class == Fixnum", message: "Id không hợp lệ"}
            ]
          }
        }
      },
      customer: {
        params_structure: {
          name: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.length <= 255", message: "Tên có độ dài quá mức cho phép!"},
              {expression: "var.present?", message: "Trường name không được bỏ trống!"}
            ]
          },
          code: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var.present?", message: "Trường code không được bỏ trống!"}
            ]
          },
          phone: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.match(/^0[0-9]{9,11}$/)", message: "Số điện thoại không hợp lệ"}
            ]
          },
          phone2: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || var.match(/^0[0-9]{9,11}$/)", message: "Số điện thoại không hợp lệ"}
            ]
          },
          birthdate: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || Date.parse(var) rescue nil != nil", message: "Ngày sinh không hợp lệ"}
            ]
          },
          gender: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || var.class == Fixnum", message: "Giới tính không hợp lệ"}
            ]
          },
          identification_date: {
            status: Settings.params_attribute_status.optional,
            validation: [
              {expression: "var.blank? || Date.parse(var) rescue nil != nil", message: "Ngày cấp CMND không hợp lệ"}
            ]
          },
          customer_type: {
            status: Settings.params_attribute_status.required,
            validation: [
              {expression: "var == 'owner' || var == 'relation'", message: "Chưa nhập loại khách hàng"}
            ]
          }
        }
      }
    }
  }
end
