pragma solidity ^0.4.11;
import "./Owned.sol";
import "./Rates.sol";

contract SubscriberWallet is owned { // TODO: make it mortal
    int8 constant public ERR_NOSUBSCRIPTION = -1;
    int8 constant public ERR_ALREADYCHARGED = -2;
    int8 constant public ERR_INSUFFICIENT_BALANCE = -3;
    int8 constant public ERR_NO_ACTIVESUBSCRIPTION = -4;
    int8 constant public ERR_INVALID_FREQUENCY = -5;
    int8 constant public SUCCESS = 1;
    uint constant public MAX_FREQUENCY = 3650;
    uint constant public MIN_FREQUENCY = 1;

    struct Subscription {
        address provider; // contract address of provider
        uint idx; // index in subscriptions array
        uint frequency ; // in seconds TODO: rename to period
        uint amount; // USD chargable
        uint lastCharged; // unix timestamp when the last charge has happened
        uint chargeCount;
        bool isActive;
    }

    address[] public subscriptions;
    mapping(address => Subscription) public m_subscriptions;
    Rates rates;

    function () payable { // required to be able to top
    }

    function SubscriberWallet (address ratesAddress) {
        rates = Rates(ratesAddress);
    }

    function getBalanceInUsd() constant returns (uint usdBalance) {
        return rates.convertWeiToUsd(this.balance);
    }

    event e_subscription(address indexed provider, address subscriber, uint frequency, uint amount);
    function subscribe(address provider, uint frequency, uint amount) onlyOwner returns (int8 result) {
        if(this.balance < rates.convertUsdToWei(amount)) {
            return ERR_INSUFFICIENT_BALANCE;
        }
        if(frequency > MAX_FREQUENCY || frequency < MIN_FREQUENCY) {
            return ERR_INVALID_FREQUENCY;
        }

        uint idx;
        if(m_subscriptions[provider].frequency > 0) {
            // if it's a subscription already there for this provider then we just overwrite in the array.
            idx = m_subscriptions[provider].idx;
            m_subscriptions[provider] = Subscription(provider, idx, frequency, amount, now, 1, true);
        } else {
            // no subscription yet for this provider, new in array
            m_subscriptions[provider] = Subscription(provider, 0, frequency, amount, now, 1, true);
            idx = subscriptions.push(provider) - 1;
            m_subscriptions[provider].idx = idx;
        }
        provider.transfer(amount); // TODO: call charge instead so fee deducted + charge event emited
        e_subscription(provider, this, frequency, amount);
        return SUCCESS;
    }

    function getTime() constant returns (uint) {
        return now;
    }

    function withdraw(uint amount) onlyOwner {
        owner.transfer(amount);
    }

    event e_charged(address indexed provider, address subscriber, uint amount);
    function charge(address provider) returns (int8 result) {
        if( !m_subscriptions[provider].isActive ) { // when provider is not in map or subscription is not active
            return ERR_NOSUBSCRIPTION;
        }
        if( now < m_subscriptions[provider].lastCharged + m_subscriptions[provider].frequency) {
            return ERR_ALREADYCHARGED;
        }
        if( this.balance <= rates.convertUsdToWei(m_subscriptions[provider].amount)) {
            return ERR_INSUFFICIENT_BALANCE;
        }
        m_subscriptions[provider].lastCharged = m_subscriptions[provider].lastCharged
                        + m_subscriptions[provider].frequency;
        m_subscriptions[provider].chargeCount += 1;
        provider.transfer(m_subscriptions[provider].amount);
        // TODO: charge fee
        e_charged(provider, this, m_subscriptions[provider].amount);
        return SUCCESS;
    }

    // TODO: add getter for subscription paid up to ...

    event e_cancelled(address indexed provider, address subscriber);
    function cancel(address provider) onlyOwner returns(int8 result) {
        // CHECK: if we should lock amount unpaid periods?
        if(m_subscriptions[provider].isActive) {
            m_subscriptions[provider].isActive = false;
            e_cancelled(provider, this);
            // TODO: set subscription state in provider contract
            return SUCCESS;
        } else {
            return ERR_NO_ACTIVESUBSCRIPTION;
        }

    }

}
