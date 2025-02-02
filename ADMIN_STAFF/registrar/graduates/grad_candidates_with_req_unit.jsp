<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function PrintPage(){
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);

	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	
	window.print();
}

///ajax here to load major..
function loadMajor() {
	return;
		var objCOA=document.getElementById("load_major");
		
		var objCourseInput = document.form_.course_index[document.form_.course_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=104&all=1&course_ref="+objCourseInput;
		this.processRequest(strURL);
}

//end of ajax to finish loading.. 
</script>
<body>
<%@ page language="java" import="utility.*,enrollment.EntranceNGraduationData,java.util.Vector"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Graduates","grad_candidates_with_req_unit.jsp");
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
														"Registrar Management","GRADUATES",request.getRemoteAddr(),
														"grad_candidates_with_req_unit.jsp");
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

Vector vRetResult = null;
EntranceNGraduationData eng = new EntranceNGraduationData();
if(WI.fillTextValue("course_index").length() > 0) {
	vRetResult = eng.viewAllGraduatingStudentsWithUnitsCon(dbOP,request);
	if(vRetResult == null) 
		strErrMsg = eng.getErrMsg();
}

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<form name="form_" action="./grad_candidates_with_req_unit.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          TENTATIVE GRADUATE LIST ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="97%" height="25" colspan="4" style="font-size:16px; color:#FF0000;"><%=WI.getStrValue(strErrMsg,"")%></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable2">
    <tr>
      <td height="25" >&nbsp;</td>
      <td height="25" ><font size="1"><strong>SY</strong></font></td>
      <td height="25" >
<%
	if (WI.fillTextValue("sy_from").length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	else
		strTemp = WI.fillTextValue("sy_from");
%>
	  <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        - 
<%
	if (WI.fillTextValue("sy_to").length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	else
		strTemp = WI.fillTextValue("sy_to");
%>
        <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4">
        &nbsp;&nbsp; 

        <select name="semester">
          <option value="1">1st Sem</option>
<%
	if (WI.fillTextValue("semester").length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	else
		strTemp = WI.fillTextValue("semester");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td width="3%" height="25" >&nbsp;</td>
      <td width="8%" height="25" ><strong><font size="1">Course </font></strong></td>
      <td width="89%" height="25" > 
<% 	
	strTemp = WI.fillTextValue("course_index");
%> <select name="course_index" onChange="loadMajor();">
  <!--        <option value="">Select a Course</option>-->
      <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_VALID=1 and degree_type = 0 order by course_name asc",	strTemp, false)%> </select></td>
    </tr>
<!--
    <tr> 
      <td height="25" >&nbsp;</td>
      <td height="25" ><strong><font size="1">Major</font></strong></td>
      <td height="25" > 
		<select name="major_index">
          <option value="">ALL</option>
        	<%//if(strTemp.length() > 0) {%>
				<%//=dbOP.loadCombo("major_index","major_name"," from	 major where IS_DEL=0 and course_index = " + strTemp + " order by major_name asc",	WI.fillTextValue("major_index"), false)%> 
			<%//}%>
		</select> 
		</td>
    </tr>
-->
    <tr> 
      <td height="25" >&nbsp;</td>
      <td colspan="2" style="font-size:9px"><strong>Lacking Units :</strong> 
	  <select name="lac_unit_param">
		  <option value="0">Equals</option>
<%
strTemp = WI.fillTextValue("lac_unit_param");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		  <option value="1"<%=strErrMsg%>>Less than</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		  <option value="2"<%=strErrMsg%>>between</option>
	  </select>
	  
	    <input name="allowed_unit_fr" type="text" class="textbox" onKeyUp="AllowOnlyInteger('form_','allowed_unit_fr');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','allowed_unit_fr');style.backgroundColor='white'" value="<%=WI.fillTextValue("allowed_unit_fr")%>" size="3" maxlength="2">
	  &nbsp;to&nbsp;&nbsp;
	    <input name="allowed_unit_to" type="text" class="textbox" onKeyUp="AllowOnlyInteger('form_','allowed_unit_to');"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','allowed_unit_fr');style.backgroundColor='white'" value="<%=WI.fillTextValue("allowed_unit_to")%>" size="3" maxlength="2">
	  &nbsp;&nbsp;&nbsp;
	  <input type="submit" value=" Show List " style="font-size:11px; height:20px;border: 1px solid #FF0000;">	  
	  
	  <input type="checkbox" name="debug" value="checked" <%=WI.fillTextValue("debug")%>>Show Total Unit to complete and lacking units (for debugging)
	  </td>
    </tr>
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" style="font-size:11px;">Report Name : 
	  <input name="report_title" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	   onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("report_title")%>" size="48" maxlength="128">
	  &nbsp;&nbsp;&nbsp;&nbsp;
	  
	  Rows Per Page : 
	  	<select name="rows_per_pg">
	  	<%
		int iDefVal = 0;
		strTemp = WI.fillTextValue("rows_per_pg");
		if(strTemp.length() == 0) 
			iDefVal = 30;
		else	
			iDefVal = Integer.parseInt(strTemp);
		for(int i =30; i < 100; ++i){
			if( i == iDefVal)
				strErrMsg = " selected";
			else	
				strErrMsg = "";%>
			<option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
		<%}%>
	  	</select>
		&nbsp;&nbsp;&nbsp;
		<a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0" height="24"></a> click to print report 	  
	</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {
int iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iCount = 0;
int iPageOf   = 1;
int iTotalPages = vRetResult.size()/(2 * iRowPerPg);
if(vRetResult.size() % (2 * iRowPerPg) > 0)
	++iTotalPages;

for(int i = 0; i < vRetResult.size(); ++iPageOf){
if(i > 0) {%> 
	<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="2" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <u><%=WI.fillTextValue("report_title")%></u>
	 </td>
    </tr>
    <tr>
      <td width="37%" height="22" style="font-size:10px">Page <%=iPageOf%> of <%=iTotalPages%>&nbsp;</td>
      <td width="63%" align="right" style="font-size:10px">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="8%" style="font-size:9px; font-weight:bold" class="thinborder">NO.</td>
      <td width="29%" height="22" style="font-size:9px; font-weight:bold" class="thinborder">ID NUMBER</td>
      <td width="63%" style="font-size:9px; font-weight:bold" class="thinborder">NAME</td>
    </tr>
<%for(; i < vRetResult.size(); i += 2) {%>
   <tr> 
      <td style="font-size:9px;" class="thinborder">&nbsp;<%=++iCount%>.</td>
      <td height="22" style="font-size:9px;" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td style="font-size:9px;" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
    </tr>
<%
	if(iCount % iRowPerPg == 0) {
		i += 2;
		break;
	}
}%>
  </table>
<%}//end of outer for loop

} //end if vRetResult is not null %>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
