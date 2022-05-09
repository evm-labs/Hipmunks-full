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
   `"'``
                    𝕓𝕪 @𝕖𝕧𝕞_𝕝𝕒𝕓𝕤 & @𝕕𝕚𝕞𝕚𝕣𝕖𝕒𝕕𝕤𝕥𝕙𝕚𝕟𝕘𝕤 (𝕋𝕨𝕚𝕥𝕥𝕖𝕣)
*/

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";


contract Hipnation is Ownable{

    using SafeMath for uint256;

    address payable internal CharityAddress;
    mapping (address => bool) internal AdminVoted;
    mapping (address => uint) internal CharityVote;
    address payable[] internal adminsVoted;
    address public DAOadmin = owner();
    address public DAOadminValidator = owner();
    uint32 private DonationDate = 1656680400; // July 1st 2021, 9AM EDT
    uint32 private donationWindow = 3 days;
    uint256 public balance;

    modifier onlyEvery4thFriday(){
        require(
            (block.timestamp > DonationDate) && (block.timestamp < (DonationDate + donationWindow)),
            "Donation window is not open."
        );
        _;
    }

    modifier onlyOwnerOrAdmin(){
        require(
            (msg.sender == owner()) || (msg.sender == DAOadmin),
            "The message was not sent by the owner or the admin."
        );
        _;
    }

    modifier onlyOwnerOrAdminValidator(){
        require(
            (msg.sender == owner()) || (msg.sender == DAOadminValidator),
            "The message was not sent by the owner or the admin."
        );
        _;
    }

    modifier onlyOwnerOrAdmins(){
        require(
            (msg.sender == owner()) || (msg.sender == DAOadmin) || (msg.sender == DAOadminValidator),
            "The message was not sent by the owner or an admin."
        );
        _;
    }

    function setCharity(address payable newCharity) internal {
        CharityAddress = newCharity;
        for (uint i=0; i<=adminsVoted.length; i++){
            AdminVoted[adminsVoted[i]]=false;
        }
        delete adminsVoted;
    }

    function motionForNewCharity(address payable newCharity) public onlyOwnerOrAdmins onlyEvery4thFriday{
        require(!AdminVoted[msg.sender], "This admin has already voted.");
        CharityVote[newCharity] += 1;
        if (CharityVote[newCharity] >= 2) {
            setCharity(newCharity);
        }
        adminsVoted.push(payable(msg.sender));
        AdminVoted[msg.sender]=true;
    }

    function transferToCharity(uint256 _amountInWei) external onlyOwnerOrAdmin onlyEvery4thFriday{
        require(
            _amountInWei + _amountInWei.mul(2).div(100) <= address(this).balance,
            "Requested amount exceeds available funds."
        );
        (bool successfulDonation, ) = CharityAddress.call{value:_amountInWei}(""); 
        require(successfulDonation, "Failed to Donate. Transfer transaction was not successful.");
        updateDonationDate();
        for (uint i=0; i<=adminsVoted.length; i++){
            if (adminsVoted[i] != owner()){
                (bool successfulTip, ) = adminsVoted[i].call{value:_amountInWei.mul(1).div(100)}(""); 
                require(successfulTip, "Failed to Deposit. Transfer transaction was not successful.");   
            }
        }
    }

    function setDAOAdmin(address _admin) external onlyOwnerOrAdmin{
        DAOadmin = _admin;
    }

    function setDAOadminValidator(address _admin) external onlyOwnerOrAdminValidator{
        DAOadminValidator = _admin;
    }   

    function getBalance() external {
        balance = address(this).balance;
    }

    function updateDonationDate() internal {
        DonationDate += 4 weeks;
    }

    function setDonationDate(uint32 _unixTimestamp) external onlyOwner {
        DonationDate = _unixTimestamp;
    }

    receive() external payable {}

    fallback() external payable {}
}