pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";


contract Treasury {
    using SafeMath for uint256;
    IERC20 public taco;

    IERC20[] public acceptedTokens;

    constructor(IERC20 _taco) public {
        taco = _taco;
        addToken(_taco);
    }
    
    function addToken(IERC20 _token) public onlyOwner {
        
    }
}
