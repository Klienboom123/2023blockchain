// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Uncomment the line to use openzeppelin/ERC721
// You can use this dependency directly because it has been installed by TA already
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import "./MyERC4907.sol";
import "hardhat/console.sol";
contract BorrowYourCar {

    // use a event if you want
    // to represent time you can choose block.timestamp
    event CarBorrowed(uint32 carTokenId, address borrower, uint256 startTime, uint256 duration);

    // maybe you need a struct to store car information
    struct Car {
        address owner;
        address borrower;
        uint256 borrowUntil;
    }
    mapping(uint256 => Car) public cars; // A map from car index to its information
    MyERC4907 public my=new MyERC4907("CarTokens","CarTokensSymbol");
    // ...
    // TODO add any variables if you want

    constructor() {
        Car memory car;
        for(uint16 i=0;i<3;i++)
        {
            my.airdrop(address(this));
            car.owner=address(this);
            car.borrower=address(0);
            car.borrowUntil=0;
            cars[i]=car;
        }
        // maybe you need a constructor
    }

    function helloworld() pure external returns(string memory) {
        return "hello world";
    }

    function GetCarList() view external  returns(uint256[] memory){
        uint16 count=0;
        for(uint16 i=0;i<my.getAmount();i++)
        {
            if(cars[i].owner==address(msg.sender))
            count++;
        }
        uint256[] memory carS=new uint256[](count);
        count=0;
            for(uint16 i=0;i<my.getAmount();i++)
            {
                if(cars[i].owner==address(msg.sender)){
                    carS[count]=i;
                    count++;
                }
            }
        return carS;
    }

    function GetALLCarList() view external  returns(uint256[] memory){
        uint256[] memory carS=new uint256[](my.getAmount());
        for(uint16 i=0;i<my.getAmount();i++)
        {
            carS[i]=i;
        }
        return carS;
    }
    function GetALLCarListNB(uint64 now) view external  returns(uint256[] memory){
        uint16 count=0;
        for(uint16 i=0;i<my.getAmount();i++)
        {
            if(cars[i].borrowUntil<now)
                count++;
        }
        uint256[] memory carS=new uint256[](count);
        count=0;
        for(uint16 i=0;i<my.getAmount();i++)
        {
            if(cars[i].borrowUntil<now){
                carS[count]=i;
                count++;
            }
        }
        return carS;
    }

    function GetCarListNB(uint64 now) view external returns(uint256[] memory){
        uint16 count=0;
        for(uint16 i=0;i<my.getAmount();i++)
        {
            if(cars[i].owner==address(msg.sender)&&cars[i].borrowUntil<now)
                count++;
        }
        uint256[] memory carS=new uint256[](count);
        count=0;
        for(uint16 i=0;i<my.getAmount();i++)
        {
            if(cars[i].owner==address(msg.sender)&&cars[i].borrowUntil<now){
                carS[count]=i;
                count++;
            }
        }
        return carS;
    }

    function GetRentCarList(uint64 now) view external returns(uint256[] memory){
        uint16 count=0;
        for(uint16 i=0;i<my.getAmount();i++)
        {
            if(cars[i].borrower==address(msg.sender)&&cars[i].borrowUntil>now)
                count++;
        }
        uint256[] memory carS=new uint256[](count);
        count=0;
        for(uint16 i=0;i<my.getAmount();i++)
        {
            if(cars[i].borrower==address(msg.sender)&&cars[i].borrowUntil>now){
                carS[count]=i;
                count++;
            }
        }
        return carS;
    }

    function GetOwner(uint256 CAR) external returns(address){
        if (CAR>=my.getAmount()){
            return address(0);
        }
        return cars[CAR].owner;
    }

    function GetBorrower(uint256 CAR,uint64 now) external returns(address){
        if (CAR>=my.getAmount()){
            return address(0);
        }
        if(cars[CAR].borrower==address(0)||cars[CAR].borrowUntil<now){
            return address(0);
        }
        return cars[CAR].borrower;
    }

    function BorrowCar(uint256 car, uint64 now,uint64 duration) external returns(bool,string memory){
        if(my.getAmount()<=car)
            return (false,"there is no such car");
        else if(cars[car].borrowUntil>=now)
            return (false,"this car has been borrowed");
        else{
            cars[car].borrowUntil=now+duration;
            cars[car].borrower=msg.sender;
            return (true,"borrow successfully");
        }
    }

    function GetaCar() public {
        my.airdrop(msg.sender);
        Car memory car;
        car.owner=msg.sender;
        car.borrower=address(0);
        car.borrowUntil=0;
        cars[my.getAmount()-1]=car;
    }
    // ...
    // TODO add any logic if you want
}