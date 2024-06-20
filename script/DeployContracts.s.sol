// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Script.sol";
import "../src/GovernanceToken.sol";
import "../src/RewardNFT.sol";
import "../src/DAO.sol";

contract DeployContracts is Script {
    function run() external {
        vm.startBroadcast();

        GovernanceToken governanceToken = new GovernanceToken();
        RewardNFT rewardNFT = new RewardNFT();
        DAO dao = new DAO(IERC20(governanceToken), rewardNFT);

        console.log("GovernanceToken deployed at:", address(governanceToken));
        console.log("RewardNFT deployed at:", address(rewardNFT));
        console.log("DAO deployed at:", address(dao));

        vm.stopBroadcast();
    }
}
