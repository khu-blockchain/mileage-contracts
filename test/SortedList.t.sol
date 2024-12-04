// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {SortedList} from "../src/SortedList.sol";
import {MockSortedList} from "./MockSortedList.sol";
import {BubbleSort} from "./utils/BubbleSort.sol";

contract SortedListTest is BubbleSort, Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    MockSortedList mockSortedList;

    function setUp() public {
        mockSortedList = new MockSortedList();
    }

    function test_addElement() public {
        mockSortedList.addElement(address(0x1234), 0x1000);
    }

    // function testFail_DuplicateNode() public {
    //     mockSortedList.addElement(address(0xAAAA), 0x1);
    //     mockSortedList.addElement(address(0xAAAA), 0x1);
    // }

    function test_getAllElement() public {
        for (uint256 i = 0; i < 128; i++) {
            mockSortedList.addElement(address(uint160(127 - i)), i);
        }
        SortedList.DataPair[] memory result = mockSortedList.getAllElement();
        for (uint256 i = 0; i < 128; i++) {
            assertEq(result[i].addr, address(uint160(i)));
            assertEq(result[i].value, 127 - i);
        }
    }

    function test_getAllElement_Stablity() public {
        address[] memory addr = new address[](7);
        uint256[] memory value = new uint256[](7);
        addr[0] = address(0x1);
        value[0] = 10;
        addr[1] = address(0x2);
        value[1] = 5;
        addr[2] = address(0x3);
        value[2] = 10;
        addr[3] = address(0x4);
        value[3] = 1;
        addr[4] = address(0x5);
        value[4] = 7;
        addr[5] = address(0x6);
        value[5] = 7;
        addr[6] = address(0x7);
        value[6] = 11;

        // addr = [1, 2, 3, 4, 5, 6, 7]
        // value = [10, 5, 10, 1, 7, 7, 11]

        mockSortedList.addElement(addr[0], value[0]);
        mockSortedList.addElement(addr[1], value[1]);
        mockSortedList.addElement(addr[2], value[2]);
        mockSortedList.addElement(addr[3], value[3]);
        mockSortedList.addElement(addr[4], value[4]);
        mockSortedList.addElement(addr[5], value[5]);
        mockSortedList.addElement(addr[6], value[6]);

        SortedList.DataPair[] memory result = mockSortedList.getAllElement();

        // expected address list = [7, 1, 3, 5, 6, 2, 4]

        assertEq(result[0].addr, address(0x7));
        assertEq(result[1].addr, address(0x1));
        assertEq(result[2].addr, address(0x3));
        assertEq(result[3].addr, address(0x5));
        assertEq(result[4].addr, address(0x6));
        assertEq(result[5].addr, address(0x2));
        assertEq(result[6].addr, address(0x4));
    }

    // function test_getElementRange_0w()

    function test_getElementRange1() public {
        address[] memory addr = new address[](7);
        uint256[] memory value = new uint256[](7);
        addr[0] = address(0x1);
        value[0] = 10;
        addr[1] = address(0x2);
        value[1] = 5;
        addr[2] = address(0x3);
        value[2] = 10;
        addr[3] = address(0x4);
        value[3] = 1;
        addr[4] = address(0x5);
        value[4] = 7;
        addr[5] = address(0x6);
        value[5] = 7;
        addr[6] = address(0x7);
        value[6] = 11;

        // addr = [1, 2, 3, 4, 5, 6, 7]
        // value = [10, 5, 10, 1, 7, 7, 11]

        mockSortedList.addElement(addr[0], value[0]);
        mockSortedList.addElement(addr[1], value[1]);
        mockSortedList.addElement(addr[2], value[2]);
        mockSortedList.addElement(addr[3], value[3]);
        mockSortedList.addElement(addr[4], value[4]);
        mockSortedList.addElement(addr[5], value[5]);
        mockSortedList.addElement(addr[6], value[6]);

        // SortedList.DataPair[] memory result = bytes32ToDataPair(mockSortedList.getElementRange(1, 1));
        SortedList.DataPair[] memory result = abi.decode(mockSortedList.getElementRange(1, 1), (SortedList.DataPair[]));
        assertEq(result.length, 1);
        assertEq(result[0].addr, addr[6]);

        result = abi.decode(mockSortedList.getElementRange(7, 7), (SortedList.DataPair[]));
        assertEq(result.length, 1);
        assertEq(result[0].addr, addr[3]);

        result = abi.decode(mockSortedList.getElementRange(3, 100), (SortedList.DataPair[]));
        assertEq(result.length, 5);
        assertEq(result[0].addr, addr[2]);

        result = abi.decode(mockSortedList.getElementRange(3, 6), (SortedList.DataPair[]));
        assertEq(result.length, 4);
        assertEq(result[0].addr, addr[2]);

        vm.expectRevert();
        mockSortedList.getElementRange(0, 100);

        vm.expectRevert();
        mockSortedList.getElementRange(3, 2);
    }

    function compare(
        address[7] memory expected
    ) private view {
        SortedList.DataPair[] memory result = mockSortedList.getAllElement();
        for (uint256 i = 0; i < 7; i++) {
            assertEq(result[i].addr, expected[i]);
        }
    }

    function test_updateElement() public {
        uint256 n = 7;
        address[] memory addr = new address[](n);
        uint256[] memory value = new uint256[](n);

        addr[0] = address(0x1);
        value[0] = 10;
        addr[1] = address(0x2);
        value[1] = 5;
        addr[2] = address(0x3);
        value[2] = 10;
        addr[3] = address(0x4);
        value[3] = 1;
        addr[4] = address(0x5);
        value[4] = 7;
        addr[5] = address(0x6);
        value[5] = 7;
        addr[6] = address(0x7);
        value[6] = 11;

        // addr = [1, 2, 3, 4, 5, 6, 7]
        // value = [10, 5, 10, 1, 7, 7, 11]
        // expected address list = [7, 1, 3, 5, 6, 2, 4]

        mockSortedList.addElement(addr[0], value[0]);
        mockSortedList.addElement(addr[1], value[1]);
        mockSortedList.addElement(addr[2], value[2]);
        mockSortedList.addElement(addr[3], value[3]);
        mockSortedList.addElement(addr[4], value[4]);
        mockSortedList.addElement(addr[5], value[5]);
        mockSortedList.addElement(addr[6], value[6]);

        require(mockSortedList.getListLength() == 7, "!=7");

        compare([addr[6], addr[0], addr[2], addr[4], addr[5], addr[1], addr[3]]);

        mockSortedList.updateElement(addr[6], 0); // 1 -> 7
        compare([addr[0], addr[2], addr[4], addr[5], addr[1], addr[3], addr[6]]);

        mockSortedList.updateElement(addr[5], 6); // not move
        compare([addr[0], addr[2], addr[4], addr[5], addr[1], addr[3], addr[6]]);

        //////// error

        mockSortedList.updateElement(addr[5], 5); // 4 -> 5
        compare([addr[0], addr[2], addr[4], addr[1], addr[5], addr[3], addr[6]]);

        mockSortedList.updateElement(addr[2], 11); // 2 -> 1
        compare([addr[2], addr[0], addr[4], addr[1], addr[5], addr[3], addr[6]]);
        // compare(expected);
    }

    function test_updateElement_SameValue() public {
        address x = makeAddr("x");
        address y = makeAddr("y");
        address z = makeAddr("z");
        address w = makeAddr("w");

        mockSortedList.push(x, 10);
        mockSortedList.push(y, 10);
        mockSortedList.push(z, 10);
        mockSortedList.push(w, 10);

        SortedList.DataPair[] memory d = mockSortedList.getAllElement();

        assertEq(d.length, 4);

        assertEq(d[0].addr, w);
        assertEq(d[1].addr, z);
        assertEq(d[2].addr, y);
        assertEq(d[3].addr, x);

        mockSortedList.updateElement(z, 10);

        SortedList.DataPair[] memory d2 = mockSortedList.getAllElement();

        assertEq(d2.length, 4);

        assertEq(d2[0].addr, w);
        assertEq(d2[1].addr, y);
        assertEq(d2[2].addr, x);
        assertEq(d2[3].addr, z);
    }

    function test_updateElement_SmallN_one() public {
        address x = makeAddr("x");
        address y = makeAddr("y");

        mockSortedList.push(x, 10);
        mockSortedList.updateElement(y, 5);

        SortedList.DataPair[] memory d = mockSortedList.getAllElement();

        assertEq(d.length, 2);

        assertEq(d[0].addr, x);
        assertEq(d[0].value, 10);
        assertEq(d[1].addr, y);
        assertEq(d[1].value, 5);
    }

    function test_updateElement_SmallN_two() public {
        address x = makeAddr("x");
        address y = makeAddr("y");

        mockSortedList.push(x, 10);
        mockSortedList.updateElement(y, 5);

        SortedList.DataPair[] memory d = mockSortedList.getAllElement();

        assertEq(d.length, 2);

        assertEq(d[0].addr, x);
        assertEq(d[0].value, 10);
        assertEq(d[1].addr, y);
        assertEq(d[1].value, 5);
    }

    function test_removeElement_SmallN() public {
        address x = makeAddr("x");
        address y = makeAddr("y");

        mockSortedList.push(x, 10);
        mockSortedList.updateElement(y, 5);

        SortedList.DataPair[] memory d = mockSortedList.getAllElement();

        assertEq(mockSortedList.getListLength(), 2);
        assertEq(d.length, 2);

        assertEq(d[0].addr, x);
        assertEq(d[0].value, 10);
        assertEq(d[1].addr, y);
        assertEq(d[1].value, 5);

        mockSortedList.removeElement(y);

        SortedList.DataPair[] memory d2 = mockSortedList.getAllElement();

        assertEq(mockSortedList.getListLength(), 1);
        assertEq(d2.length, 1);

        assertEq(d2[0].addr, x);
        assertEq(d2[0].value, 10);

        mockSortedList.removeElement(x);

        SortedList.DataPair[] memory d3 = mockSortedList.getAllElement();

        assertEq(mockSortedList.getListLength(), 0);
        assertEq(d3.length, 0);

        mockSortedList.updateElement(y, 16);
        SortedList.DataPair[] memory d4 = mockSortedList.getAllElement();
        assertEq(mockSortedList.getListLength(), 1);
        assertEq(d4.length, 1);
        assertEq(d4[0].addr, y);
        assertEq(d4[0].value, 16);

        mockSortedList.updateElement(x, 10);
        SortedList.DataPair[] memory d5 = mockSortedList.getAllElement();
        assertEq(mockSortedList.getListLength(), 2);
        assertEq(d5.length, 2);
        assertEq(d5[0].addr, y);
        assertEq(d5[0].value, 16);
        assertEq(d5[0].addr, y);
        assertEq(d5[0].value, 16);
    }

    function test_removeElement_SmallN_two() public {
        address x = makeAddr("x");
        address y = makeAddr("y");
        address z = makeAddr("z");
        mockSortedList.updateElement(x, 1);
        mockSortedList.updateElement(y, 2);
        mockSortedList.updateElement(z, 3);

        SortedList.DataPair[] memory d1 = mockSortedList.getAllElement();
        assertEq(mockSortedList.getListLength(), 3);
        assertEq(d1.length, 3);
        assertEq(d1[0].addr, z);
        assertEq(d1[0].value, 3);
        assertEq(d1[1].addr, y);
        assertEq(d1[1].value, 2);
        assertEq(d1[2].addr, x);
        assertEq(d1[2].value, 1);

        mockSortedList.removeElement(y);

        SortedList.DataPair[] memory d2 = mockSortedList.getAllElement();
        assertEq(mockSortedList.getListLength(), 2);
        assertEq(d2.length, 2);
        assertEq(d2[0].addr, z);
        assertEq(d2[0].value, 3);
        assertEq(d2[1].addr, x);
        assertEq(d2[1].value, 1);
    }

    function testFuzz_getAllElemnt(
        uint256[] memory values
    ) public {
        vm.assume(0 < values.length && values.length <= 100);
        address[] memory addr = new address[](values.length);
        for (uint256 i = 0; i < values.length; i++) {
            addr[i] = address(uint160(i + 0x10000000));
            values[i] = bound(values[i], 0, 100);
            mockSortedList.addElement(addr[i], values[i]);
        }

        addDataArray(addr, values);

        address[] memory sorted = sort();

        SortedList.DataPair[] memory result = mockSortedList.getAllElement();

        for (uint256 i = 0; i < addr.length; i++) {
            assertEq(result[i].addr, sorted[i]);
        }
    }
}
