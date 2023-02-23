// SPDX-License-Identifier: MIT

pragma solidity ^0.8.10 .0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

contract TokenSwap {
    address public owner;

    IUniswapV2Router02 public uniswapRouter;
    address public token1;
    address public token2;
    event Approval(
        address approverAddress,
        uint256 amount,
        address approvalTarget
    );
    event Swap(uint256 amountIn, uint256 amountOut, address[] path, address to);

    constructor() {
        owner = msg.sender;
        uniswapRouter = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        token1 = 0x52bE818A4b3F760Ae95079D9D46697429134fd0f;
        token2 = 0x3C13178F60BFb2eCb7180a312E51BBD6252b8E11;

        // // Approve Uniswap Router to spend token1
        require(
            IERC20(token1).approve(address(uniswapRouter), type(uint256).max),
            "Approve Failed."
        );
        require(
            IERC20(token1).approve(address(this), type(uint256).max),
            "Approve Failed."
        );
    }
      modifier onlyOwner {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }


    function setTokens(address _token1, address _token2) public onlyOwner {
        token1 = _token1;
        token2 = _token2;
    }

    function swapTokens(uint256 amountIn, address to) external  onlyOwner {
        require(
            IERC20(token1).transferFrom(msg.sender, address(this), amountIn),
            "Transfer From Failed"
        );

        address[] memory path = new address[](2);
        path[0] = token1;
        path[1] = token2;

        uint256[] memory amounts = uniswapRouter.getAmountsOut(amountIn, path);

        uint256 amountOutMin = amounts[1];

        uniswapRouter.swapExactTokensForTokens(
            amountIn,
            amountOutMin,
            path,
            to,
            block.timestamp
        );
        emit Swap(amountIn, amountOutMin, path, to);
    }
}
