pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
contract MyERC4907 is ERC721{
    struct UserInfo
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp, user expires
    }

    mapping (uint256  => UserInfo) internal _users;
    uint256  amount;
    constructor(string memory name, string memory symbol)
    ERC721(name,symbol)
    {
        amount=0;
    }

    function airdrop(address User) public{
        _mint(User,amount);
        amount++;
        UserInfo memory user;
        user.user=User;
        user.expires=1697778000;
        _users[amount-1]=user;
    }
    function getAmount() public view returns(uint256){
        return amount;
    }
    function mint(uint256 tokenId, address to) public {
        _mint(to, tokenId);
    }

} 