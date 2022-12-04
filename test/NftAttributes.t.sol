// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NftAttributes.sol";
import "solmate/utils/SSTORE2.sol";

contract NftAttributesTest is Test {
    NftAttributes public nftAttributes;
    address public storageAddress;

    function setUp() public {
        bytes memory attributesBytecode = vm.getCode("artifacts/random5000NFTs.json");

        assembly {
            sstore(storageAddress.slot, create(0, add(attributesBytecode, 0x20), mload(attributesBytecode)))
        }

        nftAttributes = new NftAttributes(storageAddress);
    }

    function assertAttributes(uint8[12] memory attributes, uint8[12] memory expectedAttributes) internal {
        for (uint256 i = 0; i < 12; i++) {
            assertEq(attributes[i], expectedAttributes[i]);
        }
    }

    function testAttributes() public {
        uint8[12] memory expectedToken1 = [48, 29, 4, 39, 10, 30, 13, 50, 23, 7, 12, 13];
        assertAttributes(nftAttributes.readTokenAttributes(1), expectedToken1);

        uint8[12] memory expectedToken1000 = [50, 15, 0, 8, 8, 89, 11, 51, 56, 7, 20, 23];
        assertAttributes(nftAttributes.readTokenAttributes(1000), expectedToken1000);

        uint8[12] memory expectedToken4000 = [28, 44, 2, 40, 9, 2, 35, 45, 25, 2, 25, 26];
        assertAttributes(nftAttributes.readTokenAttributes(4000), expectedToken4000);

        uint8[12] memory expectedToken5000 = [34, 34, 4, 29, 0, 48, 40, 34, 71, 3, 5, 14];
        assertAttributes(nftAttributes.readTokenAttributes(5000), expectedToken5000);
    }
}
