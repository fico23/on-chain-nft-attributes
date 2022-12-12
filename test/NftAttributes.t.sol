// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/NftAttributes.sol";
import "../src/NftAttributesPacked.sol";
import "solmate/utils/SSTORE2.sol";

contract NftAttributesTest is Test {
    NftAttributes public nftAttributes;
    NftAttributesPacked public nftAttributesPacked;
    address public storageAddress;
    address public storagePackedAddress;

    function setUp() public {
        bytes memory attributesBytecode = vm.getCode("artifacts/random5000NFTs.json");

        assembly {
            sstore(storageAddress.slot, create(0, add(attributesBytecode, 0x20), mload(attributesBytecode)))
        }

        nftAttributes = new NftAttributes(storageAddress);

        bytes memory attributesPackedBytecode = vm.getCode("artifacts/random5000NFTsPacked.json");

        assembly {
            sstore(
                storagePackedAddress.slot,
                create(0, add(attributesPackedBytecode, 0x20), mload(attributesPackedBytecode))
            )
        }

        nftAttributesPacked = new NftAttributesPacked(storagePackedAddress);
    }

    function assertAttributes(uint8[12] memory attributes, uint8[12] memory expectedAttributes) internal {
        for (uint256 i = 0; i < 12; i++) {
            assertEq(attributes[i], expectedAttributes[i]);
        }
    }

    function testAttributes() public {
        uint8[12] memory expectedToken1 = [27, 35, 6, 15, 0, 68, 32, 11, 39, 3, 20, 16];
        assertAttributes(nftAttributes.readTokenAttributes(1), expectedToken1);
        assertAttributes(nftAttributesPacked.readTokenAttributes(1), expectedToken1);

        uint8[12] memory expectedToken1000 = [55, 14, 6, 35, 6, 80, 5, 27, 4, 3, 5, 14];
        assertAttributes(nftAttributes.readTokenAttributes(1000), expectedToken1000);
        assertAttributes(nftAttributesPacked.readTokenAttributes(1000), expectedToken1000);

        uint8[12] memory expectedToken4000 = [7, 43, 0, 30, 3, 36, 2, 34, 17, 1, 23, 21];
        assertAttributes(nftAttributes.readTokenAttributes(4000), expectedToken4000);
        assertAttributes(nftAttributesPacked.readTokenAttributes(4000), expectedToken4000);

        uint8[12] memory expectedToken5000 = [0, 58, 7, 6, 8, 17, 45, 49, 46, 4, 12, 15];
        assertAttributes(nftAttributes.readTokenAttributes(5000), expectedToken5000);
        assertAttributes(nftAttributesPacked.readTokenAttributes(5000), expectedToken5000);
    }
}
