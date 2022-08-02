pragma solidity ^0.5.0;

contract collegeRating{

  //global variable
  address cAdd;


  struct ratingStruct{
          uint[] deptId;
          mapping(uint => uint) rating;
          mapping(uint => string) dName;
          uint avgRating;
          
        }  
  
  mapping (address => ratingStruct) cRating;

  constructor() public{

    cAdd = msg.sender;
  }

  // event declearation 
  // event are used to print message in log
   event enterRating(address collegeAddress,uint dId, uint _rating);

    // modifier declearation 
    // same college should not give rating to itself
   modifier mCheckCollege(address collegeAddress)  {
       //require(cAdd == msg.sender || studentId == msg.sender, "You are not authorised.");
       require(collegeAddress != msg.sender, "Same College can't give rating to itself.");
       _;
   }

   modifier mCheckId(uint mId)  {
       //require(cAdd == msg.sender || studentId == msg.sender, "You are not authorised.");
       require( (mId != 0 && mId <= 3) , "College ID should be  between 1 to 3.");
       _;
   }

      modifier mCheckRating(uint rating)  {
       require( (rating > 0 && rating <= 10) , "Please give rating between 1 to 10.");
       _;
   }

      modifier mCheckName(address _collegeAddress, uint _deptId  )  { 
        string memory mName = cRating[_collegeAddress].dName[_deptId] ;
       require( (bytes(mName).length == bytes('LAW').length  || 
                 bytes(mName).length == bytes('BBA').length  || 
                 bytes(mName).length == bytes('MBA').length  ) , 
                 "Valid Department Name are MBA , BBA or LAW") ;
       _;
   }

  function setRating(address _collegeAddress, uint _deptId , string memory _dName  , uint _rating )
     public mCheckCollege(_collegeAddress) 
     mCheckId(_deptId) 
     mCheckRating(_rating)
    // mCheckName(_collegeAddress, _deptId  )
     {
       cRating[_collegeAddress].deptId.push(_deptId);
       cRating[_collegeAddress].rating[_deptId] = _rating;
       cRating[_collegeAddress].dName[_deptId] = _dName;
      
       emit enterRating(_collegeAddress, _deptId, _rating );
       

     }


    function getDeptRating(address _collegeAddress, uint _deptId )
     public  mCheckId(_deptId) view returns(  string memory, uint){
     

     return ( 
              cRating[_collegeAddress].dName[_deptId] ,
              cRating[_collegeAddress].rating[_deptId] 
            );
     }

     function getCollageRating(address _collegeAddress ) public view returns(uint , uint)
     {
       uint length ; uint  temp ;
       uint collRating = 0;
       
       length = cRating[_collegeAddress].deptId.length ;


       for (uint i = 0 ; i < length ; i++){
            temp =  cRating[_collegeAddress].deptId[i];
            collRating = cRating[_collegeAddress].rating[temp] + collRating ;
            
       }

      // result = "Number of college are  "  length  ;
        collRating = collRating / length ;
       return   ( length , collRating ) ;

     }

}
