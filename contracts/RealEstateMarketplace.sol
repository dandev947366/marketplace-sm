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
    event RealEstateCreated(
        uint indexed id,
        string name,
        string description,
        string location,
        string images,
        uint rooms,
        uint price,
        address owner,
        bool booked,
        bool deleted,
        uint timestamp
    );
    event RealEstateUpdated(
        uint indexed id,
        string name,
        string description,
        string location,
        string images,
        uint rooms,
        uint price,
        address owner,
        bool booked,
        bool deleted,
        uint timestamp
    );

    struct RealEstateOwner{
        address ownerAddress;
        string name;
        string contactDetails;
        uint[] ownedProperties;
    }

    struct RealEstateRenter{
        address renterAddress;
        string name;
        string contacDetails;
        uint[] rentedProperties;
        uint[] bookingHistory;
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

    event BookingCreated(
        uint indexed id,
        uint indexed aid,
        address tenant,
        uint date,
        uint price,
        bool checked,
        bool cancelled
    );

    struct Review{
        uint id;
        uint aid;
        string reviewText;
        uint timestamp;
        address owner;
    }

    event ReviewCreated(
        uint indexed id,
        uint indexed aid,
        string reviewText,
        uint timestamp,
        address owner
    );

    uint public securityFee;
    uint public taxPercent;

    mapping(uint => RealEstate) idToRealEstate;
    mapping(address => RealEstate[]) RealEstatesOf;
    mapping(uint => Booking[]) bookingsOf;
    mapping(uint => Review[]) reviewsOf;
    mapping(uint => bool) realEstateExist;
    mapping(uint => uint[]) bookedDates;
    mapping(uint => mapping(uint => bool)) isDateBooked;
    mapping(address => mapping(uint => bool)) hasBooked;


    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can change listing price");
        _;
    }
    constructor(uint _taxPercent, uint _securityFee){
        taxPercent = _taxPercent;
        securityFee = _securityFee;
    };

    // CRUD FOR REAL ESTATE
    function createRealEstate(
        string memory _name,
        string memory _description,
        string memory _location,
        string memory _images,
        uint _rooms,
        uint _price
    ) public {
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(bytes(_location).length > 0, "Location cannot be empty");
        require(bytes(_images).length > 0, "Images cannot be empty");
        require(_rooms > 0, "Rooms cannot be empty");
        require(_price > 0, "Price cannot be 0");

        _totalRealEstate.increment();
        uint currentCount = _totalRealEstate.current();

        RealEstate memory realEstate;
        realEstate.id = currentCount;
        realEstate.name = _name;
        realEstate.description = _description;
        realEstate.location = _location;
        realEstate.images = _images;
        realEstate.rooms = _rooms;
        realEstate.price = _price;
        realEstate.owner = msg.sender;
        realEstate.booked = false;
        realEstate.deleted = false;
        realEstate.timestamp = block.timestamp;
        realEstateExist[realEstate.id] = true;
        idToRealEstate[currentCount] = realEstate;  // Store the real estate in the mapping
        emit RealEstateCreated(
            realEstate.id,
            realEstate.name,
            realEstate.description,
            realEstate.location,
            realEstate.images,
            realEstate.rooms,
            realEstate.price,
            realEstate.owner,
            realEstate.booked,
            realEstate.deleted,
            realEstate.timestamp
        );
    }

    function updateRealEstate(
        uint _id,
        string memory _name,
        string memory _description,
        string memory _location,
        string memory _images,
        uint _rooms,
        uint _price
    ){
        require(realEstateExist[_id] == true, "Real estate not found");
        require(idToRealEstate[_id].owner == msg.sender, "Unauthorized");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        require(bytes(_location).length > 0, "Location cannot be empty");
        require(bytes(_images).length > 0, "Images cannot be empty");
        require(_rooms > 0, "Rooms cannot be empty");
        require(_price > 0, "Price cannot be 0");
        RealEstate memory realEstate = idToRealEstate[_id];
        realEstate.name = _name;
        realEstate.description = _description;
        realEstate.location = _location;
        realEstate.images = _images;
        realEstate.rooms = _rooms;
        realEstate.price = _price;
        idToRealEstate[_id] = realEstate;
        emit RealEstateUpdated(
            realEstate.id,
            realEstate.name,
            realEstate.description,
            realEstate.location,
            realEstate.images,
            realEstate.rooms,
            realEstate.price,
            realEstate.owner,
            realEstate.booked,
            realEstate.deleted,
            realEstate.timestamp
        );
    }
    function deleteRealEstate(){}
    function getRealEstate(){}
    function getAllRealEstates(){}

    // CRUD FOR BOOKING
    function createBooking(){}
    function updateBooking(){}
    function deleteBooking(){}
    function getBooking(){}
    function getAllBookings(){}

    // CRUD FOR REVIEW
    function createReview(){}
    function updateReview(){}
    function deleteReview(){}
    function getReview(){}
    function getAllReviews(){}





}