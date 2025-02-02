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
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPage(){
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
	
	document.getElementById('myTable4').deleteRow(0);	
	document.getElementById('myTable4').deleteRow(0);
	
	window.print();

}

function Search(){
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.form_.search_.value = '1';
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
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
								"Admin/staff-Enrollment-REPORTS","head_count_per_course.jsp");
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
														"head_count_per_course.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.


ReportEnrollment enrlReport = new ReportEnrollment();
Vector vRetResult = new Vector();

Vector vCourseList = new Vector();
Vector vSectionList = new Vector();
Vector vCountResult = new Vector();
Vector vCountPerLevel = new Vector();
Vector vIrregularList = new Vector();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlReport.getStudentHeadCountPerCourse(dbOP, request);
	if(vRetResult == null)
		strErrMsg = enrlReport.getErrMsg();
	else{
		vCourseList = (Vector)vRetResult.remove(0);
		vSectionList = (Vector)vRetResult.remove(0);
		vCountResult = (Vector)vRetResult.remove(0);
		vCountPerLevel = (Vector)vRetResult.remove(0);
		vIrregularList = (Vector)vRetResult.remove(0);
		if(vCourseList == null)
			strErrMsg = enrlReport.getErrMsg();
	}
}


String strSYFrom = null;
String strSemester = null;

String[] astrConverSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem"};

