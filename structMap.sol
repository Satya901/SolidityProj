pragma solidity ^0.5.0;

contract studentMarks{

    //global declearation 
    address pAdd;

    struct studentMarksStructure {
        uint[] subjectList;
        mapping (uint => uint) subjectMarks;
        bool grade;

    }
    
    // studentID => studentMarksStructure
    mapping (address => studentMarksStructure) studentReport;

    // event declreation 
     event eAddStudentSubjectMark(address studentId, uint subjectId,  uint _marks) ;
     event etMark(address studentId,  uint _tmarks) ;

   // modifier declearation 
   modifier mCheckStudent(address studentId)  {
       require(pAdd == msg.sender || studentId == msg.sender, "You are not authorised.");
       //require(studentId == msg.sender, "You are not authorised.");
       _;
   }

       modifier mIsPrinciple {
        require(msg.sender == pAdd, "Your role is not recognised as a principle");
        _;
    }

    // constructor
        constructor() public {
    //    constructor()  {
        pAdd = msg.sender;
    }

    // function set student subject marks
        function setStudentMarks(address _studentId, uint _subjectId, uint _marks) public{
          studentReport[_studentId].subjectList.push(_subjectId);
          studentReport[_studentId].subjectMarks[_subjectId] = _marks;

          emit  eAddStudentSubjectMark(_studentId, _subjectId, _marks) ;
        }


    //function getstudent marks
        function getStudentMarks(address _studentId , uint _subjectId) public view returns(uint) {
            return studentReport[_studentId].subjectMarks[_subjectId];

        }
      
      function getTotalMarks(address _studentId) public mCheckStudent(_studentId) returns(uint){
          uint length = studentReport[_studentId].subjectList.length;
          uint totalMarks = 0;
      
          for(uint i = 0 ; i < length ; i++ ){
              
              totalMarks = studentReport[_studentId].subjectMarks[studentReport[_studentId].subjectList[i]] 
              + totalMarks;
          }
            emit etMark( _studentId,  totalMarks) ;
            return totalMarks ;
           }

      function addGrade (address _studentId) public mIsPrinciple returns(bool){
          uint totalMarks = getTotalMarks(_studentId);
          // let consider one student appear in two exams 
          if(totalMarks >= 120){
              studentReport[_studentId].grade = true;

          }
          return studentReport[_studentId].grade ;

      }



}