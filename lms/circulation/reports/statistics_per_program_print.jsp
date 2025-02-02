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
	
	var obj = document.getElementById('myTable4');
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
								"LMS-CIRCULATION-REPORTS","statistics_per_program_print.jsp");
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
														"LIB_Circulation","REPORTS",request.getRemoteAddr(),
														"statistics_per_program_print.jsp");
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


iStart = Integer.parseInt(WI.fillTextValue("sy_year_from"));
iLimit = iStart + 5;

	
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
							vRetResult.addElement(null);// [2] school year            1
							//first sem							
							vRetResult.addElement(null);// [3] semester	    		  2
							vRetResult.addElement("0"); // [4] student population.    3
							vRetResult.addElement("0");	// [5] no. of borrower		  4
							vRetResult.addElement("0");	// [6] books used.			  5
							//second sem							
							vRetResult.addElement(null);// [7] semester		   		  6		
							vRetResult.addElement("0"); // [8] student population.	  7
							vRetResult.addElement("0");	// [9] no. of borrower		  8
							vRetResult.addElement("0");	// [10] books used.			  9					
							//summer							
							vRetResult.addElement(null);// [11] semester			  10			
							vRetResult.addElement("0"); // [12] student population.   11
							vRetResult.addElement("0");	// [13] no. of borrower	      12
							vRetResult.addElement("0");	// [14] books used.	          13
							
							//Year 2
							vRetResult.addElement(null);// [15] school year 		  14  
							//first sem							
							vRetResult.addElement(null);// [16] semester				  15			
							vRetResult.addElement("0"); // [17] student population.    16
							vRetResult.addElement("0");	// [18] no. of borrower		  17
							vRetResult.addElement("0");	// [19] books used.			  18
							//second sem							
							vRetResult.addElement(null);// [20] semester				  19			
							vRetResult.addElement("0"); // [21] student population.    20
							vRetResult.addElement("0");	// [22] no. of borrower	      21
							vRetResult.addElement("0");	// [23] books used.			  22					
							//summer							
							vRetResult.addElement(null);// [24] semester			  23	
							vRetResult.addElement("0"); // [25] student population.   24
							vRetResult.addElement("0");	// [26] no. of borrower	      25
							vRetResult.addElement("0");	// [27] books used.	          26
							
							//Year 3
							vRetResult.addElement(null);// [28] school year 			  27
							//first sem							
							vRetResult.addElement(null);// [29] semester				  28	
							vRetResult.addElement("0"); // [30] student population.    29
							vRetResult.addElement("0");	// [31] no. of borrower	      30
							vRetResult.addElement("0");	// [32] books used.	          31
							//second sem							
							vRetResult.addElement(null);// [33] semester				  32	
							vRetResult.addElement("0"); // [34] student population.    33
							vRetResult.addElement("0");	// [35] no. of borrower	      34
							vRetResult.addElement("0");	// [36] books used.		      35						
							//summer							
							vRetResult.addElement(null);// [37] semester			  36		
							vRetResult.addElement("0"); // [38] student population.   37
							vRetResult.addElement("0");	// [39] no. of borrower	      38
							vRetResult.addElement("0");	// [40] books used.	          39
							
							//Year 4
							vRetResult.addElement(null);// [41] school year 			  40
							//first sem							
							vRetResult.addElement(null);// [42] semester				  41	
							vRetResult.addElement("0"); // [43] student population.    42
							vRetResult.addElement("0");	// [44] no. of borrower	      43
							vRetResult.addElement("0");	// [45] books used.			  44
							//second sem							
							vRetResult.addElement(null);// [46] semester				  45
							vRetResult.addElement("0"); // [47] student population.    46
							vRetResult.addElement("0");	// [48] no. of borrower		  47
							vRetResult.addElement("0");	// [49] books used.			  48				
							//summer							
							vRetResult.addElement(null);// [50] semester			  49	
							vRetResult.addElement("0"); // [51] student population.   50
							vRetResult.addElement("0");	// [52] no. of borrower	      51
							vRetResult.addElement("0");	// [53] books used.		   	  52
							
							//Year 5
							vRetResult.addElement(null);// [54] school year			  53
							//first sem							
							vRetResult.addElement(null);// [55] semester				  54
							vRetResult.addElement("0"); // [56] student population.    55
							vRetResult.addElement("0");	// [57] no. of borrower	      56
							vRetResult.addElement("0");	// [58] books used.	          57
							//second sem							
							vRetResult.addElement(null);// [59] semester			      58		
							vRetResult.addElement("0"); // [60] student population.    59
							vRetResult.addElement("0");	// [61] no. of borrower	 	  60
							vRetResult.addElement("0");	// [62] books used.			  61					
							//summer							
							vRetResult.addElement(null);// [63] semester			  62	
							vRetResult.addElement("0"); // [64] student population.   63
							vRetResult.addElement("0");	// [65] no. of borrower	      64
							vRetResult.addElement("0");	// [66] books used.			  65
							
								
						} 	
						rs.close();					
						
	

iSem = 0;
iPopulation = 0;
iYear = 1;

int iFirstSem = 0;
int iFirstPop = 0;