%>
<form action="./head_count_per_course.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
	<tr bgcolor="#A49A6A">	
		<td width="100%" height="25" bgcolor="#A49A6A"><div align="center">
		<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: STUDENT HEAD COUNT ::::</strong></font></div></td>
	</tr>
	<tr bgcolor="#FFFFFF"><td height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>
  
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term: </td>
		
		<td colspan="3">			
			<%
				strSYFrom = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strSYFrom%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
				
				
			<%
			strSemester = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<select name="offering_sem">
			<%if(strSemester.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strSemester.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strSemester.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strSemester.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>
	  </td>
	</tr>
	
	
	
	
	
	
	
	
	
	
	
	<td><td colspan="3">&nbsp;</td></td>
	<tr>
		<td colspan="2">&nbsp;</td>
		<td><a href="javascript:Search();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
	</tr>
	
</table>
<%
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchoolAdd  = SchoolInformation.getAddressLine1(dbOP,false,true);


if(vCourseList != null && vCourseList.size() > 0){


%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable3">

	<tr><td align="right" colspan="3">
		<a href="javascript:PrintPage();">
		<img src="../../../../images/print.gif" border="0"></a></td></tr>
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr><td colspan="3"><div align="center"><strong><%=strSchoolName%></strong><br>
          <%=strSchoolAdd%><br><br>
		  </div></td></tr>
	<tr>
		<td width="28%">&nbsp;</td>
		<td colspan="" align="center" height="25"><strong><u>STUDENT HEAD COUNT</u></strong></td>
		<td rowspan="3" valign="top">
			<table class="thinborderALL" cellpadding="0" cellspacing="0">
			<tr>
				<td>
				<font size="1">
				Form ID: EDP 0014<br>
				Rev. No.: 01<br>
				Rev. Date: 06/15/06				</font>				</td>
			</tr>
			</table>		</td>

		</td>
	</tr>
	<tr>
		<td>&nbsp;</td>
		<td colspan="" align="center" height="25">
		<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>, 
		<%=astrConverSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%></strong></strong></td>
	</tr>
	<tr><td colspan="2" height="25">&nbsp;</td></tr>	
</table>

	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td height="25" width="15%" align="center" class="thinborder"><strong>COURSE</strong></td>
		<td width="5%" align="center" class="thinborder"><strong>YEAR</strong></td>		
		<%for(int i = 0; i < vSectionList.size(); i++){
			if((String)vSectionList.elementAt(i) == null)
				continue;
		%>
		<td width="" align="center" class="thinborder"><strong><%=(String)vSectionList.elementAt(i)%></strong></td>			
		<%}%>
		
		<td width="10%" align="center" class="thinborder"><strong>IRREGULAR</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>TOTAL</strong></td>			
	</tr>

	<% 		
		int iIndexOf = 0;	
		String strCourseName = null;
		String strCourseIndex = null;
		String strYearLevel = null;
		int iCount = 0;
		int iTotal = 0;
		int iGrandTotal = 0;
		for(int i = 0; i < vCourseList.size(); i+=4){
			iTotal = 0;
			strCourseIndex = (String)vCourseList.elementAt(i);
			strCourseName = (String)vCourseList.elementAt(i+2);			
			strYearLevel = (String)vCourseList.elementAt(i+3);
	%>
	
	<tr>
		<td height="25" class="thinborder"><%=strCourseName%></td>
		<td class="thinborder" align="right"><%=strYearLevel%></td>
		<%
		for(int x = 0; x < vSectionList.size(); x++){	
			
			strTemp = (String)vSectionList.elementAt(x);
			if(strTemp == null)
				continue;
			
			iCount = 0;
			
			for(int j = 0; j < vCountResult.size(); j+=4){
				if(!((String)vCountResult.elementAt(j )).equals(strCourseIndex))
					continue;
					
				if((String)vCountResult.elementAt(j+1) == null)
					continue;
				
				if(!((String)vCountResult.elementAt(j+1)).equals(strTemp))
					continue;
					
				iCount = Integer.parseInt(WI.getStrValue((String)vCountResult.elementAt(j+3),"0"));
				break;
			}
						
			iTotal += iCount;
			
			
		%>
		<td class="thinborder" align="right"><%=iCount%></td>	
		<%}%>
		
		
		<%
		iIndexOf = vIrregularList.indexOf(strCourseIndex);
		if(iIndexOf == -1)
			iCount = 0;
		else
			iCount = Integer.parseInt(WI.getStrValue((String)vIrregularList.elementAt(iIndexOf + 2),"0"));
			
		iTotal += iCount;
		iGrandTotal += iTotal;
		%>
		<td class="thinborder" align="right"><%=iCount%></td>	
		<td align="right" class="thinborder"><%=iTotal%></td>
		
		
	</tr>
	<%}%>
	
	<tr>
		<td colspan="2" height="20">&nbsp;</td>
		<%for(int i = 0; i < vSectionList.size(); i++){
		if((String)vSectionList.elementAt(i) == null)
			continue;
		%>
		<td>&nbsp;</td>			
		<%}%>
		<td class="thinborder">Grand Total</td>
		<td class="thinborder" align="right"><%=iGrandTotal%></td>
	</tr>
	
		
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" >
	<tr>
		<td height="16"></td>
	</tr>
	<tr>
		<td width="25%">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">		
		<%				
		String[] astrYearLevel = {"", "1ST YEAR", "2ND YEAR", "3RD YEAR", "4TH YEAR", "5TH YEAR", "6TH YEAR", "7TH YEAR"};
		iTotal = 0;
		int iHighYearLevel = Integer.parseInt((String)vCountPerLevel.remove(0));
		for(int i = 1; i <= iHighYearLevel; i++){
			iIndexOf = vCountPerLevel.indexOf(Integer.toString(i)+" YEAR");
			
			if(iIndexOf == -1)
				iCount = 0;
			else{
				iCount = Integer.parseInt(WI.getStrValue((String)vCountPerLevel.elementAt(iIndexOf + 2),"0"));
			}
			
			iTotal += iCount;
		%>
		<tr>
			<td height="20" width="15%" class="thinborder"><%=astrYearLevel[i]%></td>
			<td height="20" width="10%" class="thinborder" align="right"><%=iCount%></td>			
		</tr>
		<%}%>
		<tr>
			<td class="thinborder" height="20">TOTAL</td>
			<td class="thinborder" align="right"><%=iTotal%></td>
		</tr>
		
	</table>
</td>
		<td>&nbsp;</td>
	</tr>
</table>


<%}//end vRetResult != null%>
  
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable4">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" />
</form>

 <!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div> 

</body>
</html>
<%
dbOP.cleanUP();
%>