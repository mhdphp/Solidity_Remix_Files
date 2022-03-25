// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;


interface IERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

contract ERC165 is IERC165 {

    /*
    The ERC165 standard actually requires that the supportsInterface function "use less than 30,000 gas".
    So rather re-calculating interfaceIDs every time someone calls supportsInterface, let's keep our
    supported interfaceIDs in a mapping.

    bytes4: Bytes is a dynamic array for bytes. It's shortcut for byte[].

    bytes4 is exactly 4 bytes long.

    You can define a variable using the keyword bytesX, where X  can be from 1 to 32.

    keccak256: keccak256 computes the Keccak-256 hash of the input. 
    Creating an deterministic unique ID from and input.
    */

     // hash table to keep track of contract fingerprint data of byte function conversion
    mapping(bytes4 => bool) private _supportedInterfaces;

    // write a byte calculation interface function algorithm for one and second function (just for test)
    function calcFingerPrint() public pure returns(bytes4){
        return bytes4(keccak256('supportsInterface(bytes4)'));
        // function supports value: 0x01ffc9a7 - for first function
    }

    constructor() {
        _registeringInterface(0x01ffc9a7);
    }

    // function inherited must be marked as override
    function supportsInterface(bytes4 interfaceID) external override view returns (bool) {
        return _supportedInterfaces[interfaceID];
    }

     // registering the interface
    function _registeringInterface(bytes4 interfaceID) public {
        require(interfaceID != 0xffffffff,'ERC165: invalid interfaceId');
        _supportedInterfaces[interfaceID] = true;
    } 

}