// SPDX-License-Identifier: MIT

pragma solidity 0.8.15;

import "./libs/Address.sol";
import "./libs/Base64.sol";
import './libs/SafeMath.sol';
import './libs/SafeCast.sol';
import './libs/INFTDescriptor.sol';
import './libs/ERC721Enumerable.sol';
import './libs/NFTPropertyStorageV4.sol';
import './libs/NFTMintManager.sol';
import './libs/CfoNftTakeable.sol';

contract CeresDID is CfoNftTakeable,ERC721Enumerable,NFTPropertyStorage,NFTMintManager {
    using SafeMath for uint256;
    using SafeCast for uint256;

    mapping(uint256 => string) private _propertyNames;
    
    mapping(bytes32 => string) private _propertyAlias;
    
    mapping(uint256 => string) public tokenDIDOf;
    
    mapping(bytes32 => uint256) public didTokenIdOf;
    
    mapping(uint256 => string) public customImageOf;
    
    mapping(uint256 => address) public minterOf;
    
    mapping(address => uint256) public mintedTokenOf;
    
    mapping(uint256 => mapping(uint256 => string)) public stringPropertyOf;
    bool public transferAllowed;
    uint256 public constant allPackedPropsLength = 3; 
    uint256 public constant allPropsLength = 6;
    uint256 private constant allStringPropsLength = 6;
    address public tokenDescriptor;
    string public constant description = "Ceres DID is Decentralized digital identity system with programmable metadata and verifiable signatures.";
 
    event Minted(address minter,address to,uint tokenId,bytes32[] packedProps,string did);

    constructor() ERC721("Ceres DID NFT", "Ceres DID NFT") {
        addMinter(msg.sender);
        addUpdater(msg.sender);

        _propertyNames[0] = "s1";
        
        _propertyNames[1] = "s2";
        
        _propertyNames[2] = "s3";
        
        _propertyNames[3] = "s4";
        
        _propertyNames[4] = "s5";
        
        _propertyNames[5] = "s6";

        _propertyNames[6] = "n1";
        
        _propertyNames[7] = "n2";
        
        _propertyNames[8] = "n3";
        
        _propertyNames[9] = "n4";
        
        _propertyNames[10] = "n5";
        
        _propertyNames[11] = "n6";
    }

    function packProperties(uint[] memory unpackedProps) public pure returns(bytes32[] memory) {
        bytes32[] memory bs = new bytes32[](allPackedPropsLength);
        bs[0] = bytes32(
            (uint(SafeCast.toUint128(unpackedProps[0])) << 128) + 
            uint(SafeCast.toUint128(unpackedProps[1]))
        );
        bs[1] = bytes32(
            (uint(SafeCast.toUint128(unpackedProps[2])) << 128) + 
            uint(SafeCast.toUint128(unpackedProps[3]))
        );
        bs[2] = bytes32(
            (uint(SafeCast.toUint128(unpackedProps[4])) << 128) + 
            uint(SafeCast.toUint128(unpackedProps[5]))
        );

        return bs;
    }

    function unpackPreperties(bytes32[] memory packedProps) public pure returns(uint[] memory) {
        uint[] memory props = new uint[](allPropsLength);
        props[0] = NFTPropertyPacker.readUint128(packedProps[0], 0);
        props[1] = NFTPropertyPacker.readUint128(packedProps[0], 16);
        props[2] = NFTPropertyPacker.readUint128(packedProps[1], 0);
        props[3] = NFTPropertyPacker.readUint128(packedProps[1], 16);
        props[4] = NFTPropertyPacker.readUint128(packedProps[2], 0);
        props[5] = NFTPropertyPacker.readUint128(packedProps[2], 16);

        return props;
    }

    function safeMint(address to,uint[] memory numberProps,string[] memory stringProps, string memory did,string memory imageUrl) public onlyMinter returns(uint256) {  
        require(to != address(0),"safeMint: to can not be address 0");
        require(numberProps.length == allPropsLength && stringProps.length == allStringPropsLength,"safeMint: invalid properties length");
        require(mintedTokenOf[to] == 0,"to address already minted");
        require(!didExists(did),"did already exists");

        uint tokenId = nextTokenId++;
        _safeMint(to, tokenId);
       
        bytes32[] memory packedProps = packProperties(numberProps);
        _addNewItem(tokenId,packedProps);

        _setDID(tokenId,did);
        mintedTokenOf[to] = tokenId;
        minterOf[tokenId] = to;

        _setCustomImage(tokenId, imageUrl);

        for(uint i=0;i<stringProps.length;i++){
            if(bytes(stringProps[i]).length > 0){
                stringPropertyOf[tokenId][i] = stringProps[i];
            }
        }

        emit Minted(msg.sender,to,tokenId,packedProps,did);
        return tokenId;
    }

    function _transfer(address from,address to,uint256 tokenId) internal override {
        require(transferAllowed,"disabled");
        super._transfer(from,to,tokenId);
    }

    function _setDID(uint tokenId,string memory did) internal {
        require(tokenId > 0,"tokenId can not be 0");
        require(!didExists(did),"did already exists");
        
        tokenDIDOf[tokenId] = did;
        didTokenIdOf[_didKey(did)] = tokenId;
    }

    function _setCustomImage(uint tokenId, string memory imageUri) internal {
        customImageOf[tokenId] = imageUri;
    }

    function _burn(uint256 tokenId) internal override {
        super._burn(tokenId);
        
        delete _itemPackedProps[tokenId][0];
        string memory did = tokenDIDOf[tokenId];
        delete tokenDIDOf[tokenId];
        delete didTokenIdOf[_didKey(did)];

        address minter = minterOf[tokenId];        
        delete minterOf[tokenId];
        delete mintedTokenOf[minter];        
        delete customImageOf[tokenId];
    }

    function didOwnerOf(string memory did) external view returns(address){
        require(bytes(did).length > 0,"did can not be empty");
        require(didExists(did),"did not exist");
        return ownerOf(didTokenIdOf[_didKey(did)]);
    }

    function imageOf(uint tokenId) public view returns(string memory) {
        return customImageOf[tokenId];
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        require(_exists(tokenId), "ERC721: URI query for nonexistent token");
        if (tokenDescriptor != address(0)) {
            return INFTDescriptor(tokenDescriptor).tokenURI(address(this), tokenId);
        }

        bytes memory output = abi.encodePacked('{"name": "', name(), ' #',Strings.toString(tokenId),'","description": "',description,'", "image": "',imageOf(tokenId),'","attributes":', _propertiesToJson(tokenId),'}');
        output = abi.encodePacked('data:application/json;base64,', Base64.encode(bytes(string(output))));
        return string(output);
    }

    function itemProperties(uint tokenId) public view returns(uint[] memory) {
        bytes32[] memory props = new bytes32[](allPackedPropsLength);
        for(uint i=0;i<allPackedPropsLength;i++){
            props[i] = _itemPackedProps[tokenId][i];
        }

        return unpackPreperties(props);
    }

    function _propertiesToJson(uint tokenId) internal view returns(string memory){
        uint[] memory props = itemProperties(tokenId);

        bytes memory output = abi.encodePacked('[{"trait_type":"DID","value":"', tokenDIDOf[tokenId],'"}');
        output = abi.encodePacked(output,',{"trait_type":"Minter","value":"', Strings.toHexString(uint(uint160(minterOf[tokenId])),20),'"}');

        for(uint i=0;i<allStringPropsLength;i++){
            output = abi.encodePacked(output,',{"trait_type":"',_propertyNames[i],'","value":"', stringPropertyOf[tokenId][i],'"}'); 
        }

        for(uint i=0;i<allPropsLength; i++){
            string memory aliasName_ = _propertyAlias[_aliasKey(i, props[i])];
            output = abi.encodePacked(output,',{"trait_type":"',_propertyNames[i+allStringPropsLength],'","value":"',(bytes(aliasName_).length > 0 ? aliasName_ : Strings.toString(props[i])),'"}'); 
        }
        output = abi.encodePacked(output,']');
        return string(output);
    }

    function updateProperty(uint tokenId,uint mapIndex,uint pos,uint length,uint newVal) external onlyUpdater {
        require(mapIndex < allPackedPropsLength,"updateProperty: invalid mapIndex");
        require((pos==0 || pos==16) && length==16,"invalid pos or length");
        require(_exists(tokenId),"updateProperty: token id nonexistent");
        
        _updateProperty(tokenId, mapIndex, pos,length,newVal);
    }

    function updatePackedProperties(uint tokenId, uint mapIndex, bytes32 newPackedProps) public onlyUpdater {
        require(mapIndex < allPackedPropsLength,"updateProperty: invalid mapIndex");
        require(_exists(tokenId),"updateProperty: token id nonexistent");
        _updatePackedProperties(tokenId,mapIndex,newPackedProps);
    }

    function updateCustomImage(uint tokenId, string memory imageUri) external onlyUpdater {
        require(exists(tokenId),"token id not exists");
        _setCustomImage(tokenId, imageUri);
    }

    function updateStringProperty(uint tokenId,uint propIndex, string calldata val) external onlyUpdater {
        require(tokenId > 0,"token id can not be 0");
        stringPropertyOf[tokenId][propIndex] = val;
    }

    function exists(uint tokenId) public view returns(bool) {
        return _exists(tokenId);
    }

    function didExists(string memory did) public view returns(bool){
        if(bytes(did).length == 0) return true;

        return didTokenIdOf[_didKey(did)] > 0;
    }

    function _didKey(string memory did) internal pure returns(bytes32){
        return keccak256(bytes(did));
    }

    function userAllTokens(address account) external view returns(uint256[] memory){
        uint balance_ = balanceOf(account);
        uint[] memory ids = new uint[](balance_);
        if(balance_ > 0){
            for(uint i = 0;i < balance_;i++){
                ids[i] = tokenOfOwnerByIndex(account, i);
            }
        }
        return ids;
    }

    function burn(uint tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function propertyNameOf(uint _pIndex) external view returns(string memory){
        return _propertyNames[_pIndex];
    }

    function aliasOf(uint _pIndex,uint _pVal) external view returns(string memory){
        return _propertyAlias[_aliasKey(_pIndex,_pVal)];
    }

    function _aliasKey(uint pIndex,uint val) internal pure returns(bytes32) {
        return keccak256(abi.encode(pIndex,val));
    }

    function setPropertyName(uint _pIndex,string memory _pName) external onlyOwner {
        require(_pIndex < allPropsLength,"invalid _pIndex");
        require(bytes(_pName).length > 0,"_pName can not be empty");
        _propertyNames[_pIndex] = _pName;
    }

    function setAlias(uint _pIndex,uint _val,string memory _aliasName) external onlyOwner {
        require(_pIndex < allPropsLength,"invalid _pIndex");
        _propertyAlias[_aliasKey(_pIndex, _val)] = _aliasName;
    }

    function setDescriptor(address descriptor) external onlyOwner {
        tokenDescriptor = descriptor;
    }

    function setTransferAllowed(bool isAllowed) external onlyOwner {
        transferAllowed = isAllowed;
    }
}
