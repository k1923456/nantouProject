// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IDecreasable.sol";

contract Item is IDecreasable {
    Quantity public quantity;

    struct ItemData {
        uint256 shid;
        uint256 organizationID;
        uint256 producedDate;
        uint256 expirationDate;
        address organization;
        string name;
        string organizationName;
    }
    ItemData public itemData;

    struct ProcedureMetadata {
        string name;
        string[] mediaList;
        string[] sensorList;
        uint256 startTime;
        uint256 endTime;
    }
    address[] public procedureList;
    mapping(address => ProcedureMetadata) private procedureData;

    struct UsedItemData {
        uint256 shid;
        uint256 phid;
        address usedItem;
        uint256 usedNumber;
    }
    UsedItemData[] public sourceList;
    UsedItemData[] public destinationList;
    mapping(address => bool) public destination;

    event ItemCreated(
        uint256 indexed shid,
        uint256 producedNumber,
        uint256 restNumber,
        uint256 packNumber,
        uint256 producedDate,
        uint256 expirationDate,
        address organization
    );

    event ItemModified(
        uint256 indexed shid,
        uint256 producedNumber,
        uint256 restNumber,
        uint256 packNumber,
        uint256 producedDate,
        uint256 expirationDate,
        address organization
    );

    modifier onlyOrganization() {
        require(
            msg.sender == itemData.organization,
            "Item: Caller is not a valid organization"
        );
        _;
    }

    modifier notExpired() {
        require(
            block.timestamp <= itemData.expirationDate,
            "Item: This item has been expired"
        );
        _;
    }

    modifier enoughQuantity(uint256 _number) {
        require(_number <= quantity.restNumber, "Item: quantity is not enough");
        _;
    }

    modifier requireDest(address _item) {
        require(destination[_item] == true, "Item: Item is not in destination");
        _;
    }

    constructor(ItemData memory _itemData, Quantity memory _quantity) {
        itemData = _itemData;
        quantity = _quantity;

        emit ItemCreated(
            _itemData.shid,
            _quantity.producedNumber,
            _quantity.restNumber,
            _quantity.packNumber,
            _itemData.producedDate,
            _itemData.expirationDate,
            _itemData.organization
        );
    }

    function modify(ItemData memory _itemData, Quantity memory _quantity)
        public
        onlyOrganization
    {
        itemData = _itemData;
        quantity = _quantity;

        emit ItemModified(
            _itemData.shid,
            _quantity.producedNumber,
            _quantity.restNumber,
            _quantity.packNumber,
            _itemData.producedDate,
            _itemData.expirationDate,
            _itemData.organization
        );
    }

    function decrease(uint256 _number)
        public
        requireDest(msg.sender)
        enoughQuantity(_number)
    {
        quantity.restNumber -= _number;
    }

    function addSources(UsedItemData[] memory _sources)
        public
        onlyOrganization
        notExpired
    {
        for (uint256 i = 0; i < _sources.length; i++) {
            sourceList.push(_sources[i]);
            IDecreasable(_sources[i].usedItem).decrease(_sources[i].usedNumber);
        }
    }

    function addDests(UsedItemData[] memory _dests)
        public
        onlyOrganization
        notExpired
    {
        for (uint256 i = 0; i < _dests.length; i++) {
            destinationList.push(_dests[i]);
            destination[_dests[i].usedItem] = true;
        }
    }

    function addProcedure(ProcedureMetadata memory _procedureData)
        public
        notExpired
    {
        procedureList.push(msg.sender);
        procedureData[msg.sender] = _procedureData;
    }
}
