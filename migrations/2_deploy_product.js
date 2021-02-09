const Product = artifacts.require("Product");

module.exports = function (deployer) {
  const _productName = '鮮奶烏龍'
  const _productId = 47246
  const _startTime = 1612715765
  const _endTime = 1612725765
  const _number = 1400
  const _unit = '毫升'
  deployer.deploy(Product, _productName, _productId, _startTime, _endTime, _number, _unit);
};
