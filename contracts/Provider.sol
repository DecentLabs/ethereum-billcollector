pragma solidity ^0.4.11;

import "./Owned.sol";

contract Provider is owned {
    address[] public subscriberWalletAddresses;
    mapping(address => uint) public m_subscribers;

    function addSubscriberWallet(address subscriberWalletAddress) onlyOwner returns (int8 result)  {
        if(m_subscribers[subscriberWalletAddress] != 0 ){
            return -1; // provider already exist
        }
        uint idx;
        idx = subscriberWalletAddresses.push(subscriberWalletAddress);
        m_subscribers[subscriberWalletAddress] = idx;

        return 1; // success
    }

    // TODO: withdraw, getters?

}
