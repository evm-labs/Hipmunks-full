const ConvertLib = artifacts.require("ConvertLib");
const MetaCoin = artifacts.require("MetaCoin");
const Hipmunks = artifacts.require("HippieHipsterChipmunks");
const Hipnation = artifacts.require("Hipnation");


module.exports = function(deployer) {
  deployer.deploy(ConvertLib);
  deployer.deploy(MetaCoin);
  deployer.deploy(Hipmunks);
  deployer.deploy(Hipnation);
  deployer.link(Hipnation, Hipmunks, MetaCoin, ConvertLib);
};
