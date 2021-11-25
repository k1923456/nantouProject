// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

contract Item {
    uint256 public shid;
    uint256 public organizationID;
    uint256 public producedDate;
    uint256 public expirationDate;
    string public name;
    string public organizationName;
    address public manufacturer;

    address[] public sourceList;
    address[] public destinationList;

    struct Quantity {
        uint256 number;
        uint256 maxNumber;
        uint256 maxPackNumber;
        string unit;
    }

    struct ProcedureMetadata {
        uint256 startTime;
        uint256 endTime;
        string name;
        string[] mediaList;
        string[] sensorList;
    }
    
    Quantity public quantity;
    mapping(address => ProcedureMetadata) private metadata;

    modifier onlyManufacurer() {
        require(msg.sender == manufacturer, "Caller is not a manufacturer.");
        _;
    }

    modifier notExpired(uint256 timestamp) {
        require(timestamp <= expirationDate, "Item has been expired.");
        _;
    }

    modifier enoughQuantity(uint256 number) {
        require(number <= quantity.number, "Item number is not enough.");
        _;
    }

    event InitEvent(
        uint256 indexed shid,
        uint256 organizationID,
        uint256 number,
        uint256 packNumber,
        uint256 producedDate,
        uint256 expirationDate,
        string name,
        string organizationName,
        address manufacturer,
        string unit
    );

    constructor(
        uint256 _shid,
        uint256 _organizationID,
        uint256 _number,
        uint256 _packNumber,
        uint256 _producedDate,
        uint256 _expirationDate,
        string memory _name,
        string memory _organizationName,
        string memory _unit
    ) {
        shid = _shid;
        name = _name;
        organizationID = _organizationID;
        organizationName = _organizationName;
        manufacturer = msg.sender;
        quantity.number = _number;
        quantity.maxNumber = _number;
        quantity.unit = _unit;
        quantity.maxPackNumber = _packNumber;
        producedDate = _producedDate;
        expirationDate = _expirationDate;

        emit InitEvent(
            _shid,
            _organizationID,
            _number,
            _packNumber,
            _producedDate,
            _expirationDate,
            _name,
            _organizationName,
            manufacturer,
            _unit
        );
    }

    function getNumber() public view returns (uint256) {
        return quantity.number;
    }

    function getMaxNumber() public view returns (uint256) {
        return quantity.maxNumber;
    }

    function getMaxPackNumber() public view returns (uint256) {
        return quantity.maxPackNumber;
    }

    function getUnit() public view returns (string memory) {
        return quantity.unit;
    }

    function getMetadata(address _procedure)
        public
        view
        returns (uint256, uint256, string memory, string[] memory, string[] memory)
    {
        return (
            metadata[_procedure].startTime,
            metadata[_procedure].endTime,
            metadata[_procedure].name,
            metadata[_procedure].mediaList,
            metadata[_procedure].sensorList
        );
    }

    function decrease(uint256 _number) public enoughQuantity(_number) {
        quantity.number = quantity.number - _number;
    }

    function addSource(address source) public {
        sourceList.push(source);
    }

    function addDest(address source) public {
        sourceList.push(source);
    }

    function addProcedure(
        address[] calldata _sourceList,
        uint256 _startTime,
        uint256 _endTime,
        string memory _name,
        string[] memory _mediaList,
        string[] memory _sensorList
    ) public {
        for (uint256 i = 0; i < _sourceList.length; i++) {
            sourceList.push(_sourceList[i]);
        }
        metadata[msg.sender].startTime = _startTime;
        metadata[msg.sender].endTime = _endTime;
        metadata[msg.sender].name = _name;
        metadata[msg.sender].mediaList = _mediaList;
        metadata[msg.sender].sensorList = _sensorList;
    }
}
