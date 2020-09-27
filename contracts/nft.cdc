// NFTv2.cdc
//
// This is a complete version of the NonFungibleToken contract
// that includes withdraw and deposit functionality, as well as a
// collection resource that can be used to bundle NFTs together.
//
// It also includes a definition for the Minter resource,
// which can be used by admins to mint new NFTs.

import FungibleToken from 0xee82856bf20e2aa6

pub contract NonFungibleToken {


  pub var idCount: UInt64
  init() {
      self.idCount = 1
  }

  // Declare the NFT resource type
  pub resource NFT {

      // The unique ID that differentiates each NFT
      pub let id: UInt64
      pub let mixins: @{String:AnyResource{Trait}}
      // Initialize both fields in the init function
      init(initID: UInt64) {
          self.id = initID
          self.mixins  <- {}

      }

      //There should probably be a method on NFT to create a Mixin 
      pub fun mixin(_ trait: @AnyResource{Trait})  {
          log("mixing in".concat(" ").concat(trait.type))
          let oldToken <- self.mixins[trait.type] <- trait
          destroy oldToken
      }

      //There could be several more convenience methods to fetch information about mixins. Like get all descriptions aso

      pub fun borrowTrait(_ type: String): auth &AnyResource{Trait} {
          return &self.mixins[type] as auth &AnyResource{Trait} 
      }

      pub fun hasTrait(_ type: String) : Bool {
          return self.mixins.keys.contains(type)
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

  pub resource interface Trait {

        //The type of this trait. Should be on the form 0xAddress.ClassName
        pub let type: String

        //Data about this trait that can be printed out to show what it is
        //Not all traits need to implement this
        pub fun data(): AnyStruct{}? 

        //This has to return something, the most relevant of the three above
        pub fun description() : String
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

    pub fun createArtTrait(name: String, artistName: String, artist: Address, url: String, description: String) : @Art{
      let type = self.account.address.toString().concat(".Art")
      let art  = ArtData(
          name: name, artistName: artistName, artist: artist, url: url, description: description
      )
      return <- create Art(type: type, artData: art)
    }

    pub struct ArtData {
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
            self.description = description
        }
    }

    pub resource Art: Trait {

        pub let type: String 
        pub let art: ArtData
      
        pub fun description(): String {
            return self.art.name
        }
        pub fun data() : AnyStruct{}? {
            return self.art
        }

        pub fun arty() : String {
            return "foo"
        }

        init(type: String, artData: ArtData) {
            self.type = type
            self.art = artData            
        }
    }

    //Example of another Trait
    pub resource OriginalArtistCut: Trait {
        pub let type: String
 
        pub fun description() : String {
            var owner= self.receiver.borrow()!.owner!.address.toString()
            return "Original artist ".concat(owner).concat(" would like a ").concat(self.cutPercentage.toString()).concat(" cut")
        }

        pub fun data(): AnyStruct{}? {
            return nil
        }

        pub fun claimRoyalty(totalAmount: UFix64, vault: @FungibleToken.Vault): @FungibleToken.Vault {
                //Withdraw cuplace and put it in their vault
            let amount=totalAmount*self.cutPercentage
            let beneficiaryCut <- vault.withdraw(amount:amount)

            let cutVault=self.receiver.borrow()!
            cutVault.deposit(from: <- beneficiaryCut)
            return <- vault
        }

        pub let cutPercentage: UFix64

        pub let receiver: Capability<&{FungibleToken.Receiver}>

        init(type: String, cutPercentage: UFix64, receiver: Capability<&{FungibleToken.Receiver}>) {
            self.type=type
            self.cutPercentage=cutPercentage
            self.receiver=receiver
        }
    }

    pub fun createOriginalArtistCut(cutPercentage: UFix64, receiver: Capability<&{FungibleToken.Receiver}>) : @OriginalArtistCut {

        let type = self.account.address.toString().concat(".OriginalArtistCut")
        return <- create OriginalArtistCut(type: type, cutPercentage: cutPercentage, receiver: receiver )
        
    }
 
}
