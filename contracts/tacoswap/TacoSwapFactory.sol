// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.0;

import './interfaces/ITacoSwapFactory.sol';
import './TacoSwapPair.sol';

contract TacoSwapFactory is ITacoSwapFactory {
    address public override feeTo;
    address public override feeToSetter;
    address public override migrator;
    uint8 public protocolFeeDenominator = 4; // uses 0.1% (1/~5 of 0.50%) per trade as default

    mapping(address => mapping(address => address)) public override getPair;
    address[] public override allPairs;

    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external override view returns (uint) {
        return allPairs.length;
    }

    function pairCodeHash() external pure returns (bytes32) {
        return keccak256(type(TacoSwapPair).creationCode);
    }

    function createPair(address tokenA, address tokenB) external override returns (address pair) {
        require(tokenA != tokenB, 'TacoSwap: IDENTICAL_ADDRESSES');
        (address token0, address token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'TacoSwap: ZERO_ADDRESS');
        require(getPair[token0][token1] == address(0), 'TacoSwap: PAIR_EXISTS'); // single check is sufficient
        bytes memory bytecode = type(TacoSwapPair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        TacoSwapPair(pair).initialize(token0, token1);
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external override {
        require(msg.sender == feeToSetter, 'TacoSwap: FORBIDDEN');
        feeTo = _feeTo;
    }

    function setMigrator(address _migrator) external override {
        require(msg.sender == feeToSetter, 'TacoSwap: FORBIDDEN');
        migrator = _migrator;
    }

    function setFeeToSetter(address _feeToSetter) external override {
        require(msg.sender == feeToSetter, 'TacoSwap: FORBIDDEN');
        feeToSetter = _feeToSetter;
    }

    function setProtocolFee(uint8 _protocolFeeDenominator) external {
        require(msg.sender == feeToSetter, 'TacoSwap: FORBIDDEN');
        require(_protocolFeeDenominator > 0, 'TacoSwap: FORBIDDEN_FEE');
        protocolFeeDenominator = _protocolFeeDenominator;
    }

    function setSwapFee(address _pair, uint8 _swapFee) external {
        require(msg.sender == feeToSetter, 'TacoSwap: FORBIDDEN');
        TacoSwapPair(_pair).setSwapFee(_swapFee);
    }
}
