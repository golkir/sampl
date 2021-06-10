const hre = require('hardhat')
const { ethers, upgrades } = require("hardhat");
const BigNumber = require('bignumber.js');
require('dotenv').config()
const SAMPL = process.env.SAMPL
const AMPL = process.env.AMPL
const AMPL_DECIMALS = 9
const SAMPL_DECIMALS = 9
const one_gwei = new BigNumber('1000000000').toString()

async function depositAMPL (amount) {
	amount = new BigNumber(amount).shiftedBy(AMPL_DECIMALS).toFixed()
	let sampl_contract = await ethers.getContractAt('SAMPL', SAMPL)
	
	let deposit = await sampl_contract.deposit(amount,{ gasPrice: one_gwei, gasLimit: 3000000 })

	let deposit_receipt = await deposit.wait()

	// Check SAMPL balance after deposit

	let balance = await sampl_contract.balanceOf(process.env.ACCOUNT)

	console.log(`The user has ${balance} $SAMPL`)

	// Check the size of AMPL pool in contract

	let pool = await sampl_contract.pool_balance()

	console.log(`The contract AMPL pool has ${pool} $AMPL`)

}

// depositAMPL(111)

// Amount of SAMPL to unwrap into AMPL

async function unwrapSAMPL (amount) {
	amount = new BigNumber(amount).shiftedBy(SAMPL_DECIMALS).toFixed()
	let sampl_contract = await ethers.getContractAt('SAMPL', SAMPL)

	// Check user SAMPL balance before unwrap

	let balance_user_before = await sampl_contract.balanceOf(process.env.ACCOUNT)

	// Check pool before unwrap

	let balance_pool_before = await sampl_contract.pool_balance()

	console.log(`$SAMPL balance of user before unwrap: ${balance_user_before}`)

	console.log(`$AMPL balance of pool before unwrap: ${balance_pool_before}`)

	let unwrap = await sampl_contract.unwrap(amount,{ gasPrice: one_gwei, gasLimit: 3000000 })

	let receipt = await unwrap.wait()

	console.log(receipt)

	// Check SAMPL balance after unwrap 

	let balance_user_after = await sampl_contract.balanceOf(process.env.ACCOUNT)
	let balance_pool_after = await sampl_contract.pool_balance()

	console.log(`$SAMPL balance of user after unwrap: ${balance_user_after}`)
	console.log(`$AMPL balance of pool after unwrap: ${balance_pool_after}`)

	
}

// unwrapSAMPL(11)


