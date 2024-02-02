using SymbolicPriceOracle as priceOracle;

ghost mapping(address => mathint) usageOfPriceOracle {
    init_state axiom forall address asset. usageOfPriceOracle[asset] == 0;
    axiom forall address asset. usageOfPriceOracle[asset] >= 0;
}

hook Sload uint256 p priceOracle.price[KEY address asset] STORAGE {
	usageOfPriceOracle[asset] = usageOfPriceOracle[asset] + 1;
}

rule priceOracelCounter(address asset, method f) {
	env e;
	calldataarg args;
	mathint before = usageOfPriceOracle[asset];
	f(e, args);
	assert usageOfPriceOracle[asset] == before;
}
