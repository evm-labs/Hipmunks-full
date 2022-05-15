const Hipmunks = artifacts.require("HippieHipsterChipmunks");

contract("First hipmunks test", async accounts => {

/*
Tests
- DaoAdmin cannot be set by non owner
- DaoAdmin can be set by owner
- DaoAdmin can be set by admin
*/

  it("sample test should pass", async () => {
    const instance = await Hipmunks.deployed();
    const balance = await instance.getBalance.call(accounts[0]);
    assert.equal(1, 1);
  });
});
