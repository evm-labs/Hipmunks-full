const Hipnation = artifacts.require("Hipnation");

contract("First hipmunks test", async accounts => {
  it("sample test should pass", async () => {
    const instance = await Hipnation.deployed();
    const balance = await instance.getBalance.call(accounts[0]);
    assert.equal(1, 1);
  });
});

/*
Tests


*/