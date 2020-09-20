// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Treasury {
    using SafeMath for uint256;
    IERC20 public taco;

    struct TokenInfo {
        IERC20 token;
    }

    address[] public acceptedTokenAddresses;
    mapping (address => TokenInfo) acceptedTokens;

    constructor(IERC20 _taco) public {
        taco = _taco;
        addToken(_taco);
    }
    
    function addToken(IERC20 _token) public onlyOwner {
        acceptedTokens.push(_token);
    }
}
