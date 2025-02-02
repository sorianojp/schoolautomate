<%@ page language="java" import="utility.*,lms.CirculationReport,java.util.Vector" %>
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
	
	var value = year - document.form_.sy_from.value
	if(value < 4){
		alert("School year must be less than 5 years from todays year.");
		return;
	}
	
	document.form_.college.value = document.form_.c_index[document.form_.c_index.selectedIndex].text;	
	document.form_.reloadPage.value = "1";
	document.form_.submit();
}
</script>
<body bgcolor="#D0E19D" topmargin="0" bottommargin="0">
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
								"LMS-CIRCULATION-REPORTS","statistics_per_program_CIT.jsp");
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
														"statistics_per_program_CIT.jsp");
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
	strSchCode = "";
	



CirculationReport CR = new CirculationReport();

Vector vRetResult = new Vector();

if(WI.fillTextValue("reloadPage").equals("1")){
	vRetResult = CR.statisticsPerProgram(dbOP, request);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();
}

%>
<form action="./statistics_per_program_CIT.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#77A251">
      <td width="100%" height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          STATISTICS REPORT PER PROGRAM ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable2">
 	<tr>
		<td class="" height="25" width="6%">&nbsp;</td>
		<td width="15%">College :</td>
		<td colspan="2">
		<%strTemp = WI.fillTextValue("c_index");%>

		<select name="c_index">
			<%=dbOP.loadCombo("C_INDEX","C_NAME"," FROM college where is_del = 0 and " + 
					"exists (select * from course_offered where course_offered.is_valid = 1 and is_offered = 1 and is_visible = 1 " +
					"and course_offered.c_index = college.c_index) order by c_name",strTemp,false)%>
		</select></td>
	</tr>   
	<tr> 
      <td width="" height="25">&nbsp;</td>
      <td width="" height="25">School year </td>
      <td width="" height="25" colspan="2">
	  <select name="sy_from">
		<%
		strTemp = WI.fillTextValue("sy_year_from");
		if(strTemp.length() == 0) {
			strTemp = String.valueOf(Integer.parseInt(WI.getTodaysDate(12)) - 4);
		}
		%>
	  
	  	<%=dbOP.loadComboYear(strTemp,8, 0)%>
	  </select>
	  </td>   
	  <td width="">
	  <input type="button" name="Login" value="Generate Report"	  
	   onClick="GenerateReport();" >	  </td>   
    </tr>
	
	<!--<tr>
		<td height="25">&nbsp;</td>
		<td>REPORT TYPE :</td>
		<td width="30%">
			<select name="report_type">
				<%
				strTemp = WI.fillTextValue("report_type");
				if(strTemp.equals("1")){
				%>
				<option value="1" selected>STUDENT</option>
				<%}else{%>
				<option value="1">STUDENT</option>
				<%}if(strTemp.equals("2")){%>
				<option value="2" selected>FACULTY</option>
				<%}else{%>
				<option value="2">FACULTY</option>
				<%}%>
			</select>
		</td>
		<td width="">
	  <input type="button" name="Login" value="Generate Report"	  
	   onClick="GenerateReport();" >	  </td>
	</tr>
	-->
	
    <tr> 
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
  </table>
  
  
  
  
