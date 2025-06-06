// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Clones} from "openzeppelin-contracts/contracts/proxy/Clones.sol";
import {IAdmin} from "./IAdmin.sol";

interface IStudentManagerImpl is IAdmin {
    function initialize(address _mileageToken, address admin) external;
}

contract StudentManagerFactory {
    using Clones for address;

    address private _implementation;

    event StudentManagerCreated(address indexed contractAddress);

    constructor(
        address impl
    ) {
        _implementation = impl;
    }

    function implementation() external view returns (address) {
        return _implementation;
    }

    function setImplementation(
        address impl
    ) external {
        _implementation = impl;
    }

    function deploy(
        address mileageToken
    ) external returns (address) {
        address clone = _implementation.clone();
        IStudentManagerImpl(clone).initialize(mileageToken, msg.sender);
        emit StudentManagerCreated(clone);
        return address(clone);
    }
}
