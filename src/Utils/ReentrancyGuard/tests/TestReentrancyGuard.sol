//SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

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

contract Test is ReentrancyGuard {
    mapping(address => bool) private _tested;

    function vulnerable() external {
        require(!_tested[msg.sender]);
        AttackVulnerable(payable(address(msg.sender))).receiver();
        _tested[msg.sender] = true;
    }

    function guarded() external nonReentrant {
        require(!_tested[msg.sender]);
        AttackGuarded(payable(address(msg.sender))).receiver();
        _tested[msg.sender] = true;
    }
}

contract AttackVulnerable {
    Test test;
    uint256 public counter;
    uint256 public attackLimit;
    uint256 public attackValue;

    constructor() {
        test = new Test();
    }
    
    function attack(uint256 _attackLimit) external {
        attackLimit = _attackLimit;
        test.vulnerable();
    }
    function receiver() external {
        if (++counter >= attackLimit) return;
        test.vulnerable();
    }
}

contract AttackGuarded {
    Test test;
    uint256 public counter;
    uint256 public attackLimit;
    uint256 public attackValue;

    constructor() {
        test = new Test();
    }

    function attack(uint256 _attackLimit) external {
        attackLimit = _attackLimit;
        test.guarded();
    }
    function receiver() external {
        if (++counter >= attackLimit) return;
        test.guarded();
    }
}
