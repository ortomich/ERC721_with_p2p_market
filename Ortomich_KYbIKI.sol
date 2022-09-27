// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./ERC721A.sol";

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <brecht@loopring.org>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);
        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)
            for {
                let i := 0
            } lt(i, len) {
            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)
                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)
                mstore(resultPtr, out)
                resultPtr := add(resultPtr, 4)
            }
            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }
            mstore(result, encodedLen)
        }
        return string(result);
    }
}

contract Ortomich_KYbIKI is ERC721A {

    struct Market {
        bool isOnSale;
        uint256 price;
    }

    mapping (uint256 => Market) public market;

    uint256 public communityComissionsSum;
    uint8 public communityComissionsPercent; // in 1/1000, so 50 will be 5% comission
    address public owner;

    uint256 public constant maxSupply = 40;
    bool public sale;
    mapping(address => bool) public numOfMintedByWallet;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier isExist(uint256 tokenId) {
        require(_exists(tokenId), "token do not exist");
        _;
    }

    // metadata functions

    function generateHTMLandSVG() internal pure returns (string memory html_main, string memory svg_main) {
        svg_main = string(abi.encodePacked('<svg xmlns="http://www.w3.org/2000/svg" width="350" height="350"> <style> .heavy { font: bold 30px sans-serif; } </style> <text x="40" y="85" class="heavy" fill="red">K</text> <text x="70" y="115" class="heavy" fill="green">Y</text> <text x="100" y="155" class="heavy" fill="black">b</text> <text x="130" y="130" class="heavy" fill="purple">I</text> <text x="160" y="185" class="heavy" fill="orange">K</text> <text x="190" y="195" class="heavy" fill="blue">I</text> </svg>'));
        html_main = string(abi.encodePacked('<!DOCTYPE html> <html lang="en"> <head></head> <body> <script type="importmap">{"imports": {"three": "https://cdn.jsdelivr.net/npm/three@0.142.0/build/three.module.js"}} </script> <script type="module"> import * as THREE from "three"; import { OrbitControls } from "https://cdn.jsdelivr.net/npm/three@0.142.0/examples/jsm/controls/OrbitControls.js"; import { RectAreaLightHelper } from "https://cdn.jsdelivr.net/npm/three@0.142.0/examples/jsm/helpers/RectAreaLightHelper.js"; import { RectAreaLightUniformsLib } from "https://cdn.jsdelivr.net/npm/three@0.142.0/examples/jsm/lights/RectAreaLightUniformsLib.js"; let renderer, scene, camera; let arrGlobal = []; init(); function init() { renderer = new THREE.WebGLRenderer( { antialias: true } ); renderer.setPixelRatio( window.devicePixelRatio ); renderer.setSize( window.innerWidth, window.innerHeight ); renderer.setAnimationLoop( animation ); renderer.outputEncoding = THREE.sRGBEncoding; document.body.appendChild( renderer.domElement ); camera = new THREE.PerspectiveCamera( 45, window.innerWidth / window.innerHeight, 1, 1000 ); camera.position.set( 20, 15, -5 ); scene = new THREE.Scene(); RectAreaLightUniformsLib.init(); for (var i = -5; i <= 5; i++) { let arr_local = []; for (var j = -5; j <= 5; j++) { const geometry = new THREE.BoxGeometry( 1, 3, 1 ); let color = Math.floor(Math.random() * 16777215).toString(16); var material = new THREE.MeshBasicMaterial( { color: parseInt(color, 16), linewidth: 40 } ); let mesh = new THREE.Mesh( geometry, material ); mesh.position.set( i, 0, j ); mesh.name = "mesh" + i + j; scene.add( mesh ); arr_local.push((10000000 - i - j) * 3050); } arrGlobal.push(arr_local); } const controls = new OrbitControls( camera, renderer.domElement ); controls.update(); window.addEventListener( "resize", onWindowResize ); } function onWindowResize() { renderer.setSize( window.innerWidth, window.innerHeight ); camera.aspect = ( window.innerWidth / window.innerHeight ); camera.updateProjectionMatrix(); } function animation() { for (var i = -5; i <= 5; i++) { for (var j = -5; j <= 5; j++) { const mesh = scene.getObjectByName( "mesh" + i + j ); mesh.position.y = Math.abs( Math.sin( (Date.now() - arrGlobal[i+5][j+5]) * 0.004 ) ); } } renderer.render( scene, camera ); } </script> </body> </html>'));

        return(html_main, svg_main);
    }

    function htmlToImageURI(string memory html) internal pure returns (string memory) {
        string memory baseURL = "data:text/html;base64,";
        string memory htmlBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(html))));
        return string(abi.encodePacked(baseURL,htmlBase64Encoded));
    }

    function svgToImageURI(string memory svg) internal pure returns (string memory) {
        string memory baseURL = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(bytes(string(abi.encodePacked(svg))));
        return string(abi.encodePacked(baseURL,svgBase64Encoded));
    }


    function tokenURI(uint256 tokenId) override public view returns (string memory) {
        (string memory html, string memory svg) = generateHTMLandSVG();
        string memory imageURIhtml = htmlToImageURI(html);

        string memory imageURIsvg = svgToImageURI(svg);

        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            "KYbIKI | ", uint2str(tokenId),"",
                            '", "description":"`Wow, opyat krutaya NFT, pravda?", "image":"', imageURIsvg,'", "animation_url":"', imageURIhtml,'"}'
                        )
                    )
                )
            )
        );
    }


    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    // main functions

    function mint() public {
        require(numOfMintedByWallet[msg.sender] == false, "Dont try this again!");
        require(tx.origin == msg.sender, "bot");
        require(totalSupply() < maxSupply, "invalid claim");
        require(sale == true, "sale is stopped!");

        numOfMintedByWallet[msg.sender] = true;
        _safeMint(msg.sender, 1);
    }

    // market functions

    function isListed(uint256 tokenId) public view isExist(tokenId) returns(bool) {
        return(market[tokenId].isOnSale);
    }

    function NFTPrice(uint256 tokenId) public view isExist(tokenId) returns(uint256) {
        return(market[tokenId].price);
    }

    function getCommunityComissionsSum() public view returns(uint256) {
        return(communityComissionsSum);
    }

    function list(uint256 tokenId, uint256 price) public isExist(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "not owner");

        market[tokenId] = Market({
            isOnSale: true,
            price: price
        });
    }

    function stopListing(uint256 tokenId) public isExist(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "not owner");

        market[tokenId].isOnSale = false;
    }

    function buy(uint256 tokenId) public payable isExist(tokenId) {
        require(market[tokenId].isOnSale == true &&
                market[tokenId].price <= msg.value);

        market[tokenId].isOnSale = false;
        communityComissionsSum += (msg.value / 1000 * communityComissionsPercent);

        payable(ownerOf(tokenId)).transfer(msg.value - (msg.value / 1000 * communityComissionsPercent));
        unsafeTransferFrom(ownerOf(tokenId), msg.sender, tokenId);
    }

    function withdrawAllComissions() public {
        for (uint32 tokenId = 1; tokenId<=totalSupply(); tokenId++){
            payable(ownerOf(tokenId)).transfer(communityComissionsSum/totalSupply());
        }
        communityComissionsSum = 0;
    }

    // Admin functions

    function setComissions(uint8 _communityComissionsPercent) public onlyOwner {
        communityComissionsPercent = _communityComissionsPercent;
    }

    function setNewOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setSale(bool _set) public onlyOwner {
        sale = _set;
    }

    // constructor

    constructor() ERC721A("Ortomich KYbIKI", "OK") {
        owner = msg.sender;
        communityComissionsPercent = 10;
        _safeMint(msg.sender, 4);
    }
}