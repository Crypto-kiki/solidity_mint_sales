// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MintNft.sol";


contract SaleNft is Ownable {
    MintNft mintNftContract;

    constructor(address _mintNftAddress) {
        mintNftContract = MintNft(_mintNftAddress);
    }

    mapping(uint => uint) tokenPrices;
    uint[] public onSaleNft;

    function setSaleNft(uint _tokenId, uint _price) public {
        address nftOwner = mintNftContract.ownerOf(_tokenId);
        require(nftOwner == msg.sender);
        require(mintNftContract.isApprovedForAll(nftOwner, address(this)));  // 판매 권한 체크
        require(_price > 0);  // 음수로 팔지않고, 0원으로 판매등록 못하도록 
        require(tokenPrices[_tokenId] == 0 );  // 판매중이 아니여야 함.

        tokenPrices[_tokenId] = _price;
        onSaleNft.push(_tokenId);
    }

    function purchaseNft(uint _tokenId) public payable {
        address nftOwner = mintNftContract.ownerOf(_tokenId);
        uint nftPrice = tokenPrices[_tokenId];

        require(nftOwner != msg.sender);
        require(nftPrice > 0);
        require(nftPrice <= msg.value); // 돈이 충분한가. < 부등호를 사용한 이유는 돈을 더 주는 경우도 있을 수 있으니까?

        uint tradeFee = msg.value / 20;

        payable(nftOwner).transfer(msg.value - tradeFee);
        payable(owner()).transfer(tradeFee);
        mintNftContract.safeTransferFrom(nftOwner, msg.sender, _tokenId);
    }

}