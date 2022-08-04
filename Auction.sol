//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./lib.sol";
import "./Auction.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
//import "./Ownable.sol";

contract NFT is ERC721, lib {
    uint256 private currentTokenID;
    string public url;
    
    constructor(string memory link) ERC721("WhaleEye", "WEye") {
        url = link;
    }

    function mint(address recipient) payable public cost() is_whitelisted(recipient) NFT_count(recipient) max_NFTs(currentTokenID) returns (string memory) {
        if (is_auction_enabled() == false) {
            currentTokenID += 1;
            _safeMint(recipient, currentTokenID);
            payable(ADMIN).transfer(address(this).balance - 10000000000000000);
            NFT_counter[recipient] = NFT_counter[recipient] + 1;
            return Strings.toString(currentTokenID);
        }
        
        else {
            revert("Error: Currently only auctions are available");
        }
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

    //Auction

    bool public auction_enabled;
    uint256 public current_bid;
    address public highest_bidder;
    bool public auction_available;

    mapping(address => uint256) Bids;
    address[] Bidders;
    
    modifier does_auction_exist(bool on_off) {
        if (on_off = false) {require((auction_available = false), "Error: Currently, there is an auction available");}
        else {require((auction_available = true), "Error: Currently, there is no auction available");}
        _;
    }
    
    function is_auction_enabled() view public returns (bool){
        if (auction_enabled == false) {
            return false;
        }
        
        else {
            return true;
        }
    }

    function enable_auction() public lib.is_admin()  {
        auction_enabled = true;
    }

    function disable_auction() public lib.is_admin() {
        auction_enabled = false;
    }

    function bid() public payable does_auction_exist(true) lib.is_whitelisted(msg.sender) {
        if (msg.value > current_bid) {
            highest_bidder = msg.sender;
            current_bid = msg.value;
        }
        
        else {
            revert("Error: Bid is too low");
        }
    }
    
    function create_auction() public does_auction_exist(false) {
        current_bid = 0;
        auction_available = true;
    }

    function close_auction() public does_auction_exist(true) {
        auction_available = false;
        mint(highest_bidder);
        Bids[highest_bidder] = 0;
        for (uint256 i = 0; i < Bidders.length;) {

        }
    }
}
