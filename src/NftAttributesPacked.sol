// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "solmate/utils/SSTORE2.sol";
import "forge-std/Test.sol";

contract NftAttributesPacked is Test {
    // can be constant but immutable for testing purposes
    address immutable storageAddress;

    uint256 internal constant MASK_ONE = 0xfc0000000000000;
    uint256 internal constant MASK_TWO = 0x3c000000000000;
    uint256 internal constant MASK_THREE = 0x3f00000000000;
    uint256 internal constant MASK_FOUR = 0xf0000000000;
    uint256 internal constant MASK_FIVE = 0xfe00000000;
    uint256 internal constant MASK_SIX = 0x1f8000000;
    uint256 internal constant MASK_SEVEN = 0x7e00000;
    uint256 internal constant MASK_EIGHT = 0x1fc000;
    uint256 internal constant MASK_NINE = 0x3c00;
    uint256 internal constant MASK_TEN = 0x3e0;
    uint256 internal constant MASK_ELEVEN = 0x1f;

    uint256 internal constant SHIFT_ZERO = 60;
    uint256 internal constant SHIFT_ONE = 54;
    uint256 internal constant SHIFT_TWO = 50;
    uint256 internal constant SHIFT_THREE = 44;
    uint256 internal constant SHIFT_FOUR = 40;
    uint256 internal constant SHIFT_FIVE = 33;
    uint256 internal constant SHIFT_SIX = 27;
    uint256 internal constant SHIFT_SEVEN = 21;
    uint256 internal constant SHIFT_EIGHT = 14;
    uint256 internal constant SHIFT_NINE = 10;
    uint256 internal constant SHIFT_TEN = 5;

    uint256 internal constant MASK_ATTRIBUTES = 0x3FFFFFFFFFFFFFFFF;

    constructor(address _storageAddress) {
        storageAddress = _storageAddress;
    }

    function readTokenAttributes(uint256 tokenId) public view returns (uint8[12] memory attributes) {
        unchecked {
            uint256 endBit = tokenId * 66;
            uint256 endByte = divRoundUp(endBit, 8);
            uint256 junkBitsRight = endByte * 8 - endBit;
            uint72 attributesWithJunk = uint72(bytes9((SSTORE2.read(storageAddress, (tokenId - 1) * 66 / 8, endByte))));

            return parseTokenAttributes(uint72(attributesWithJunk >> junkBitsRight & MASK_ATTRIBUTES));    
        }
    }

    function parseTokenAttributes(uint72 attributesPacked) internal pure returns (uint8[12] memory attributes) {
        attributes[0] = uint8(attributesPacked >> SHIFT_ZERO);
        attributes[1] = uint8((attributesPacked & MASK_ONE) >> SHIFT_ONE);
        attributes[2] = uint8((attributesPacked & MASK_TWO) >> SHIFT_TWO);
        attributes[3] = uint8((attributesPacked & MASK_THREE) >> SHIFT_THREE);
        attributes[4] = uint8((attributesPacked & MASK_FOUR) >> SHIFT_FOUR);
        attributes[5] = uint8((attributesPacked & MASK_FIVE) >> SHIFT_FIVE);
        attributes[6] = uint8((attributesPacked & MASK_SIX) >> SHIFT_SIX);
        attributes[7] = uint8((attributesPacked & MASK_SEVEN) >> SHIFT_SEVEN);
        attributes[8] = uint8((attributesPacked & MASK_EIGHT) >> SHIFT_EIGHT);
        attributes[9] = uint8((attributesPacked & MASK_NINE) >> SHIFT_NINE);
        attributes[10] = uint8((attributesPacked & MASK_TEN) >> SHIFT_TEN);
        attributes[11] = uint8((attributesPacked & MASK_ELEVEN));
    }

    function divRoundUp(
        uint256 x,
        uint256 y
    ) internal pure returns (uint256 z) {
        /// @solidity memory-safe-assembly
        assembly {
            // Equivalent to require(y != 0)
            if iszero(y) {
                revert(0, 0)
            }

            // If x modulo y is strictly greater than 0,
            // 1 is added to round up the division of x by the y.
            z := add(gt(mod(x, y), 0), div(x, y))
        }
    }
}
