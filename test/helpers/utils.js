const TYPE_STAKE = 1;
const TYPE_YIELD = 2;
const TYPE_BOTH = 3;

const EXIT_TRUE = true;
const EXIT_FALSE = false;

const toWei = (number) => web3.utils.toWei(number.toString());
const fromWei = (x) => web3.utils.fromWei(x);
const addr0 = "0x0000000000000000000000000000000000000000";
const bytes0 = "0x0000000000000000000000000000000000000000000000000000000000000000";
const ethBalance = (address) => web3.eth.getBalance(address);
const roundBN = (bn, n=2) => {
    const coefficient = 10**n;
    return Math.round(parseFloat(fromWei(bn)) * coefficient) / coefficient;
}

module.exports = {
    toWei,
    fromWei,
    addr0,
    bytes0,
    ethBalance,
    roundBN,

    TYPE_STAKE, TYPE_YIELD, TYPE_BOTH,
    EXIT_TRUE, EXIT_FALSE, 
}