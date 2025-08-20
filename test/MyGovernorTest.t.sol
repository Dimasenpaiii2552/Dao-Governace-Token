//SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MyGovernor} from "../src/MyGovernor.sol";
import {Box} from "../src/Box.sol";
import {GovToken} from "../src/GovToken.sol";
import {TimeLock} from "../src/TimeLock.sol";

contract MyGovernorTest is Test {

    MyGovernor governor;
    Box box;
    GovToken govToken;
    TimeLock timelock;

    address public USER = makeAddr("USER");
    uint256 public INITIAL_SUPPLY = 100 ether;

    uint256 public constant MIN_DELAY = 3600;
    uint256 public constant VOTING_DELAY = 1;
    uint256 public constant VOTING_PERIOD = 50400;

    address[] proposers;
    address[] executors;
    uint256[] values;
    bytes[] calldatas;
    address[] targets;


    function setUp() external {
        govToken = new GovToken();
        govToken.mint(USER, INITIAL_SUPPLY);

        vm.startPrank(USER);
        govToken.delegate(USER);
        timelock = new TimeLock(MIN_DELAY, proposers, executors);
        governor = new MyGovernor(govToken, timelock);

        bytes32 proposalRole = timelock.PROPOSER_ROLE();
        bytes32 executorRole = timelock.EXECUTOR_ROLE();
        bytes32 adminRole = timelock.DEFAULT_ADMIN_ROLE();

        timelock.grantRole(proposalRole, address(governor));
        timelock.grantRole(executorRole, address(0));
        timelock.revokeRole(adminRole, USER);
        vm.stopPrank();

        box = new Box();
        box.transferOwnership(address(timelock));

    }

    function testCantUpdateBoxWithoutGovernace() public {
        vm.expectRevert();
        box.storeNumber(10);
    }

    function testGovernaceUpdatesBox() public {
        uint256 valueToStore = 888;

        string memory description = "store 1 in Box";
        bytes memory encodeFunctionCall = abi.encodeWithSignature(
            "storeNumber(uint256)", valueToStore);
        values.push(0);
        calldatas.push(encodeFunctionCall);
        targets.push(address(box));

        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        vm.warp(block.timestamp + VOTING_DELAY+ 1);
        vm.roll(block.number + VOTING_DELAY + 1);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        string memory reason = "Itachi Uchiha is Awesome";

        uint8 voteWay = 1;

        vm.prank(USER);
        governor.castVoteWithReason(proposalId, voteWay, reason);
    
        vm.warp(block.timestamp + VOTING_PERIOD+ 1);
        vm.roll(block.number + VOTING_PERIOD + 1);

        console.log("Proposal State:", uint256(governor.state(proposalId)));

        
        bytes32 descriptionHash = keccak256(abi.encodePacked(description));
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.warp(block.number + MIN_DELAY + 1);
        vm.roll(block.timestamp + MIN_DELAY+ 1);

        governor.execute(targets, values, calldatas, descriptionHash);

        console.log("Box value", box.getNumber());
        assert(box.getNumber() == valueToStore);
        
        
    }









}