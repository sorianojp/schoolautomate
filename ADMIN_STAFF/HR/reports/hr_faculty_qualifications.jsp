<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoEducationExtn" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Faculty Qualifications</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function CheckLoad(){
		if(document.form_.teaching_staff[0].checked){
			document.form_.with_load.checked = "";
			document.form_.with_load.disabled = true;
		}
		else{
			document.form_.with_load.disabled = false;
		}
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.view_profile.value = "";
		document.form_.submit();
	}
	
	function ViewProfile(){
		document.form_.view_profile.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}

</script>
<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	String strTemp = null;	
	String strErrMsg = null;	
	
	if (WI.fillTextValue("print_page").equals("1")){ %>
		<jsp:forward page="./hr_faculty_qualifications_print.jsp" />
	<% return;	}
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS-Awards",
								"hr_faculty_qualifications.jsp");

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
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
												"HR Management","REPORTS AND STATISTICS",
												request.getRemoteAddr(),"hr_faculty_qualifications.jsp");
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

	int[] iTotals =  new int[9];

	HRInfoEducationExtn hrEduExtn = new HRInfoEducationExtn();
	Vector vRetResult = null;
	
	if(WI.fillTextValue("view_profile").length() > 0){
		vRetResult = hrEduExtn.getFacultyEducQualification(dbOP, request);
		if(vRetResult == null)
			strErrMsg = hrEduExtn.getErrMsg();
	}
%>
<form name="form_" method="post" action="./hr_faculty_qualifications.jsp">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" class="footerDynamic"><div align="center">
				<font color="#FFFFFF"><strong>:::: FACULTY PROFILE BY EDUCATIONAL QUALIFICATIONS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>SY/Term: </td>
			<td>
				<select name="offering_sem" onChange="ReloadPage();">
					<option value="1">1st Sem</option>
				<%
					strTemp = WI.fillTextValue("offering_sem");
					if(strTemp.length() ==0)
						strTemp = (String)request.getSession(false).getAttribute("cur_sem");
					
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
				</select>
				&nbsp;
				<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  readonly="yes">
				</td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Category:</td>
			<td width="80%">
				<%
					strErrMsg = WI.getStrValue(WI.fillTextValue("teaching_staff"), "0");
					if(strErrMsg.equals("0")){
						strTemp = "checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = "checked";
					}
				%>
				<input type="radio" name="teaching_staff" value="0" <%=strTemp%> onClick="CheckLoad();">NTP&nbsp;
				<input type="radio" name="teaching_staff" value="1" <%=strErrMsg%> onClick="CheckLoad();">Faculty </td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%
					strTemp = "";
					if(strErrMsg.length() == 0)
						strErrMsg = "disabled";
					else{
						strErrMsg = "";
						
						if(WI.fillTextValue("with_load").length() > 0)
							strTemp = "checked";
						else
							strTemp = "";
					}
				%>
				<input type="checkbox" name="with_load" value="1" <%=strTemp%> <%=strErrMsg%>>
				<font size="1">Select only with faculty load.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td height="25">
				<a href="javascript:ViewProfile();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to show faculty profile.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
				<font size="1">Click to print.</font>&nbsp;</td>
		</tr>
	</table>
	<table width="100%" bgcolor="FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">		
		<tr>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>UNIT</strong></td>
			<td height="25" colspan="2" align="center" class="thinborder"><strong>BS</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>MA/MS/MD/L.l.B.</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>Ph.D. / DD</strong></td>
			<td colspan="2" align="center" class="thinborder"><strong>Total</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Total</strong></td>
		</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>PT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>PT</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder "width="10%"><strong>PT</strong></td>
			<td align="center" class="thinborder" width="10%"><strong>FT</strong></td>
		    <td align="center" class="thinborder "width="10%"><strong>PT</strong></td>
		    <td align="center" class="thinborder"><strong>(per Unit) </strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 13){%>
		<tr>
			<%
				if((String)vRetResult.elementAt(i+1) != null && (String)vRetResult.elementAt(i+12) != null)
					strTemp = "/ ";
				else
					strTemp = "";
			%>
			<td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1))%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+2);
				iTotals[0] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				iTotals[1] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				iTotals[2] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				iTotals[3] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				iTotals[4] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+7);
				iTotals[5] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+8);
				iTotals[6] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+9);
				iTotals[7] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+10);
				iTotals[8] += Integer.parseInt(strTemp);
				if(strTemp.equals("0"))
					strTemp = "&nbsp;";
			%>
		    <td align="center" class="thinborder"><%=strTemp%></td>
		</tr>
	<%}%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<strong>TOTAL</strong></td>
		    <td align="center" class="thinborder"><%=iTotals[0]%></td>
		    <td align="center" class="thinborder"><%=iTotals[1]%></td>
		    <td align="center" class="thinborder"><%=iTotals[2]%></td>
		    <td align="center" class="thinborder"><%=iTotals[3]%></td>
		    <td align="center" class="thinborder"><%=iTotals[4]%></td>
		    <td align="center" class="thinborder"><%=iTotals[5]%></td>
		    <td align="center" class="thinborder"><%=iTotals[6]%></td>
		    <td align="center" class="thinborder"><%=iTotals[7]%></td>
		    <td align="center" class="thinborder"><%=iTotals[8]%></td>
		</tr>
	</table>
<%}%>
  
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="footer">
		<tr> 
			<td height="25">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
  
  	<input type="hidden" name="print_page">
	<input type="hidden" name="view_profile">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>