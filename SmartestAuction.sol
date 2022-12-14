//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

address constant ADMIN = 0x3dEca47CfCB97E2a03a31bcAEe47d55B80bF8981;

contract NFT is ERC721 {
    uint256 private currentTokenID;
    string public url;
    uint256 min_price;

    constructor(string memory link) ERC721("WhaleEye", "WEye") {
        url = link;
        Whitelist[ADMIN] = true;
    }

    mapping (address => uint256) NFT_counter;
    mapping (address => bool) Whitelist;

    modifier cost() {
        require(msg.value >= 0.1 ether, "Error: Not enough money sent");
        _;
    }

    modifier is_admin() {
            require((msg.sender == ADMIN), "No admin permission");
            _;
        }

    modifier is_whitelisted(address recipient) {
        require((Whitelist[recipient] == true), "Error: Address is not whitelisted");
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

    function mint(address recipient) payable public cost() is_whitelisted(recipient) NFT_count(recipient) max_NFTs() returns (string memory) {         
        if (auction_enabled = false) {
            currentTokenID += 1;
            _safeMint(recipient, currentTokenID);
            payable(ADMIN).transfer(address(this).balance - 0.01 ether);
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
    mapping (address => uint256) public Bids;
    address payable [] public Bidders;
    
    modifier does_auction_exist(bool on_off) {
        if (on_off = false) {require((auction_available = false), "Error: Currently, there is an auction available");}
        else {require((auction_available = true), "Error: Currently, there is no auction available");}
        _;
    }

    modifier is_auction_enabled() {
        require((auction_enabled == true), "Auctions are disabled right now");
        _;
    }

    function enable_auction() public is_admin()  {
        auction_enabled = true;
    }

    function disable_auction() public does_auction_exist(false) is_admin() {
        auction_enabled = false;
    }

    function add_to_bid() public payable NFT_count(msg.sender) does_auction_exist(true) is_whitelisted(msg.sender) {
        require(((Bids[msg.sender] += msg.value) > min_price), "Error: Bid is lower than the minimum");
        require(((Bids[msg.sender] += msg.value) > current_bid), "Error: Your bid does not top the highest bid");
        Bids[msg.sender] += msg.value;
        highest_bidder = msg.sender; 
        current_bid = Bids[msg.sender]; 
        Bidders.push(payable(msg.sender));
    }
    
    function create_auction(uint256 minimum_price) public max_NFTs() is_auction_enabled() does_auction_exist(false) {
        current_bid = 0;
        auction_available = true;
        min_price = minimum_price;
    }

    function close_auction() public does_auction_exist(true) {
        auction_available = false;
        _safeMint(highest_bidder, currentTokenID);
        Bids[highest_bidder] = 0; 
        for (uint256 i = 0; i < Bidders.length; i++) {
            Bidders[i].transfer(Bids[Bidders[i]]);
        }
        highest_bidder = address(0);
        current_bid = 0;
        for (uint256 i = 0; i< Bidders.length; i++) {
            Bids[Bidders[i]] = 0;
        }
        delete Bidders;
    }

    function testing() public {
        add_to_whitelist(0x0D821AEFaB67ADe8053f9DBA5653B69D418413Ed);
        enable_auction();
        create_auction(0.1 ether);
    }
}

//Bids[msg.sender] 3x the expected value
