/** SPDX-License-Identifier: MIT*/
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SikkerMaths {
    using SafeMath for uint256;
    using SafeMath for uint32;

    function percentage(uint32 _multiplier, uint256 _amount, uint32 _divider) internal pure returns(uint256) {
        require(_divider > 0, "percentage: _divider can not be null.");
        require(_amount >= _divider.mul(10), "percentage: _amount should be >= 10 times _divider.");

        _multiplier = _multiplier == 0 ? 1 : _multiplier;
        return _multiplier.mul(_amount).div(_divider);
    }
}
