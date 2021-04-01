pragma solidity ^0.5.12;
import "./UniswapExchangeInterface.sol";

contract Erc20 {
    function approve(address, uint) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function balanceOf(address) public view returns (uint);
}

contract CErc20 {
    function mint(uint) external returns (uint);
    function redeem(uint redeemTokens) public returns (uint);
}

contract CEth {
    function mint() external payable;
    function redeem(uint redeemTokens) public returns (uint);

}



contract Uniswaping {
    address payable exchange = 0x242E084657F5cdcF745C03684aAeC6E9b0bB85C5;
    address payable tbtcErc20Address = 0x083f652051b9CdBf65735f98d83cc329725Aa957;
    
    function approve(address _spender, uint256 _value) external returns (bool);

    function approveUni() public returns (bool){
        UniswapExchangeInterface uniswap = UniswapExchangeInterface(exchange);
        return uniswap.approve(address(this), 100000000000000000000);
    }
    //add liquidity
    function SwapTbtcToEth() public returns (uint256) {
        Erc20 underlying = Erc20(tbtcErc20Address);
        uint currentTbtcBalance = underlying.balanceOf(address(this));

        UniswapExchangeInterface uniswap = UniswapExchangeInterface(exchange);
        return uniswap.addLiquidity(1, currentTbtcBalance, 1584337723);
    }
    //swap
    function SwapEthtoTbtc() public returns (uint256) {
        Erc20 underlying = Erc20(tbtcErc20Address);
        uint currentTbtcBalance = underlying.balanceOf(address(this));
        underlying.approve(exchange, currentTbtcBalance);

        UniswapExchangeInterface uniswap = UniswapExchangeInterface(exchange);
        //return uniswap.addLiquidity(1, 1584337723).value(balanceOf(address(this)).gas(250000)();
    }
}

contract RobosaverFactory {
    mapping(address => address) public userContractMapping;

    function createContract(address payable owner) public returns (address){
        require(userContractMapping[owner] == address(0x0));
        Robosaver newRobosaver = new Robosaver(owner);
        userContractMapping[owner] = address(newRobosaver);
        return address(newRobosaver);
    }
    
    function returnMappingValue(address _owner) public view returns (address) {
        return userContractMapping[_owner];
    }
}

contract Robosaver {
    //Compound addresses for Ropsten
    address payable ctbtcAddress = 0xB40d042a65Dd413Ae0fd85bECF8D722e16bC46F1;
    address payable tbtcErc20Address = 0x083f652051b9CdBf65735f98d83cc329725Aa957;

    address payable public owner;
    
    constructor (address payable _owner) public payable{
        owner = _owner;
    }
    function supplyEthToCompound() public payable returns (bool) {
        CEth(ctbtcAddress).mint.value(msg.value).gas(250000)();
        return true;
    }
    
    function supplyErc20ToCompound(uint256 _numTokensToSupply) public returns (uint) {
        Erc20 underlying = Erc20(tbtcErc20Address);
        CErc20 cToken = CErc20(ctbtcAddress);
        underlying.approve(ctbtcAddress, _numTokensToSupply);
        uint mintResult = cToken.mint(_numTokensToSupply);
        return mintResult;
    }
  
    function withdrawAllFromCompound() public returns (uint){
        Erc20 underlying = Erc20(ctbtcAddress);
        return CErc20(ctbtcAddress).redeem(underlying.balanceOf(address(this)));
    }
    
    function moveAllTbtcToCompound() public returns (uint) {
        Erc20 underlying = Erc20(tbtcErc20Address);
        CErc20 cToken = CErc20(ctbtcAddress);
        uint currentTbtcBalance = underlying.balanceOf(address(this));
        underlying.approve(ctbtcAddress, currentTbtcBalance);
        uint mintResult = cToken.mint(currentTbtcBalance);
        return mintResult;
    }
    
    function transferOut(address _usersAddress, uint _amount) public payable returns(bool) {
        Erc20 underlying = Erc20(tbtcErc20Address);
        underlying.approve(_usersAddress, _amount);
        return underlying.transfer(_usersAddress, _amount);
    }
    
    function transferAllOut(address _usersAddress) public payable returns(bool) {
        Erc20 underlying = Erc20(tbtcErc20Address);
        underlying.approve(_usersAddress, underlying.balanceOf(address(this)));
        return underlying.transfer(_usersAddress, underlying.balanceOf(address(this)));
    }
  
    function () external payable{}
}