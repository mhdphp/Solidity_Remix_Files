// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

interface ITest{
  
    function balanceOf(address _owner) external view returns (uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function transferFrom(address _from, address _to, uint256 _tokenId) external;
}

contract Test is ITest{

    function calcSignature() public view returns(bytes4){
        return bytes4(
            keccak256('balanceOf(bytes4)')^
            keccak256('ownerOf(bytes4)')^
            keccak256('transferFrom(bytes4)')
        );
    }


    function balanceOf(address _owner) external view override returns (uint256){
        return 5;
    }

    function ownerOf(uint256 _tokenId) external view override returns (address){
        return msg.sender;
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) external override {
        uint x = 10;
    }

}