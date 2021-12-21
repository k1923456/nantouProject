// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./TraceableObject.sol";

contract Item is TraceableObject {
    struct ItemData {
        uint256 shid;
        uint256 organizationID;
        uint256 producedDate;
        uint256 expirationDate;
        address payable organization;
        string name;
        string organizationName;
    }
    ItemData public itemData;

    struct ProcedureData {
        address procedure;
        string name;
        string[] mediaList;
        string[] sensorDataURLs;
        uint256 startTime;
        uint256 endTime;
    }
    ProcedureData[] public procedureList;

    event ItemCreated(
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

    modifier onlyProcedure(address _procedure) {
        require(
            msg.sender == _procedure,
            "Item: ProcedureData can only be added by prodecure"
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

    function addSources(TraceData[] memory _sources)
        public
        virtual
        override
        onlyOrganization
        notExpired
    {
        super.addSources(_sources);
    }

    function delSource(address _object)
        public
        virtual
        override
        onlyOrganization
    {
        super.delSource(_object);
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

    function delDest(address _object) public virtual override onlyOrganization {
        super.delDest(_object);
    }

    function markDestDeleted(address _object) public virtual override onlyOrganization {
        super.markDestDeleted(_object);
    }

    function destruct(address payable to)
        public
        virtual
        override
        onlyOrganization
    {
        super.destruct(to);
    }

    function addProcedure(ProcedureData memory _procedureData)
        public
        onlyProcedure(_procedureData.procedure)
        notExpired
    {
        procedureList.push(_procedureData);
    }
}
