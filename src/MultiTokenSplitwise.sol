// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract MultiTokenSplitwise is ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct Split {
        address initiator;
        string purpose;
        address tokenAddress; // If tokenAddress is address(0), it means ETH is used
        uint256 totalAmount;
        uint256 numberOfParticipants;
        uint256 amountPerParticipant;
        uint256 deadline;
        uint256 totalContributed;
        mapping(address => uint256) contributions;
        mapping(address => bool) hasContributed;
        bool isActive;
        bool isCancelled;
    }

    mapping(bytes32 => Split) public splits;
    uint256 private _splitIdCounter = 1;

    event SplitCreated(bytes32 indexed splitId, address indexed initiator, string purpose, address tokenAddress, uint256 totalAmount, uint256 amountPerParticipant, uint256 deadline);
    event ContributionMade(bytes32 indexed splitId, address indexed contributor, uint256 amount);
    event SplitClosed(bytes32 indexed splitId);
    event SplitCancelled(bytes32 indexed splitId);
    event FundsReturned(bytes32 indexed splitId, address indexed participant, uint256 amount);

    function createSplit(
        string memory _purpose,
        address _tokenAddress,
        uint256 _totalAmount,
        uint256 _numberOfParticipants,
        uint256 _durationInDays
    ) external returns (bytes32) {
        require(_totalAmount > 0, "Total amount must be greater than 0");
        require(_numberOfParticipants > 1, "Number of participants must be greater than 1");
        require(_tokenAddress == address(0) || _tokenAddress != address(0), "Invalid token address");
        require(_durationInDays > 0, "Duration must be greater than 0");

        bytes32 splitId = keccak256(abi.encodePacked(_splitIdCounter, msg.sender, block.timestamp));
        _splitIdCounter++;
        
        Split storage newSplit = splits[splitId];
        newSplit.initiator = msg.sender;
        newSplit.purpose = _purpose;
        newSplit.tokenAddress = _tokenAddress;
        newSplit.totalAmount = _totalAmount;
        newSplit.numberOfParticipants = _numberOfParticipants;
        newSplit.amountPerParticipant = _totalAmount / _numberOfParticipants;
        newSplit.deadline = block.timestamp + (_durationInDays * 1 days);
        newSplit.isActive = true;
        newSplit.totalContributed = 0;

        emit SplitCreated(splitId, msg.sender, _purpose, _tokenAddress, _totalAmount, newSplit.amountPerParticipant, newSplit.deadline);
        return splitId;
    }

    function contribute(bytes32 _splitId, uint256 _amount) external payable nonReentrant {
        Split storage split = splits[_splitId];
        require(split.isActive, "Split is not active");
        require(!split.isCancelled, "Split has been cancelled");
        require(!split.hasContributed[msg.sender], "Already contributed");
        require(block.timestamp <= split.deadline, "Split deadline has passed");
        require(_amount == split.amountPerParticipant, "Incorrect contribution amount");

        if (split.tokenAddress == address(0)) {
            // ETH contribution
            require(msg.value == _amount, "Incorrect ETH contribution amount");
        } else {
            // ERC20 token contribution
            require(msg.value == 0, "Do not send ETH for ERC20 split");
            IERC20 token = IERC20(split.tokenAddress);
            token.safeTransferFrom(msg.sender, address(this), _amount);
        }

        split.contributions[msg.sender] = _amount;
        split.hasContributed[msg.sender] = true;
        split.totalContributed += _amount;

        emit ContributionMade(_splitId, msg.sender, _amount);

        if (split.totalContributed >= split.totalAmount) {
            closeSplit(_splitId);
        }
    }

    function closeSplit(bytes32 _splitId) internal {
        Split storage split = splits[_splitId];
        require(split.isActive, "Split is not active");
        require(split.totalContributed >= split.totalAmount, "Not all participants have contributed");

        split.isActive = false;
        
        if (split.tokenAddress == address(0)) {
            // ETH transfer
            payable(split.initiator).transfer(split.totalAmount);
        } else {
            // ERC20 token transfer
            IERC20 token = IERC20(split.tokenAddress);
            token.safeTransfer(split.initiator, split.totalAmount);
        }

        emit SplitClosed(_splitId);
    }

    function cancelSplit(bytes32 _splitId) external {
        Split storage split = splits[_splitId];
        require(msg.sender == split.initiator, "Only initiator can cancel the split");
        require(split.isActive, "Split is not active");
        require(!split.isCancelled, "Split is already cancelled");

        split.isActive = false;
        split.isCancelled = true;

        emit SplitCancelled(_splitId);
    }

    function withdrawFunds(bytes32 _splitId) external nonReentrant {
        Split storage split = splits[_splitId];
        require(!split.isActive || split.isCancelled || block.timestamp > split.deadline, "Split is still active");
        require(split.hasContributed[msg.sender], "No contribution to withdraw");

        uint256 amount = split.contributions[msg.sender];
        require(amount > 0, "No funds to withdraw");

        split.contributions[msg.sender] = 0;
        split.totalContributed -= amount;

        if (split.tokenAddress == address(0)) {
            // ETH withdrawal
            payable(msg.sender).transfer(amount);
        } else {
            // ERC20 token withdrawal
            IERC20 token = IERC20(split.tokenAddress);
            token.safeTransfer(msg.sender, amount);
        }

        emit FundsReturned(_splitId, msg.sender, amount);
    }

    function getSplitDetails(bytes32 _splitId) external view returns (
        address initiator,
        string memory purpose,
        address tokenAddress,
        uint256 totalAmount,
        uint256 numberOfParticipants,
        uint256 amountPerParticipant,
        uint256 deadline,
        uint256 totalContributed,
        bool isActive,
        bool isCancelled
    ) {
        Split storage split = splits[_splitId];
        return (
            split.initiator,
            split.purpose,
            split.tokenAddress,
            split.totalAmount,
            split.numberOfParticipants,
            split.amountPerParticipant,
            split.deadline,
            split.totalContributed,
            split.isActive,
            split.isCancelled
        );
    }

    function hasContributed(bytes32 _splitId, address _participant) external view returns (bool) {
        return splits[_splitId].hasContributed[_participant];
    }

    function getAmountPerParticipant(bytes32 _splitId) external view returns (uint256) {
        return splits[_splitId].amountPerParticipant;
    }
}