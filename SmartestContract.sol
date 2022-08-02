//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract NFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private currentTokenId;
    
    string public url;

    constructor(string memory link) ERC721("WhaleEye", "WEye") {
        url = link;
    }

    function mintTo(address recipient) public 
        returns (uint256)
    {
        currentTokenId.increment();
        uint256 newItemId = currentTokenId.current();
        _safeMint(recipient, newItemId);
        return newItemId;
    }

    function tokenURI(uint256 tokenID) view public override returns (string memory) {
        return string(abi.encodePacked(url, Strings.toString(tokenID)));
    }
}
