pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract TacoBar is ERC20("TacoBar", "xTACO"){
    using SafeMath for uint256;
    IERC20 public taco;

    constructor(IERC20 _taco) public {
        taco = _taco;
    }

    // Enter the bar. Pay some TACOs. Earn some shares.
    function enter(uint256 _amount) public {
        uint256 totalTaco = taco.balanceOf(address(this));
        uint256 totalShares = totalSupply();
        if (totalShares == 0 || totalTaco == 0) {
            _mint(msg.sender, _amount);
        } else {
            uint256 what = _amount.mul(totalShares).div(totalTaco);
            _mint(msg.sender, what);
        }
        taco.transferFrom(msg.sender, address(this), _amount);
    }

    // Leave the bar. Claim back your TACOs.
    function leave(uint256 _share) public {
        uint256 totalShares = totalSupply();
        uint256 what = _share.mul(taco.balanceOf(address(this))).div(totalShares);
        _burn(msg.sender, _share);
        taco.transfer(msg.sender, what);
    }
}