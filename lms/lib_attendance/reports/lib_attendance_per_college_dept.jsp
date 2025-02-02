<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function submitForm() {
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	document.getElementById('myTable3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
	

	

}
function ReloadPage()
{
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}

function GenerateReport(){
	var date = new Date();	
	var year = date.getFullYear(); 
	
	var value = year - document.form_.sy_year_from.value
	if(value < 4){
		alert("School year must be less than 5 years from todays year.");
		return;
	}
	document.form_.college.value = document.form_.college_name[document.form_.college_name.selectedIndex].text;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary","enrolment_summary.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrolment_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";//for UI, the detrails are different from others. UI adds elementary details.
	
//I have to get if this is per college or per course program.
boolean bolIsGroupByCollege = WI.getStrValue(WI.fillTextValue("g_by"), "1").equals("2");


ReportEnrollment reportEnrollment = new ReportEnrollment();

Vector vRetResult = new Vector();
Vector vCollegeIndex = new Vector();


String strSQLQuery     = null;
String strCollegeIndex = null;
String strUserIndex    = null;
String strCollegeCode  = null;
String strSYFrom  	   = null;
String strSemester     = null;


java.sql.ResultSet rs  = null;

int iIndexOf = 0;



int iStart 	  = 0;
int iLimit 	  = 0;

int iSem 	  = 0; 
int iPopulation = 0; 
int iYear = 0;

if(WI.fillTextValue("sy_year_from").length() > 0  && WI.fillTextValue("reloadPage").compareTo("1") !=0)
{			
	//vRetResult = reportEnrollment.getEnrollmentSummary(dbOP, request);
	//if(vRetResult == null || vRetResultBasic ==null)
	//	strErrMsg = reportEnrollment.getErrMsg();

iStart = Integer.parseInt(WI.fillTextValue("sy_year_from"));
iLimit = iStart + 5;

	//for(int i = iStart; i < iLimit; i++){
		strSQLQuery = "select course_code,course_index from course_offered "+
				" where is_del=0 and is_valid=1 and is_offered=1 and degree_type=0 and is_visible=1 and c_index="+WI.fillTextValue("college_name")+" "+
				" and exists(select * from STUD_CURRICULUM_HIST "+
				" where is_valid=1 and sy_from >= "+WI.fillTextValue("sy_year_from")+" and sy_from <= "+iLimit+" "+
				" and STUD_CURRICULUM_HIST.course_index=course_offered.course_index) "+
				" group by course_code,course_index order by course_code";
	
						rs = dbOP.executeQuery(strSQLQuery);
				
						while(rs.next()) {							
							vRetResult.addElement(rs.getString(1)); // [0] course_index
							vRetResult.addElement(rs.getString(2)); // [1] course_code	
							//Year 1
							vRetResult.addElement(null);// [2] school year              
							//first sem							
							vRetResult.addElement(null);// [3] semester	    		    
							vRetResult.addElement("0"); // [4] student population.      
							vRetResult.addElement("0");	// [5] faculty		  		    
							
							//second sem							
							vRetResult.addElement(null);// [6] semester	    		    
							vRetResult.addElement("0"); // [7] student population.    	
							vRetResult.addElement("0");	// [8] faculty		  		  				
							//summer							
							vRetResult.addElement(null);// [9] semester	    		    
							vRetResult.addElement("0"); // [10] student population.     
							vRetResult.addElement("0");	// [11] faculty		  		    
							
							//Year 2
							vRetResult.addElement(null);// [12] school year 		      
							//first sem							
							vRetResult.addElement(null);// [13] semester	    		
							vRetResult.addElement("0"); // [14] student population.     
							vRetResult.addElement("0");	// [15] faculty		  		    
							//second sem							
							vRetResult.addElement(null);// [16] semester	    		
							vRetResult.addElement("0"); // [17] student population.     
							vRetResult.addElement("0");	// [18] faculty		  		  					
							//summer							
							vRetResult.addElement(null);// [19] semester	    		
							vRetResult.addElement("0"); // [20] student population.     
							vRetResult.addElement("0");	// [21] faculty		  		  	
							
							//Year 3
							vRetResult.addElement(null);// [22] school year 			
							//first sem							
							vRetResult.addElement(null);// [23] semester	    		
							vRetResult.addElement("0"); // [24] student population.    	
							vRetResult.addElement("0");	// [25] faculty		  		  	
							//second sem							
							vRetResult.addElement(null);// [26] semester	    		
							vRetResult.addElement("0"); // [27] student population.    	
							vRetResult.addElement("0");	// [28] faculty		  		  						
							//summer							
							vRetResult.addElement(null);// [29] semester	    		
							vRetResult.addElement("0"); // [30] student population.     
							vRetResult.addElement("0");	// [31] faculty		  		  	
							
							//Year 4
							vRetResult.addElement(null);// [32] school year 			
							//first sem							
							vRetResult.addElement(null);// [33] semester	    		
							vRetResult.addElement("0"); // [34] student population.     
							vRetResult.addElement("0");	// [35] faculty		  		    
							//second sem							
							vRetResult.addElement(null);// [36] semester	    		
							vRetResult.addElement("0"); // [37] student population.     
							vRetResult.addElement("0");	// [38] faculty		  		    		
							//summer							
							vRetResult.addElement(null);// [39] semester	    		
							vRetResult.addElement("0"); // [40] student population.     
							vRetResult.addElement("0");	// [41] faculty		  		    
							
							//Year 5
							vRetResult.addElement(null);// [42] school year			    
							//first sem							
							vRetResult.addElement(null);// [43] semester	    		
							vRetResult.addElement("0"); // [44] student population.     
							vRetResult.addElement("0");	// [45] faculty		  		    
							//second sem							
							vRetResult.addElement(null);// [46] semester	    		
							vRetResult.addElement("0"); // [47] student population.     
							vRetResult.addElement("0");	// [48] faculty		  		    
							//summer							
							vRetResult.addElement(null);// [49] semester	    		
							vRetResult.addElement("0"); // [20] student population.    
							vRetResult.addElement("0");	// [51] faculty		  		  
							
								
						} 	
						rs.close();					
						
		//}
		
	//System.out.println("vRetResult "+vRetResult);
	

//count the number of population per course

iSem = 0;
iYear = 1;
int iStud = 0;

int iFirstSem = 0;
int iFirstStud = 0;

int iSecondSem = 0;
int iSecondStud = 0;

int iSummer = 0;
int iSummerStud = 0;

int iPrevSem = 0;
int iPrevStud = 0;

for(int i=iStart; i < iLimit; i++){
	strSQLQuery="select course_offered.course_code,course_offered.course_index,lms_attendance.sy_from,lms_attendance.semester,count(*) "+
					" from lms_attendance "+
					" join stud_curriculum_hist on (stud_curriculum_hist.user_index=lms_attendance.user_index) "+
					" join course_offered on (course_offered.course_index=stud_curriculum_hist.course_index) "+
					" where lms_attendance.sy_from="+i+" and course_offered.c_index="+WI.fillTextValue("college_name")+" "+
					" group by lms_attendance.user_index,course_offered.course_index,course_code,lms_attendance.sy_from,lms_attendance.semester "+
					" order by lms_attendance.sy_from,lms_attendance.semester";
			
			rs = dbOP.executeQuery(strSQLQuery);
			
			
			while(rs.next()){
				iIndexOf = vRetResult.indexOf(rs.getString(1));				
				if (iIndexOf == -1)
					continue;	
					
				if((strSYFrom == null && strSemester == null && strCollegeIndex == null)){										
					strSYFrom = rs.getString(3);
					strSemester = rs.getString(4);
					strCollegeIndex = rs.getString(2);					
					
					iYear = 2;	
								
					if(strSemester.equals("1")){						
						iFirstSem = 3;
						iFirstStud = 4;
						iSem = iFirstSem;
						iStud = iFirstStud;
					}else if(strSemester.equals("2")){						
						iSecondSem = 6;
						iSecondStud = 7;
						iSem = iSecondSem;
						iStud = iSecondStud;						
					}else{						
						iSummer  = 9;
						iSummerStud = 10;
						iSem = iSummer;
						iStud = iSummerStud;							
					}	

					vRetResult.setElementAt(rs.getString(3), (iIndexOf + iYear)); //school year					
					vRetResult.setElementAt(rs.getString(4), (iIndexOf + iSem)); //semester
					vRetResult.setElementAt(rs.getString(5), (iIndexOf + iStud)); // student population.
									
				}else if(!strSYFrom.equals(rs.getString(3))){					
					strSYFrom = rs.getString(3);
					strSemester = rs.getString(4);
					strCollegeIndex = rs.getString(2);
					
					iYear += 10;
					iFirstSem += 10;
					iFirstStud += 10;
					iSecondSem += 10;
					iSecondStud += 10;
					iSummer  += 10;
					iSummerStud += 10;
					
					if(strSemester.equals("1")){
						iSem = iFirstSem;
						iStud = iFirstStud;
					}else if(strSemester.equals("2")){
						iSem = iSecondSem;
						iStud = iSecondStud;	
					}else{					
						iSem = iSummer;
						iStud = iSummerStud;	
					}
					
					iPrevSem = iSem;		
					iPrevStud = iStud;											
					
					vRetResult.setElementAt(rs.getString(3), (iIndexOf + iYear)); //school year					
					vRetResult.setElementAt(rs.getString(4), (iIndexOf + iSem)); //semester
					vRetResult.setElementAt(rs.getString(5), (iIndexOf + iStud)); // student population.
				
				
				}else if(strSYFrom.equals(rs.getString(3)) && !strSemester.equals(rs.getString(4)) && !strCollegeIndex.equals(rs.getString(2))){					
					strSYFrom = rs.getString(3);
					strSemester = rs.getString(4);
					strCollegeIndex = rs.getString(2);
					
					//they are in the first loop/first year.
					if(iPrevSem == 0 && iPrevStud ==0){
						if(strSemester.equals("1")){						
							iFirstSem = 3;
							iFirstStud = 4;
							iSem = iFirstSem;
							iStud = iFirstStud;
						}else if(strSemester.equals("2")){						
							iSecondSem = 6;
							iSecondStud = 7;
							iSem = iSecondSem;
							iStud = iSecondStud;						
						}else{						
							iSummer  = 9;
							iSummerStud = 10;
							iSem = iSummer;
							iStud = iSummerStud;						
						}	
					}else{						
						if(strSemester.equals("1")){													
							iSem = iFirstSem;
							iStud = iFirstStud;
						}else if(strSemester.equals("2")){													
							iSem = iSecondSem;
							iStud = iSecondStud;						
						}else{
							iSem = iSummer;
							iStud = iSummerStud;							
						}					
					}
					
					vRetResult.setElementAt(rs.getString(3), (iIndexOf + iYear)); //school year							
					vRetResult.setElementAt(rs.getString(4), (iIndexOf + iSem)); //semester
					vRetResult.setElementAt(rs.getString(5), (iIndexOf + iStud)); // student population.
					
				}else if(strSYFrom.equals(rs.getString(3)) && strSemester.equals(rs.getString(4)) && !strCollegeIndex.equals(rs.getString(2))){					
					strSYFrom = rs.getString(3);
					strSemester = rs.getString(4);
					strCollegeIndex = rs.getString(2);
					
					vRetResult.setElementAt(rs.getString(3), (iIndexOf + iYear)); //school year						
					vRetResult.setElementAt(rs.getString(4), (iIndexOf + iSem)); //semester
					vRetResult.setElementAt(rs.getString(5), (iIndexOf + iStud)); // student population.	
					
				}else{					
					continue;
				}
				
			}
			rs.close();			
}	



	
strSYFrom = null;
strSemester = null;
strCollegeIndex = null;
strUserIndex = null;

int iBooksCount = 0;
int iBorrowerCount = 0;



for(int i=iStart; i < iLimit; i++){	
			
	strSQLQuery = "select course_offered.course_code,STUD_CURRICULUM_HIST.sy_from,STUD_CURRICULUM_HIST.semester,course_offered.course_index,count(*) from lms_book_issue "+
		" join stud_curriculum_hist on(stud_curriculum_hist.user_index=lms_book_issue.user_index) "+
		" join course_offered on(course_offered.course_index=stud_curriculum_hist.course_index) "+
		" where c_index="+WI.fillTextValue("college_name")+" and course_offered.degree_type=0 and lms_book_issue.sy_from="+i+" "+
		" and STUD_CURRICULUM_HIST.sy_from="+i+" group by lms_book_issue.user_index,course_offered.course_index,STUD_CURRICULUM_HIST.sy_from,STUD_CURRICULUM_HIST.semester, "+
		" course_code order by STUD_CURRICULUM_HIST.sy_from,STUD_CURRICULUM_HIST.semester,course_offered.course_index";
			
			rs = dbOP.executeQuery(strSQLQuery);	
				
			int iIndexYear = vRetResult.indexOf(Integer.toString(i));
							
			if (iIndexYear == -1)			
				continue;
			while(rs.next()){	
				
				iIndexOf = vRetResult.indexOf(rs.getString(1));								
				if (iIndexOf == -1)
					continue;
					
				
					
				//if(!Integer.toString(i).equals(vRetResult.elementAt(iIndexYear)))					
				//	continue;
				
				if(strSYFrom == null && strSemester == null && strCollegeIndex==null){
					//System.out.println("a");
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
				
					iBooksCount = rs.getInt(5);
					iBorrowerCount = 1;					
					
					vRetResult.setElementAt(Integer.toString(iBooksCount), (iIndexOf + iIndexYear + 4)); //books used
					vRetResult.setElementAt(Integer.toString(iBorrowerCount), (iIndexOf + iIndexYear + 3)); // borrower count	
					
				}else if(!strSYFrom.equals(rs.getString(2))){
					//System.out.println("b");
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
				
					iBooksCount = rs.getInt(5);
					iBorrowerCount = 1;					
						
					vRetResult.setElementAt(Integer.toString(iBooksCount), (iIndexOf + iIndexYear + 4)); //books used
					vRetResult.setElementAt(Integer.toString(iBorrowerCount), (iIndexOf + iIndexYear + 3)); // borrower count	
									
				}else if(strSYFrom.equals(rs.getString(2)) && strSemester.equals(rs.getString(3)) && !strCollegeIndex.equals(rs.getString(4))){
					//System.out.println("c");
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
					
					iBooksCount = rs.getInt(5);
					iBorrowerCount = 1;					
					
					vRetResult.setElementAt(Integer.toString(iBooksCount), (iIndexOf + iIndexYear + 4)); //books used
					vRetResult.setElementAt(Integer.toString(iBorrowerCount), (iIndexOf + iIndexYear + 3)); // borrower count	
							
				}else if(strSYFrom.equals(rs.getString(2)) && strSemester.equals(rs.getString(3)) && strCollegeIndex.equals(rs.getString(4))){
					//System.out.println("d");
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
					
					iBooksCount += rs.getInt(5);
					iBorrowerCount++;					
							
					vRetResult.setElementAt(Integer.toString(iBooksCount), (iIndexOf + iIndexYear + 4)); //books used
					vRetResult.setElementAt(Integer.toString(iBorrowerCount), (iIndexOf + iIndexYear + 3)); // borrower count	
				}else{				
					//System.out.println("e");
					continue;
				}
					
				

			}
			rs.close();
}	

	//System.out.println("vRetResult "+vRetResult);

}

%>
<form action="lib_attendance_per_college_dept.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          SUMMARY REPORT ON ENROLMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  id="myTable2">
 	<tr>
		<td class="" height="25">&nbsp;</td>
		<td>College :</td>
		<td>
		<%strTemp = WI.fillTextValue("college_name");%>

		<select name="college_name">
			<%=dbOP.loadCombo("C_INDEX","C_NAME"," FROM college where is_del = 0 and " + 
					"exists (select * from course_offered where course_offered.is_valid = 1 and is_offered = 1 and is_visible = 1 " +
					"and course_offered.c_index = college.c_index) order by c_name",strTemp,false)%>
		</select></td>
	</tr>   
	<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="11%" height="25">School year </td>
      <td width="22%" height="25">
	  <select name="sy_year_from">
		<%
		strTemp = WI.fillTextValue("sy_year_from");
		if(strTemp.length() == 0) {
			strTemp = String.valueOf(Integer.parseInt(WI.getTodaysDate(12)) - 4);
		}
		%>
	  
	  	<%=dbOP.loadComboYear(strTemp,8, 0)%>
	  </select>
	  </td>
      
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report"	  
	   onClick="GenerateReport();" >	  </td>
    </tr>

    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
  
  
  
<% 	

if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  id="myTable3">
    <tr>
      <td width="12%" height="25">&nbsp;</td>
      <td align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a> 
        <font size="1">click to print statistics</font></td>
    </tr>
  </table>
	
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  	<tr><td align="center" height="20"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td></tr>
	<tr><td align="center" height="20">Library and Learning Resource Center</td></tr>
	<tr><td align="center" height="20">&nbsp;</td></tr>
	<tr><td align="center" height="20">Attendance Statistics of Library User</td></tr>
	<tr><td align="center" height="20">Students and Faculty</td></tr>	
	<tr><td align="center" height="20">&nbsp;</td></tr>
	<tr><td align="center" height="20"><%=WI.fillTextValue("college")%></td></tr>
	
  </table>
   
 
 	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		
		
		<tr>
			<td class="thinborder" width="10%" rowspan="2">School Year</td>
			<!----mag loop dinhe ang department--->
			<%for(int i=0;i<vRetResult.size();i+=67){%>
			<td class="thinborder" align="center" width="10%" colspan="2"><%=vRetResult.elementAt(i)%></td>
			<%}%>
		</tr>
		<tr>
			<%for(int i=0;i<vRetResult.size();i+=67){%>
			<td align="center" class="thinborder">Student</td>
			<td align="center" class="thinborder">Faculty</td>
			<%}%>
		</tr>
		<tr>
			<td class="thinborder">20007</td>
		</tr>
		
		
		
	</table>
 
<%}//only if vRetResult is not null%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="summary_of_roe" value="<%=WI.fillTextValue("summary_of_roe")%>">
<input type="hidden" name="reloadPage">
<input type="hidden" name="college" value="<%=WI.fillTextValue("college")%>"/>
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>