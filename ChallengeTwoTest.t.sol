// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ChallengeTwo.sol";

contract ChallengeTwoTest is Test {
    ChallengeTwo public challengeTwo;
    Exploit public exploit;

    address user = address(0x123);

    function setUp() public {
        // Deploy the contracts
        challengeTwo = new ChallengeTwo();
        exploit = new Exploit();

        // Label the addresses for better debugging
        vm.label(user, "User");
        vm.label(address(challengeTwo), "ChallengeTwo");
        vm.label(address(exploit), "Exploit");
    }

    function testPassKey() public {
        // Test passing the correct key
        vm.prank(user);
        exploit.passkey(address(challengeTwo));

    }

    function testGetEnoughPoints() public {
        // Pass the key first
        vm.prank(user);
        exploit.passkey(address(challengeTwo));

        // Accumulate points
        vm.prank(user);
        exploit.point(address(challengeTwo));

        // Check if the user's point increased and Name is correctly set
        assertEq(challengeTwo.userPoint(user), 1);
        assertEq(challengeTwo.Names(user), "Pelz");

        // Revert the point accumulation because points != 4
        vm.expectRevert("invalid point Accumulated");
        vm.prank(user);
        challengeTwo.getENoughPoint("Pelz");
    }

    function testAddYourName() public {
        // Complete the first two steps: Pass key and accumulate enough points
        vm.prank(user);
        exploit.passkey(address(challengeTwo));
        for (uint i = 0; i < 4; i++) {
            vm.prank(user);
            exploit.point(address(challengeTwo));
        }

        // Add the name
        vm.prank(user);
        exploit.add(address(challengeTwo));

        // Check that the user is added to champions
        assertEq(challengeTwo.hasCompleted(user), true);
    }

    function testGetAllWinners() public {
        // Complete the challenge and add user to champions
        vm.prank(user);
        exploit.passkey(address(challengeTwo));

        for (uint i = 0; i < 4; i++) {
            vm.prank(user);
            exploit.point(address(challengeTwo));
        }

        vm.prank(user);
        exploit.add(address(challengeTwo));

        // Retrieve all winners
        string[] memory winners = challengeTwo.getAllwiners();
        assertEq(winners[0], "Pelz");
    }

    function testExploit() public {
        // Test the fallback exploit
        vm.deal(user, 1 ether);

        // Simulate multiple fallback invocations
        for (uint i = 0; i < 4; i++) {
            vm.prank(user);
            (bool success, ) = address(challengeTwo).call{value: 1 ether}("");
            require(success, "Fallback failed");
        }
        assertEq(challengeTwo.userPoint(user), 4);

        // Ensure the user can complete the challenge
        vm.prank(user);
        exploit.add(address(challengeTwo));

        assertEq(challengeTwo.hasCompleted(user), true);
    }
}
