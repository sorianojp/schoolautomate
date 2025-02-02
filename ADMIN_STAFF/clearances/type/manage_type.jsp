<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
<!--
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() {
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.page_action.value="";
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname){
	var loadPg = "../../HR/hr_updatelist.jsp?opner_form_name=form_&tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+labelname;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<%@ page language="java" import="utility.*,clearance.ClearanceType, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearances-Clearance Type-Manage Clearance Type","manage_type.jsp");
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
														"Clearances","Clearance Type",request.getRemoteAddr(),
														"manage_type.jsp");
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
	ClearanceType clrType = new ClearanceType();

	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(clrType.operateOnClearanceName(dbOP, request, Integer.parseInt(strTemp)) != null ) {
			strPrepareToEdit = "0";
			strErrMsg = "Operation successful.";
		}
		else
			strErrMsg = clrType.getErrMsg();
	}


	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = clrType.operateOnClearanceName(dbOP, request, 3);
		if(vEditInfo == null && strErrMsg == null )
			strErrMsg = clrType.getErrMsg();
	}
	//view all

	vRetResult = clrType.operateOnClearanceName(dbOP, request, 4);
	if (strErrMsg==null)
		strErrMsg=clrType.getErrMsg();

%>


<body bgcolor="#D2AE72">
<form name="form_" action="./manage_type.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>::::
          CLEARANCES - MANAGE CLEARANCE TYPE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;<font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr>
      <td width="4%" height="30">&nbsp;</td>
      <td width="16%">Effectivity Date:</td>
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		else
			strTemp = WI.fillTextValue("eff_date_fr");
	%>
      <td width="80%" colspan="2" valign="middle"><input name="eff_date_fr" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.eff_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
        to
        <%
		if(vEditInfo != null && vEditInfo.size() > 0)
		{
		if ((String)vEditInfo.elementAt(2)!=null)
			strTemp = (String)vEditInfo.elementAt(2);
			else
			strTemp = "";
		}
		else
			strTemp = WI.fillTextValue("eff_date_to");
	%>
      <input name="eff_date_to" type= "text" class="textbox" id="date"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="true">
        <a href="javascript:show_calendar('form_.eff_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
       </td>
    </tr>
    <tr>
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td>Clearance Type </td>
      <%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("clr_type");
	%>
      <td height="25" colspan="2" valign="middle">
      <input name="clr_type" class="textbox" type="text" size="32" maxlength="64"
       onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'
       value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="middle">Applicable to </td>
      <td height="25" colspan="2" valign="middle">
       <%if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = WI.fillTextValue("app_index");
	%>
      <select name="app_index">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("CLE_APPLICABLE_INDEX","APPLICABLE_TO"," from CLE_APPLICABLE_INFO  order by APPLICABLE_TO asc", strTemp, false)%>
        </select>
        <font size="1"><a href='javascript:viewList("CLE_APPLICABLE_INFO","CLE_APPLICABLE_INDEX","APPLICABLE_TO","APPLICABLE TO")'>
        <img src="../../../images/update.gif" border="0"></a>click to update list
        of APPLICABLE TO </font></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="middle">College</td>
      <td height="25" colspan="2" valign="middle">
      <%String  strColCode = null;
      if(vEditInfo != null && vEditInfo.size() > 0)
			strColCode = (String)vEditInfo.elementAt(10);
		else
			strColCode = WI.fillTextValue("c_index");
		%>
      <select name="c_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strColCode, false)%>
        </select></td>

    </tr>

    <tr>
      <td height="30">&nbsp;</td>
      <td valign="middle">Course</td>
      <td height="25" colspan="2" valign="middle">
      <%if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		else
			strTemp = WI.fillTextValue("course_index");%>
      <select name="course_index">
          <option value="">ALL</option>
          <%strTemp2 = " FROM COURSE_OFFERED WHERE IS_DEL = 0 AND IS_VALID = 1 "+WI.getStrValue(strColCode, " AND C_INDEX = ","","")+" ORDER BY COURSE_CODE";%>
          <%=dbOP.loadCombo("COURSE_INDEX","COURSE_NAME",strTemp2, strTemp, false)%>
               </select></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="middle">Year Level</td>
      <td height="25" colspan="2" valign="middle">
         <%if(vEditInfo != null && vEditInfo.size() > 0){
			if (vEditInfo.elementAt(7)!=null)
				strTemp = (String)vEditInfo.elementAt(7);
			else
				strTemp = "";
			}
		else
			strTemp = WI.fillTextValue("yr_lvl");
		%>
      <select name="yr_lvl">
      <option value="">ALL</option>
		<%for (int i = 1;i<7;++i){%>
			<%if (strTemp.compareTo(Integer.toString(i))==0){%>
			<option value="<%=i%>" selected><%=i%></option>
			<%}else{%>
			<option value="<%=i%>"><%=i%></option><%}%>
		<%}%>
        </select></td>
          </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <td valign="middle">Remarks</td>
      <td height="25" colspan="2" valign="middle">
      <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = WI.getStrValue(((String)vEditInfo.elementAt(8)),"");
		else
			strTemp = WI.fillTextValue("remarks");
	%>
      <textarea name="remarks" cols="48" rows="3" class="textbox"
      onfocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'><%=strTemp%></textarea></td>

    </tr>
    <tr>
      <td height="15" colspan="4"><font size="1">&nbsp; </font><font size="1">&nbsp;
        </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="1">
       <%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> Click to add entry
        <%}else{%>
        <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> Click to edit event
        <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> Click to clear entries </font>
        <%}%></font></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
	<tr bgcolor="#ABA37C">
		<td height="23" colspan="7" class="thinborder">
			<div align="center"> <strong><font size="2">LIST OF CLEARANCES TYPE</font></strong></div>
		</td>
	</tr>
	<tr>
		<td width="15%" class="thinborder">
			<div align="center"><font size="1"><strong>EFFECTIVE DATE FROM </strong></font></div>
		</td>
		<td width="15%" height="23" class="thinborder">
					<div align="center"><font size="1"><strong>EFFECTIVE DATE TO </strong></font></div>
		</td>
		<td width="20%" height="23" class="thinborder">
			<div align="center"><font size="1"><strong>CLEARANCE
				TYPE </strong></font></div>
		</td>
		<td width="22%" class="thinborder">
			<div align="center"><font size="1"><strong>APPLICABLE
				TO </strong></font></div>
		</td>
		<td width="22%" class="thinborder">
			<div align="center"><font size="1"><strong>REMARKS</strong></font></div>
		</td>
		<td colspan="2" align="center" class="thinborder"> <font size="1"><strong>&nbsp;
			OPTIONS</strong> </font>
			<div align="center"></div>
		</td>
	</tr>
	<%
    for (int i = 0; i<vRetResult.size(); i+=12) { %>
	<tr>
		<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		<td class="thinborder" height="25"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"","","PRESENT")%></font></td>
		<td class="thinborder" height="25"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
		<td class="thinborder"><font size="1">
		Applicable to: <%=WI.getStrValue((String)vRetResult.elementAt(i+4),"","","ALL")%><br>
		College: <%=WI.getStrValue((String)vRetResult.elementAt(i+5),"","","ALL")%><br>
		Course: <%=WI.getStrValue((String)vRetResult.elementAt(i+6),"","","ALL")%><br>
		Year Level: <%=WI.getStrValue((String)vRetResult.elementAt(i+7),"","","ALL")%>
		</font></td>
		<td class="thinborder"><%=WI.getStrValue(((String)vRetResult.elementAt(i+8)),"No Remark")%></td>
		<td width="9%" class="thinborder">
			<div align="left"> <font size="1">
        <% if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
        <%}else{%>
        Not authorized to edit
        <%}%>
        </font></div>
		</td>
		<td width="12%" class="thinborder">
			<div align="left"><font size="1">
        <% if(iAccessLevel ==2){%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
        <%}else{%>
        Not authorized to delete
        <%}%>
        </font></div>
		</td>
	</tr>
	<%}%>
</table>
  <%}%>
    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
     <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>

  </table>
	<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
