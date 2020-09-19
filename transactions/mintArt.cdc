import NonFungibleToken from 0x01cf0e2f2f715450



// This transaction creates an empty NFT Collection in the signer's account
transaction {



  prepare(account: AuthAccount) {
    // store an empty NFT Collection in account storage




    let nft <- NonFungibleToken.createNFT()

    let artMixin <- NonFungibleToken.artMixin(
        name: "An awesome art piece", 
        artistName: "John Doe", 
        artist: account.address,
        url: "http://foo/bar",
        description: "This is an description"
      )

    log(&artMixin as &NonFungibleToken.Mixin)

    nft.mixin(<- artMixin)

 
    let data = nft.extractData("0x1cf0e2f2f715450.Art") 
    log(data)


    let art: NonFungibleToken.Art = data as? NonFungibleToken.Art  ?? panic("Can not cast to art")
    log(art.name)

    log("Created an NFT with art mixin")
    destroy nft

  }
}