int iSecondSem = 0;
int iSecondPop = 0;

int iSummer = 0;
int iSummerPop = 0;

int iPrevSem = 0;
int iPrevPop = 0;

for(int i=iStart; i < iLimit; i++){
	strSQLQuery="select course_offered.course_code,STUD_CURRICULUM_HIST.sy_from,STUD_CURRICULUM_HIST.semester,STUD_CURRICULUM_HIST.course_index,count(*) "+ 
			" from STUD_CURRICULUM_HIST "+
			" join course_offered on (course_offered.course_index=stud_curriculum_hist.course_index) "+
			" where STUD_CURRICULUM_HIST.is_valid =1 and sy_from = "+i+" and course_offered.c_index="+WI.fillTextValue("college_name")+" "+
			" and course_offered.degree_type=0 group by STUD_CURRICULUM_HIST.course_index,semester,sy_from,course_code "+
			" order by semester,sy_from";
			
			rs = dbOP.executeQuery(strSQLQuery);
			
			
			while(rs.next()){
				iIndexOf = vRetResult.indexOf(rs.getString(1));				
				
				if (iIndexOf == -1)
					continue;	
					
				if((strSYFrom == null && strSemester == null && strCollegeIndex == null)){										
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);					
					
					iYear = 2;	
								
					if(strSemester.equals("1")){						
						iFirstSem = 3;
						iFirstPop = 4;
						iSem = iFirstSem;
						iPopulation = iFirstPop;
					}else if(strSemester.equals("2")){						
						iSecondSem = 7;
						iSecondPop = 8;
						iSem = iSecondSem;
						iPopulation = iSecondPop;						
					}else{						
						iSummer  = 11;
						iSummerPop = 12;
						iSem = iSummer;
						iPopulation = iSummerPop;							
					}	
				
				}else if(!strSYFrom.equals(rs.getString(2))){					
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
					
					iYear += 13;
					iFirstSem += 13;
					iFirstPop += 13;
					iSecondSem += 13;
					iSecondPop += 13;
					iSummer  += 13;
					iSummerPop += 13;
					
					if(strSemester.equals("1")){
						iSem = iFirstSem;
						iPopulation = iFirstPop;
					}else if(strSemester.equals("2")){
						iSem = iSecondSem;
						iPopulation = iSecondPop;	
					}else{					
						iSem = iSummer;
						iPopulation = iSummerPop;	
					}
					
					iPrevSem = iSem;		
					iPrevPop = iPopulation;		
				}else if(strSYFrom.equals(rs.getString(2)) && !strSemester.equals(rs.getString(3)) && !strCollegeIndex.equals(rs.getString(4))){					
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
					
					//they are in the first loop/first year.
					if(iPrevSem == 0 && iPrevPop ==0){
						if(strSemester.equals("1")){						
							iFirstSem = 3;
							iFirstPop = 4;
							iSem = iFirstSem;
							iPopulation = iFirstPop;
						}else if(strSemester.equals("2")){						
							iSecondSem = 7;
							iSecondPop = 8;
							iSem = iSecondSem;
							iPopulation = iSecondPop;						
						}else{						
							iSummer  = 11;
							iSummerPop = 12;
							iSem = iSummer;
							iPopulation = iSummerPop;							
						}	
					}else{						
						if(strSemester.equals("1")){													
							iSem = iFirstSem;
							iPopulation = iFirstPop;
						}else if(strSemester.equals("2")){													
							iSem = iSecondSem;
							iPopulation = iSecondPop;						
						}else{
							iSem = iSummer;
							iPopulation = iSummerPop;							
						}					
					}
				}else if(strSYFrom.equals(rs.getString(2)) && strSemester.equals(rs.getString(3)) && !strCollegeIndex.equals(rs.getString(4))){					
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);					
				}else{					
					continue;
				}
				
				
				vRetResult.setElementAt(rs.getString(2), (iIndexOf + iYear)); //school year						
				vRetResult.setElementAt(rs.getString(3), (iIndexOf + iSem)); //semester
				vRetResult.setElementAt(rs.getString(5), (iIndexOf + iPopulation)); // student population.	
				
				
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
					
				if( (strSYFrom == null && strSemester == null && strCollegeIndex==null) ||
					(!strSYFrom.equals(rs.getString(2))) ||
					(strSYFrom.equals(rs.getString(2)) && strSemester.equals(rs.getString(3)) && !strCollegeIndex.equals(rs.getString(4))) ){					
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
				
					iBooksCount = rs.getInt(5);
					iBorrowerCount = 1;				
				}else if(strSYFrom.equals(rs.getString(2)) && strSemester.equals(rs.getString(3)) && strCollegeIndex.equals(rs.getString(4))){					
					strSYFrom = rs.getString(2);
					strSemester = rs.getString(3);
					strCollegeIndex = rs.getString(4);
					
					iBooksCount += rs.getInt(5);
					iBorrowerCount++;
				}else{
					continue;
				}
					
				vRetResult.setElementAt(Integer.toString(iBooksCount), (iIndexOf + iIndexYear + 4)); //books used
				vRetResult.setElementAt(Integer.toString(iBorrowerCount), (iIndexOf + iIndexYear + 3)); // borrower count	

			}
			rs.close();
}	

	

}

