//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
//import "./Ownable.sol";

address constant ADMIN = 0x3dEca47CfCB97E2a03a31bcAEe47d55B80bF8981;

contract NFT is ERC721 {
    uint256 private currentTokenID;
    string public url;

    mapping (address => uint256) NFT_counter;
    mapping (address => bool) Whitelist;
    
    constructor(string memory link) ERC721("WhaleEye", "WEye") {
        url = link;
        Whitelist[ADMIN] = true;
    }

    modifier cost() {
        require(msg.value >= 10000000000000000, "Error: Not enough money sent");
        _;
    }

    modifier is_admin() {
            require((msg.sender == ADMIN), "No admin permission");
            _;
        }

    modifier is_whitelisted(address recipient) {
        require((Whitelist[recipient] == true), "Error: Recipient is not whitelisted");
        _;
    }

    modifier NFT_count(address recipient) {
        require((NFT_counter[recipient] < 2), "Error: Recipient has too many NFTs");
        _;
    }

    modifier max_NFTs() {
        require((currentTokenID <= 3), "Error: NFTs sold out");
        _;
    }

    function mint(address recipient) payable public cost() is_whitelisted(recipient) NFT_count(recipient) 
    returns (string memory)
    {   
        currentTokenID += 1;
        _safeMint(recipient, currentTokenID);
        payable(ADMIN).transfer(address(this).balance - 10000000000000000);
        NFT_counter[recipient] = NFT_counter[recipient] + 1;
        return Strings.toString(currentTokenID);
    }

    function tokenURI(uint256 tokenID) view public override returns (string memory) {
        if (tokenID < currentTokenID) {
            return string(abi.encodePacked(url, Strings.toString(tokenID), ".json"));
        }

        else {
            revert("Error: This NFT does not exist");
        }
    }

    function add_to_whitelist(address wallet_to_add) public is_admin() {
        Whitelist[wallet_to_add] = true;
    }
    
    function remove_from_whitelist(address wallet_to_remove) public is_admin() {
        Whitelist[wallet_to_remove] = false;
    }
}
