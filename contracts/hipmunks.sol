pragma solidity ^0.8.13;
// SPDX-License-Identifier: None



/*
             ,;:;;,
           ;;;;;
   .=',    ;:;;:,    ░░░░░    Ｈｉｐｐｉｅ   ░░░░░
  /_', "=. ';:;:;    ░░░░░   Ｈｉｐｓｔｅｒ   ░░░░░ 
  @=:__,  \,;:;:'    ░░░░░  Ｃｈｉｐｍｕｎｋｓ ░░░░░
    _(\.=  ;:;;'
   `"_(  _/="`
   `"'`
                    𝕓𝕪 @𝕖𝕧𝕞_𝕝𝕒𝕓𝕤 & @𝕕𝕚𝕞𝕚𝕣𝕖𝕒𝕕𝕤𝕥𝕙𝕚𝕟𝕘𝕤 (𝕋𝕨𝕚𝕥𝕥𝕖𝕣)
*/



import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract HippieHipsterChipmunks is ERC721, Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    using SafeMath for uint256;
    using ECDSA for bytes32;
    using Strings for uint256;

    uint256 public constant MAX_CHIPMUNKS = 8888;
    uint256 public constant MAX_CHIPMUNKS_PER_PURCHASE = 4;
    uint256 public constant MAX_CHIPMUNKS_WHITELIST_CAP = 2;
    uint256 public constant CHIPMUNK_PRICE = 0.066 ether;
    uint256 public constant PRESALE_CHIPMUNKS = 2000;
    uint256 public constant DONATION_CHIPMUNKS = 22;
    uint256 public constant RESERVED_CHIPMUNKS = 200;
    address payable constant HipDAOAddress = payable(0xD7ACd2a9FD159E69Bb102A1ca21C9a3e3A5F771B);  // change this address

    string public tokenBaseURI;
    string public unrevealedURI;
    bool public presaleActive = false;
    bool public mintActive = false;
    bool public reservesMinted = false;
    bool public donationsMinted = false;
    uint256 public balance;

    mapping(address => uint256) private whitelistAddressMintCount;
    Counters.Counter public reserveMintEntry;
    Counters.Counter public tokenSupply;

    constructor() ERC721("Hippie Hipster Chipmunks", "HHC") {}

    function setTokenBaseURI(string memory _baseURI) external onlyOwner {
        tokenBaseURI = _baseURI;
    }

    function setUnrevealedURI(string memory _unrevealedUri) external onlyOwner {
        unrevealedURI = _unrevealedUri;
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        bool revealed = bytes(tokenBaseURI).length > 0;

        if (!revealed) {
            return unrevealedURI;
        }

        require(
            _exists(_tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        return string(abi.encodePacked(tokenBaseURI, _tokenId.toString())); //.toString() is Strings based
    }

    function changePresaleStatus() external onlyOwner {
        presaleActive = !presaleActive;
    }

    function changeMintStatus() external onlyOwner {
        mintActive = !mintActive;
    }

    function verifyOwnerSignature(bytes32 hash, bytes memory signature)
        private
        view
        returns (bool)
    {
        return hash.toEthSignedMessageHash().recover(signature) == owner(); //.recover() is ECDSA based
    }

    function presaleMint(uint256 _quantity, bytes calldata _whitelistSignature)
        external
        payable
        nonReentrant
    {
        require(
            verifyOwnerSignature(
                keccak256(abi.encode(msg.sender)),
                _whitelistSignature
            ),
            "Invalid whitelist signature"
        );
        require(presaleActive, "Presale is not active");
        require(
            tokenSupply.current().add(_quantity) <= PRESALE_CHIPMUNKS,
            "This purchase would exceed max supply of Presale Chipmunks"
        );
        require(
            whitelistAddressMintCount[msg.sender].add(_quantity) <=
                MAX_CHIPMUNKS_WHITELIST_CAP,
            "This purchase would exceed the maximum Chipmunks you are allowed to mint in the presale"
        );

        whitelistAddressMintCount[msg.sender] += _quantity;
        _safeMintChipmunks(_quantity);
    }

    function publicMint(uint256 _quantity) external payable nonReentrant {
        require(mintActive, "Sale is not active.");
        require(
            _quantity <= MAX_CHIPMUNKS_PER_PURCHASE,
            "Quantity is more than allowed per transaction."
        );

        _safeMintChipmunks(_quantity);
    }

    function _safeMintChipmunks(uint256 _quantity) internal {
        require(_quantity > 0, "You must mint at least 1 Chipmunk");    
        require(
            tokenSupply.current().add(_quantity) <= MAX_CHIPMUNKS,
            "This purchase would exceed max supply of Chipmunks"
        );
        require(
            msg.value == CHIPMUNK_PRICE.mul(_quantity),
            "The ether value sent is not correct"
        );

        for (uint256 i = 0; i < _quantity; i++) {
            uint256 mintIndex = tokenSupply.current();

            if (mintIndex < MAX_CHIPMUNKS) {
                tokenSupply.increment();
                _safeMint(msg.sender, mintIndex);
            }
        }
    }

    function mintReservedChipmunks() external payable onlyOwner {
        require(!reservesMinted, "Reserves have already been minted.");
        require(
            tokenSupply.current().add(RESERVED_CHIPMUNKS) <= MAX_CHIPMUNKS,
            "This mint would exceed max supply of Chipmunks"
        );
        reserveMintEntry.increment();
        uint256 chimpmunksToMint = RESERVED_CHIPMUNKS.div(2);
        for (uint256 i = 0; i < chimpmunksToMint; i++) {
            uint256 mintIndex = tokenSupply.current();

            if (mintIndex < MAX_CHIPMUNKS) {
                tokenSupply.increment();
                _safeMint(HipDAOAddress, mintIndex);
            }
        }
        if (reserveMintEntry.current() == 2){reservesMinted = true;}
    }

    function mintDonatedChipmunks() external payable onlyOwner {
        require(!donationsMinted, "Donations have already been minted.");
        require(
            tokenSupply.current().add(DONATION_CHIPMUNKS) <= MAX_CHIPMUNKS,
            "This mint would exceed max supply of Chipmunks"
        );

        for (uint256 i = 0; i < DONATION_CHIPMUNKS; i++) {
            uint256 mintIndex = tokenSupply.current();

            if (mintIndex < MAX_CHIPMUNKS) {
                tokenSupply.increment();
                _safeMint(HipDAOAddress, mintIndex);
            }
        }
        donationsMinted = true;
    }

   function getBalance() external {
        balance = address(this).balance;
    }

    function withdraw() external payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{value:address(this).balance}(""); 
        require(success, "Failed to Deposit. Transfer transaction was not successful.");
    }

    function depositToDao() external payable onlyOwner {
        uint256 transferAmount = address(this).balance.mul(15).div(100);
        (bool success, ) = HipDAOAddress.call{value:transferAmount}(""); 
        require(success, "Failed to Deposit. Transfer transaction was not successful.");
    }

    receive() external payable {}

    fallback() external payable {}


}