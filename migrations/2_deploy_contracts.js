const Hipmunks = artifacts.require("HippieHipsterChipmunks");
const Hipnation = artifacts.require("Hipnation");


module.exports = function(deployer) {
  deployer.deploy(Hipmunks);
  deployer.deploy(Hipnation);
  deployer.link(Hipnation, Hipmunks);
};
