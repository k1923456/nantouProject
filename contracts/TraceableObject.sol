// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
import "hardhat/console.sol";

abstract contract TraceableObject {
    uint256 public constant DIVISOR = 10000;

    struct Quantity {
        uint256 producedNumber;
        uint256 restNumber;
        uint256 packNumber;
        string unit;
    }
    Quantity public quantity;

    struct TraceData {
        uint256 shid;
        uint256 phid;
        address usedObject;
        uint256 usedNumber;
        bool isDeleted;
        string name;
    }
    TraceData[] public sourceList;
    TraceData[] public destinationList;
    mapping(address => bool) public isDestination;

    modifier enoughQuantity(uint256 _number) {
        require(
            _number <= quantity.restNumber,
            "TraceableObject: quantity is not enough"
        );
        _;
    }

    modifier notExceedQuantity(uint256 _number) {
        require(
            _number + quantity.restNumber <= quantity.producedNumber,
            "TraceableObject: quantity exceeds produced number"
        );
        _;
    }

    modifier requireDest(address _item) {
        require(
            isDestination[_item] == true,
            "TraceableObject: Item is not in destination"
        );
        _;
    }

    function getDivisor() public pure returns (uint256) {
        return DIVISOR;
    }

    function decrease(uint256 _number)
        public
        requireDest(msg.sender)
        enoughQuantity(_number)
    {
        quantity.restNumber -= _number;
    }

    function increase(uint256 _number) internal notExceedQuantity(_number) {
        quantity.restNumber += _number;
    }

    function getSourceList() public view returns (TraceData[] memory) {
        return sourceList;
    }

    function addSources(TraceData[] memory _sources) public virtual {
        for (uint256 i = 0; i < _sources.length; i++) {
            sourceList.push(_sources[i]);
            TraceableObject(_sources[i].usedObject).decrease(
                _sources[i].usedNumber
            );
        }
    }

    function delSource(address _object) public virtual {
        for (uint256 i = 0; i < sourceList.length; i++) {
            if (sourceList[i].usedObject == _object) {
                sourceList[i].isDeleted = true;
                break;
            }
        }
    }

    function getDestinationList() public view returns (TraceData[] memory) {
        return destinationList;
    }

    function addDests(TraceData[] memory _dests) public virtual {
        console.log("AAA");
        for (uint256 i = 0; i < _dests.length; i++) {
            console.log("BBB");
            destinationList.push(_dests[i]);
            console.log("BBB");
            isDestination[_dests[i].usedObject] = true;
        }
    }

    function delDest(address _object) public virtual {
        for (uint256 i = 0; i < destinationList.length; i++) {
            if (destinationList[i].usedObject == _object) {
                destinationList[i].isDeleted = true;
                increase(destinationList[i].usedNumber);
                break;
            }
        }
    }

    function markDestDeleted(address _object) public virtual {
        for (uint256 i = 0; i < destinationList.length; i++) {
            if (destinationList[i].usedObject == _object) {
                destinationList[i].isDeleted = true;
                break;
            }
        }
    }

    function destruct(address payable to) public virtual {
        selfdestruct(to);
    }
}
