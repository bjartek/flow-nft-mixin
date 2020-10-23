import NonFungibleToken from 0x01cf0e2f2f715450
import ArtTrait from 0x179b6b1cb6755e31
import SignatureTrait from 0xf3fcd2c1a78f5eee


// This transaction creates an empty NFT Collection in the signer's account
transaction {

  prepare(account: AuthAccount) {
    // store an empty NFT Collection in account storage

    let nft <- NonFungibleToken.createNFT()

    let artTrait <- ArtTrait.create(
        name: "An awesome art piece", 
        artistName: "John Doe", 
        artist: account.address,
        url: "http://foo/bar",
        description: "This is an description"
      )

    log(artTrait.description())

    nft.mixin(<- artTrait)

    nft.mixin(<- SignatureTrait.create(name:"John Doe", address: account.address ))

    if nft.hasTrait(ArtTrait.type) {
        let art = nft.borrowTrait(ArtTrait.type) as? &ArtTrait.Art ?? panic("Could not borrow trait as Art")
        log(art.data())
        log(art.arty())
    }

    if nft.hasTrait(SignatureTrait.type) {
        log(nft.borrowTrait(SignatureTrait.type).data())
    }

    log("Created an NFT with art mixin and signature mixin")
    destroy nft

  }
}