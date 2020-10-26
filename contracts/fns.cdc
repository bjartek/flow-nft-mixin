
pub contract FlowNamingService {

    pub event NameRegistred(address:Address, alias:String, until:UFix64)

    pub struct NameRegistration {

        pub var address: Address
        pub var leaseUntil: UFix64
        pub var alias: String

        init(alias:String, address:Address, leaseUntil: UFix64 ) {
            self.address=address
            self.leaseUntil=leaseUntil
            self.alias=alias
        }
    }

    pub resource Collection {

        //double store to get quick looukups both ways
        pub var namingRegistry :{String:NameRegistration}

        //One could argue that this should return a list of NameRegistration
        pub var reverseLookup: {Address:NameRegistration}

        init() {
            self.namingRegistry = {}
            self.reverseLookup={}
        }

    }

    pub fun lookup(alias:String): Address? {
        return self.registryCollection.namingRegistry[alias]?.address
    }

    pub fun alias(address:Address): String? {
        return self.registryCollection.reverseLookup[address]?.alias
    }

    //not sure if you would want a lease until
    pub fun registerName(alias: String, address:Address, leaseUntil:UFix64) {

            var block=getCurrentBlock()
            if let currentRegistration= self.registryCollection.namingRegistry[alias] {

                var expired = currentRegistration.leaseUntil > block.timestamp
                var registeredByMe = currentRegistration.address == address

                if !registeredByMe && !expired {
                    panic("alias=".concat(alias).concat(" is already leased."))
                }
            }

            emit NameRegistred(address:address, alias:alias, until:leaseUntil)
            var registration= NameRegistration(alias: alias, address: address, leaseUntil: leaseUntil)
            self.registryCollection.namingRegistry[alias]=registration
            self.registryCollection.reverseLookup[address]=registration
    }

    pub var registryCollection: @Collection
    init() {
        self.registryCollection <- create Collection()

    }

}
