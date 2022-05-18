const Hipmunks = artifacts.require("HippieHipsterChipmunks");
const truffleAssert = require('truffle-assertions');

contract("First hipmunks test", async accounts => {

/*
Tests completed
- Cannot mint Sale before time
- Owner (and only owner) can change the statuses
- Anyone can mint sale once open
- Only owner can mint reserved
- Owner can only reserve once (or twice)


Tests to add
- Cannot mint preSale before time
- Owner (and only owner) can set the URIs
- Only whitelist can mint presale once open
- Cannot mint presale & sale more than amount
- Only owner can mint donated
- Only owner can deposit to Dao
- Only owner can withdraw

*/


  it("owner should be able to change Pre and Sale Status", async () => {
    const contract = await Hipmunks.deployed();
    const contractOwner = await contract.owner.call();
    await contract.changeMintStatus({from: contractOwner});
    await contract.changePresaleStatus({from: contractOwner});
    const mintStatus = await contract.mintActive();
    const presaleStatus = await contract.presaleActive();
    assert.equal(
      mintStatus,
      true,
      "Sale status was not changed."
    );
    assert.equal(
      presaleStatus,
      true,
      "Pre-Sale status was not changed."
    );
    await contract.changeMintStatus({from: contractOwner}); // revert for rest of tests
    await contract.changePresaleStatus({from: contractOwner});
  })

  it("non owner should not be able to change Pre and Sale Status", async () => {
    const contract = await Hipmunks.deployed();
    const randomAccount = await accounts[1];

    await truffleAssert.reverts(
      contract.changeMintStatus({from: randomAccount}),
      "Ownable: caller is not the owner"
    );

    await truffleAssert.reverts(
      contract.changePresaleStatus({from: randomAccount}),
      "Ownable: caller is not the owner"
    );


  })

  it("Cannot mint before sale opens", async () => {
    const contract = await Hipmunks.deployed();
    const randomAccount = await accounts[1];

    await truffleAssert.reverts(
      contract.publicMint(1, {from: randomAccount, value: 0.066*Math.pow(10, 18)}),
      "Sale is not active."
    );
  })

  it("Can mint after sale opens", async () => {
    const contract = await Hipmunks.deployed();
    const contractOwner = await contract.owner.call();
    await contract.changeMintStatus({from: contractOwner});
    const randomAccount = await accounts[1];

    const tokensBefore = await contract.tokenSupply();
    await contract.publicMint(1, {from: randomAccount, value: 0.066*Math.pow(10, 18)});
    const tokensAfter = await contract.tokenSupply();

    assert.equal(
      tokensAfter - tokensBefore,
      1,
      "Supply did not increase."
    );

    await contract.changeMintStatus({from: contractOwner}); // revert for rest of tests

  })


  it("Owner can mint reserved, non owner cannot mint, owner cannot mint over reserved amount", async () => {
    const contract = await Hipmunks.deployed();
    const contractOwner = await contract.owner.call();
    const randomAccount = await accounts[1];

    let tokensBefore = await contract.tokenSupply();
    await contract.mintReservedChipmunks({from: contractOwner});
    let tokensAfter = await contract.tokenSupply();

    // Check the owner can call reserve (only reserves half)
    assert.equal(
      tokensAfter - tokensBefore,
      100,
      "Supply did not increase."
    );

    // Check that no one else can call reserve
    await truffleAssert.reverts(
      contract.mintReservedChipmunks({from: randomAccount}),
      "Ownable: caller is not the owner"
    );

    tokensBefore = await contract.tokenSupply();
    await contract.mintReservedChipmunks({from: contractOwner});
    tokensAfter = await contract.tokenSupply();

    // Check that owner can call reserve second time
    assert.equal(
      tokensAfter - tokensBefore,
      100,
      "Supply did not increase."
    );

    // Check that owner cannot call reserve again
    await truffleAssert.reverts(
      contract.mintReservedChipmunks({from: contractOwner}),
      "Reserves have already been minted."
    );

  })



});
