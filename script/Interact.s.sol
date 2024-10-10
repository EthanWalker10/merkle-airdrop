// SPDX-Licence-Indentifier: MIT
pragma solidity ^0.8.24;

import { Script, console } from "forge-std/Script.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";
import { MerkleAirdrop } from "../src/MerkleAirdrop.sol";

contract ClaimAirdrop is Script {
    address private constant CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 private constant AMOUNT_TO_COLLECT = (25 * 1e18); // 25.000000

    bytes32 private constant PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 private constant PROOF_TWO = 0x46f4c7c1c21e8a90c03949beda51d2d02d1ec75b55dd97a999d3edbafa5a1e2f;
    bytes32[] private proof = [PROOF_ONE, PROOF_TWO];

    // the signature will change every time you redeploy the airdrop contract!
    bytes private SIGNATURE =
        hex"fbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c";

    error __ClaimAirdropScript__InvalidSignatureLength();

    function claimAirdrop(address airdrop) public {
        vm.startBroadcast();
        // split the signature into v, r, s
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(SIGNATURE);
        console.log("Claiming Airdrop");
        console.log(airdrop);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, AMOUNT_TO_COLLECT, proof, v, r, s);
        vm.stopBroadcast();
        console.log("Claimed Airdrop");
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert __ClaimAirdropScript__InvalidSignatureLength();
        }
        // assembly 关键字用于在 Solidity 中编写内联汇编代码。
        // EVM 是基于字节码运行的虚拟机，而汇编语言允许开发者更直接地控制 EVM 的操作。在这种情况下，汇编代码被用来处理字节数组 sig 的内存读取。
        assembly {
            // 在汇编代码中，:= 是赋值运算符，用于将右边的表达式的值分配给左边的变量。
            // mload和byte是内联汇编指令, 直接与以太坊虚拟机（EVM）交互的低级操作。在assembly块中使用时，它们会调用EVM指令来操作内存或数据。
            // 在Solidity中，bytes类型的数据在内存中的第一个32字节存储的是长度信息，实际数据从偏移32字节之后开始。
            r := mload(add(sig, 32)) // mload 是 EVM
                // 中的一个指令，用来从内存中加载数据。它接受一个参数，表示从哪个内存位置开始读取32字节（256位）的数据。EVM内存是按32字节为单位操作的，mload 总是读取32字节的数据。
            s := mload(add(sig, 64)) // add 指令用于计算两个数值的和。当你需要在内存中访问不同位置的数据时，可以用 add 来偏移内存地址。
            v := byte(0, mload(add(sig, 96))) // 作用：byte
                // 是一个内联汇编指令，用来提取一个字节（8位）的数据。它用于从一个32字节的值中提取特定的字节。用法：byte(index, value)
        }
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}
