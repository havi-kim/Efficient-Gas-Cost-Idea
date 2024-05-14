// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "src/storage/IStorage.sol";

library StaticStorage {
    bytes32 private constant _STATIC_STORAGE = keccak256("src.repository.StaticStorage.v1");

    function readUint(IStorage _key) internal returns (uint256 value) {
        assembly {
            value := tload(_key)
        }
        if (value != 0) {
            return value;
        }
        if (copyToTransientStorage()) {
            assembly {
                value := tload(_key)
            }
        }
    }

    function readAddress(IStorage _key) internal returns (address value) {
        assembly {
            value := tload(_key)
        }
        if (value != address(0)) {
            return value;
        }
        if (copyToTransientStorage()) {
            assembly {
                value := tload(_key)
            }
        }
    }

    function readBytes32(IStorage _key) internal returns (bytes32 value) {
        assembly {
            value := tload(_key)
        }
        if (value != bytes32(0)) {
            return value;
        }
        if (copyToTransientStorage()) {
            assembly {
                value := tload(_key)
            }
        }
    }

    function writeUint(IStorage _key, uint256 _value) internal {
        writeBytes32(_key, bytes32(_value));
    }

    function writeAddress(IStorage _key, address _value) internal {
        writeBytes32(_key, bytes32(uint256(uint160(_value))));
    }

    function writeBytes32(IStorage _key, bytes32 _value) internal {
        store(_key, _value);
    }

    function copyToTransientStorage() private returns (bool) {
        bytes32 location = _STATIC_STORAGE;
        address storageContract;
        assembly {
            storageContract := tload(location)
        }

        if (storageContract != address(0)) {
            return false;
        }

        assembly {
            storageContract := sload(location)
            tstore(location, storageContract)
        }

        uint256 size;
        assembly {
            size := extcodesize(storageContract)
        }

        bytes memory code = new bytes(size);
        assembly {
            extcodecopy(storageContract, add(code, 0x20), 3, size)
        }

        (bytes32[] memory keys, bytes32[] memory values) = abi.decode(code, (bytes32[], bytes32[]));


        assembly {
            let keysLength := mload(keys)
            let keysPtr := add(keys, 0x20)
            let valuesPtr := add(values, 0x20)
            let end := add(keysPtr, mul(keysLength, 0x20))

            for { } lt(keysPtr, end) {
                keysPtr := add(keysPtr, 0x20)
                valuesPtr := add(valuesPtr, 0x20)
            } {
                let key := mload(keysPtr)
                let value := mload(valuesPtr)
                tstore(key, value)
            }
        }

        return true;
    }

    function store(IStorage _key, bytes32 _value) private {
        address storageContract;
        bytes32[] memory keys;
        bytes32[] memory values;
        bytes memory newCode;
        bool found = false;

        uint256 size;
        bytes32 location = _STATIC_STORAGE;
        assembly {
            storageContract := sload(location)
            size := extcodesize(storageContract)
        }

        if (size > 0) {
            bytes memory code = new bytes(size);
            assembly {
                extcodecopy(storageContract, add(code, 0x20), 3, size)
            }
            (keys, values) = abi.decode(code, (bytes32[], bytes32[]));
        }

        for (uint256 i = 0; i < keys.length; i++) {
            if (keys[i] == IStorage.unwrap(_key)) {
                values[i] = _value;
                found = true;
                break;
            }
        }

        if (!found) {
            keys = copyBytes32Array(keys);
            values = copyBytes32Array(values);

            keys[keys.length - 1] = IStorage.unwrap(_key);
            values[values.length - 1] = _value;
        }

        newCode = createContractCreationCode(abi.encode(keys, values));
        assembly {
            // Create new storage contract
            storageContract := create(0, add(newCode, 0x20), mload(newCode))
            sstore(location, storageContract)

            // Copy the new storage to transient storage
            let keysLength := mload(keys)
            let keysPtr := add(keys, 0x20)
            let valuesPtr := add(values, 0x20)
            let end := add(keysPtr, mul(keysLength, 0x20))

            for { } lt(keysPtr, end) {
                keysPtr := add(keysPtr, 0x20)
                valuesPtr := add(valuesPtr, 0x20)
            } {
                let key := mload(keysPtr)
                let value := mload(valuesPtr)
                tstore(key, value)
            }
        }
    }

    function readStorageContract() private view returns (address storageContract) {
        bytes32 location = _STATIC_STORAGE;
        assembly {
            storageContract := sload(location)
        }
    }

    function createContractCreationCode(bytes memory _code) private pure returns (bytes memory result) {
        unchecked {
            bytes memory prefix;
            uint256 codeLength = _code.length;

            if (codeLength < 512) {
                prefix = hex"608060405234801561000f575f80fd5b506102038061001d5f395ff3fe";
            } else if (codeLength < 1024) {
                prefix = hex"608060405234801561000f575f80fd5b506104038061001d5f395ff3fe";
            } else if (codeLength < 1536) {
                prefix = hex"608060405234801561000f575f80fd5b506106038061001d5f395ff3fe";
            } else if (codeLength < 2048) {
                prefix = hex"608060405234801561000f575f80fd5b506108038061001d5f395ff3fe";
            } else if (codeLength < 2560) {
                prefix = hex"608060405234801561000f575f80fd5b50610a038061001d5f395ff3fe";
            } else if (codeLength < 3072) {
                prefix = hex"608060405234801561000f575f80fd5b50610c038061001d5f395ff3fe";
            } else if (codeLength < 3584) {
                prefix = hex"608060405234801561000f575f80fd5b50610e038061001d5f395ff3fe";
            } else {
                revert("Do not store too much data in static storage");
            }

            assembly {
                let totalLength := add(codeLength, 32)

                // Allocate memory for result
                result := mload(0x40)
                mstore(result, totalLength)
                mstore(0x40, add(add(result, 0x20), totalLength))

                let resultPtr := add(result, 0x20)
                let prefixPtr := add(prefix, 0x20)
                let codePtr := add(_code, 0x20)

                // Copy prefix to result
                mstore(resultPtr, mload(prefixPtr))

                // Copy code to result
                for { let i := 0 } lt(i, codeLength) { i := add(i, 0x20) } {
                    mstore(add(resultPtr, add(i, 32)), mload(add(codePtr, i)))
                }

                // Update free-memory pointer
                mstore(0x40, add(resultPtr, add(totalLength, 0x20)))
            }
            return result;
        }
    }

    function copyBytes32Array(bytes32[] memory source) internal pure returns (bytes32[] memory) {
        bytes32[] memory destination = new bytes32[](source.length + 1);
        assembly {
            let length := mload(source)
            let src := add(source, 0x20)
            let dest := add(destination, 0x20)
            for { let end := add(src, mul(length, 0x20)) } lt(src, end) {
                src := add(src, 0x20)
                dest := add(dest, 0x20)
            } { mstore(dest, mload(src)) }
        }
        return destination;
    }
}