<%if(vRetResult != null && vRetResult.size() > 0){
	int iYear = Integer.parseInt(WI.fillTextValue("sy_from"));
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable3">
	<tr>
		<td width="12%" height="25">&nbsp;</td>
		<td align="right"><a href="javascript:PrintPg();"><img src="../../images/print_circulation.gif" border="0"></a> 
		<font size="1">click to print report</font></td>
	</tr>
	</table>

<%

String strPrevCourse = "";
String strSYFrom = "";
String strSemester = "";

String strBorrowerCount = "-";
String strBookUsedCount = "-";
String strPopulation = "-";
int iPercentage = 0;

boolean bolIsPageBreak = false;
int iResultSize = 8;
int iLineCount = 0;
int iMaxLineCount = 6;	
int iCount = 0;	
int i = 0;
//System.out.println("vRetResult.size() "+vRetResult.size());
while(iResultSize <= vRetResult.size()){
//System.out.println("iResultSize "+iResultSize);
iLineCount = 0;
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr><td align="center" height="20"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></td></tr>
		<tr><td align="center" height="20">Library and Learning Resource Center</td></tr>
		<tr><td align="center" height="20"><%=WI.fillTextValue("college")%></td></tr>
		<tr><td align="center" height="20">Utilization of Library Materials</td></tr>	
	</table>


	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">	
		<tr>
			<td class="thinborder" rowspan="2" align="center">School Year</td>
			<%for(int ii=iYear; ii < iYear+5; ii++){%>
			<td class="thinborder" width="100" colspan="2" align="center"><%=ii%>-<%=ii+1%></td>
			<td class="thinborder" width="50" rowspan="2" align="center">Pop.</td>
			<td class="thinborder" width="50" rowspan="2" align="center">%</td>
			<%}%>
		</tr>
		
		<tr>			
			<%for(int ii=iYear; ii < iYear+5; ii++){%>
			<td class="thinborder" width="50" align="center"># of borrower</td>
			<td class="thinborder" width="50" align="center">Books Used</td>			
			<%}%>			
		</tr>
		
		
		<%
		
		for(; i < vRetResult.size(); ){		
			strTemp = (String)vRetResult.elementAt(i+1);
			iResultSize += 8;
					
			
		%>
		
		<%if(!strPrevCourse.equals(strTemp)){
			iResultSize += 8;
			iLineCount++;
		%>
		<tr>
			<td class="thinborder"><%=strTemp%></td>
			<td class="thinborder" colspan="20">&nbsp;</td>			
		</tr>
		
		<tr>		
			<td align="right" class="thinborder">1st Sem.</td>
		<%for(int iii=iYear; iii < iYear+5; iii++){%>
			<%for(int ii=0; ii < vRetResult.size(); ii+=8){
				strSYFrom = (String)vRetResult.elementAt(ii+3);
				strSemester = (String)vRetResult.elementAt(ii+4);				
				
				if(((String)vRetResult.elementAt(ii+1)).equals(strTemp) && strSYFrom.equals(iii+"") && strSemester.equals("1")){
					strBorrowerCount = (String)vRetResult.elementAt(ii+5);
					strBookUsedCount = (String)vRetResult.elementAt(ii+6);
					strPopulation = (String)vRetResult.elementAt(ii+7);					
					iPercentage = (Integer.parseInt(strBorrowerCount)/Integer.parseInt(strPopulation))*100;										
					break;
				}else{
					strBorrowerCount = "-";
					strBookUsedCount = "-";
					strPopulation = "-";		
					iPercentage = 0;
					continue;
				}
					
			
			}%>
			<td align="center" class="thinborder"><%=strBorrowerCount%></td>
			<td align="center" class="thinborder"><%=strBookUsedCount%></td>
			<td align="center" class="thinborder"><%=strPopulation%></td>
			<td align="center" class="thinborder"><%=iPercentage%></td>
		<%}%>
		</tr>
		
		
		<tr>			
			<td align="right" class="thinborder">2nd Sem.</td>
		<%for(int iii=iYear; iii < iYear+5; iii++){%>
			<%for(int ii=0; ii < vRetResult.size(); ii+=8){
				strSYFrom = (String)vRetResult.elementAt(ii+3);
				strSemester = (String)vRetResult.elementAt(ii+4);				
				
				if(((String)vRetResult.elementAt(ii+1)).equals(strTemp) && strSYFrom.equals(iii+"") && strSemester.equals("2")){
					strBorrowerCount = (String)vRetResult.elementAt(ii+5);
					strBookUsedCount = (String)vRetResult.elementAt(ii+6);
					strPopulation = (String)vRetResult.elementAt(ii+7);					
					iPercentage = (Integer.parseInt(strBorrowerCount)/Integer.parseInt(strPopulation))*100;										
					break;
				}else{
					strBorrowerCount = "-";
					strBookUsedCount = "-";
					strPopulation = "-";		
					iPercentage = 0;
					continue;
				}
					
			
			}%>
			<td align="center" class="thinborder"><%=strBorrowerCount%></td>
			<td align="center" class="thinborder"><%=strBookUsedCount%></td>
			<td align="center" class="thinborder"><%=strPopulation%></td>
			<td align="center" class="thinborder"><%=iPercentage%></td>
		<%}%>
		</tr>
		
		
		<tr>
			<td align="right" class="thinborder">Summer</td>
		<%for(int iii=iYear; iii < iYear+5; iii++){%>
			<%for(int ii=0; ii < vRetResult.size(); ii+=8){
				strSYFrom = (String)vRetResult.elementAt(ii+3);
				strSemester = (String)vRetResult.elementAt(ii+4);			
				
				if(((String)vRetResult.elementAt(ii+1)).equals(strTemp) && strSYFrom.equals(iii+"") && strSemester.equals("0")){
					strBorrowerCount = (String)vRetResult.elementAt(ii+5);
					strBookUsedCount = (String)vRetResult.elementAt(ii+6);
					strPopulation = (String)vRetResult.elementAt(ii+7);					
					iPercentage = (Integer.parseInt(strBorrowerCount)/Integer.parseInt(strPopulation))*100;										
					break;
				}else{
					strBorrowerCount = "-";
					strBookUsedCount = "-";
					strPopulation = "-";		
					iPercentage = 0;
					continue;
				}
					
			
			}%>
			<td align="center" class="thinborder"><%=strBorrowerCount%></td>
			<td align="center" class="thinborder"><%=strBookUsedCount%></td>
			<td align="center" class="thinborder"><%=strPopulation%></td>
			<td align="center" class="thinborder"><%=iPercentage%></td>
		<%}%>			
			
		</tr>
		<%
		}
			strPrevCourse = strTemp;
		%>
		
		<%
			i+=8;
			if(iLineCount >= iMaxLineCount){			
				bolIsPageBreak = true;
				break;		
			}else
				bolIsPageBreak = false;	
		%>
		
		
		<%}%>
	
	</table>
	
	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>	
<%}
}//only if vRetResult is not null%>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#77A251">&nbsp;</td>
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