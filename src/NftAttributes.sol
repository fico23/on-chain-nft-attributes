// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/utils/SSTORE2.sol";

contract NftAttributes {
    // can be constant but immutable for testing purposes
    address immutable storageAddress;

    uint8 internal constant MASK_4_DIGITS = 0xf;
    uint8 internal constant MASK_5_DIGITS = 0x1f;
    uint8 internal constant MASK_6_DIGITS = 0x3f;
    uint8 internal constant MASK_7_DIGITS = 0x7f;

    uint8 internal constant SHIFT_ZERO = 60;
    uint8 internal constant SHIFT_ONE = 54;
    uint8 internal constant SHIFT_TWO = 50;
    uint8 internal constant SHIFT_THREE = 44;
    uint8 internal constant SHIFT_FOUR = 40;
    uint8 internal constant SHIFT_FIVE = 33;
    uint8 internal constant SHIFT_SIX = 27;
    uint8 internal constant SHIFT_SEVEN = 21;
    uint8 internal constant SHIFT_EIGHT = 14;
    uint8 internal constant SHIFT_NINE = 10;
    uint8 internal constant SHIFT_TEN = 5;

    constructor(address _storageAddress) {
        storageAddress = _storageAddress;
    }

    function readTokenAttributes(uint256 tokenId) public view returns (uint8[12] memory attributes) {
        unchecked {
            return parseTokenAttributes(uint72(bytes9((SSTORE2.read(storageAddress, (tokenId - 1) * 9, tokenId * 9)))));
        }
    }

    function parseTokenAttributes(uint72 attributesPacked) internal pure returns (uint8[12] memory attributes) {
        attributes[0] = uint8(attributesPacked >> SHIFT_ZERO);
        attributes[1] = uint8(attributesPacked >> SHIFT_ONE) & MASK_6_DIGITS;
        attributes[2] = uint8(attributesPacked >> SHIFT_TWO) & MASK_4_DIGITS;
        attributes[3] = uint8(attributesPacked >> SHIFT_THREE) & MASK_6_DIGITS;
        attributes[4] = uint8(attributesPacked >> SHIFT_FOUR) & MASK_4_DIGITS;
        attributes[5] = uint8(attributesPacked >> SHIFT_FIVE) & MASK_7_DIGITS;
        attributes[6] = uint8(attributesPacked >> SHIFT_SIX) & MASK_6_DIGITS;
        attributes[7] = uint8(attributesPacked >> SHIFT_SEVEN) & MASK_6_DIGITS;
        attributes[8] = uint8(attributesPacked >> SHIFT_EIGHT) & MASK_7_DIGITS;
        attributes[9] = uint8(attributesPacked >> SHIFT_NINE) & MASK_4_DIGITS;
        attributes[10] = uint8(attributesPacked >> SHIFT_TEN) & MASK_5_DIGITS;
        attributes[11] = uint8(attributesPacked) & MASK_5_DIGITS;
    }
}
