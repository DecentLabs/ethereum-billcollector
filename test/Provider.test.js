var Provider = artifacts.require("./Provider.sol");
require('babel-polyfill');

contract("Provider  tests", accounts => {

    it('should be possible to add a new subscriber', async function () {
        var instance = await Provider.new();
        var res = await instance.addSubscriberWallet(accounts[1]);

        assert.equal(await instance.subscriberWalletAddresses(0), accounts[1], "subscriberWalletAddresses should contain contract address");
        assert.equal(await instance.m_subscribers(accounts[1]), 1, "m_subscribers should point to subscriberWalletAddresses[]");
    });

    it('only the owner should add a new subscriber');
    it('should be possible to remove a subscriber');
    it('only the owner should remove a subscriber');

});
