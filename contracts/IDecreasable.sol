// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IDecreasable {
    struct Quantity {
        uint256 restNumber;
        uint256 maxNumber;
        uint256 maxPackNumber;
        string unit;
    }

    function decrease(uint256 _number) external;
}
