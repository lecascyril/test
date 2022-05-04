// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";



contract Billets is ERC1155, Ownable, PaymentSplitter{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct Ticket{
        string nameShoww;
        uint date;
        uint maxSupply;
    }
    Ticket[] ticket;
    mapping(uint => uint) public ticketsSold;

    constructor(address[] memory _payees, uint256[] memory _shares) 
        ERC1155("https://gateway.pinata.cloud/ipfs/QmT2uYvfEgNFDMGSwiVvQ6EUuKgEPj88NKnFtmwi5eRquv/{id}.json")
        PaymentSplitter(_payees, _shares) payable {
            ticket.push(Ticket("Fake",block.timestamp, 1));
        }

     function supportsInterface(bytes4 interfaceId) public view virtual override(ERC1155) returns (bool){
        return super.supportsInterface(interfaceId);
    }

    function CreateBillet(string memory _nameShow, uint _date, uint _maxSupply) public onlyOwner{
        _tokenIds.increment();
		ticket.push(Ticket(_nameShow, _date, _maxSupply));
    }

    function MintTicket(address _spectator, uint _id, uint _amount) public{
        require(ticket[_id].date>block.timestamp, "spectacle deja fait");
        require(_id < _tokenIds.current(), "vous essayer de miter des nft n'existant pas");
        require(ticketsSold[_id]+_amount <= ticket[_id].maxSupply, "Il n'y a plus assez de ticket a la vente");
        _mint(_spectator, _id, _amount, "");
    }
}
