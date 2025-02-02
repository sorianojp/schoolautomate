<%@ page language="java" import="utility.*,java.util.Vector,enrollment.CurriculumSM" %>
<%
	//added code for HR/companies.
	boolean bolIsSchool = false;
	WebInterface WI = new WebInterface(request);
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(6);
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>..</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
	}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage(){
	document.form_.show_result.value="";
	document.form_.submit();
}
//  about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		
		var layer_ = document.getElementById("processing_");
		var objCOAInput = document.getElementById("coa_info");
		 
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		layer_.style.display = 'block';

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
						 		 "&name_format=4&complete_name="+escape(strCompleteName);

		this.processRequest(strURL);
		
}
function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<body bgcolor="#D2AE72" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	//add security here. 
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Subject Configuration","set_payload.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.

Vector vRetResult  = null;
int iRowsDisplayed = 0;
CurriculumSM csm = new CurriculumSM();

boolean bolShowWithNoRecord = false;
if(WI.fillTextValue("show_with_noinfo").length() > 0) 
	bolShowWithNoRecord = true;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(csm.operateOnSubjectFacultyLoadHr(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = csm.getErrMsg();
	else	
		strErrMsg = "Information successfully updated.";
}

if(WI.fillTextValue("show_result").length() > 0) {
	vRetResult = csm.operateOnSubjectFacultyLoadHr(dbOP, request, 4);
	if(strErrMsg == null && vRetResult == null)
		strErrMsg = csm.getErrMsg();
}	

%>
<form action="./set_payload.jsp" method="post" name="form_" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" align="center" class="footerDynamic"><font color="#FFFFFF"><strong>:::: SUBJECT LOAD-HR INFORMATION ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFF0F0">
    <tr> 
      <td height="18" colspan="2" style="font-size:14px; font-weight:bold; color:#FF0000">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr>
      <td height="25" class="fontsize10" width="16%">&nbsp;Subject Filter </td>
      <td width="38%" class="fontsize10"><input name="sub_code" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("sub_code")%>" size="16"> 
      (leave empty to show all) </td>
      <td width="46%">&nbsp; 
				<div style="position:absolute; overflow:auto; width:300px; height:225px; display:none;" id="processing_">
				<label id="coa_info"></label>
				</div>			</td>
    </tr>
    <tr>
      <td height="25" colspan="3" class="fontsize10">&nbsp; 
	  <input type="checkbox" name="show_with_noinfo" value="checked" <%=WI.fillTextValue("show_with_noinfo")%>> 
	  Show Subject Without Load-hr Information</td>
    </tr>
    <tr>
      <td height="25" colspan="3" class="fontsize10" align="center">
  	  <a href="#"%><img src="../../../../images/form_proceed.gif" width="81" height="21" border="0" onClick="document.form_.show_result.value='1';document.form_.submit()"></a></td>
    </tr>
    <tr> 
      <td height="14" colspan="3" class="fontsize10"><hr size="1" noshade></td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0) {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292" align="center">
	  	<strong><font color="#FFFFFF">SEARCH RESULT</font></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="5%" height="25" class="thinborder">Count</td>
      <td width="15%" class="thinborder">Subject code </td>
      <td width="37%" class="thinborder">Subject Name </td>
      <td width="10%" class="thinborder">Load-Hr Set </td>
      <td width="7%" class="thinborder">Lec Unit </td>
      <td width="7%" class="thinborder">Lab Unit </td>
      <td width="7%" class="thinborder">Lec Hr </td>
      <td width="7%" class="thinborder">Lab Hr </td>
      <td width="5%" class="thinborder">Select</td>
    </tr>
<%for(int i =0; i < vRetResult.size(); i += 8) {%>
    <tr>
      <td height="25" class="thinborder"><%=iRowsDisplayed + 1%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "Not yet Set")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 7), "&nbsp;")%></td>
      <td class="thinborder"><input type="checkbox" name="sub_index_<%=iRowsDisplayed++%>" value="<%=vRetResult.elementAt(i)%>" checked="checked"></td>
    </tr>
<%}%>
  </table>
<%if(bolShowWithNoRecord){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center" style="font-size:11px;">
	  Enter Load-Hr  
	    <input name="load_hr" type="text" class="textbox" 
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("load_hr")%>" size="16">
	  &nbsp;&nbsp;&nbsp;&nbsp;
	    <input type="submit" name="1" value="&nbsp;&nbsp; Set Load-Hr Information &nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'; document.form_.page_action.value='1'">
	  </td>
    </tr>
 </table>
<%}else{%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" align="center">
	  <input type="submit" name="1" value="&nbsp;&nbsp;Remove Load-Hr Information &nbsp;&nbsp;" 
	  	style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value='1'; document.form_.page_action.value='0'">
	 </td>
    </tr>
 </table>
<%}%>

<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="show_result" value="<%=WI.fillTextValue("show_result")%>">
<input type="hidden" name="rows_display" value="<%=iRowsDisplayed%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>