// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Mahi is ERC721, ERC721Enumerable, Pausable, Ownable {
    using Counters for Counters.Counter;
    uint256 maxSupply = 100;

    bool public allowListMintOpen = false;
    bool public publicMintOpen = false;

    //creating a mapping to allow some special people only to mint NFT
    mapping(address=>bool) public allowList;

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("Mahi", "MSD") {}

    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/QmW3caNC1J9QCBTSKypinjgwYMLv86bW7myhtbfe9PwzMh?filename=Dhoni.jpg";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    // creating a function that allows to operate allowListMintOpen and publicMintOpen
    function editMintWindow(bool _allowListMintOpen,bool _publicMintOpen) external onlyOwner{
        allowListMintOpen =_allowListMintOpen;
        publicMintOpen = _publicMintOpen;
    }

    //creating a function to deciding the cost = 0.001Eth for 1 NFT of already registered user
    function allowListMint() public payable{
        require(allowListMintOpen == true,"AllowList Mint Closed");
        require(allowList[msg.sender]== true,"You are not in Allow List");
        require(msg.value== 0.0001 ether,"Not Enough Fund!!");
        // require(totalSupply() < maxSupply,"NFT Sold Out");
        // uint256 tokenId = _tokenIdCounter.current();
        // _tokenIdCounter.increment();
        // _safeMint(msg.sender, tokenId);
        simplifyMint();
    }
   
    // rename safeMint -> publicmint and add some extra features(payable,limiting of supply
    // and deciding the cost = 0.01Eth for 1 NFT for public minter)
    function publicMint() public payable {
        require(publicMintOpen == true,"Public Mint Closed");
        require(msg.value== 0.001 ether,"Not Enough Fund!!");
        // require(totalSupply() < maxSupply,"NFT Sold Out");
        // uint256 tokenId = _tokenIdCounter.current();
        // _tokenIdCounter.increment();
        // _safeMint(msg.sender, tokenId);
        simplifyMint();
    }

    // for simplyfy the code we put common code of publicMint() and allowListMint() function 
    // in one seprate function
    function simplifyMint() internal{
        require(totalSupply() < maxSupply,"NFT Sold Out");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
    }

    //creating a function to add special address in allowList Mapping only that address will
    // allow to mint NFT during allowListMintOpen 
    function setAllowList(address[] calldata addresses) external onlyOwner{
        for(uint256 i=0;i<addresses.length;i++){
            allowList[addresses[i]]= true;
        }
    } 

    //creating a withdraw function to send contract balance on NFT creator or NFTowner's address
    function withdraw(address addrrs) external onlyOwner {
        //get the balance of contract
        uint256 balances = address(this).balance;
        payable(addrrs).transfer(balances);

    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}