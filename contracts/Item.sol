// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./TraceableObject.sol";

contract Item is TraceableObject {
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

    struct ProcedureData {
        string name;
        string[] mediaList;
        string[] sensorList;
        uint256 startTime;
        uint256 endTime;
    }
    address[] public procedureList;
    mapping(address => ProcedureData) private procedureData;

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

    function addSources(TraceData[] memory _sources)
        public
        virtual
        override
        onlyOrganization
        notExpired
    {
        super.addSources(_sources);
    }

    function addDests(TraceData[] memory _dests)
        public
        virtual
        override
        onlyOrganization
        notExpired
    {
        super.addDests(_dests);
    }

    function addProcedure(ProcedureData memory _procedureData)
        public
        notExpired
    {
        procedureList.push(msg.sender);
        procedureData[msg.sender] = _procedureData;
    }
}
