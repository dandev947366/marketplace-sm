// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract RealEstateMarketplace is Ownable, ReentrancyGuard {
    using Counters for Counters.Counter;
    Counters.Counter private _totalRealEstate;

    struct RealEstate {
        uint256 id;
        string name;
        string description;
        string location;
        string images;
        uint rooms;
        uint price;
        address owner;
        bool booked;
        bool deleted;
        uint timestamp;
    }

    struct Booking{
        uint id;
        uint aid;
        address tenant;
        uint date;
        uint price;
        bool checked;
        bool cancelled;
    }

    struct Review{
        uint id;
        uint aid;
        string reviewText;
        uint timestamp;
        address owner;
    }

    uint public securityFee;
    uint public taxPercent;

    mapping(uint => RealEstate) private idToRealEstate;
    mapping(uint => Booking[]) bookingsOf;
    mapping(uint => Review[]) reviewsOf;
    mapping(uint => bool) realEstateExist;
    mapping(uint => uint[]) bookedDates;
    mapping(uint => mapping(uint => bool)) isDateBooked;
    mapping(address => mapping(uint => bool)) hasBooked;

    constructor(uint _taxPercent, uint _securityFee){
        taxPercent = _taxPercent;
        securityFee = _securityFee;
    };

}