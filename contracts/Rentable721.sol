// SPDX-License-Identifier: MIT
import "./ERC4907.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Rentable721 is ERC4907, Ownable {
    struct RentInfo {
        bool isRentable;
        uint64 maxRentLimit;
        uint256 feePerSecond;
    }

    mapping(uint256 => RentInfo) public tokenRentInfo;

    constructor(string memory name_, string memory symbol_) ERC4907(name_, symbol_) {
        
    }

    function mint(address to) public {
        //_mint(to, tokenId);

    }

    function setRentInfo(uint256 tokenId, bool isRentable, uint64 maxTimeLimit, uint256 fee) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");
        RentInfo storage rentInfo = tokenRentInfo[tokenId];
        rentInfo.isRentable = isRentable;
        rentInfo.maxRentLimit = maxTimeLimit;
        rentInfo.feePerSecond = fee;
    }

    function rent(uint256 tokenId, uint64 expires) payable public {
        require(userOf(tokenId) == address(0), "Renting in progress");
        require(expires < tokenRentInfo[tokenId].maxRentLimit, "Exceed rent time limit");
        require(tokenRentInfo[tokenId].isRentable, "Can not rent");
        uint256 totalFee = expires * tokenRentInfo[tokenId].feePerSecond;
        require(msg.value == totalFee, "Invalid amount");

        payable(ownerOf(tokenId)).transfer(totalFee);
        UserInfo storage info = _users[tokenId];
        info.user = msg.sender;
        info.expires = uint64(block.timestamp) + expires;
        
        emit UpdateUser(tokenId, msg.sender, expires);
    }
}