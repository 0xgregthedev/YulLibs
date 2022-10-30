//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

abstract contract ReentrancyGuard {
    error Reentered();
    uint256 private _locked = 1;

    modifier nonReentrant() virtual {
        assembly {
            //Revert Reentered()
            if eq(sload(_locked.slot), 0x2) {
                mstore(0x00, 0xb5dfd9e5)
                revert(0x1c, 0x04)
            }
            sstore(_locked.slot, 0x2)
        }
        _;
        assembly {
            sstore(_locked.slot, 0x1)
        }
    }
}
