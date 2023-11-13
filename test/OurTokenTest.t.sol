// SPDX License-Identifier: MIT

pragma solidity ^0.8.0;

import {Test, console} from "forge-std/Test.sol";
import {DeployOurToken} from "../script/DeployOurToken.s.sol";
import {OurToken} from "../src/OurToken.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract OurTokenTest is Test{
    OurToken public ourToken;
    DeployOurToken public deployer;

    // This fake address to pretend to be a real one
    address bob = makeAddr("bob");
    address Alice = makeAddr("Alice");

    // Creating some balance to give to bob and alice
    uint256 public constant BALANCE_TO_GUEST = 1000 ether;

    function setUp() public {
        deployer = new DeployOurToken();
        ourToken = deployer.run();

        // The Deployer is the owner of the contract
        vm.prank(msg.sender);
        ourToken.transfer(bob, BALANCE_TO_GUEST);
    }
    function testBobBalance() public {
        assertEq( BALANCE_TO_GUEST, ourToken.balanceOf(bob));
    }

    function testAllowance() public {

        uint256 initialAlloowance = 1000 ether;
        uint256 transferAmount = 500 ether;

        // Bob approves Alice to spend tokens on her behalf
        vm.prank(bob);
        ourToken.approve(Alice, initialAlloowance);

        // Here Alice are taking the token from Bob because Bob appoved her
        vm.prank(Alice);
        ourToken.transferFrom(bob, Alice, transferAmount);
        
        assertEq(ourToken.balanceOf(Alice), transferAmount);
        assertEq(ourToken.balanceOf(bob), BALANCE_TO_GUEST - transferAmount );    


    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(ourToken)).mint(address(this), 1);
    }

    function testTransfer() public {
        uint256 amount = 1000 ether;
        uint256 amountToTransfer = 500 ether;
        uint256 balance = ourToken.balanceOf(address(this));

        address sender = address(this);
        address reciver = address(0x456); // Another random address

        ourToken.transfer(reciver , amountToTransfer);
        assertEq(ourToken.balanceOf(reciver), amountToTransfer);
        assertEq(ourToken.balanceOf(sender), amount - amountToTransfer);

       
    }

     function testTransferFrom() public {
        uint256 amount = 1000 ether;
        address recipient = address(0x1);
        vm.prank(msg.sender);
        ourToken.approve(address(this), amount);
        vm.prank(msg.sender);
        ourToken.transferFrom(msg.sender, recipient, amount);
        assertEq(ourToken.balanceOf(recipient), amount);
 }


    
}
