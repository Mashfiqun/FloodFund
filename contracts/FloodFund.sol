// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FloodFund {
    // replace the addresses from your REMIX IDE | here public can also be used
    address payable private fundraiserSylhet = payable(0x8B70BC92020C31414040BFe72d637dC2F2c0cC22);
    address payable private fundraiserCtgNorth = payable(0xc16A0Ba232456b01236e5B083652B35fb0775Eca);
    address payable private fundraiserCtgSouth = payable(0x590CBB6d83b5782F5208eCCa13741180ddA92865);

    struct Donor {
        string name;
        string mobileNumber;
    }

    struct Balance{
        uint256 sylhet;
        uint256 ctgNorth;
        uint256 ctgSouth;
        uint256 total;
    }

    mapping ( address => Donor ) donorList;

    // if false, the function will revert and the message in string mentioned will be thrown | if true the function continues to execute 
    modifier exceptFundreiser() {
        require(
            msg.sender != fundraiserSylhet &&
            msg.sender != fundraiserCtgNorth &&
            msg.sender != fundraiserCtgSouth,
            "Your account is a fundraiser account. Please use a non-fundreiser account."
        );
        _;
    }

    // registering the donor | the the beginning of the function call the exceptFundreiser will be executed to check its condition
     function registerDonor(string memory _name, string memory _mobileNumber) public exceptFundreiser {
        require(bytes(_name).length != 0, "Please provide name.");
        require(bytes(_mobileNumber).length != 0, "Please provide mobile number.");
        donorList[msg.sender] = Donor(_name, _mobileNumber);
    }

    // donate function | The require will check if the condition is false, the function will revert and the string message will be thrown, else continue
    function donate(string memory _fundraiserZone, string memory _mobileNumber) public payable {
        require(bytes(_mobileNumber).length != 0, "Please provide the mobile number" );
        require(keccak256(abi.encodePacked(donorList[msg.sender].mobileNumber)) == keccak256(abi.encodePacked(_mobileNumber)), "Mobile Number not matched or not registered.");


        if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("sylhet"))) {
            fundraiserSylhet.transfer(msg.value);
        } 
        else if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("chittagong-south"))) {
            fundraiserCtgNorth.transfer(msg.value);
        } 
        else if (keccak256(abi.encodePacked(_fundraiserZone)) == keccak256(abi.encodePacked("chittagong-north"))) {
            fundraiserCtgSouth.transfer(msg.value);
        } 
        else{
            revert("Unavailable zone");
        }
    }

    // getting all of the individual and total balance  
    function showTotal() public view returns (string memory, uint, string memory, uint, string memory, uint, string memory, uint) {
        // Divided by one ether to make the output a little bit more visible.
        return ("Sylhet", fundraiserSylhet.balance, "CtgSouth", fundraiserCtgNorth.balance, "CtgNorth", fundraiserCtgSouth.balance, "Total", (fundraiserSylhet.balance + fundraiserCtgNorth.balance + fundraiserCtgSouth.balance));
    }

    // getting donor info
    function getDonorInfoByAddress(address _donorAddress) public view returns (string memory, string memory) {
        require(bytes(donorList[_donorAddress].name).length != 0 || bytes(donorList[_donorAddress].mobileNumber).length != 0, "Address not registered" );
        //  the above require here is optional and it is to check if the address is registered or not. but it is, optional 
        return (donorList[_donorAddress].name, donorList[_donorAddress].mobileNumber);
    }

}