// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test {
    OurToken public ourToken;
    DeployOurToken public deployer;

    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    uint256 public constant STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        vm.prank(msg.sender);
        ourToken.transfer(bob, STARTING_BALANCE);
    }

    function testInitialSupply() public {
        assertEq(ourToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testBobBalance() public {
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE);
    }

    function testAllowancesWork() public {
        uint256 initialAllowance = 1000;

        //Bob approves alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;
        vm.prank(alice);
        ourToken.transferFrom(bob, alice, transferAmount);

        assertEq(ourToken.balanceOf(alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), STARTING_BALANCE - transferAmount);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    // function testTransfer() public {
    //     uint256 amount = 100;
    //     ourToken.transfer(alice, amount);
    //     assertEq(ourToken.balanceOf(alice), amount);
    // }

    // function testAllowance() public {
    //     uint256 amount = 75;
    //     ourToken.approve(bob, amount);
    //     assertEq(ourToken.allowance(address(this), bob), amount);
    // }

    // function testIncreaseAllowance() public {
    //     uint256 initialAmount = 100;
    //     uint256 increaseAmount = 50;
    //     ourToken.approve(bob, initialAmount);
    //     ourToken.increaseAllowance(bob, increaseAmount);
    //     assertEq(
    //         ourToken.allowance(address(this), bob),
    //         initialAmount + increaseAmount
    //     );
    // }

    // function testDecreaseAllowance() public {
    //     uint256 initialAmount = 100;
    //     uint256 decreaseAmount = 30;
    //     ourToken.approve(bob, initialAmount);
    //     ourToken.decreaseAllowance(bob, decreaseAmount);
    //     assertEq(
    //         ourToken.allowance(address(this), bob),
    //         initialAmount - decreaseAmount
    //     );
    // }

    // function testBurn() public {
    //     uint256 burnAmount = 25;
    //     ourToken.burn(burnAmount);
    //     assertEq(
    //         ourToken.balanceOf(address(this)),
    //         deployer.INITIAL_SUPPLY() - burnAmount
    //     );
    // }

    // function testBurnFrom() public {
    //     uint256 burnAmount = 15;
    //     ourToken.approve(bob, burnAmount);
    //     ourToken.connect(bob).burnFrom(address(this), burnAmount);
    //     assertEq(
    //         ourToken.balanceOf(address(this)),
    //         deployer.INITIAL_SUPPLY() - burnAmount
    //     );
    // }
}
