// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "lib/openzeppelin/token/ERC721/ERC721.sol";
import "lib/openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import "lib/openzeppelin/access/Ownable.sol";

contract RewardNFT is ERC721URIStorage, Ownable {
    uint256 public tokenCounter;

    constructor() ERC721("Reward NFT", "RNFT") {
        tokenCounter = 0;
    }

    function mintReward(address recipient, string memory tokenURI) external onlyOwner returns (uint256) {
        uint256 newTokenId = tokenCounter;
        _safeMint(recipient, newTokenId);
        _setTokenURI(newTokenId, tokenURI);
        tokenCounter++;
        return newTokenId;
    }
}
