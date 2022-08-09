// SPDX-License-Identifier: CC0-1.0
import "./interfaces/IERC4907.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
pragma solidity ^0.8.0;

contract ERC4907 is ERC721, IERC4907 {
    struct UserInfo {
        address user;
        uint64 expires;
    }

    mapping(uint256 => UserInfo) internal _users;

    constructor(string memory name_, string memory symbol_) ERC721(name_, symbol_) {}

    function setUser(uint256 tokenId, address user, uint64 expires) public {
        require(userOf(tokenId) == address(0), "Can not set: User is not expired");
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        UserInfo storage info = _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId, user, expires);
    }

    function userOf(uint256 tokenId) public view returns(address) {
        if(uint256(_users[tokenId].expires) >= block.timestamp) {
            return _users[tokenId].user;
        } else {
            return address(0);
        }
    }

    function userExpires(uint256 tokenId) public view returns(uint256) {
        return _users[tokenId].expires;
    }

    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return interfaceId == type(IERC4907).interfaceId || super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address from, 
        address to, 
        uint256 tokenId
    ) internal virtual override{
        if(from != to) {
            require(userOf(tokenId) == address(0), "User is not expired.");
        }

        super._beforeTokenTransfer(from, to, tokenId);
    }
}