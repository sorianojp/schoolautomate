<%@ page language="java" import="utility.*,java.util.Vector,chedReport.CHEDBCFormNew"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("REGISTRAR MANAGEMENT"),"0"));
		}
	}

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
//end of authenticaion code.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"Admin/staff-CHED REPORTS-CHED COURSE MAPPING","ched_course_mapping.jsp");
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
	
Vector vRetResult = null; Vector vListToMap = null; boolean bolCleanUP = false;
CHEDBCFormNew chedBC = new CHEDBCFormNew();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(chedBC.operateOnCourseMap(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = chedBC.getErrMsg();
	else {	
		strErrMsg = chedBC.getErrMsg();
		bolCleanUP = true;
	}
}

vRetResult = chedBC.operateOnCourseMap(dbOP, request, 4); 
if(strErrMsg == null && vRetResult == null)
	strErrMsg = chedBC.getErrMsg();
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>CHED E-FORM B/C</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
.body_font{
	font-size:11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function UpdateCheckBox(objInputBox, objCheckBox) {
	if(objInputBox.value.length > 0) 
		objCheckBox.checked = true;
	else
		objCheckBox.checked = false;
}
</script>
<body>
<form name="form_" action="./ched_course_mapping.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" size="2" face="Arial, Helvetica, sans-serif"><strong>::: CHED COURSE MAJOR MAPPING ::: </strong> </font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2" style="font-weight:bold; font-size:14px; color:#FF0000">&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#DDDDDD">
    <tr>
      <td height="25" colspan="12" align="center" style="font-weight:bold" class="thinborder">List of Course to Map</td>
    </tr>
<%
vListToMap = chedBC.operateOnCourseMap(dbOP, request, 5);
if(vListToMap == null){%>
	<tr>
      <td height="25" colspan="12" style="font-size:13px; font-weight:bold; color:#FF0000" class="thinborder">&nbsp;Error in getting the list to Map. Description :: <%=chedBC.getErrMsg()%></td>
    </tr>
<%}else{%>
	<tr bgcolor="#CFE9F7">
	  <td height="25" style="font-weight:bold" class="thinborder" width="30%">Course Name</td>
	  <td style="font-weight:bold" class="thinborder" width="15%">Major Name </td>
	  <td style="font-weight:bold" class="thinborder" width="10%">Program</td>
	  <td style="font-weight:bold" class="thinborder" width="5%">GP No </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">GP Yr Granted </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">GP Issued By </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">GR No </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">GR Yr Granted </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">GR Issued By </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">Program Mode </td>
	  <td style="font-weight:bold" class="thinborder" width="5%">Normal Len </td>
	  <td height="25" style="font-weight:bold" class="thinborder" width="5%">Select</td>
	</tr>
<%
boolean bolIsMajor = false; int j = 0;
	for(int i = 0; i < vListToMap.size(); i += 6,++j) {
	if(vListToMap.elementAt(i + 1) != null)
		bolIsMajor = true;
	else	
		bolIsMajor = false;%>
	<tr bgcolor="#FFFFDD">
	  <td height="25" colspan="12" style="font-weight:bold" class="thinborder"><%=j + 1%>. <%=vListToMap.elementAt(i)%> <%=WI.getStrValue((String)vListToMap.elementAt(i + 1), " ; <font color=blue>Major : ", "</font>", "")%></td>
	</tr>
	<tr>
	  <td height="25" class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("course_name_"+j);
%>
  	  <input name="course_name_<%=j%>" type="text" size="40" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="UpdateCheckBox(document.form_.course_name_<%=j%>,document.form_.course_<%=j%>);style.backgroundColor='white'"></td>
	  <td class="thinborder"><%if(bolIsMajor){%>
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("major_name_"+j);
%>
  	  <input name="major_name_<%=j%>" type="text" size="24" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  <%}else{%>No Major<%}%>
	  </td>
	  <td class="thinborder">
	  <select name="main_prog_<%=j%>" style="font-size:10px;">
	  	<option value="1">Doctoral</option>
<%
strTemp = WI.fillTextValue("main_prog_"+j);
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="2">Masteral</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="3">Post Bacc.</option>
<%
if(strTemp.equals("4"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="4">Baccalaureate</option>
<%
if(strTemp.equals("5"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="5">Pre Bacc.</option>
<%
if(strTemp.equals("6"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
		<option value="6">Voc/Tech</option>
	  </select>
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("gp_no_"+j);
%>
	  	<input name="gp_no_<%=j%>" type="text" size="8" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("gp_yr_"+j);
%>
	  	<input name="gp_yr_<%=j%>" type="text" size="4" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("gp_issued_"+j);
%>
	  	<input name="gp_issued_<%=j%>" type="text" size="10" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("gr_no_"+j);
%>
	  	<input name="gr_no_<%=j%>" type="text" size="8" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("gr_yr_"+j);
%>
	  	<input name="gr_yr_<%=j%>" type="text" size="4" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
	  <td class="thinborder">
<%
if(bolCleanUP)
	strTemp = "";
else	
	strTemp = WI.fillTextValue("gr_issued_"+j);
%>
	  	<input name="gr_issued_<%=j%>" type="text" size="10" maxlength="64" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
	  <td class="thinborder">
	  <select name="prog_mode_<%=j%>" style="font-size:10px;">
		<%=dbOP.loadCombo("COURSE_STATUS_CODE","COURSE_STATUS_CODE"," from CHED_COURSE_STATUS order by course_status_index",(String)vListToMap.elementAt(i + 5), false)%>
	  </select>
	  </td>
	  <td class="thinborder">
<%
strTemp = (String)vListToMap.elementAt(i + 4);
if(strTemp == null)
	strTemp = WI.fillTextValue("len_"+j);
%>
	  	<input name="len_<%=j%>" type="text" size="1" maxlength="1" value="<%=strTemp%>" class="textbox" style="font-size:10px" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
	  </td>
	  <td class="thinborder">
		<input type="checkbox" name="course_<%=j%>" value="<%=vListToMap.elementAt(i + 2)%>">
		<input type="hidden" name="major_<%=j%>" value="<%=WI.getStrValue(vListToMap.elementAt(i + 3))%>">
	  </td>
	</tr>
	<%}//end of for loop%>
	<tr>
	  <td height="25" colspan="12" class="thinborder" align="center"><input type="submit" name="Save" value="Save Information" onClick="document.form_.page_action.value='1'"></td>
    </tr><input type="hidden" name="max_disp" value="<%=j%>">
	
<%}//end of else.%>
  </table>
  <br><br>
  <table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
  <tr>
  	<td colspan="12" class="thinborder" align="center" style="font-size:14px; font-weight:bold">::: List of Mapped Course/Major Information ::: </td>
  </tr>
 <%if(vRetResult != null && vRetResult.size() > 0) {%>
		<tr bgcolor="#9DB6F4">
		  <td height="25" style="font-weight:bold" class="thinborder" width="25%">Course Name/Major Name</td>
		  <td style="font-weight:bold" class="thinborder" width="20%">Equivalent Course Name/Major Name </td>
		  <td style="font-weight:bold" class="thinborder" width="10%">Program</td>
		  <td style="font-weight:bold" class="thinborder" width="5%">GP No </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">GP Yr Granted </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">GP Issued By </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">GR No </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">GR Yr Granted </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">GR Issued By </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Program Mode </td>
		  <td style="font-weight:bold" class="thinborder" width="5%">Normal Len </td>
		  <td height="25" style="font-weight:bold" class="thinborder" width="5%">Delete</td>
		</tr>
		<%
		String[] astrConvertMainProgram = {"","Doctoral","Masteral","Post-Bacc","Bacc","Pre-Bacc","Voc/Tech"};
		for(int i = 0; i < vRetResult.size(); i += 19) {%>
		<tr bgcolor="#FFFFCC">
		  <td height="25" class="thinborder" width="25%"><%=vRetResult.elementAt(i + 17)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 18), "<br>Major : ","","")%></td>
		  <td class="thinborder" width="20%"><%=vRetResult.elementAt(i + 3)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 5), "<br>Major : ","","")%></td>
		  <td class="thinborder" width="10%"><%=astrConvertMainProgram[Integer.parseInt((String)vRetResult.elementAt(i + 7))]%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 8), "&nbsp;")%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 9), "&nbsp;")%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 10), "&nbsp;")%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 11), "&nbsp;")%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 12), "&nbsp;")%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 13), "&nbsp;")%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 14), "&nbsp;")%></td>
		  <td class="thinborder" width="5%"><%=WI.getStrValue((String)vRetResult.elementAt(i + 15), "&nbsp;")%></td>
		  <td height="25" class="thinborder" width="5%"><input type="submit" name="_" value="Delete" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'"></td>
		</tr>
		<%}%>
	</table> 	
 <%}%>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">

</form>

</body>
</html>
<%
	dbOP.cleanUP();
%>
