// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0 <0.9.0;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

/**
 * @title BasicBank
 * @dev Implements basic despoit, withdraw, and ability to fund owner
 */
contract BasicBank {
    using SafeMathChainlink for uint256;

    address private owner;
    uint256 private minDepositUSD;
    mapping(address => uint256) public addressToBalance;
    AggregatorV3Interface private priceFeed;

    /**
     * @dev Set contract deployer as owner
     */
    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
        minDepositUSD = 50;
    }

    /**
     * @dev Change the minimumUSD amount
     * @param _minDepositUSD USD amount to change the minimum to
     */
    function setMinDeposit(uint256 _minDepositUSD) public onlyOwner {
        minDepositUSD = _minDepositUSD;
    }

    /**
     * @dev Get the minimum deposit in USD amount
     * @return Minimum deposit in USD
     */
    function getMinDeposit() public view returns (uint256) {
        return minDepositUSD;
    }

    /**
     * @dev Deposit into account
     */
    function deposit() public payable {
        require(
            getConversionRate(msg.value) >= minDepositUSD,
            "Must deposit above the minimum amount"
        );
        addressToBalance[msg.sender] += msg.value;
    }

    /**
     * @dev Fund the owner
     */
    function fundOwner() public payable {
        addressToBalance[owner] += msg.value;
    }

    /**
     * @dev Get price of ETH in USD with 8 decimals
     * @return address of owner
     */
    function getPrice() public view returns (uint256) {
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return uint256(answer);
    }

    /**
     * @dev Convert ETH in Wei to USD
     * @param ethAmountWei amount of ETH in Wei to convert
     * @return equivalent amount of USD
     */
    function getConversionRate(uint256 ethAmountWei)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = ((ethAmountWei) * (ethPrice)) / 1e26;
        return ethAmountInUsd;
    }

    /**
     * @dev Withdraw a certain amount of Wei
     * @param _amountWei amount of ETH in Wei to withdraw
     */
    function withdraw(uint256 _amountWei) public payable {
        require(
            addressToBalance[msg.sender] - _amountWei >= 0,
            "Insufficient balance"
        );
        addressToBalance[msg.sender] -= _amountWei;
        msg.sender.transfer(_amountWei);
    }

    /**
     * @dev Withdraw all ETH in account
     */
    function withdrawAll() public payable {
        require(addressToBalance[msg.sender] > 0, "Insufficient balance");
        uint256 balance = addressToBalance[msg.sender];
        addressToBalance[msg.sender] = 0;
        msg.sender.transfer(balance);
    }

    /**
     * @dev Return minimum deposit amount
     * @return The minimum deposit amount
     */
    function getEntranceFee() public view returns (uint256) {
        uint256 price = getPrice();
        uint256 precision = 1 * 10**8;
        return (minDepositUSD * 10**18 * precision) / price;
    }

    /**
     * @dev Return owner address
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
}
