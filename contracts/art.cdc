
import NonFungibleToken from 0x1cf0e2f2f715450

pub contract ArtTrait {

    pub var type: String

    init(){
        self.type=self.account.address.toString().concat(".Art")
    }

     /*
    
    This is an example of an Art mixin fetching the url from url with a given 
     */

    pub fun create(name: String, artistName: String, artist: Address, url: String, description: String) : @Art{
      let art  = ArtData(
          name: name, artistName: artistName, artist: artist, url: url, description: description
      )
      return <- create Art(artData: art)
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

    pub resource Art: NonFungibleToken.Trait {

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

        init(artData: ArtData) {
            self.type = ArtTrait.type
            self.art = artData            
        }
    }
}