// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "./TraceableObject.sol";

contract Product is TraceableObject {
    struct ProductData {
        uint256 phid;
        uint256 organizationID;
        uint256 ownerID;
        uint256 transactionDate;
        uint256 expirationDate;
        address payable organization;
        address owner;
        string name;
        string organizationName;
        string ownerName;
    }
    ProductData public productData;

    event ProductCreated(
        uint256 indexed phid,
        uint256 producedNumber,
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

    constructor(ProductData memory _productData, Quantity memory _quantity) {
        productData = _productData;
        quantity = _quantity;

        emit ProductCreated(
            _productData.phid,
            _quantity.producedNumber,
            _quantity.packNumber,
            _productData.transactionDate,
            _productData.expirationDate,
            _productData.organization,
            _productData.owner
        );
    }

    function destruct() public onlyOrganization {
        selfdestruct(productData.organization);
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
}
