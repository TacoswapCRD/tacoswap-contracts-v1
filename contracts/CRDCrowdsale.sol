pragma solidity ^0.7.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
/**
 * @title Crowdsale
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet
 * as they arrive.
 */
contract CRDCrowdsale is Ownable {
  using SafeMath for uint256;

  // The token being sold
  IERC20 public token;

  // address where funds are collected
  address payable public wallet;

  // how many token units a buyer gets per ether
  uint256 public rate = 900;

  // amount of raised money in wei
  uint256 public weiRaised;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, uint256 value, uint256 amount);

  constructor(address payable _wallet, IERC20 _token) public {
    require(_wallet != address(0));

    token = _token;
    wallet = _wallet;
  }

  // fallback function can be used to buy tokens
  fallback() external payable {
    buyTokens();
  }

  receive() external payable {
    buyTokens();
  }

  // low level token purchase function
  function buyTokens() public payable {

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    emit TokenPurchase(msg.sender, weiAmount, tokens);
    token.transfer(msg.sender, tokens);

    wallet.transfer(msg.value);
  }
  
  function close() public onlyOwner {
    token.transfer(wallet, token.balanceOf(address(this)));
    selfdestruct(wallet);
  }
}
