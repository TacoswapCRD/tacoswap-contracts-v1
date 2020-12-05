// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;

import "./tacoswap/interfaces/ITacoSwapPair.sol";
import "./tacoswap/interfaces/ITacoSwapFactory.sol";

contract Migrator {
    address public chef;
    address public oldFactory;
    ITacoSwapFactory public factory;
    uint256 public notBeforeBlock;
    uint256 public desiredLiquidity = uint256(-1);

    constructor(
        address _chef,
        address _oldFactory,
        ITacoSwapFactory _factory,
        uint256 _notBeforeBlock
    ) {
        chef = _chef;
        oldFactory = _oldFactory;
        factory = _factory;
        notBeforeBlock = _notBeforeBlock;
    }

    function migrate(ITacoSwapPair orig) public returns (ITacoSwapPair) {
        require(msg.sender == chef, "not from master chef");
        require(block.number >= notBeforeBlock, "too early to migrate");
        require(orig.factory() == oldFactory, "not from old factory");
        address token0 = orig.token0();
        address token1 = orig.token1();
        ITacoSwapPair pair = ITacoSwapPair(factory.getPair(token0, token1));
        if (pair == ITacoSwapPair(address(0))) {
            pair = ITacoSwapPair(factory.createPair(token0, token1));
        }
        uint256 lp = orig.balanceOf(msg.sender);
        if (lp == 0) return pair;
        desiredLiquidity = lp;
        orig.transferFrom(msg.sender, address(orig), lp);
        orig.burn(address(pair));
        pair.mint(msg.sender);
        desiredLiquidity = uint256(-1);
        return pair;
    }
}
