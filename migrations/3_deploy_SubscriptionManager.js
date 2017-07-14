var SubscriptionManager = artifacts.require("./SubscriptionManager.sol");

module.exports = function(deployer) {
  deployer.deploy(SubscriptionManager);
};
