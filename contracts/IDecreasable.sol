// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface IDecreasable {
    struct Quantity {
        uint256 producedNumber;
        uint256 restNumber;
        uint256 packNumber;
        string unit;
    }

    function decrease(uint256 _number) external;
}
