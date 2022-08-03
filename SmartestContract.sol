//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

address constant ADMIN = 0x3dEca47CfCB97E2a03a31bcAEe47d55B80bF8981;

contract NFT is ERC721 {
    uint256 private currentTokenID;
    string public url;

      

    mapping (address => uint256) private NFT_counter;
    mapping (address => bool) private Whitelist;
    

    constructor(string memory link) ERC721("WhaleEye", "WEye") {
        url = link;
    }

    function mint(address recipient) public 
    returns (string memory)
    {
        require((NFT_counter[recipient] < 2), "Error: Recipient has too many NFTs");
        require((Whitelist[recipient] == true), "Error: Recipient is not whitelisted");
        currentTokenID += 1;
        uint256 newItemID = currentTokenID;
        _safeMint(recipient, newItemID);
        NFT_counter[recipient] = NFT_counter[recipient] + 1;
        return Strings.toString(newItemID);
    }

    function tokenURI(uint256 tokenID) view public override returns (string memory) {
        if (tokenID < currentTokenID) {
            return string(abi.encodePacked(url, Strings.toString(tokenID), ".json"));
        }

        else {
            return string("Error: This NFT does not exist");
        }
    }

    function add_to_whitelist(address wallet_to_add) public {
        if(msg.sender == ADMIN) {
            Whitelist[wallet_to_add] = true;
        }
    }
    
    function remove_from_whitelist(address wallet_to_remove) public {
        if(msg.sender == ADMIN) {
            Whitelist[wallet_to_remove] = false;
        }
    }
}
