// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./IDecreasable.sol";

contract Product is IDecreasable {
    Quantity public quantity;

    struct ProductData {
        uint256 phid;
        uint256 organizationID;
        uint256 ownerID;
        uint256 transactionDate;
        uint256 expirationDate;
        address organization;
        address owner;
        string name;
        string organizationName;
        string ownerName;
    }
    ProductData public productData;

    struct UsedItemData {
        uint256 shid;
        uint256 phid;
        address usedItem;
        uint256 usedNumber;
    }
    UsedItemData[] public sourceList;
    UsedItemData[] public destinationList;
    mapping(address => bool) public destination;

    event ProductCreated(
        uint256 indexed phid,
        uint256 organizationID,
        uint256 ownerID,
        uint256 number,
        uint256 packNumber,
        uint256 transactionDate,
        uint256 expirationDate,
        address organization,
        address owner
    );

    event ProductModified(
        uint256 indexed phid,
        uint256 organizationID,
        uint256 ownerID,
        uint256 number,
        uint256 packNumber,
        uint256 transactionDate,
        uint256 expirationDate,
        address organization,
        address owner
    );

    modifier onlyOrganization() {
        require(
            msg.sender == productData.organization,
            "Item: Caller is not a valid organization"
        );
        _;
    }

    modifier notExpired() {
        require(
            block.timestamp <= productData.expirationDate,
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

    constructor(
        ProductData memory _productData,
        Quantity memory _quantity
    ) {
        productData = _productData;
        quantity = _quantity;

        emit ProductCreated(
            _productData.phid,
            _productData.organizationID,
            _productData.ownerID,
            _quantity.maxNumber,
            _quantity.maxPackNumber,
            _productData.transactionDate,
            _productData.expirationDate,
            _productData.organization,
            _productData.owner
        );
    }

    function modify(
        ProductData memory _productData,
        Quantity memory _quantity
    ) public onlyOrganization {
        productData = _productData;
        quantity = _quantity;

        emit ProductCreated(
            _productData.phid,
            _productData.organizationID,
            _productData.ownerID,
            _quantity.maxNumber,
            _quantity.maxPackNumber,
            _productData.transactionDate,
            _productData.expirationDate,
            _productData.organization,
            _productData.owner
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
}
