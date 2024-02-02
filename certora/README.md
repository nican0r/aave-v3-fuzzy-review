# Certora

Assuming you have already [installed](https://docs.certora.com/en/latest/docs/user-guide/getting-started/install.html) the Prover, to run it against the `priceOracleCounter.spec` file to see the vulnerability highlighted in the [Certora report](https://github.com/aave/aave-v3-core/blob/master/certora/Aave_V3_Formal_Verification_Report_Jan2022.pdf) as 
    - H2: Confusion of Asset and EMode price feed for liquidations  
use the following command from the aave-v3-core directory: `certoraRun certoraRun certora/confs/priceOracleCounter.conf`
