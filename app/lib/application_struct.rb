class ApplicationStruct < Dry::Struct
  transform_keys(&:to_sym)
  
   include ActiveModel::Validations

   class SchemaValidator < ActiveModel::Validator
     def validate(record)
       errors = options[:schema].call(record.attributes).errors.to_h

       errors.each_pair do |key, messages|
         messages.each do |message|
           record.errors.add(key, message)
         end
       end
      end
    end
end
