var Subscriber = artifacts.require("./Subscriber.sol");

module.exports = function(deployer) {
  deployer.deploy(Subscriber);
};