%>
<form action="./statistics_per_program_print.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          LIBRARY STATISTICS REPORT ::::</strong></font></div></td>
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
	<tr><td align="center" height="20"><%=WI.fillTextValue("college")%></td></tr>
	<tr><td align="center" height="20">Utilization of Library Materials</td></tr>	
</table>
  
  
   	
 
   
   
<%

String strTemp2 = null;

String strBorrower = null;
String strBooksUsed = null;
String strPopulation = null;
String strPercent = "";


int iPercentage = 0;
int iIndex=0;
int iLineCount = 0;

boolean bolIsPageBreak = false;
String[] astrConverSem = {"","1st Sem","2nd Sem","3rd Sem"};
	//while(vRetResult.size() >0)
	strTemp = null;
%>

	



<%
int iResultSize = 67;
int k =0;
while(iResultSize <= vRetResult.size()){
	iLineCount = 0;
	%>
	
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   
		<tr>
			<td rowspan="2" align="center" class="thinborder">Year<br/>School</td>
			<%for(int i=iStart,x=0; i < iLimit; i++,x++){%>
			<td class="thinborder" width="100" colspan="2" align="center"><%=iStart+x%>-<%=iStart+x+1%></td>
			<td class="thinborder" width="50" rowspan="2" align="center">Pop.</td>
			<td class="thinborder" width="50" rowspan="2" align="center">%</td>
			<%}%>
		</tr>	
		<tr>
			<%for(int i = iStart; i < iLimit; i++){%>
			<td class="thinborder" width="50" align="center"># of borrower</td>
			<td class="thinborder" width="50" align="center">Books Used</td>
			<%}%>
		</tr>


<%
		for(;k < vRetResult.size();){//this loop every course.		
		iLineCount++;
		iResultSize += 67;
		
		%>
		
			<%for(int x=0;x<16;x+=4){//this loop is for the course name,1st sem,2nd sem,summer
			
			%>
			<tr>
				<%if(x==0){
					strTemp = (String)vRetResult.elementAt(k);
					strTemp2 = "align=\"left\" style=\"font-weight:bold\"";
					}
				  else{
					strTemp = astrConverSem[x/4];
					strTemp2 = "align=\"right\"";
					}
				%>
				<td <%=strTemp2%> class="thinborder"><%=strTemp%></td>		
				
					<%
					strTemp2 = "";
					for(int i=k+2; i < k+67; i+=13){
									
						if(x==0){
							strTemp2 = "&nbsp;";
							strBorrower = "";
							strBooksUsed = "";
							strPopulation = "";
						}
						else{
							//get sem
							strTemp2 = (String)vRetResult.elementAt(i+(x-4)+1);
							if(strTemp2 != null){
								if(strTemp2.compareTo("1")==0){							
									iIndex = i+1;
									strBorrower = (String)vRetResult.elementAt(i+(x-4)+3);
									strBooksUsed = (String)vRetResult.elementAt(i+(x-4)+4);
									strPopulation = (String)vRetResult.elementAt(i+(x-4)+2);
									iPercentage = (Integer.parseInt(strBorrower)/Integer.parseInt(strPopulation)*100);
								}
								else if(strTemp2.compareTo("2")==0){
									iIndex = 3;
									strBorrower = (String)vRetResult.elementAt(i+(x-4)+3);
									strBooksUsed = (String)vRetResult.elementAt(i+(x-4)+4);
									strPopulation = (String)vRetResult.elementAt(i+(x-4)+2);
									iPercentage = (Integer.parseInt(strBorrower)/Integer.parseInt(strPopulation)*100);
								}else{
									iIndex = 3;
									strBorrower = (String)vRetResult.elementAt(i+(x-4)+3);
									strBooksUsed = (String)vRetResult.elementAt(i+(x-4)+4);
									strPopulation = (String)vRetResult.elementAt(i+(x-4)+2);
									iPercentage = (Integer.parseInt(strBorrower)/Integer.parseInt(strPopulation)*100);
								}
								
								if(iPercentage > 100)
									strPercent = "100";
								else
									strPercent = Integer.toString(iPercentage);
									
							}else
								strTemp2 = "";
						}
							
					%>
					
						<td align="center" class="thinborder">&nbsp;<%=strBorrower%></td>
						<td align="center" class="thinborder">&nbsp;<%=strBooksUsed%></td>
						<td align="center" class="thinborder">&nbsp;<%=strPopulation%></td>
						<td align="center" class="thinborder">&nbsp;<%=strPercent%></td>
					<%}//end for(int i = iStart; i < iLimit; i++)%>
			</tr>
			
			<%}%>
			
			<%
				k+=67;
				if(iLineCount > 8){
					bolIsPageBreak = true;		
					break;				
				}else
					bolIsPageBreak = false;	
			%>
			
		<%}%>	
		
	</table>	
	
	
		<%if(bolIsPageBreak){%>
			<div style="page-break-after:always">&nbsp;</div>
	<%}
	
}%>
	
   
   
 
 
<%}//only if vRetResult is not null%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable4">
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