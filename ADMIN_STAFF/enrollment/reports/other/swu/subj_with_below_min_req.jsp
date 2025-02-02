<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/treelinkcss.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../../Ajax/ajax2.js"></script>
<script language="JavaScript">


function DisplayAll(){

	document.form_.search_.value = "1";	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	
	document.form_.college_name.value = document.form_.c_index[document.form_.c_index.selectedIndex].text;
	
	document.forms[0].submit();	
}

function PrintPg(){
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	
	
	document.getElementById('myID3').deleteRow(0);	
	
	document.getElementById('myID4').deleteRow(0);
	document.getElementById('myID4').deleteRow(0);
	
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-SUBJECT OFFERINGS","subj_with_below_min_req.jsp");
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
														"Enrollment","SUBJECT OFFERINGS",request.getRemoteAddr(),
														"subj_with_below_min_req.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
//enrollment.SubjectSection SS = new enrollment.SubjectSection();
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
Vector vRetResult = null;


String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");


if(WI.fillTextValue("search_").length() > 0){
	vRetResult = reportEnrl.getSubjectForDissolve(dbOP, request);
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
}

String[] strConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
%>

<form name="form_" action="./subj_with_below_min_req.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CLASS PROGRAM - SUBJECT BELOW MINIMUM REQUIRED STUDENT ::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myID2">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td colspan="4" height="25"><strong><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2" valign="bottom">School year : 
        <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");

strSYFrom = strTemp;%> <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")' value="<%=strTemp%>" size="4" maxlength="4">
        to 

 <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

strSYTo = strTemp;
%>
 <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="4" maxlength="4"
	  readonly="yes">
 &nbsp;&nbsp;&nbsp;
 <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");

strSemester = strTemp;

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select> </td>
      
    </tr>
	
	<tr>
      <td height="25">&nbsp;</td>
      <td width="15%">Offering College: </td>
	  <td width="82%" colspan="2">
	  <select name="c_index" onChange="document.form_.submit();">
	  <option value=""></option>
	  <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index"), false)%>
	  </select>	  </td>
    </tr>
   
   
    

	<tr> 
      <td colspan="5" height="10"></td>
    </tr>
	
	<tr>
		<td colspan="2">&nbsp;</td>
		<td valign="bottom"><a href="javascript: DisplayAll()"><img src="../../../../../images/form_proceed.gif"border="0"></a></td>
	</tr>
	
    <tr><td colspan="5" height="10"></td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {%>


<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myID3">
	<tr><td align="right" colspan="8">
		<a href="javascript:PrintPg();"><img src="../../../../../images/print.gif" border="0"></a>
		<font size="1">click to print report</font>
	</td></tr>
	<tr><td colspan="8" align="center">
		<div align="center"><font style="font-size:12px; font-weight:bold;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
          <%if(strSchCode.startsWith("SWU")){%>Founded 1946 &nbsp; &nbsp;<%}%><%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>		
			<%=strConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%><br>		  			
			<%=WI.fillTextValue("college_name")%><br><br>&nbsp;
	  </div>
	</td></tr>
	<%if(strSchCode.startsWith("SWU")){%><tr><td colspan="7"><strong>Subject Below Minimum Required Student</strong></td><td align="right"><strong><%=WI.getTodaysDate(1)%></strong></td></tr><%}%>
	<tr>
		<td width="4%" height="22" class="thinborderTOPBOTTOM">No.</td>
		<td width="13%" class="thinborderTOPBOTTOM">Class Code</td>
		<td width="14%" class="thinborderTOPBOTTOM">Subj Name</td>
		<td width="7%" align="center" class="thinborderTOPBOTTOM">Units</td>
		<td width="10%" align="center" class="thinborderTOPBOTTOM">Days</td>
		<td width="21%" align="center" class="thinborderTOPBOTTOM">Time</td>
		<td width="8%" align="center" class="thinborderTOPBOTTOM">Students</td>
		<td width="23%" align="center" class="thinborderTOPBOTTOM">Remarks</td>
	</tr>
	
	<%
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+=9){%>
	<tr>
		<td valign="bottom" height="18"><%=iCount++%>.</td>
		<td valign="bottom"><%=vRetResult.elementAt(i+3)%></td>
		<td valign="bottom"><%=vRetResult.elementAt(i+4)%></td>
		<td valign="bottom" align="center"><%=vRetResult.elementAt(i+6)%></td>
		<td valign="bottom" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+7),"&nbsp;")%></td>
		<td valign="bottom" style="padding-left:15px;"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>
		<td valign="bottom" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+1),"&nbsp;")%></td>
		<td class="thinborderBOTTOM">&nbsp;</td>
	</tr>
	
	<%}%>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	<tr>
		<td width="23%" height="35" valign="bottom"><strong>Confirmed true and correct: </strong></td>
		<td width="28%" valign="bottom" class="thinborderBOTTOM">&nbsp;</td>
		<td width="49%" valign="bottom" align="right"></td>
	</tr>
	<tr>
		<td></td>
		<td valign="top" align="center">Dean Signature</td>
		<td></td>
	</tr>
</table>

<%} // if (vRetResult != null && vRetResult.size() > 0)%>



<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myID4">
<tr><td height="25">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" >&nbsp;</td></tr>
</table>


<input type="hidden" name="search_" >
<input type="hidden" name="college_name" value="<%=WI.fillTextValue("college_name")%>">

</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>
