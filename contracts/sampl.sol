// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SAMPL is ERC20 {

	using SafeMath for uint256;

	// AMPL address on Rinkeby
	address constant AMPL = 0x027dbcA046ca156De9622cD1e2D907d375e53aa7;

	// AMPL 9 decimals, Wrapped AMPL - 18 by default

	constructor () ERC20("Wrapped AMPL", "SAMPL") {}

	/* @dev $SAMPL has the same number of decimals as $AMPL*/

	function decimals() public view override returns (uint8) {
        return 9;
    }

	/* * 	
	 *  If AMPL pool is empty mint SAMPL 1:1 with AMPL
	 *  If the pool is non-empty use formula for minting: 
     *  S = SAMPL totalSupply
	 *  A = AMPL pool balance
	 *  s = amount of minted SAMPL
	 *  a = amount of deposited AMPL
	 *  s = a * S / A
	*/

	function deposit(uint256 amount) public {

		require(amount > 0, 'Amount should be greater than 0');

		if (isPoolEmpty()) {
			IERC20(AMPL).transferFrom(msg.sender, address(this), amount);
			_mint(msg.sender, amount);
		} 

		else {
			uint supply_sampl = totalSupply();
			uint balance_ampl = pool_balance();
			uint toMint = amount.mul(supply_sampl).div(balance_ampl);
			IERC20(AMPL).transferFrom(msg.sender, address(this), amount);
			_mint(msg.sender, toMint);
		}

	}

	/* * 	 
     *  S = SAMPL totalSupply
	 *  A = AMPL pool balance
	 *  s = amount of minted SAMPL
	 *  a = amount of deposited AMPL
	 *  a = s * A / S
	*/

	function unwrap(uint256 amount_sampl) public {


		uint balance_ampl = pool_balance();
		uint supply_sampl = totalSupply();

		require(supply_sampl > 0, "$SAMPL supply is zero");
		require(balance_ampl > 0, '$AMPL pool balance is zero');

		uint toWithdraw = amount_sampl.mul(balance_ampl).div(supply_sampl);

		require(balanceOf(msg.sender) >= amount_sampl, 'Not enough $SAMPL');

		_burn(msg.sender, amount_sampl);
		
		IERC20(AMPL).transfer(msg.sender, toWithdraw);

	}

	function pool_balance() public view returns(uint256) {
		return IERC20(AMPL).balanceOf(address(this));
	}

	function isPoolEmpty() public view returns(bool isEmpty) {

		isEmpty = IERC20(AMPL).balanceOf(address(this)) == uint256(0) ? true : false;
	}


}
