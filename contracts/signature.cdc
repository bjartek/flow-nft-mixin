
import NonFungibleToken from 0x1cf0e2f2f715450

pub contract SignatureTrait {

    pub var type: String

    init(){
        self.type=self.account.address.toString().concat(".Signature")
        log(self.type)
    }

    pub fun create(name: String, address: Address): @Signature {
      return <- create Signature(SignatureData(name: name, address: address))
    }

    pub struct SignatureData {
        pub let name: String
        pub let address: Address

         init(name: String,address: Address) {
            self.name = name
            self.address = address
        }
    }

    pub resource Signature: NonFungibleToken.Trait {

        pub let type: String 
        pub let signature: SignatureData
      
        pub fun description(): String {
            return self.signature.name
        }
        pub fun data() : AnyStruct{}? {
            return self.signature
        }
        init(_ data: SignatureData) {
            self.type = SignatureTrait.type
            self.signature = data            
        }
    }
}