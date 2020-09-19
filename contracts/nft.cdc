// NFTv2.cdc
//
// This is a complete version of the NonFungibleToken contract
// that includes withdraw and deposit functionality, as well as a
// collection resource that can be used to bundle NFTs together.
//
// It also includes a definition for the Minter resource,
// which can be used by admins to mint new NFTs.


pub contract NonFungibleToken {


  pub var idCount: UInt64
  init() {
      self.idCount = 1
  }

  // Declare the NFT resource type
  pub resource NFT {

      // The unique ID that differentiates each NFT
      pub let id: UInt64
      pub let mixins: @{String:Mixin}
      // Initialize both fields in the init function
      init(initID: UInt64) {
          self.id = initID
          self.mixins  <- {}

      }

      pub fun mixin(_ mixin: @Mixin)  {
          log("mixing in".concat(" ").concat(mixin.type))


          let oldToken <- self.mixins[mixin.type] <- mixin
          destroy oldToken
      }

      pub fun extractData(_ type: String): AnyStruct{} {
          return self.mixins[type]?.data ?? panic("mixin type does not exist")
      }


       destroy() {
          destroy self.mixins
      }
  }

  // We define this interface purely as a way to allow users
  // to create public, restricted references to their NFT Collection.
  // They would use this to only expose the deposit, getIDs,
  // and idExists fields in their Collection
  pub resource interface NFTReceiver {

      pub fun deposit(token: @NFT)

      pub fun getIDs(): [UInt64]

      pub fun idExists(id: UInt64): Bool
      pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT 

  }

  pub resource Mixin {

        //The type of the mixin
        pub let type: String

        //And url to the schema for the data
        pub let schemaUrl: String?

        //A struct with data for the mixing, case this to a type that conform to the schema above
        pub let data: AnyStruct{}

        //A text description for the mixing
        pub let description: String


        pub let resource: @AnyResource? 

        init(type: String, data: AnyStruct{}, description: String, schemaUrl : String?, resource: @AnyResource?) {
            self.type=type
            self.data = data
            self.description=description
            self.schemaUrl=schemaUrl
            self.resource <- resource
        }

        destroy() {            
           destroy self.resource
        }
        
  }

  // The definition of the Collection resource that
  // holds the NFTs that a user owns
  pub resource Collection: NFTReceiver {
      // dictionary of NFT conforming tokens
      // NFT is a resource type with an `UInt64` ID field
      pub var ownedNFTs: @{UInt64: NFT}

      // Initialize the NFTs field to an empty collection
      init () {
          self.ownedNFTs <- {}
      }

    
      // withdraw
      //
      // Function that removes an NFT from the collection
      // and moves it to the calling context
      pub fun withdraw(withdrawID: UInt64): @NFT {
          // If the NFT isn't found, the transaction panics and reverts
          let token <- self.ownedNFTs.remove(key: withdrawID)!

          return <-token
      }

      // deposit
      //
      // Function that takes a NFT as an argument and
      // adds it to the collections dictionary
      pub fun deposit(token: @NFT) {
          // add the new token to the dictionary which removes the old one
          let oldToken <- self.ownedNFTs[token.id] <- token
          destroy oldToken
      }

        // borrowNFT gets a reference to an NFT in the collection
        // so that the caller can read its metadata and call its methods
        pub fun borrowNFT(id: UInt64): &NonFungibleToken.NFT {
            return &self.ownedNFTs[id] as &NonFungibleToken.NFT
        }

      // idExists checks to see if a NFT
      // with the given ID exists in the collection
      pub fun idExists(id: UInt64): Bool {
          return self.ownedNFTs[id] != nil
      }

      // getIDs returns an array of the IDs that are in the collection
      pub fun getIDs(): [UInt64] {
          return self.ownedNFTs.keys
      }

      // If a resource has member fields that are resources,
      // it is required to define a `destroy` block to specify
      // what should happen to those member fields
      // if the top level object is destroyed
      destroy() {
          destroy self.ownedNFTs
      }
  }

  // creates a new empty Collection resource and returns it
  pub fun createEmptyCollection(): @Collection {
      return <- create Collection()
  }

	// mintNFT mints a new NFT with a new ID
	pub fun createNFT() : @NFT {

        var newNFT <- create NFT(initID:self.idCount)
        self.idCount = self.idCount + UInt64(1)
        return <- newNFT
	}


    /*
    
    This is an example of an Art mixin fetching the url from url with a given 
     */

    pub fun artMixin(name: String, artistName: String, artist: Address, url: String, description: String) : @Mixin{
        let art  = Art(
            name: name, artistName: artistName, artist: artist, url: url, description: description
        )
       let type = self.account.address.toString().concat(".Art")
        return <- create Mixin(type: type, data: art, description: "", schemaUrl: nil, resource: nil )
    }

    pub struct Art {
        pub let name: String
        pub let artistName: String
        pub let artist: Address
        pub let url: String
        pub let description: String

        init(name: String, artistName: String, artist: Address, url: String, description: String) {
            self.name = name
            self.artistName=artistName 
            self.artist = artist
            self.url = url
            self.description= description
        }
    }

    /*
        Another mixin where the orginal artist ask for a cut
    
    pub struct OriginalArtistCut {
        pub let cutPercentage: UFix64
        pub let capablity: Capability<&{FungibleToken.Receiver}>

        init(cutPercentage: UFix64, capability: Capability<&{FungibleToken.Receiver}>) {
            self.cutPercentage=cutPercentage
            self.capablity=capability
        }
    }

    pub fun originalArtistMixin(cutPercentage: UFix64, capability: Capability<&{FungibleToken.Receiver}>) : @Mixin {
        let cut = OriginalArtistCut(cutPercentage: cutPercentage, capability: capability)
        let type = self.account.address.toString().concat(".OriginalArtistCut")

        return <- create Mixin(type: type, data: cut, description: "The original artist has kindly asked for a small cut of resale", schemaUrl: nil, resource: nil)
    }
 
     */
}
