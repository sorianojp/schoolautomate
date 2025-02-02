<%@ page language="java" import="utility.*,enrollment.ApplicationMgmt,java.util.Vector"	%>
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
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

function UpdateApplStat(strAppIndex,strCanUpdate,strTempId) 
{
	var win=window.open("./update_application_stat_preload.jsp","PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
//ajax here.. 
function AjaxUpdateStat(objRemark, strStatIndex, strLabelInfo) {
	
	var objCOAInput = document.getElementById(strLabelInfo);
			
	this.InitXmlHttpObject2(objCOAInput, 2, "<img src='../../../Ajax/ajax-loader_small_black.gif'>");//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=208&user_="+strStatIndex+"&new_stat="+
			objRemark[objRemark.selectedIndex].value;

		this.processRequest(strURL);
}

</script>

<body bgcolor="#D2AE72">
<%
	Vector vRetResult = null;
	String strErrMsg = null;
	String strTemp = null;	
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null) 
		strSchCode = "";
	
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-APPLICANT STATUS","encode_application_stat_auf.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%	return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();

int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","APPLICATION STATUS",request.getRemoteAddr(),
														"encode_application_stat_auf.jsp");
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
ApplicationMgmt applMgmt = new ApplicationMgmt();
//. i am using ajax to upate status.. 


if(WI.fillTextValue("search_").length() > 0) {
	vRetResult = applMgmt.operateOnApplicationStatusAUF(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = applMgmt.getErrMsg();
}
%>
<form name="form_" action ="./encode_application_stat_auf.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="91%" height="25" colspan="8" bgcolor="#A49A6A"><div align="center"><strong><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">:::: 
          APPLICATION STATUS UPDATE PAGE::::</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Temporary ID </td>
      <td width="26%"> <input name="id_number" type="text" class="textbox" value="<%=WI.fillTextValue("id_number")%>"
       
         onfocus="style.backgroundColor='#D3EBFF'"	onblur='style.backgroundColor="white"' >      </td>
      <td width="11%">Gender </td>
      <td width="47%"><select name="gender">
          <option value="">N/A</option>
          <%
if(WI.fillTextValue("gender").compareTo("F") == 0){%>
          <option value="F" selected>Female</option>
          <%}else{%>
          <option value="F">Female</option>
          <%}if(WI.fillTextValue("gender").compareTo("M") ==0){%>
          <option value="M" selected>Male</option>
          <%}else{%>
          <option value="M">Male</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Lastname</td>
      <td><input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>SY-SEM</td>
      <td><% strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
        <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
	onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
to
<%  strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
<input name="sy_to" type="text" size="4" maxlength="4" 
		  value="<%=strTemp%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
/
<select name="semester">
  <% strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("0") ==0){%>
  <option value="0" selected>Summer</option>
  <%}else{%>
  <option value="0">Summer</option>
  <%}if(strTemp.compareTo("1") ==0){%>
  <option value="1" selected>1st Sem</option>
  <%}else{%>
  <option value="1">1st Sem</option>
  <%}if(strTemp.compareTo("2") == 0){%>
  <option value="2" selected=>2nd Sem</option>
  <%}else{%>
  <option value="2">2nd Sem</option>
  <%}if(strTemp.compareTo("3") == 0){%>
  <option value="3" selected>3rd Sem</option>
  <%}else{%>
  <option value="3">3rd Sem</option>
  <%}%>
</select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Year Level</td>
      <td><select name="year_level">
        <option value="">N/A</option>
        <% strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0) {%>
        <option value="1" selected>1st</option>
        <%}else{%>
        <option value="1">1st</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}if(strTemp.compareTo("3") ==0) {%>
        <option value="3" selected>3rd</option>
        <%}else{%>
        <option value="3">3rd</option>
        <%}if(strTemp.compareTo("4") ==0) {%>
        <option value="4" selected>4th</option>
        <%}else{%>
        <option value="4">4th</option>
        <%}if(strTemp.compareTo("5") ==0) {%>
        <option value="5" selected>5th</option>
        <%}else{%>
        <option value="5">5th</option>
        <%}if(strTemp.compareTo("6") ==0) {%>
        <option value="6" selected>6th</option>
        <%}else{%>
        <option value="6">6th</option>
        <%}%>
      </select></td>
      <td colspan="2" style="font-size:11px;">
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.length() == 0) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="" <%=strErrMsg%>> Show All 
<%
if(strTemp.endsWith("is null")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value=" and appl_stat is null" <%=strErrMsg%>> Show all not encoded 
<%
if(strTemp.endsWith("is not null")) 
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value=" and appl_stat is not null" <%=strErrMsg%>> Show all Encoded	  </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Course</td>
      <td colspan="3"><select name="course_index" style="font-size:11px;">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
		  					" and is_offered = 1 and is_visible = 1  order by course_name asc", 
							request.getParameter("course_index"), false)%> 
        </select></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="25%">&nbsp;</td>
      <td width="25%"><a href="#"><img src="../../../images/form_proceed.gif" border="0" onClick="document.form_.search_.value='1';document.form_.submit()"></a></td>
      <td width="32%">
	  <a href="javascript:UpdateApplStat();">Update Application Status</a>
	  </td>
    </tr>
  </table>

<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="23" colspan="4" class="thinborder"><div align="center"><strong><font color="#FFFFFF" size="1">LIST 
          OF <%=WI.getStrValue(request.getParameter("ShowType")).toUpperCase()%> 
		  APPLICANTS FOR 
		  <%=dbOP.getHETerm(Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"-1"))).toUpperCase()%>, 
		  SY <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")%></font></strong></div></td>
    </tr>
    <tr>  
      <td height="25" colspan="3" class="thinborder"><strong><font size="1">
		  TOTAL APPLICANT(S) : <%=vRetResult.size() /7%></font></strong></td>
      <td height="25" align="right" class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td width="13%" height="25" class="thinborder"><div align="center"><strong><font size="1">Applicant ID </font></strong></div></td>
      <td width="24%" class="thinborder"><div align="center"><strong>
	  <font size="1">Applicant Name </font></strong></div></td>
      <td width="22%" class="thinborder"><div align="center"><strong><font size="1">Application Status </font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><b><font size="1">New Application Status </font></b></div></td>
      <b> </b>    </tr>

<%for(int i = 0 ; i< vRetResult.size(); i += 7){%>
    <tr> 
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "----")%></td>
      <td class="thinborder">
	  <label id="<%=i%>" style="font-size:9px; font-weight:bold; color:#993300">
	  <select name="stat_<%=i%>" style="font-size:10px" tabindex="-1" onChange="AjaxUpdateStat(document.form_.stat_<%=i%>,'<%=vRetResult.elementAt(i)%>', '<%=i%>')">
          <option value=""></option>
		  <%=dbOP.loadCombo("STAT_INDEX","APPL_STAT_NAME"," from NEW_APPLICATION_STAT_PRELOAD order by APPL_STAT_NAME",null, false,false)%>
      </select>
	  </label>
	  </td>
    </tr>
<%}%>
  </table>
<%}//end of vRetResult != null%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#B5AB73">
    <tr>
      <td bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="search_">
<input type="hidden" name="info_index" >
<input type="hidden" name="page_action" >

</form>
</body>
</html>
<% 
dbOP.cleanUP();
%>