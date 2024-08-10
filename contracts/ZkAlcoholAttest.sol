// Copyright 2024 RISC Zero, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.20;

import "openzeppelin/contracts/utils/Base64.sol";
import "openzeppelin/contracts/token/ERC721/ERC721.sol";
import "openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {ImageID} from "./ImageID.sol"; // auto-generated contract after running `cargo build`.

contract ZkAlcoholAttest is ERC721, ERC721Burnable {
    /// @notice RISC Zero verifier contract address.
    IRiscZeroVerifier public immutable verifier;
    bytes32 public constant imageId = ImageID.ZK_ATTEST_GUEST_ID;

    mapping(uint256 => uint256) public alcoholLevels;
    uint256 private nextTokenId;

    /// @notice Initialize the contract, binding it to a specified RISC Zero verifier.
    constructor(
        IRiscZeroVerifier _verifier
    ) ERC721("zkAlcoholAttest", "ALCOHOL") {
        verifier = _verifier;
    }

    function mint(address to, uint256 value, bytes calldata seal) public {
        bytes memory journal = abi.encode(to, value);
        verifier.verify(seal, imageId, sha256(journal));
        uint256 tokenId = nextTokenId++;
        alcoholLevels[tokenId] = value;
        _mint(to, tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        require(tokenId < nextTokenId, "Token ID out of bounds");

        string[] memory uriParts = new string[](4);
        uriParts[0] = string("data:application/json;base64,");
        string memory level = Strings.toString(alcoholLevels[tokenId]);
        // TODO Fix descirption
        uriParts[1] = string(
            abi.encodePacked(
                '{"name":"Level ',
                level,
                '",',
                '"description":"This NFT represents your alcohol level attested by ZK",',
                '"attributes":[{"trait_type":"Level","value":"',
                level,
                '"}],',
                '"image":"data:image/svg+xml;base64,'
            )
        );
        uriParts[2] = Base64.encode(
            abi.encodePacked(
                '<svg width="800px" height="800px" viewBox="0 0 1024 1024" class="icon"  version="1.1" xmlns="http://www.w3.org/2000/svg"><path d="M857.6 345.6h-102.4v64h64v51.2c0 204.8-62.72 247.04-115.2 318.72C842.24 734.72 896 678.4 896 396.8c0-16.64 0-51.2-38.4-51.2z" fill="#FAC546" /><path d="M704 792.32c-3.84 0-7.68-1.28-10.24-5.12-3.84-5.12-3.84-10.24 0-15.36 7.68-11.52 16.64-21.76 24.32-32C764.16 683.52 806.4 629.76 806.4 460.8v-38.4h-51.2c-7.68 0-12.8-5.12-12.8-12.8v-64c0-7.68 5.12-12.8 12.8-12.8h102.4c51.2 0 51.2 48.64 51.2 64 0 279.04-52.48 345.6-200.96 394.24-1.28 1.28-2.56 1.28-3.84 1.28zM768 396.8h51.2c7.68 0 12.8 5.12 12.8 12.8v51.2c0 174.08-44.8 235.52-90.88 291.84C839.68 711.68 883.2 645.12 883.2 396.8c0-25.6-3.84-38.4-25.6-38.4h-89.6v38.4z" fill="#231C1C" /><path d="M755.2 819.2c0 28.16 0 76.8-76.8 76.8H320c-76.8 0-76.8-48.64-76.8-76.8V256h512v563.2z" fill="#FAC546" /><path d="M678.4 908.8H320c-89.6 0-89.6-62.72-89.6-89.6V256c0-7.68 5.12-12.8 12.8-12.8h512c7.68 0 12.8 5.12 12.8 12.8v563.2c0 26.88 0 89.6-89.6 89.6zM256 268.8v550.4c0 28.16 0 64 64 64h358.4c64 0 64-35.84 64-64V268.8H256z" fill="#231C1C" /><path d="M358.4 832c-7.68 0-12.8-5.12-12.8-12.8V448c0-7.68 5.12-12.8 12.8-12.8s12.8 5.12 12.8 12.8v371.2c0 7.68-5.12 12.8-12.8 12.8zM499.2 832c-7.68 0-12.8-5.12-12.8-12.8V448c0-7.68 5.12-12.8 12.8-12.8s12.8 5.12 12.8 12.8v371.2c0 7.68-5.12 12.8-12.8 12.8z" fill="#231C1C" /><path d="M640 832c-7.68 0-12.8-5.12-12.8-12.8V448c0-7.68 5.12-12.8 12.8-12.8s12.8 5.12 12.8 12.8v371.2c0 7.68-5.12 12.8-12.8 12.8z" fill="#231C1C" /><path d="M720.64 166.4c-3.84 0-7.68 0-11.52 1.28-14.08-24.32-38.4-39.68-66.56-39.68-34.56 0-81.92-19.2-92.16 12.8-10.24-10.24-6.4 25.6-21.76 25.6h-1.28c-6.4-57.6-51.2-64-107.52-64-48.64 0-89.6-3.84-103.68 42.24-12.8-10.24-5.12 8.96-23.04 8.96-43.52 0-76.8 11.52-76.8 57.6S225.28 256 268.8 256h11.52v83.2c0 17.92 14.08 32 32 32s32-14.08 32-32V256h51.2v179.2c0 14.08 16.64 25.6 38.4 25.6s38.4-11.52 38.4-25.6V256h89.6v64c0 21.76 16.64 38.4 38.4 38.4s38.4-16.64 38.4-38.4v-64h80.64c33.28 0 47.36 10.24 47.36-25.6s-12.8-64-46.08-64z" fill="#FFFFFF" /><path d="M435.2 473.6c-28.16 0-51.2-16.64-51.2-38.4V268.8h-25.6v70.4c0 24.32-20.48 44.8-44.8 44.8S268.8 363.52 268.8 339.2V268.8h-1.28c-21.76 0-37.12 0-47.36-7.68-11.52-8.96-14.08-25.6-14.08-49.92 0-46.08 30.72-70.4 89.6-70.4h1.28v-1.28c1.28-2.56 5.12-8.96 11.52-10.24h1.28C327.68 88.32 368.64 89.6 408.32 89.6h11.52c35.84 0 90.88 0 112.64 46.08 2.56-3.84 5.12-7.68 10.24-8.96C558.08 104.96 588.8 108.8 614.4 112.64c10.24 1.28 19.2 2.56 28.16 2.56 29.44 0 55.04 14.08 72.96 38.4 39.68-3.84 65.28 26.88 65.28 76.8 0 11.52-1.28 24.32-10.24 32-8.96 7.68-20.48 7.68-33.28 6.4-5.12 0-10.24-1.28-16.64-1.28H652.8v51.2c0 28.16-23.04 51.2-51.2 51.2s-51.2-23.04-51.2-51.2v-51.2h-64v166.4c0 23.04-23.04 39.68-51.2 39.68z m-89.6-230.4h51.2c7.68 0 12.8 5.12 12.8 12.8v179.2c0 5.12 10.24 12.8 25.6 12.8s25.6-7.68 25.6-12.8V256c0-7.68 5.12-12.8 12.8-12.8h89.6c7.68 0 12.8 5.12 12.8 12.8v64c0 14.08 11.52 25.6 25.6 25.6s25.6-11.52 25.6-25.6v-64c0-7.68 5.12-12.8 12.8-12.8h80.64c6.4 0 12.8 0 17.92 1.28 5.12 0 12.8 1.28 14.08 0 0 0 1.28-2.56 1.28-14.08 0-19.2-3.84-51.2-34.56-51.2-2.56 0-6.4 0-8.96 1.28-5.12 1.28-11.52-1.28-14.08-6.4C686.08 153.6 665.6 140.8 642.56 140.8c-10.24 0-21.76-1.28-32-2.56-30.72-3.84-44.8-3.84-48.64 7.68-1.28 3.84-5.12 7.68-8.96 8.96-2.56 8.96-7.68 25.6-24.32 25.6h-1.28c-6.4 0-11.52-5.12-12.8-11.52-3.84-46.08-34.56-53.76-94.72-53.76h-11.52c-47.36 0-70.4 1.28-79.36 33.28-1.28 3.84-3.84 7.68-8.96 8.96-2.56 0-3.84 1.28-6.4 0-2.56 5.12-8.96 8.96-19.2 8.96-56.32 0-64 21.76-64 44.8 0 6.4 0 25.6 5.12 29.44 3.84 2.56 16.64 2.56 32 2.56H281.6c7.68 0 12.8 5.12 12.8 12.8v83.2c0 10.24 8.96 19.2 19.2 19.2s19.2-8.96 19.2-19.2V256c0-7.68 5.12-12.8 12.8-12.8z" fill="#231C1C" /><text x="200" y="100" fill="#FAC546" font-family="Helvetica" font-size="150" font-weight="bold">Level ',
                level,
                "</text></svg>"
            )
        );
        uriParts[3] = string('"}');
        string memory uri = string.concat(
            uriParts[0],
            Base64.encode(
                abi.encodePacked(uriParts[1], uriParts[2], uriParts[3])
            )
        );

        return uri;
    }
}
