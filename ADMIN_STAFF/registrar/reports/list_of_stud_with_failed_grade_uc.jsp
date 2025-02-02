<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,student.GWA,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

if(strSchCode == null) {%>
		<p style="font-family:Geneva, Arial, Helvetica, sans-serif; font-weight:bold; color:#FF0000;"> You are already logged out. please login again.</p>
<%return;}
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
	
	TD.thinborderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
	}

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderLegend {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 8px;
    }

-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PrintPage()
{		
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);

		
	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);	

	document.getElementById('myTable3').deleteRow(0);

	document.getElementById('myTable4').deleteRow(0);
	document.getElementById('myTable4').deleteRow(0);	
	
	window.print();
}

function Search(){	
	document.form_.remark_name.value = document.form_.remark_index[document.form_.remark_index.selectedIndex].text;
	document.form_.search_.value = '1';
	document.form_.submit();
}

</script>


<body bgcolor="#D2AE72">
<form name="form_" action="./list_of_stud_with_failed_grade_uc.jsp" method="post">
<%
	String strErrMsg  = null;
	String strTemp    = null;
	String strTemp2   = null;
		
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","list_of_stud_with_failed_grade_uc.jsp");
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

//int iAccessLevel = 2;
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Grades",request.getRemoteAddr(),
														"list_of_stud_with_failed_grade_uc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
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

ReportEnrollment enrlReport = new ReportEnrollment();
GWA gwa = new GWA();

Vector vRetResult = new Vector();


if(WI.fillTextValue("search_").length() > 0){
	vRetResult = enrlReport.viewStudListWithGradeStatus(dbOP, request);
	if(vRetResult == null)
		strErrMsg = enrlReport.getErrMsg();	
}	

%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LIST OF STUDENT WITH FAILED GRADE ::::</strong></font></div></td>
    </tr>
	<tr> 
      <td height="25" colspan="7">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
</table>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable2">
	
	
	
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term</td>		
		<td>			
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));%>
			<select name="semester">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select></td>		
	</tr>
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">Grade Status</td>		
		<td><select name="remark_index">
          <option value="">Select a grade status</option>
			<%=dbOP.loadCombo("remark_index","remark"," from REMARK_STATUS where IS_DEL=0 and is_internal = 1 order by remark", request.getParameter("remark_index"), false)%>
        </select></td>		
	</tr>	
	<tr><td colspan="3" height="15">&nbsp;</td></tr>
	<tr><td colspan="2">&nbsp;</td>
		<td><a href="javascript:Search();"><img src="../../../images/form_proceed.gif" border="0" align="absmiddle"></a></td>
	</tr>
	
</table>

<%
String[] astrConvertSem = {"SUMMER","1ST SEMESTER","2ND SEMESTER","3RD SEMESTER","4TH SEMESTER","5TH SEMESTER"};
if(vRetResult != null && vRetResult.size() > 0){%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable3">
	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a></td></tr>
</table>



<%
String strSchoolName = SchoolInformation.getSchoolName(dbOP,true,false);

boolean bolIsPageBreak = false;
int iResultSize = 16;
int iLineCount = 0;
int iMaxLineCount = 40;	
int iCount = 1;	
int i = 0;

while(iResultSize <= vRetResult.size()){
	iLineCount = 0;
%>

	


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
	<tr><td align="center">GRADE SLIPS SENT TO PARENTS</td></tr>
	<tr><td align="center" class="thinborderALL">LIST OF STUDENTS WITH GRADE STATUS : <%=WI.getStrValue(WI.fillTextValue("remark_name"))%></td></tr>
	<tr><td align="center" class="thinborderBOTTOMLEFTRIGHT">For <%=WI.fillTextValue("sy_from")%><%=WI.getStrValue(WI.fillTextValue("sy_to"),"-","","")%>,
	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> </td></tr>
	<tr><td align="center" height="6"></td></tr>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td class="thinborder" rowspan="2" align="center" width="5%">SL#</td>
		<td class="thinborder" rowspan="2" align="center" width="12%"><strong>STUDENT ID</strong></td>
		<td class="thinborder" align="center" width="30%"><strong>STUDENT NAME</strong></td>
		<td class="thinborder" rowspan="2" align="center" width="15%"><strong>COURSE/MAJOR</strong></td>
		<td class="thinborder" rowspan="2" align="center" width="5%"><strong>YEAR</strong></td>
		<td class="thinborder" rowspan="2" align="center"><strong>CITY ADDRESS/HOME ADDRESS</strong></td>
	</tr>
	<tr><td class="thinborder" align="center"><strong>(fname,mi,lname)</strong></td></tr>
	
	<%
		for( ; i < vRetResult.size() ; ){
			iLineCount++;		
			iResultSize += 16;
	%>
	
	<tr>
		<td class="thinborder"><%=iCount++%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder"><%=WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"/","","")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
		<td class="thinborder">
		
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+8))+WI.getStrValue((String)vRetResult.elementAt(i+9),", ","","")+
					WI.getStrValue((String)vRetResult.elementAt(i+10),", ","","")+WI.getStrValue((String)vRetResult.elementAt(i+11));
					
		strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+12))+WI.getStrValue((String)vRetResult.elementAt(i+13),", ","","")+
					WI.getStrValue((String)vRetResult.elementAt(i+14),", ","","")+WI.getStrValue((String)vRetResult.elementAt(i+15));
		
		if(!strTemp.equals(strErrMsg))
			strTemp = strTemp+"<br>"+strErrMsg;
		%>		
		
		<%=strTemp%>
		
		</td>
	</tr>
	
	<%
		i+=16;
		if(iLineCount >= iMaxLineCount){
			bolIsPageBreak = true;
			break;		
		}else
			bolIsPageBreak = false;	
	
	}%>
	
</table>


	<%if(bolIsPageBreak){%>
		<div style="page-break-after:always">&nbsp;</div>
	<%}%>

<%}
}%>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myTable4">
	<tr><td height="25"  colspan="3">&nbsp;</td></tr>
	<tr><td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
	<input type="hidden" name="remark_name" value="<%=WI.fillTextValue("remark_name")%>" />
    <input type="hidden" name="search_">

</form>
</body>
</html>
<% dbOP.cleanUP(); %>