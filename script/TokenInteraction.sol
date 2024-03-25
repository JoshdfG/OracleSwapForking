// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./IERC20.sol";

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract TokenInteraction {
    address public ETH_ADDRESS;
    address public DAI_ADDRESS;
    address public LINK_ADDRESS;

    constructor(
        address _ETH_ADDRESS,
        address _DAI_ADDRESS,
        address _LINK_ADDRESS
    ) {
        ETH_ADDRESS = _ETH_ADDRESS;
        DAI_ADDRESS = _DAI_ADDRESS;
        LINK_ADDRESS = _LINK_ADDRESS;
    }

    //eth section
    function swapEthToDai(uint _amount) external {
        IERC20(ETH_ADDRESS).transferFrom(msg.sender, address(this), _amount);
        IERC20(DAI_ADDRESS).transfer(msg.sender, _amount);
    }

    function swapDaiToEth(uint _amount) external {
        IERC20(DAI_ADDRESS).transferFrom(msg.sender, address(this), _amount);
        IERC20(ETH_ADDRESS).transfer(msg.sender, _amount);
    }

    function swapLinkToEth(uint _amount) external {
        IERC20(LINK_ADDRESS).transferFrom(msg.sender, (address(this)), _amount);
        IERC20(ETH_ADDRESS).transfer(msg.sender, _amount);
    }

    function swapEthToLink(uint _amount) external {
        IERC20(ETH_ADDRESS).transferFrom(msg.sender, (address(this)), _amount);
        IERC20(LINK_ADDRESS).transfer(msg.sender, _amount);
    }

    ///
    function swapLinkToDai(uint _amount) external {
        IERC20(LINK_ADDRESS).transferFrom(msg.sender, address(this), _amount);
        IERC20(DAI_ADDRESS).transfer(msg.sender, _amount);
    }

    function swapDaiToLink(uint _amount) external {
        IERC20(DAI_ADDRESS).transferFrom(msg.sender, address(this), _amount);
        IERC20(LINK_ADDRESS).transfer(msg.sender, _amount);
    }

    //ChainLink
    function getDerivedPrice(
        address _base,
        address _quote,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));
        (, int256 basePrice, , , ) = AggregatorV3Interface(_base)
            .latestRoundData();
        uint8 baseDecimals = AggregatorV3Interface(_base).decimals();
        basePrice = scalePrice(basePrice, baseDecimals, _decimals);

        (, int256 quotePrice, , , ) = AggregatorV3Interface(_quote)
            .latestRoundData();
        uint8 quoteDecimals = AggregatorV3Interface(_quote).decimals();
        quotePrice = scalePrice(quotePrice, quoteDecimals, _decimals);

        return (basePrice * decimals) / quotePrice;
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }
}
