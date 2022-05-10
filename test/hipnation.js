const Hipnation = artifacts.require("Hipnation");
const truffleAssert = require('truffle-assertions');

contract("First Hipnation test", async accounts => {

/*
Tests
- DaoAdmin cannot be set by non owner
- DaoAdmin can be set by owner
- DaoAdmin can be set by admin
- DaoAdminValidator cannot be set by admin
- DaoAdminValidator can be set by owner
- DaoAdminValidator can be set by DaoAdminValidator
- Anyone can obtain balance
- No one can updateDonationDate
- Owner can setDonationDate
- DAOadmin cannot set donation date
- Owner cannot setCharity
- Owner cannot make a motion for charity outside of the window
- Admin cannot make a motion for charity outside of the window
- Owner can make a motion for charity inside the window
- Admin can make a motion for charity inside the window
- Owner cannot transfer to charity outside of Donation Date
- Owner can transfer to charity inside Donation Date
- Admin cannot transfer to charity outside of Donation Date
- Admin can transfer to charity inside Donation Date
- DaoAdminValidator cannot transfer to charity at any point


*/

  it("sample test should pass", async () => {
    const instance = await Hipnation.deployed();
    const balance = await instance.getBalance.call(accounts[0]);
    assert.equal(1, 1);
  });
});

