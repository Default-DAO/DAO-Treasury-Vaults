pragma solidity ^0.8.0;

import "./interfaces/IDNT.sol";
import "./interfaces/IUSDCShare.sol";
import "./interfaces/IDNTShare.sol";
import "./DAOContract.sol";
import "./USDCVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract DNTVault is Ownable, ReentrancyGuard {
    using SafeMath for uint256;
     
    /* the address of the token contract */
    IDNT private tokenDNT; 
    IDNTShare private tokenDNTShare;
    IUSDCShare private tokenUSDCShare;
   
 

    /* USDCVault */
    USDCVault usdcVault;

    /* DaoContract */
    address daoContractAddress;

    /* vault fee */
    uint256  vaultFee = 80;
 

    address[] usdcShareOwners;

    /* events */
    event DNTShareMinted(uint256 amountMinted);
    event DNTWithdraw(address user, uint256 amount);
    event repaidDnt(uint256 amount);
    
    constructor(IDNT _tokenDNT, IDNTShare _tokenDNTShare, IUSDCShare _tokenUSDCShare, address _usdcVaultAddr, address _daoContractAddr ) {
        tokenDNT = _tokenDNT;
        tokenDNTShare = _tokenDNTShare;
        tokenUSDCShare = _tokenUSDCShare;
        usdcVault = USDCVault(_usdcVaultAddr);
        usdcShareOwners = usdcVault.getUSDCShareOwners();
        daoContractAddress = _daoContractAddr;
    }
    function mint(uint256 amount) public onlyOwner {
        require(amount > 0, "You must mint greater than zero");
        tokenDNT.mint(address(this), amount);
        tokenDNTShare.mint(msg.sender, amount/2);
        for (uint256 i = 0; i < usdcShareOwners.length;  i++) {
            uint256 usdcShareOwnedAmount = tokenUSDCShare.balanceOf(usdcShareOwners[i]);
            if(usdcShareOwnedAmount > 0 )
            {
                uint256 usdcSharesOutstanding = tokenUSDCShare.totalSupply();
                uint256 mintAmount =  (amount / 2) * usdcShareOwnedAmount / usdcSharesOutstanding;
                tokenDNTShare.mint(usdcShareOwners[i], mintAmount);
            }
        }
        emit DNTShareMinted(amount);
    }
    function withdraw_dnt(uint256 amount) public {
        uint256 dntBalanceOfVault = tokenDNT.balanceOf(address(this));
        uint256 dntSharesOutStanding = tokenDNTShare.totalSupply();
        uint256 burningAmount = dntSharesOutStanding * amount / dntBalanceOfVault;
        tokenDNTShare.burn(msg.sender, burningAmount); 
        uint256 withdrawAmount = amount * (100-vaultFee) / 100;
        tokenDNT.transfer(msg.sender, withdrawAmount);
        emit DNTWithdraw(msg.sender, amount);
    }
    function stake_dnt(uint256 amount) public {
       

    }
    function borrow_dnt(uint256 amount) public onlyOwner {
        tokenDNT.transfer(daoContractAddress, amount);
    }
    function repay_dnt(uint256 amount) public onlyOwner{
        tokenDNT.transferFrom(msg.sender, address(this), amount);
        emit repaidDnt(amount);
    }
    
  
}
