// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Smart Contract to Sell the Tickets in the Form of the NFTs

contract TicketNFT is ERC1155, Ownable, Pausable, ERC1155Supply {

    // Ticket Prices has been set for Both Public and Super Fans
    uint256 public ticketPrice = 0.01 ether;
    uint256 public superFansTicketPrice = 0.005 ether;

    // List containing SuperFans Addresses
    mapping(address => bool) public superFansAddresses;

    // Max Supply of Tickets
    uint32 public maxTickets = 1000;

    // Boolean to Start the Sale of the Tickets
    bool public saleStartForPublic = false;
    bool public saleStartForSuperFans = false;

    event AddedAsSuperFan(address indexed _addr);
    event TicketBought(address indexed _addr, uint amount, uint price);

    constructor()
        ERC1155("ipfs://QmWYJTtxreTnAjZStk3BF9V73SuZU1YepqHumkcv7dRzC2/")
    {}

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function uri(uint256 _id) public view virtual override returns (string memory){
        require(exists(_id), "URI: Nonexistence token!");
        return string(abi.encodePacked(super.uri(_id), Strings.toString(_id), ".json"));
    }

    // Starting Sale for Super Fans
    function startSaleForSuperFans() external onlyOwner {
        saleStartForSuperFans = true;
    }

    // Starting Sale for Public
    function startSaleForPublic() external onlyOwner {
        saleStartForPublic = true;
    }

    // Adding Super Fans Addresses by the owner
    function addSuperFans(address _addr) external onlyOwner{
        superFansAddresses[_addr] = true;
        emit AddedAsSuperFan(_addr);
    }

    // Withdrawal of Funds by the Owner
    function withdraw() public onlyOwner {
        address _owner = owner();
        uint256 amount = address(this).balance;
        (bool sent, ) = _owner.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // NFT minting for the Super Fans
    function superFansMint(uint256 amount)
        public
        payable
    {
        require(saleStartForSuperFans, "Sale is not Started Yet For Super Fans!");
        require(superFansAddresses[msg.sender], "You are not the Member of Super Fans ;(");
        require(msg.value >= superFansTicketPrice * amount, "Not Enough Money Sent to buy the Ticket!");
        require(totalSupply(1) + amount <= maxTickets, "Required No. of Tickets Not Available!");

        _mint(msg.sender, 1, amount, "");
        emit TicketBought(msg.sender, amount, msg.value);
    }

    // NFT minting for the Public
    function publicMint(uint256 amount)
        public
        payable
    {
        require(saleStartForPublic, "Sale is not Started Yet for Public!");
        require(msg.value >= ticketPrice * amount, "Not Enough Money Sent to buy the Ticket!");
        require(totalSupply(1) + amount <= maxTickets, "Required No. of Tickets Not Available!");

        _mint(msg.sender, 1, amount, "");
        emit TicketBought(msg.sender, amount, msg.value);
    }

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {}

    // Fallback function is called when msg.data is not empty
    fallback() external payable {}
}