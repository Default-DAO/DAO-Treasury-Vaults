pragma solidity ^0.8.0;

import "./interfaces/IDNT.sol";
import "./interfaces/IUSDCShare.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract USDCVault is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
     
    /* the address of the token contract */
    IDNT private tokenDNT; 
    IUSDCShare private tokenUSDCShare;
    IERC20 private tokenUSDC;

    /* address of USDC*/
    address constant public USDC = address(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    /* vault fee */
    uint256  vaultFee = 10;

    /* deposited usdc amount of users */
    mapping (address => uint256) private balances; 

    /* events */
    event USDCShareMinted(address owner, uint256 amountMinted);
    event USDCShareBurned(address owner, uint256 amountBurned);
    event changedVaultFee(uint256 newFee);
    event chargedxpense(uint256 amount);
    constructor(IDNT _tokenDNT, IUSDCShare _tokenUSDCShare ) {
        tokenDNT = _tokenDNT;
        tokenUSDCShare = _tokenUSDCShare;
        tokenUSDC = IERC20(USDC);
    }

    function deposit_usdc(uint256 amount) public {
        require(amount > 0, "You must send greater than zero");
        uint256 usdcSharesOutstanding = tokenUSDCShare.totalSupply();
        uint256 usdcBalance = tokenUSDC.balanceOf(address(this));
        uint256 mintRate = usdcSharesOutstanding / usdcBalance;
        uint256 mintAmount = amount * mintRate;
        tokenUSDC.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
      
        tokenUSDCShare.mint(msg.sender, mintAmount);  
        emit USDCShareMinted(msg.sender, mintAmount);
    }
    function withdraw_usdc(uint256 amount) public {
        uint256 balance = balances[msg.sender];
        require(balance > amount, "Withdraw amount exceed");
        uint256 usdcSharesOutstanding = tokenUSDCShare.totalSupply();
        uint256 usdcBalance = tokenUSDC.balanceOf(address(this));
        uint256 burnRate = usdcSharesOutstanding / usdcBalance;
        uint256 burnAmount = amount * burnRate;
        uint256 withdrawAmount = amount * (100-vaultFee) / 100;
        tokenUSDCShare.burn(msg.sender, burnAmount);
       
        balances[msg.sender] -= withdrawAmount;
        tokenUSDC.transfer(msg.sender, withdrawAmount);
        emit USDCShareBurned(msg.sender, burnAmount);
    }
    function change_vault_fee(uint256 new_fee) public onlyOwner {
        vaultFee = new_fee;
        emit changedVaultFee(new_fee);
    }
    function charge_expense(uint256 amount) public onlyOwner {
        uint256 usdcBalance = tokenUSDC.balanceOf(address(this));
        require(usdcBalance > amount, "Withdraw amount exceed");
        tokenUSDC.transfer(msg.sender, amount);
        emit chargedxpense(amount);
    }
  
}