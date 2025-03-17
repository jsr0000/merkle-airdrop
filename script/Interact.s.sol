// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract ClaimAirdrop is Script {
    error ClaimAirdropScript__InvalidSignatureLength();
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 * 1e18;
    bytes32[] PROOF = [PROOF_ONE, PROOF_TWO];
    bytes32 PROOF_ONE =
        0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 PROOF_TWO =
        0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes private SIGNATURE =
        hex"035300347a1eded38af52fe37bf6041ce975b319af66fd8c940bc6cba23018f9016c18d223559f9a974f64ea4ab41b8a7db3ec0bc7b31b278bdd028eb4175c261b";

    function run() public {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "MerkleAirdrop",
            block.chainid
        );
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(
            CLAIMING_ADDRESS,
            CLAIMING_AMOUNT,
            PROOF,
            v,
            r,
            s
        );
        vm.stopBroadcast();
    }

    function splitSignature(
        bytes memory sig
    ) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert ClaimAirdropScript__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
