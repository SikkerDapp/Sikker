/** SPDX-License-Identifier: MIT*/

pragma solidity >=0.7.0 <0.9.0;

import "./SafeMath.sol";
import "../Sikker.sol";

contract SikkerMaths is Sikker{
    using SafeMath for uint256;
    using SafeMath for uint32;

    function Percentage(uint32 _multiplier, uint256 _amount, uint32 _divider) internal pure returns(uint256) {
        require(_multiplier > 0 && _amount > 100000 && _divider > 0, "SikkerMath/Percentage: one of the arguments is null");

        uint256 nb;

        nb = (_multiplier.mul(_amount)).div(_divider);
        return(nb);
    }

    function OneUp(uint256 _nb) internal pure returns(uint256) {
        return(_nb.add(1));
    }

    function OneDown(uint256 _nb) internal pure returns(uint256) {
        return(_nb.sub(1));
    }

}
