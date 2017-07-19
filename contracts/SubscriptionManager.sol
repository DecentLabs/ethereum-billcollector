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

    address public ratesAddress;

    function SubscriptionManager(address _ratesAddress) {
        ratesAddress = _ratesAddress;
    }

    function subscribe(address provider, uint frequency, uint amount) payable {
        require(m_providers[provider] != 0 );
        address providerContractAddress = providerContractAddresses[ m_providers[provider] -1 ];
        Provider providerInstance = Provider(providerContractAddress);

        uint idx;
        SubscriberWallet subscriberWalletInstance;
        address subscriberWalletAddress;
        if(m_subscribers[msg.sender] == 0 ) {
            // new subscriber
            subscriberWalletAddress = new SubscriberWallet(ratesAddress);
            idx = subscriberWalletAddresses.push( subscriberWalletAddress );
            m_subscribers[msg.sender] = idx;
        } else {
            // existing subscriber
            subscriberWalletAddress = subscriberWalletAddresses[m_subscribers[msg.sender] -1];
        }

        subscriberWalletInstance = SubscriberWallet(subscriberWalletAddress);
        // TODO: setowner ?
        if (msg.value > 0 ) {
            subscriberWalletInstance.transfer(msg.value);
        }

        int8 result;
        result = subscriberWalletInstance.subscribe(provider, frequency, amount);
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
        // TODO: setowner + add provider account arg?
        uint idx = providerContractAddresses.push(providerContractAddress);
        m_providers[provider] = idx;
        return SUCCESS;
    }

}
