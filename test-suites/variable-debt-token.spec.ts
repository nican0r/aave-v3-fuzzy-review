import { expect } from 'chai';
import { utils } from 'ethers';
import { impersonateAccountsHardhat } from '../helpers/misc-utils';
import { getVariableDebtToken } from '@aave/deploy-v3/dist/helpers/contract-getters';
import { MAX_UINT_AMOUNT, ZERO_ADDRESS } from '../helpers/constants';
import { ProtocolErrors, RateMode } from '../helpers/types';
import { makeSuite, TestEnv } from './helpers/make-suite';
import { topUpNonPayableWithEther } from './helpers/utils/funds';
import { convertToCurrencyDecimals } from '../helpers/contracts-helpers';
import { HardhatRuntimeEnvironment } from 'hardhat/types';
import { evmRevert, evmSnapshot, increaseTime, waitForTx } from '@aave/deploy-v3';
import './helpers/utils/wadraymath';

declare var hre: HardhatRuntimeEnvironment;

makeSuite('VariableDebtToken', (testEnv: TestEnv) => {
  const { CT_CALLER_MUST_BE_POOL, CT_INVALID_MINT_AMOUNT, CT_INVALID_BURN_AMOUNT } = ProtocolErrors;

  it('Check initialization', async () => {
    const { pool, weth, dai, helpersContract, users } = testEnv;
    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;

    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    expect(await variableDebtContract.UNDERLYING_ASSET_ADDRESS()).to.be.eq(dai.address);
    expect(await variableDebtContract.POOL()).to.be.eq(pool.address);
    expect(await variableDebtContract.getIncentivesController()).to.not.be.eq(ZERO_ADDRESS);

    const scaledUserBalanceAndSupplyUser0Before =
      await variableDebtContract.getScaledUserBalanceAndSupply(users[0].address);
    expect(scaledUserBalanceAndSupplyUser0Before[0]).to.be.eq(0);
    expect(scaledUserBalanceAndSupplyUser0Before[1]).to.be.eq(0);

    // Need to create some debt to do this good
    await dai
      .connect(users[0].signer)
      ['mint(uint256)'](await convertToCurrencyDecimals(dai.address, '1000'));
    await dai.connect(users[0].signer).approve(pool.address, MAX_UINT_AMOUNT);
    await pool
      .connect(users[0].signer)
      .deposit(
        dai.address,
        await convertToCurrencyDecimals(dai.address, '1000'),
        users[0].address,
        0
      );
    await weth.connect(users[1].signer)['mint(uint256)'](utils.parseEther('10'));
    await weth.connect(users[1].signer).approve(pool.address, MAX_UINT_AMOUNT);
    await pool
      .connect(users[1].signer)
      .deposit(weth.address, utils.parseEther('10'), users[1].address, 0);
    await pool
      .connect(users[1].signer)
      .borrow(
        dai.address,
        await convertToCurrencyDecimals(dai.address, '200'),
        RateMode.Variable,
        0,
        users[1].address
      );

    const scaledUserBalanceAndSupplyUser0After =
      await variableDebtContract.getScaledUserBalanceAndSupply(users[0].address);
    expect(scaledUserBalanceAndSupplyUser0After[0]).to.be.eq(0);
    expect(scaledUserBalanceAndSupplyUser0After[1]).to.be.gt(0);

    const scaledUserBalanceAndSupplyUser1After =
      await variableDebtContract.getScaledUserBalanceAndSupply(users[1].address);
    expect(scaledUserBalanceAndSupplyUser1After[1]).to.be.gt(0);
    expect(scaledUserBalanceAndSupplyUser1After[1]).to.be.gt(0);

    expect(scaledUserBalanceAndSupplyUser0After[1]).to.be.eq(
      scaledUserBalanceAndSupplyUser1After[1]
    );
  });

  it('Tries to mint not being the Pool (revert expected)', async () => {
    const { deployer, dai, helpersContract } = testEnv;

    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;

    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract.mint(deployer.address, deployer.address, '1', '1')
    ).to.be.revertedWith(CT_CALLER_MUST_BE_POOL);
  });

  it('Tries to burn not being the Pool (revert expected)', async () => {
    const { deployer, dai, helpersContract } = testEnv;

    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;

    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(variableDebtContract.burn(deployer.address, '1', '1')).to.be.revertedWith(
      CT_CALLER_MUST_BE_POOL
    );
  });

  it('Tries to mint with amountScaled == 0 (revert expected)', async () => {
    const { deployer, pool, dai, helpersContract, users } = testEnv;

    // Impersonate the Pool
    await topUpNonPayableWithEther(deployer.signer, [pool.address], utils.parseEther('1'));
    await impersonateAccountsHardhat([pool.address]);
    const poolSigner = await hre.ethers.getSigner(pool.address);

    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;

    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract
        .connect(poolSigner)
        .mint(users[0].address, users[0].address, 0, utils.parseUnits('1', 27))
    ).to.be.revertedWith(CT_INVALID_MINT_AMOUNT);
  });

  it('Tries to burn with amountScaled == 0 (revert expected)', async () => {
    const { deployer, pool, dai, helpersContract, users } = testEnv;

    // Impersonate the Pool
    await topUpNonPayableWithEther(deployer.signer, [pool.address], utils.parseEther('1'));
    await impersonateAccountsHardhat([pool.address]);
    const poolSigner = await hre.ethers.getSigner(pool.address);

    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;

    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract.connect(poolSigner).burn(users[0].address, 0, utils.parseUnits('1', 27))
    ).to.be.revertedWith(CT_INVALID_BURN_AMOUNT);
  });

  it('Tries to transfer debt tokens (revert expected)', async () => {
    const { users, dai, helpersContract } = testEnv;
    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;
    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract.connect(users[0].signer).transfer(users[1].address, 500)
    ).to.be.revertedWith('TRANSFER_NOT_SUPPORTED');
  });

  it('Tries to approve debt tokens (revert expected)', async () => {
    const { users, dai, helpersContract } = testEnv;
    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;
    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract.connect(users[0].signer).approve(users[1].address, 500)
    ).to.be.revertedWith('APPROVAL_NOT_SUPPORTED');
    await expect(
      variableDebtContract.allowance(users[0].address, users[1].address)
    ).to.be.revertedWith('ALLOWANCE_NOT_SUPPORTED');
  });

  it('Tries to increaseAllowance (revert expected)', async () => {
    const { users, dai, helpersContract } = testEnv;
    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;
    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract.connect(users[0].signer).increaseAllowance(users[1].address, 500)
    ).to.be.revertedWith('ALLOWANCE_NOT_SUPPORTED');
  });

  it('Tries to decreaseAllowance (revert expected)', async () => {
    const { users, dai, helpersContract } = testEnv;
    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;
    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract.connect(users[0].signer).decreaseAllowance(users[1].address, 500)
    ).to.be.revertedWith('ALLOWANCE_NOT_SUPPORTED');
  });

  it('Tries to transferFrom debt tokens (revert expected)', async () => {
    const { users, dai, helpersContract } = testEnv;
    const daiVariableDebtTokenAddress = (
      await helpersContract.getReserveTokensAddresses(dai.address)
    ).variableDebtTokenAddress;
    const variableDebtContract = await getVariableDebtToken(daiVariableDebtTokenAddress);

    await expect(
      variableDebtContract
        .connect(users[0].signer)
        .transferFrom(users[0].address, users[1].address, 500)
    ).to.be.revertedWith('TRANSFER_NOT_SUPPORTED');
  });

  it('Check Mint and Transfer events when borrowing on behalf', async () => {
    const snapId = await evmSnapshot();
    const {
      pool,
      weth,
      dai,
      users: [user1, user2, user3],
    } = testEnv;

    // Add liquidity
    await dai.connect(user3.signer)['mint(uint256)'](utils.parseUnits('1000', 18));
    await dai.connect(user3.signer).approve(pool.address, MAX_UINT_AMOUNT);
    await pool
      .connect(user3.signer)
      .supply(dai.address, utils.parseUnits('1000', 18), user3.address, 0);

    // User1 supplies 10 WETH
    await weth.connect(user1.signer)['mint(uint256)'](utils.parseUnits('10', 18));
    await weth.connect(user1.signer).approve(pool.address, MAX_UINT_AMOUNT);
    await pool
      .connect(user1.signer)
      .supply(weth.address, utils.parseUnits('10', 18), user1.address, 0);

    const daiData = await pool.getReserveData(dai.address);
    const variableDebtToken = await getVariableDebtToken(daiData.variableDebtTokenAddress);
    const beforeDebtBalanceUser2 = await variableDebtToken.balanceOf(user2.address);

    // User1 borrows 100 DAI
    const borrowAmount = utils.parseUnits('100', 18);
    expect(
      await pool
        .connect(user1.signer)
        .borrow(dai.address, borrowAmount, RateMode.Variable, 0, user1.address)
    );

    // User1 approves user2 to borrow 1000 DAI
    expect(
      await variableDebtToken
        .connect(user1.signer)
        .approveDelegation(user2.address, utils.parseUnits('1000', 18))
    );

    // Increase time so interests accrue
    await increaseTime(24 * 3600);

    // User2 borrows 1000 DAI on behalf of user1
    const borrowOnBehalfAmount = utils.parseUnits('100', 18);
    const tx = await waitForTx(
      await pool
        .connect(user2.signer)
        .borrow(dai.address, borrowOnBehalfAmount, RateMode.Variable, 0, user1.address)
    );

    const afterDebtBalanceUser2 = await variableDebtToken.balanceOf(user2.address);
    const afterDebtBalanceUser1 = await variableDebtToken.balanceOf(user1.address);

    // Calculate debt + interests
    const expectedDebtIncreaseUser1 = afterDebtBalanceUser1.sub(
      borrowOnBehalfAmount.add(borrowAmount)
    );

    const transferEventSig = utils.keccak256(
      utils.toUtf8Bytes('Transfer(address,address,uint256)')
    );
    const mintEventSig = utils.keccak256(
      utils.toUtf8Bytes('Mint(address,address,uint256,uint256)')
    );

    const rawTransferEvents = tx.logs.filter(
      ({ topics, address }) =>
        topics[0] === transferEventSig && address == variableDebtToken.address
    );
    const transferAmount = variableDebtToken.interface.parseLog(rawTransferEvents[0]).args.value;

    const rawMintEvents = tx.logs.filter(
      ({ topics, address }) => topics[0] === mintEventSig && address == variableDebtToken.address
    );
    const mintAmount = variableDebtToken.interface.parseLog(rawMintEvents[0]).args.value;

    expect(transferAmount).to.be.eq(mintAmount);
    expect(expectedDebtIncreaseUser1.add(borrowOnBehalfAmount)).to.be.eq(transferAmount);
    expect(expectedDebtIncreaseUser1.add(borrowOnBehalfAmount)).to.be.eq(mintAmount);
    expect(afterDebtBalanceUser2.sub(beforeDebtBalanceUser2)).to.be.lt(transferAmount);

    await evmRevert(snapId);
  });
});
