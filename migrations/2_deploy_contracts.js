const MoonlightTest = artifacts.require('./contracts/MoonlightTest.sol')

module.exports = function (deployer) {
  deployer.deploy(MoonlightTest)
}
