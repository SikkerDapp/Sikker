/** SPDX-License-Identifier: MIT*/
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SikkerMaths {
    using SafeMath for uint256;
    using SafeMath for uint32;

    function percentage(uint32 _multiplier, uint256 _amount, uint32 _divider) internal pure returns(uint256) {
        require(_multiplier > 0 && _amount > 100000 && _divider > 0, "SikkerMath/Percentage: one of the arguments is null");

        return _multiplier.mul(_amount).div(_divider);
    }
}
