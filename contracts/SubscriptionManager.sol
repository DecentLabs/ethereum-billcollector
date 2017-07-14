pragma solidity ^0.4.11;

import "./Owned.sol";
import "./SubscriberWallet.sol";
import "./Provider.sol";

contract SubscriptionManager is owned {
    int8 constant public ERR_PROVIDER_ALREADY_EXISTS = -1;
    int8 constant public SUCCESS = 1;

    address[] public subscriberWalletAddresses;
    address[] public providerContractAddresses;

    mapping(address => uint) public m_providers; // provider account address => idx +1 in in providers[]
    mapping(address => uint) public m_subscribers; // subscriber account address => idx+1 in subscribers[]

    function subscribe(address provider, uint period, uint frequency) payable {
        require(m_providers[provider] != 0 );
        address providerContractAddress = providerContractAddresses[ m_providers[provider] -1 ];
        Provider providerInstance = Provider(providerContractAddress);

        uint idx;
        SubscriberWallet subscriberWalletInstance;
        address subscriberWalletAddress;
        if(m_subscribers[msg.sender] == 0 ) {
            // new subscriber
            subscriberWalletAddress = new SubscriberWallet();
            idx = subscriberWalletAddresses.push( subscriberWalletAddress );
            m_subscribers[msg.sender] = idx;
        } else {
            // existing subscriber
            subscriberWalletAddress = subscriberWalletAddresses[m_subscribers[msg.sender] -1];
        }

        subscriberWalletInstance = SubscriberWallet(subscriberWalletAddress);
        if (msg.value > 0 ) {
            subscriberWalletInstance.transfer(msg.value);
        }

        int8 result;
        result = subscriberWalletInstance.subscribe(provider, period, frequency);
        if (result != subscriberWalletInstance.SUCCESS()) {
            revert();
        }

        providerInstance.addSubscriberWallet(subscriberWalletAddress);
        return;
    }

    function addProvider(address provider) returns (int8 result) {
         if(m_providers[provider] != 0 ){
            return ERR_PROVIDER_ALREADY_EXISTS;
        }

        address providerContractAddress = new Provider();
        uint idx = providerContractAddresses.push(providerContractAddress);
        m_providers[provider] = idx;
        return SUCCESS;
    }

}
