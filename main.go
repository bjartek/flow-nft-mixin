package main

import (
	"github.com/bjartek/go-with-the-flow/gwtf"
)

func main() {

	gwtf := gwtf.NewGoWithTheFlowEmulator()

	gwtf.DeployContract("nft")
	gwtf.DeployContract("art")
	gwtf.CreateAccount("artist")
	gwtf.TransactionFromFile("mintArt").SignProposeAndPayAs("artist").Run()
}
