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
    event RealEstateDeleted(
        uint indexed id,
        address indexed owner,
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

    event RealEstateReserved(
        uint indexed aid,
        address indexed tenant,
        uint[] dates,
        uint totalCost,
        uint finalCost,
        uint timestamp
    );

    event ReservationCancelled(
        uint indexed aid,
        uint indexed bookingId,
        bool cancelled,
        uint[] date,
        uint timestamp
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
    event ReviewUpdated(
        uint indexed reviewId,
        uint indexed realEstateId,
        string updatedText,
        uint timestamp
    );

    event ReviewDeleted(
        uint indexed realEstateId,
        uint indexed reviewId,
        address indexed owner,
        uint timestamp
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
    }

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
        realEstate.timestamp = currentTime();
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
            currentTime()
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
            currentTime()
        );
    }
    function deleteRealEstate(uint _id){
        require(realEstateExist[_id] == true, "Real estate not found");
        require(idToRealEstate[_id].owner == msg.sender, "Unauthorized");
        realEstateExist[realEstate.id] = false;
        idToRealEstate[_id].deleted = true;
        emit RealEstateDeleted(
            _id,
            idToRealEstate[_id].owner,
            idToRealEstate[_id].deleted,
            currentTime()
        );
    }
    function getRealEstate(uint _id) public view returns(RealEstate memory) {
        return idToRealEstate[_id];
    }
    function getAllRealEstates(address _owner) public view returns(RealEstate[] memory){
        uint available;
        for(uint i=1; i<=_totalRealEstate.current();i++){
            if(!idToRealEstate[_id].deleted) available++;
        }
        RealEstate memory realEstate = RealEstate[](available);
        uint index;
        for(uint i=1; i<=_totalRealEstate.current();i++){
            if(!idToRealEstate[_id].deleted){
                realEstate[index++] = idToRealEstate[_id];
            }
        }
    }
    // RESERVE REAL ESTATE
    function reserveRealEstate(uint _aid, uint[] memory dates) public payable{
        uint totalCost = idToRealEstate[_aid].price * dates.length;
        uint finalCost = (totalCost * securityFee) /100;
        require(realEstateExist[_aid], "Real Estate not found.");
        require(msg.value >= finalCost, "Insufficient fund.");
        require(datesAreCleared(_aid, _dates), "Booked date found among dates!.");
        for (uint i=0; i<dates.length; i++){
            Booking memory booking;
            booking.aid = _aid;
            booking.id  = bookingsOf[_aid].length;
            booking.tenant = msg.sender;
            booking.date = dates[i];
            booking.price = idToRealEstate[_aid].price;
            bookingsOf[_aid][dates[i]] = true;
            bookedDates[_aid].push(dates[i]);
        }
        emit RealEstateReserved(
            _aid,
            msg.sender,
            dates,
            totalCost,
            finalCost,
            currentTime()
        );
    }

    function datesAreCleared(uint aid, uint[] memory dates) internal view returns (bool){
        bool lastCheck = true;
        for (uint i = 0; i<dates.length; i++){
            for (uint j =0; j<bookedDates[aid].length;j++){
                if(fates[i] == bookedDates[aid][j]) lastCheck = false;
            }
        }
        return lastCheck;
    }
    function cancelReservation(uint _aid, uint _bookingId) public {
        require(realEstateExist[_aid], "Real Estate not found.");
        require(_bookingId < bookingsOf[_aid].length, "Booking not found.");

        // Fetch the booking
        Booking storage booking = bookingsOf[_aid][_bookingId];

        // Authorization and state checks
        require(booking.tenant == msg.sender, "Unauthorized");
        require(!booking.cancelled, "Booking already cancelled.");

        // Mark the booking as cancelled
        booking.cancelled = true;

        // Clear the booked dates
        uint[] memory cancelledDates = new uint[](bookedDates[_aid].length);
        uint counter = 0;

        for (uint i = 0; i < bookedDates[_aid].length; i++) {
            uint date = bookedDates[_aid][i];
            if (isDateBooked[_aid][date]) {
                isDateBooked[_aid][date] = false;
                cancelledDates[counter] = date;
                counter++;
            }
        }

        // Emit the event with the updated information
        emit ReservationCancelled(
            _aid,
            _bookingId,
            true,
            cancelledDates,
            currentTime()
        );
    }

    function getBooking(uint _aid) public view returns (Booking[] memory){
        return bookingsOf[_aid];
    }

    function createReview(uint _aid, string memory _text) public{
        require(realEstateExist[_aid], "Real Estate not found.");
        require(hasBooked[msg.sender][aid], "Need to book first.");
        require(bytes(reviewText).length) > 0, "Review text cannot be empty.");
        require(bytes(_text).length <= 500, "Review text is too long.");

        Review memory review;
        review.aid = _aid;
        review.id = reviewsOf[_aid].length;
        review.reviewText = _text;
        review.timestamp = currentTime();
        review.owner = msg.sender;
        reviewsOf[aid].push(review);

        emit ReviewCreated(
            review.id,
            _id,
            _text,
            currentTime(),
            msg.sender
        );
    }
    function updateReview(uint _aid, uint _reviewId, string memory _text) public {
        require(realEstateExist[_aid], "Real Estate not found.");
        require(hasBooked[msg.sender][_aid], "Need to book first.");
        require(bytes(_text).length > 0, "Review text cannot be empty.");
        require(bytes(_text).length <= 500, "Review text is too long.");
        require(_reviewId < reviewsOf[_aid].length, "Review not found.");

        // Fetch the review
        Review storage review = reviewsOf[_aid][_reviewId];

        // Ensure the caller is the owner of the review
        require(review.owner == msg.sender, "Unauthorized");

        // Update the review text and timestamp
        review.reviewText = _text;
        review.timestamp = currentTime();

        // Emit the event
        emit ReviewUpdated(
            _reviewId,
            _aid,
            _text,
            review.timestamp
        );
    }

    function deleteReview(uint _aid, uint _reviewId) public {
        require(realEstateExist[_aid], "Real Estate not found.");
        require(_reviewId < reviewsOf[_aid].length, "Review not found.");
        // Fetch the review
        Review storage review = reviewsOf[_aid][_reviewId];
        // Ensure the caller is the owner of the review
        require(review.owner == msg.sender, "Unauthorized");
        // Mark the review as deleted (or you can remove it from the array)
        review.deleted = true;
        // Emit the event
        emit ReviewDeleted(_aid, _reviewId, review.owner, block.timestamp);
    }

    function getReview(uint _aid, uint _reviewId) public view returns (Review memory) {
        require(realEstateExist[_aid], "Real Estate not found.");
        require(_reviewId < reviewsOf[_aid].length, "Review not found.");
        return reviewsOf[_aid][_reviewId];
    }

    function getAllReviews(uint _aid) public view returns (Review[] memory) {
        require(realEstateExist[_aid], "Real Estate not found.");
        return reviewsOf[_aid];
    }
    function claimFunds(uint _aid, uint _bookingId) public {
        require(msg.sender == idToRealEstate[_aid].owner, "Unauthorized entity.");
        require(!bookingsOf[_aid][_bookingId].checked, "Real estate already checked on this date.");
        uint price = bookingsOf[_aid][_bookingId].price;
        uint fee = (price*taxPercent)/100;
        payTo(idToRealEstate[_aid].owner, (price-fee));
        payTo(owner(),fee);
        payTo(msg.sender, securityFee);
    }
    function refundBooking(uint _aid, uint _bookingId) public nonReentrant {
        Booking memory booking = bookingsOf[_aid][_bookingId];
        require(!booking.checked, "Real estate already checked on this date.");
        require(isDateBooked[_aid][booking.date], "Did not book on this date.");
        if (msg.sender != owner()){
            require(msg.sender == booking.tenant, "Unauthorized tenant.");
            require(booking.date > currentTime(), "Can no longer refund, booking date started.");
        }
        bookingsOf[_aid][_bookingId].cancelled = true;
        isDateBooked[_aid][booking.date] = false;
        uint lastIndex = bookedDates[_aid].length - 1;
        uint lastBookingId = bookedDates[_aid][lastIndex];
        bookedDates[_aid][_bookingId] = lastBookingId;
        bookedDates[_aid].pop();
        uint fee = (booking.price * securityFee) / 100;
        uint collateral = fee / 2;
        payTo(idToRealEstatep[_aid].owner, collateral);
        payTo(owner(), collateral);
        payTo(msg.sender, booing.price);
    }
    function tenantBooked(uint _id) public view returns (bool) {
        return hasBooked[msg.sender][_id];
    }
    function getUnavailableDates(uint _aid) public view returns (uint[] memory)
    {
        return bookedDates[_aid];
    }
    function payTo(address _to, uint256 _amount) internal {
        (bool success, ) = payable(_to).call{ value: _amount }('');
        require(success);
      }
    function currentTime() internal view returns (uint256) {
        return (block.timestamp * 1000) + 1000;
      }





}