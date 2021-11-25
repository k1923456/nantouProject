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
    mapping(address => ProcedureMetadata) private procedureMetadata;

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
        uint256 organizationID,
        uint256 restNumber,
        uint256 maxNumber,
        uint256 maxPackNumber,
        uint256 producedDate,
        uint256 expirationDate,
        address organization
    );

    event ItemModified(
        uint256 indexed shid,
        uint256 organizationID,
        uint256 restNumber,
        uint256 maxNumber,
        uint256 maxPackNumber,
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

    modifier onlyDest(address _item) {
        require(destination[_item] == true, "Item: Item is not in destination");
        _;
    }

    constructor(
        ItemData memory _itemData,
        uint256 _maxNumber,
        uint256 _maxPackNumber,
        string memory _unit
    ) {
        itemData = _itemData;
        quantity.restNumber = _maxNumber;
        quantity.maxNumber = _maxNumber;
        quantity.unit = _unit;
        quantity.maxPackNumber = _maxPackNumber;

        emit ItemCreated(
            _itemData.shid,
            _itemData.organizationID,
            _maxNumber,
            _maxNumber,
            _maxPackNumber,
            _itemData.producedDate,
            _itemData.expirationDate,
            _itemData.organization
        );
    }

    function modify(
        ItemData memory _itemData,
        uint256 _maxNumber,
        uint256 _maxPackNumber,
        string memory _unit
    ) public onlyOrganization {
        itemData = _itemData;
        quantity.restNumber = _maxNumber;
        quantity.maxNumber = _maxNumber;
        quantity.unit = _unit;
        quantity.maxPackNumber = _maxPackNumber;

        emit ItemModified(
            _itemData.shid,
            _itemData.organizationID,
            _maxNumber,
            _maxNumber,
            _maxPackNumber,
            _itemData.producedDate,
            _itemData.expirationDate,
            _itemData.organization
        );
    }

    function decrease(uint256 _number)
        public
        onlyDest(msg.sender)
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
            decrease(_dests[i].usedNumber);
        }
    }

    function addProcedure(
        uint256 _startTime,
        uint256 _endTime,
        string memory _name,
        string[] memory _mediaList,
        string[] memory _sensorList
    ) public notExpired {
        procedureList.push(msg.sender);
        procedureMetadata[msg.sender].startTime = _startTime;
        procedureMetadata[msg.sender].endTime = _endTime;
        procedureMetadata[msg.sender].name = _name;
        procedureMetadata[msg.sender].mediaList = _mediaList;
        procedureMetadata[msg.sender].sensorList = _sensorList;
    }
}
