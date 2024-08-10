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

import {RiscZeroCheats} from "risc0/test/RiscZeroCheats.sol";
import {console2} from "forge-std/console2.sol";
import {Test} from "forge-std/Test.sol";
import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {ZkAlcoholAttest} from "../contracts/ZkAlcoholAttest.sol";
import {Elf} from "./Elf.sol"; // auto-generated contract after running `cargo build`.

contract ZkAlcoholAttestTest is RiscZeroCheats, Test {
    ZkAlcoholAttest public zkAlcoholAttest;

    function setUp() public {
        IRiscZeroVerifier verifier = deployRiscZeroVerifier();
        zkAlcoholAttest = new ZkAlcoholAttest(verifier);
    }

    function test_Mint() public {
        uint256 value = 12;
        address to = 0x0901549Bc297BCFf4221d0ECfc0f718932205e33;
        (bytes memory journal, bytes memory seal) = prove(
            Elf.ZK_ATTEST_GUEST_PATH,
            abi.encode(to, value)
        );

        // decode address to and uint256 value from journal
        (address decodedTo, uint256 decodedValue) = abi.decode(
            journal,
            (address, uint256)
        );

        zkAlcoholAttest.mint(decodedTo, decodedValue, seal);
        assertEq(zkAlcoholAttest.balanceOf(to), 1);
        assertEq(zkAlcoholAttest.alcoholLevels(0), value);
    }
}
