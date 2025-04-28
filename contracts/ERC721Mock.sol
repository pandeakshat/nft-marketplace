// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

/// @notice A simple ERC721 you can mint from tests
contract ERC721Mock is ERC721PresetMinterPauserAutoId {
    constructor(
        string memory name,
        string memory symbol,
        string memory baseURI
    ) ERC721PresetMinterPauserAutoId(name, symbol, baseURI) {}
}
