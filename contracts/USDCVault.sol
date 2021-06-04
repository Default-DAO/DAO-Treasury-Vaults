pragma solidity ^0.8.0;

import "./interfaces/IDNT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract USDCVault is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
   

    /* array of address of tokens in the pool */
    address[] assets;   
    /* the address of the token contract */
    IDNT private tokenReward; 


    constructor(IDNT _token) {
        tokenReward = _token;
       
    }

    function deposit_usdc(uint256 amount) public {
        require(amount > 0, "You must send greater than zero");
   
    }
  


}