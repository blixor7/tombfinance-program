// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "./owner/Operator.sol";
import "./interfaces/ITaxable.sol";
import "./interfaces/IUniswapV2Router.sol";
import "./interfaces/IERC20.sol";

/*
  ______                __       _______
 /_  __/___  ____ ___  / /_     / ____(_)___  ____ _____  ________
  / / / __ \/ __ `__ \/ __ \   / /_  / / __ \/ __ `/ __ \/ ___/ _ \
 / / / /_/ / / / / / / /_/ /  / __/ / / / / / /_/ / / / / /__/  __/
/_/  \____/_/ /_/ /_/_.___/  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/

    http://tomb.finance
*/
contract TaxOfficeV2 is Operator {
    address public tomb = address(0x6c021Ae822BEa943b2E66552bDe1D2696a53fbB7);
    address public wftm = address(0x21be370D5312f44cB42ce377BC9b8a0cEF1A4C83);
    address public uniRouter = address(0xF491e7B69E4244ad4002BC14e878a34207E38c29);

    bool TAXFREE_LP_ENABLED = true;
    mapping(address => bool) public taxExclusionEnabled;

    function setTaxTiersTwap(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(tomb).setTaxTiersTwap(_index, _value);
    }

    function setTaxTiersRate(uint8 _index, uint256 _value) public onlyOperator returns (bool) {
        return ITaxable(tomb).setTaxTiersRate(_index, _value);
    }

    function enableAutoCalculateTax() public onlyOperator {
        ITaxable(tomb).enableAutoCalculateTax();
    }

    function disableAutoCalculateTax() public onlyOperator {
        ITaxable(tomb).disableAutoCalculateTax();
    }

    function setTaxRate(uint256 _taxRate) public onlyOperator {
        ITaxable(tomb).setTaxRate(_taxRate);
    }

    function setBurnThreshold(uint256 _burnThreshold) public onlyOperator {
        ITaxable(tomb).setBurnThreshold(_burnThreshold);
    }

    function setTaxCollectorAddress(address _taxCollectorAddress) public onlyOperator {
        ITaxable(tomb).setTaxCollectorAddress(_taxCollectorAddress);
    }

    function excludeAddressFromTax(address _address) external onlyOperator returns (bool) {
        return _excludeAddressFromTax(_address);
    }

    function _excludeAddressFromTax(address _address) private returns (bool) {
        return ITaxable(tomb).excludeAddress(_address);
    }

    function includeAddressInTax(address _address) external onlyOperator returns (bool) {
        return _includeAddressInTax(_address);
    }

    function _includeAddressInTax(address _address) private returns (bool) {
        return ITaxable(tomb).includeAddress(_address);
    }

    function createLPTaxFree(uint256 amtTomb, uint256 amtWFTM) external returns (bool) {
        require(amtTomb != 0 && amtWFTM != 0, "amounts can't be 0");
        if (TAXFREE_LP_ENABLED && taxExclusionEnabled[msg.sender]) {
            _excludeAddressFromTax(msg.sender);
            _excludeAddressFromTax(uniRouter);
            IERC20(tomb).transferFrom(msg.sender, address(this), amtTomb);
            IERC20(wftm).transferFrom(msg.sender, address(this), amtWFTM);
            // mint LP
            uint256 liquidity;
            ( , , liquidity) = IUniswapV2Router(uniRouter).addLiquidity(tomb, wftm, amtTomb, amtWFTM, 0, 0, msg.sender, block.timestamp);
            _includeAddressInTax(msg.sender);
            _includeAddressInTax(uniRouter);
        } else {
            _excludeAddressFromTax(msg.sender);
            IERC20(tomb).transferFrom(msg.sender, address(this), amtTomb);
            IERC20(wftm).transferFrom(msg.sender, address(this), amtWFTM);
            // mint LP
            uint256 liquidity;
            ( , , liquidity) = IUniswapV2Router(uniRouter).addLiquidity(tomb, wftm, amtTomb, amtWFTM, 0, 0, msg.sender, block.timestamp);
            _includeAddressInTax(msg.sender);
        }
    }

    function createLPTaxFreeNative(uint256 amtTomb) external payable returns (bool) {
        require(amtTomb != 0 && msg.value != 0, "amounts can't be 0");
        if (TAXFREE_LP_ENABLED && taxExclusionEnabled[msg.sender]) {
            _excludeAddressFromTax(msg.sender);
            _excludeAddressFromTax(uniRouter);
            IERC20(tomb).transferFrom(msg.sender, address(this), amtTomb);
            // mint LP
            _approveTokenIfNeeded(tomb, uniRouter);
            uint256 liquidity;
            ( , , liquidity) = IUniswapV2Router(uniRouter).addLiquidityETH{ value : msg.value }(tomb, amtTomb, 0, 0, msg.sender, block.timestamp);
            _includeAddressInTax(msg.sender);
            _includeAddressInTax(uniRouter);
        } else {
            _excludeAddressFromTax(msg.sender);
            IERC20(tomb).transferFrom(msg.sender, address(this), amtTomb);
            // mint LP
            _approveTokenIfNeeded(tomb, uniRouter);
            uint256 liquidity;
            ( , , liquidity) = IUniswapV2Router(uniRouter).addLiquidityETH{ value : msg.value }(tomb, amtTomb, 0, 0, msg.sender, block.timestamp);
            _includeAddressInTax(msg.sender);
        }
    }

    function setTaxableTombOracle(address _tombOracle) external onlyOperator {
        ITaxable(tomb).setTombOracle(_tombOracle);
    }

    function transferTaxOffice(address _newTaxOffice) external onlyOperator {
        ITaxable(tomb).setTaxOffice(_newTaxOffice);
    }

    function setTaxFreeLPEnabled(bool enabled) external onlyOperator {
        TAXFREE_LP_ENABLED = enabled;
    }

    function taxFreeTransferFrom(address _sender, address _recipient, uint256 _amt) external {
        require(taxExclusionEnabled[msg.sender], "Address not approved for tax free transfers");
        _excludeAddressFromTax(_sender);
        IERC20(tomb).transferFrom(_sender, _recipient, _amt);
        _includeAddressInTax(_sender);
    }

    function setTaxExclusionForAddress(address _address, bool _excluded) external onlyOperator {
        taxExclusionEnabled[_address] = _excluded;
    }

    function _approveTokenIfNeeded(address _token, address _router) private {
        if (IERC20(_token).allowance(address(this), _router) == 0) {
            IERC20(_token).approve(_router, type(uint256).max);
        }
    }

}