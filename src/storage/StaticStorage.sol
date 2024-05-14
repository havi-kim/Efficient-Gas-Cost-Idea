// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./IStorage.sol";
import "./InternalStorage.sol";

library StaticStorage {
    bytes32 private constant _STATIC_STORAGE = keccak256("src.repository.StaticStorage.v1");

    function readUint(IStorage _key) internal returns (uint256 value) {
        beforeRead();
        assembly {
            value := tload(_key)
        }
    }

    function readAddress(IStorage _key) internal returns (address value) {
        beforeRead();
        assembly {
            value := tload(_key)
        }
    }

    function readBytes32(IStorage _key) internal returns (bytes32 value) {
        beforeRead();
        assembly {
            value := tload(_key)
        }
    }

    function writeUint(IStorage _key, uint256 _value) internal {
        writeBytes32(_key, bytes32(_value));
    }

    function writeAddress(IStorage _key, address _value) internal {
        writeBytes32(_key, bytes32(uint256(uint160(_value))));
    }

    function writeBytes32(IStorage _key, bytes32 _value) internal {
        address staticStorageContract = beforeRead();

        bytes32[] memory keys;
        bytes32[] memory values;
        if (staticStorageContract == address(0)) {
            keys = new bytes32[](0);
            values = new bytes32[](0);
        } else {
            (keys, values) = IStaticStorageContract(staticStorageContract).getKeyAndValues();
        }

        assembly {
            tstore(_key, _value)
        }

        for (uint256 i = 0; i < keys.length; i++) {
            if (keys[i] == IStorage.unwrap(_key)) {
                values[i] = _value;
                address newStaticStorageContract = address(new StaticStorageContract(keys, values));
                bytes32 key = _STATIC_STORAGE;
                assembly {
                    sstore(key, newStaticStorageContract)
                    tstore(key, newStaticStorageContract)
                }
                return;
            }
        }

        bytes32[] memory keys_ = new bytes32[](keys.length + 1);
        bytes32[] memory values_ = new bytes32[](values.length + 1);
        for (uint256 i = 0; i < keys.length; i++) {
            keys_[i] = keys[i];
            values_[i] = values[i];
        }
        keys_[keys.length] = IStorage.unwrap(_key);
        values_[values.length] = _value;

        address newStaticStorageContract = address(new StaticStorageContract(keys_, values_));
        bytes32 key = _STATIC_STORAGE;
        assembly {
            sstore(key, newStaticStorageContract)
            tstore(key, newStaticStorageContract)
        }
    }

    function beforeRead() private returns (address staticStorageContract) {
        bytes32 location = _STATIC_STORAGE;
        bool firstAccess;

        assembly {
            staticStorageContract := tload(location)
            if iszero(staticStorageContract) {
                staticStorageContract := sload(location)
                tstore(location, staticStorageContract)
                firstAccess := 1
            }
        }

        if (!firstAccess || staticStorageContract == address(0)) {
            return staticStorageContract;
        }

        (bytes32[] memory keys, bytes32[] memory values) =
            IStaticStorageContract(staticStorageContract).getKeyAndValues();
        for (uint256 i = 0; i < keys.length; i++) {
            bytes32 key = keys[i];
            bytes32 value = values[i];
            assembly {
                tstore(key, value)
            }
        }
    }
}

interface IStaticStorageContract {
    function getKeyAndValues() external view returns (bytes32[] memory keys, bytes32[] memory values);
}

