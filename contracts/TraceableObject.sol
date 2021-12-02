// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

abstract contract TraceableObject {
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
    }
    TraceData[] public sourceList;
    TraceData[] public destinationList;
    mapping(address => bool) public destination;

    modifier enoughQuantity(uint256 _number) {
        require(_number <= quantity.restNumber, "Item: quantity is not enough");
        _;
    }

    modifier requireDest(address _item) {
        require(destination[_item] == true, "Item: Item is not in destination");
        _;
    }

    function decrease(uint256 _number)
        public
        requireDest(msg.sender)
        enoughQuantity(_number)
    {
        quantity.restNumber -= _number;
    }

    function addSources(TraceData[] memory _sources)
        public
        virtual
    {
        for (uint256 i = 0; i < _sources.length; i++) {
            sourceList.push(_sources[i]);
            TraceableObject(_sources[i].usedObject).decrease(_sources[i].usedNumber);
        }
    }

    function addDests(TraceData[] memory _dests)
        public
        virtual
    {
        for (uint256 i = 0; i < _dests.length; i++) {
            destinationList.push(_dests[i]);
            destination[_dests[i].usedObject] = true;
        }
    }
}
