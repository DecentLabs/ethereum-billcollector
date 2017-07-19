pragma solidity ^0.4.11;

import "./Owned.sol";

// a naiv mock implamentation of ETH/USD exchange rate oracle
contract Rates is owned {
    uint public usdWeiRate = 5128205128205130;  // 1/195 ether ;

    event e_usdWeiRateChanged(uint newWeiUsdRate);
    function setUsdWei(uint newUsdWeiRate) constant onlyOwner {
        usdWeiRate = newUsdWeiRate;
        e_usdWeiRateChanged(newUsdWeiRate);
        return;
    }

    function convertUsdToWei(uint usdValue) constant returns(uint weiValue) {
        // TODO: make it safe multiply
        return usdValue * usdWeiRate;
    }

    function convertWeiToUsd(uint weiValue) constant returns(uint usdValue) {
        // TODO: safe divide ?
        return weiValue / usdWeiRate;
    }
}