contract StaticStorageContract {
    uint8 private immutable _count;

    bytes32 private immutable _key0;
    bytes32 private immutable _key1;
    bytes32 private immutable _key2;
    bytes32 private immutable _key3;
    bytes32 private immutable _key4;
    bytes32 private immutable _key5;
    bytes32 private immutable _key6;
    bytes32 private immutable _key7;
    bytes32 private immutable _key8;
    bytes32 private immutable _key9;
    bytes32 private immutable _key10;
    bytes32 private immutable _key11;
    bytes32 private immutable _key12;
    bytes32 private immutable _key13;
    bytes32 private immutable _key14;
    bytes32 private immutable _key15;

    bytes32 private immutable _value0;
    bytes32 private immutable _value1;
    bytes32 private immutable _value2;
    bytes32 private immutable _value3;
    bytes32 private immutable _value4;
    bytes32 private immutable _value5;
    bytes32 private immutable _value6;
    bytes32 private immutable _value7;
    bytes32 private immutable _value8;
    bytes32 private immutable _value9;
    bytes32 private immutable _value10;
    bytes32 private immutable _value11;
    bytes32 private immutable _value12;
    bytes32 private immutable _value13;
    bytes32 private immutable _value14;
    bytes32 private immutable _value15;

    constructor(bytes32[] memory keys_, bytes32[] memory values_) {
        require(keys_.length == values_.length, "StaticStorageContract: Invalid length");
        require(keys_.length <= 16, "StaticStorageContract: Too many keys");

        _count = uint8(keys_.length);

        if (_count == 0) {
            return;
        }

        _key0 = keys_[0];
        _value0 = values_[0];
        if (_count == 1) {
            return;
        }

        _key1 = keys_[1];
        _value1 = values_[1];
        if (_count == 2) {
            return;
        }

        _key2 = keys_[2];
        _value2 = values_[2];
        if (_count == 3) {
            return;
        }

        _key3 = keys_[3];
        _value3 = values_[3];
        if (_count == 4) {
            return;
        }

        _key4 = keys_[4];
        _value4 = values_[4];
        if (_count == 5) {
            return;
        }

        _key5 = keys_[5];
        _value5 = values_[5];
        if (_count == 6) {
            return;
        }

        _key6 = keys_[6];
        _value6 = values_[6];
        if (_count == 7) {
            return;
        }

        _key7 = keys_[7];
        _value7 = values_[7];
        if (_count == 8) {
            return;
        }

        _key8 = keys_[8];
        _value8 = values_[8];
        if (_count == 9) {
            return;
        }

        _key9 = keys_[9];
        _value9 = values_[9];
        if (_count == 10) {
            return;
        }

        _key10 = keys_[10];
        _value10 = values_[10];
        if (_count == 11) {
            return;
        }

        _key11 = keys_[11];
        _value11 = values_[11];
        if (_count == 12) {
            return;
        }

        _key12 = keys_[12];
        _value12 = values_[12];
        if (_count == 13) {
            return;
        }

        _key13 = keys_[13];
        _value13 = values_[13];
        if (_count == 14) {
            return;
        }

        _key14 = keys_[14];
        _value14 = values_[14];
        if (_count == 15) {
            return;
        }

        _key15 = keys_[15];
        _value15 = values_[15];
    }

    function getKeyAndValues() external view returns (bytes32[] memory keys, bytes32[] memory values) {
        keys = new bytes32[](_count);
        values = new bytes32[](_count);

        if (_count == 0) {
            return (keys, values);
        }

        keys[0] = _key0;
        values[0] = _value0;
        if (_count == 1) {
            return (keys, values);
        }

        keys[1] = _key1;
        values[1] = _value1;
        if (_count == 2) {
            return (keys, values);
        }

        keys[2] = _key2;
        values[2] = _value2;
        if (_count == 3) {
            return (keys, values);
        }

        keys[3] = _key3;
        values[3] = _value3;
        if (_count == 4) {
            return (keys, values);
        }

        keys[4] = _key4;
        values[4] = _value4;
        if (_count == 5) {
            return (keys, values);
        }

        keys[5] = _key5;
        values[5] = _value5;
        if (_count == 6) {
            return (keys, values);
        }

        keys[6] = _key6;
        values[6] = _value6;
        if (_count == 7) {
            return (keys, values);
        }

        keys[7] = _key7;
        values[7] = _value7;
        if (_count == 8) {
            return (keys, values);
        }

        keys[8] = _key8;
        values[8] = _value8;
        if (_count == 9) {
            return (keys, values);
        }

        keys[9] = _key9;
        values[9] = _value9;
        if (_count == 10) {
            return (keys, values);
        }

        keys[10] = _key10;
        values[10] = _value10;
        if (_count == 11) {
            return (keys, values);
        }

        keys[11] = _key11;
        values[11] = _value11;
        if (_count == 12) {
            return (keys, values);
        }

        keys[12] = _key12;
        values[12] = _value12;
        if (_count == 13) {
            return (keys, values);
        }

        keys[13] = _key13;
        values[13] = _value13;
        if (_count == 14) {
            return (keys, values);
        }

        keys[14] = _key14;
        values[14] = _value14;
        if (_count == 15) {
            return (keys, values);
        }

        keys[15] = _key15;
        values[15] = _value15;
    }
}
