// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {SwMileageTokenImpl} from "../src/SwMileageToken.impl.sol";

contract SwMileageFactoryDeployScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        vm.stopBroadcast();
    }
}
