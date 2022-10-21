class ClientDetails < ApplicationStruct
  attribute :client, Person
  attribute? :partner, Person
end
