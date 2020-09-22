// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract Treasury {
    using SafeMath for uint256;

    struct PoolToken {
        address addr;
        uint256 rewardPerBlock;
        uint256 startBlock;
        uint256 amount;
        bool exists;
    }

    address taco;
    address bar;
    uint256 startBlock;

    uint256 totalPoolTokens = 0;
    address[] poolTokensList;
    mapping (address => PoolToken) poolTokens;

    mapping (address => uint256) claims;

    constructor(address _taco, address _bar, uint256 _startBlock) public {
        startBlock = _startBlock;
        taco = _taco;
        bar = _bar;
    }

    function addToken(address _token, uint256 _rewardPerBlock, uint256 _amount) public {
        IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        PoolToken memory poolToken = poolTokens[_token];
        if (!poolToken.exists) {
            totalPoolTokens++;
            poolToken.addr = _token;
            poolToken.startBlock = block.number;
            poolToken.rewardPerBlock = _rewardPerBlock;
            poolToken.exists = true;
            poolToken.amount = amount;
        } else {
            poolToken.amount += amount;
        }
        poolTokens.push(_token);
    }

    function getAvailableReward(address _token, address _holder) public view {
        PoolToken memory poolToken = poolTokens[_token];
        uint256 lastClaimed = claims[_holder];
        if (lastClaimed == 0) {
            lastClaimed = poolToken.startBlock;
        }
        uint256 totalXTaco = IERC20(bar).totalSupply();
        uint256 userXTaco = IERC20(bar).balanceOf(msg.sender);
        uint256 userShare = userXTaco.div(totalXTaco);
        return block.number.sub(lastClaimed).mul(poolToken.rewardPerBlock).mul(userShare);
    }

    function claim(address _token) public {
        uint256 availableReward = getAvailableReward(_token, msg.sender);
        claims[msg.sender] = block.number;
        IERC20(_token).transferFrom(address(this), msg.sender, availableReward);
    }
}
