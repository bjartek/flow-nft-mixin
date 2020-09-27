import NonFungibleToken from 0x01cf0e2f2f715450


// This transaction creates an empty NFT Collection in the signer's account
transaction {

  prepare(account: AuthAccount) {
    // store an empty NFT Collection in account storage

    let nft <- NonFungibleToken.createNFT()

    let artTrait <- NonFungibleToken.createArtTrait(
        name: "An awesome art piece", 
        artistName: "John Doe", 
        artist: account.address,
        url: "http://foo/bar",
        description: "This is an description"
      )

    log(artTrait.description())

    nft.mixin(<- artTrait)
    let traitType="0x1cf0e2f2f715450.Art"
    if nft.hasTrait(traitType) {
        let art = nft.borrowTrait(traitType) as? &NonFungibleToken.Art ?? panic("Could not borrow trait as Art")
        log(art.data())
        log(art.arty())
    }


    log("Created an NFT with art mixin")
    destroy nft

  }
}