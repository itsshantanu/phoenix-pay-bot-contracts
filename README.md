# MultiTokenSplitwise

This repository contains Solidity smart contracts for managing multi-token group expenses and split payments among participants. The system supports both ETH and ERC20 tokens, allowing for flexible contributions and automated settlements.

## Contracts

### MultiTokenSplitwise.sol
This contract facilitates the creation and management of expense splits among participants using ETH or ERC20 tokens. Key features:
- **Create Expense Splits**: Initiate a new split specifying the total amount, number of participants, and duration.
- **Multi-Token Support**: Contribute using ETH or any ERC20 token.
- **Cancel or Close Splits**: Cancel an ongoing split or automatically close it once contributions are complete.
- **Withdraw Contributions**: Participants can withdraw their contributions if the split is canceled or the deadline passes.

## Usage

### Deployment
1. Deploy the `MultiTokenSplitwise` contract on the desired blockchain.
2. Configure the contract with the appropriate settings, including token addresses and participants.

### Configuration
- Use the `createSplit` function to initiate a new expense split.
- Participants can contribute using the `contribute` function.
- The initiator can cancel the split using the `cancelSplit` function if needed.

## Functions

### MultiTokenSplitwise
- `createSplit(string memory _purpose, address _tokenAddress, uint256 _totalAmount, uint256 _numberOfParticipants, uint256 _durationInDays)`
- `contribute(bytes32 _splitId) external payable nonReentrant`
- `cancelSplit(bytes32 _splitId) external`
- `withdrawFunds(bytes32 _splitId) external nonReentrant`
- `getSplitDetails(bytes32 _splitId) external view returns (address, string memory, address, uint256, uint256, uint256, uint256, uint256, bool, bool)`
- `hasContributed(bytes32 _splitId, address _participant) external view returns (bool)`
- `getAmountPerParticipant(bytes32 _splitId) external view returns (uint256)`

### Supported Tokens
- **ETH**: Native cryptocurrency for Ethereum and compatible blockchains.
- **ERC20 Tokens**: Any ERC20-compliant token.

## Deployed Contract Addresses

### Base Sepolia

- MultiTokenSplitwise contract address: [0xf6f6E270BD1138eF4881c19eA004652d9ca09473](https://sepolia.basescan.org/address/0xf6f6E270BD1138eF4881c19eA004652d9ca09473)

### OP Sepolia

- MultiTokenSplitwise contract address: [0xf6f6E270BD1138eF4881c19eA004652d9ca09473](https://sepolia-optimism.etherscan.io/address/0xf6f6E270BD1138eF4881c19eA004652d9ca09473)

### Metal L2 Testnet

- MultiTokenSplitwise contract address: [0xD18230c420f78B4Cb71Ba87fdd7129A8E34730D7](https://testnet.explorer.metall2.com/address/0xD18230c420f78B4Cb71Ba87fdd7129A8E34730D7)

### Mode Sepolia

- MultiTokenSplitwise contract address: [0xD18230c420f78B4Cb71Ba87fdd7129A8E34730D7](https://sepolia.explorer.mode.network/address/0xD18230c420f78B4Cb71Ba87fdd7129A8E34730D7)

## License

This project is licensed under the MIT License.
