var SubscriptionManager = artifacts.require("./SubscriptionManager.sol");
var Rates = artifacts.require("./Rates.sol");

module.exports = function(deployer) {
    Rates.deployed().then( res => {
        return deployer.deploy(SubscriptionManager, res.address);
    });

};
