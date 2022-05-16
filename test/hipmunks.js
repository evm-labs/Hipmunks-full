const Hipmunks = artifacts.require("HippieHipsterChipmunks");

contract("First hipmunks test", async accounts => {

/*
Tests
- Cannot mint preSale before time
- Cannot mint Sale before time
- Owner (and only owner) can change the statuses
- Owner (and only owner) can set the URIs
- Only whitelist can mint presale once open
- Anyone can mint sale once open
- Cannot mint presale & sale more than amount
- Only owner can mint reserved
- Only owner can mint donated
- Only owner can deposit to Dao
- Only owner can withdraw
*/

  it("sample test should pass", async () => {
    const instance = await Hipmunks.deployed();
    const balance = await instance.getBalance.call(accounts[0]);
    assert.equal(1, 1);
  });
  it("owner should be able to change Pre and Sale Status", async () => {
    const contract = await Hipmunks.deployed();
    const account_owner = accounts[0];
    const account_other = accounts[1];
    await contract.changeMintStatus();
    await contract.changePresaleStatus();
    const mintStatus = await contract.mintActive;
    const presaleStatus = await contract.presaleActive;
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
  })
});
