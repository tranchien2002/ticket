module GeneralHelpers

  def self.match_params(params_structure, params, error_info)
    params_structure.each do |key, value|

      #check validation cho truong du lieu cua params ung voi
      #cau truc trong params structure

      #Neu truong du lieu thuoc loai yeu cau can phai co va params
      #khong ton tai truong du lieu do thi them loi khong ton tai du lieu
      #can thiet va tiep tuc match doi voi cac truong tiep sau do

      #Neu ton tai mot hash tuong ung voi key cua params structure thi
      #goi de quy voi value = params structure moi,params[key] tuong ung
      #voi params moi can xet

      if value.is_a?(Hash)
        if params.has_key?(key)
          error_info.concat(check_validation(value, params[key]))
        end

        if value[:status] == Settings.params_attribute_status.required &&
          !params.has_key?(key)

          error_info << "Không tồn tại trường yêu cầu #{key}!"
          next
        end
        match_params(value, params_structure[key], error_info)
      end
    end
  end

  #Validate mot truong du lieu dua tren cau truc params chuan duoc cung cap

  def self.check_validation(params_structure, field)
    error_message = []

    #neu trong cau truc params ton tai truong validation thi goi nhung expression
    #san co trong do de check validation truong du lieu,tra laij message tuong ung
    #neu co

    if params_structure.has_key?(:validation)
      var = field
      params_structure[:validation].each do |v|

        unless eval v[:expression]
          error_message << v[:message]
        end
      end
    end

    return error_message
  end

  def self.get_params_standard_structure(method, params_name)
    return ParamsValidation::PARAMS_VALIDATION[method.to_sym][params_name.to_sym][:params_structure]
  end

  def self.params_validation(method, params_name, params)
    error_info = []
    standard_params_structure = get_params_standard_structure(method, params_name)
    match_params(standard_params_structure, params, error_info)

    if error_info.present?
      message = {
        message: {
          status: 400,
          message: error_info.join(" - ")
        }
      }
      # return error_info

      raise APIError::Common::BadRequest.new(message)
    end
  end
end
