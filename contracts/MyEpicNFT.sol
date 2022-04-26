// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";

import { Base64 } from "./libraries/Base64.sol";

contract MyEpicNFT is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
    string baseSvgTwo = "' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    string[] firstWords = ["Epic", "Dope", "Woke", "Shook", "Dupe"];
    string[] secondWords = ["Lord", "Sire", "Highness", "Knight", "King"];
    string[] thirdWords = ["Pepe", "Shrek", "Farquad", "Donkey", "Puss"];
    uint8 maxMints;

    string[] colors = ["#000033", "#004d40", "#bf360c", "#4a148c", "#880e4f", "#b71c1c"];

    event NewEpicNFTMinted(address sender, uint256 tokenId, string name);

    constructor() ERC721 ("EpicNFT", "EPIC") {
        console.log("Finally making my NFT contract!!");
        maxMints = 11;
    }

    modifier canMint() {
        require(_tokenIds.current() < maxMints, "Can't mint any more NFTs");
        _;
    }

    function _random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function _pickRandomWordFromArray(string[] memory _arr, string memory _seedPhrase, uint _tokenId) internal pure returns (string memory) {
        uint rand = _random(string(abi.encodePacked(_seedPhrase, Strings.toString(_tokenId))));
        rand = rand % _arr.length;
        return _arr[rand];
    }

    function makeAnEpicNFT() public canMint {
        uint newItemId = _tokenIds.current();

        string memory firstWord = _pickRandomWordFromArray(firstWords, "FIRST", newItemId);
        string memory secondWord = _pickRandomWordFromArray(secondWords, "SECOND", newItemId);
        string memory thirdWord = _pickRandomWordFromArray(thirdWords, "THIRD", newItemId);
        string memory combinedWord = string(abi.encodePacked(firstWord, secondWord, thirdWord));

        string memory color = _pickRandomWordFromArray(colors, "COLOR", newItemId);

        string memory finalSvg = string(abi.encodePacked(baseSvg, color, baseSvgTwo, combinedWord, "</text></svg>"));

        console.log("\n--------------------");
        console.log(finalSvg);
        console.log("--------------------\n");

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "', combinedWord, 
                        '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        _setTokenURI(newItemId, finalTokenUri);
        _tokenIds.increment();

        console.log("An NFT w/ ID %s has been minted to %s", newItemId, msg.sender);
        emit NewEpicNFTMinted(msg.sender, newItemId, combinedWord);
    }
}