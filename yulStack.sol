// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Stack {
    uint256[] internal stack;

    //Push new item on to the stack.
    function stackPush(uint256 item) external {
        //stack.push(item);
        assembly {
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, stack.slot)
            let size := sload(stack.slot)
            sstore(stack.slot, add(size, 1))
            sstore(add(keccak256(freeMemoryPointer, 0x20), size), item)
        }
    }
    //Remove last item added to the stack.
    function stackPop() external {
        //stack.pop();
        assembly {
            let size := sload(stack.slot)
            if iszero(size) {
                revert(0, 0)
            }
            sstore(stack.slot, sub(size, 1))
        }
    }
    //Returns the amount of items in the stack.
    function stackSize() external view returns (uint256 ret) {
        //stack.length
        assembly {
            ret := sload(stack.slot)
        }
    }

    //Will revert if index out of bounds, use pop ito grow stack.
    function setStackIndex(uint256 index, uint256 value) external {
        //stack[index] = value;
        assembly {
            let size := sload(stack.slot)
            if iszero(lt(index, size)) {
                revert(0, 0)
            }
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, stack.slot)
            sstore(add(keccak256(freeMemoryPointer, 0x20), index), value)
        }
    }

    //Get item at index of stack.
    function readStackIndex(uint256 index) external view returns (uint256 ret) {
        // return stack[index];
        assembly {
            let size := sload(stack.slot)
            if iszero(lt(index, size)) {
                revert(0, 0)
            }
            let freeMemoryPointer := mload(0x40)
            mstore(freeMemoryPointer, stack.slot)
            ret := sload(add(keccak256(freeMemoryPointer, 0x20), index))
        }
    }

    // Finds distance from top of stack.
    // Expensive, O(n); n = distance from top of stack
    // Lookups deep in very large stacks may run out of gas.
    // use IndexedStack.sol if you need to call this function from a state-mutable function.
    function findDistance(uint256 value) external view returns (uint256 dist) {
        assembly {
            let size := sload(stack.slot)
            let freeMemoryPointer := mload(0x40)
            for {let i := sub(size, 1)} gt(size, i) {i := sub(i, 1)} {
                mstore(freeMemoryPointer, stack.slot)
                if eq(sload(add(keccak256(freeMemoryPointer, 0x20), i)), value) {
                    dist := sub(size, i)
                    break
                }
            }
            if eq(dist, 0) {
                revert(0, 0)
            }
        }
    }
}
